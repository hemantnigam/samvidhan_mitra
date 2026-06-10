import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AIService {
  final String apiKey;
  final String model = 'llama-3.3-70b-versatile';

  AIService({required this.apiKey});

  final List<Map<String, String>> _history = [];
  List<dynamic>? _cachedConstitution;

  Future<void> _loadConstitution() async {
    if (_cachedConstitution != null) return;
    try {
      final String response = await rootBundle.loadString('assets/constitution.json');
      _cachedConstitution = json.decode(response);
    } catch (e) {
      print("Error loading constitution: $e");
      _cachedConstitution = [];
    }
  }

  String _getRelevantContext(String query, {String? preferredLocale}) {
    if (_cachedConstitution == null || _cachedConstitution!.isEmpty) return "";
    
    final isUserHindi = (preferredLocale == 'hi_IN') || _isHindi(query);
    final normalizedQuery = query.toLowerCase();
    
    // Improved keyword extraction: Keep numbers even if short
    final tokens = normalizedQuery.split(RegExp(r'[\s,.-]+'))
        .where((t) => t.length > 2 || RegExp(r'^\d+$').hasMatch(t))
        .toList();

    if (tokens.isEmpty && query.isNotEmpty) tokens.add(normalizedQuery);

    // Stop words that shouldn't trigger high relevance on their own
    final stopWords = {'article', 'the', 'how', 'what', 'where', 'अनुच्छेद', 'संबंͬधत', 'बारे'};

    final scoredEntries = _cachedConstitution!.map((entry) {
      final id = entry['id'].toString().toLowerCase();
      final text = entry['text'].toString().toLowerCase();
      
      double score = 0;

      // 1. Exact ID Match (Highest Priority)
      // e.g. Query "14" matches "article 14"
      for (final token in tokens) {
        if (!stopWords.contains(token)) {
           if (id == token || id == "article $token" || id == "अनुच्छेद $token") {
             score += 50;
           } else if (id.contains(token)) {
             score += 10;
           }
        }
      }

      // 2. Keyword density and frequency
      for (final token in tokens) {
        if (!stopWords.contains(token)) {
          // Count occurrences in text
          final matches = token.allMatches(text).length;
          if (matches > 0) {
            score += (matches * 2); // 2 points per occurrence
          }
        }
      }

      // 3. Multi-keyword bonus (Highest priority for natural language)
      int uniqueMatches = tokens.where((t) => !stopWords.contains(t) && text.contains(t)).length;
      if (uniqueMatches > 1) {
        score += (uniqueMatches * 10); // Massive boost for entries matching multiple keywords
      }

      // 4. Language preference
      final isArticleHindi = id.contains('अनुच्छेद');
      if (isUserHindi == isArticleHindi) {
        score += 5;
      }

      return {'entry': entry, 'score': score};
    }).where((e) => (e['score'] as double) > 0).toList();

    // Sort by score descending
    scoredEntries.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    final context = scoredEntries.take(3).map((e) {
      final entry = e['entry'] as Map<String, dynamic>;
      final id = entry['id'].toString().toUpperCase();
      final text = _cleanText(entry['text'].toString(), isUserHindi);
      return "### $id\n$text";
    }).join("\n\n");

    return context.isNotEmpty ? context : "";
  }

  bool _isHindi(String text) => RegExp(r'[\u0900-\u097F]').hasMatch(text);

  String _cleanText(String text, bool preferHindi) {
    // Remove PDF artifacts and headers
    String cleaned = text
      .replaceAll(RegExp(r'Contents ARTICLES \(.*?\)', caseSensitive: false), '')
      .replaceAll(RegExp(r'ͪवषय सूची अनुच्छेद.*?पृष्ठ \(.*?\)', caseSensitive: false), '')
      .replaceAll(RegExp(r'LIST OF ABBREVIATIONS USED.*?(?=THE CONSTITUTION|$)', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

    // If text is very long, try to truncate it but keep enough context
    if (cleaned.length > 1200) {
      cleaned = "${cleaned.substring(0, 1200)}...";
    }
    
    return cleaned;
  }

  Future<String> sendMessage(String message, {String? preferredLocale}) async {
    await _loadConstitution();
    final isUserHindi = (preferredLocale == 'hi_IN') || _isHindi(message);
    final targetLanguage = isUserHindi ? "HINDI" : "ENGLISH";
    final context = _getRelevantContext(message, preferredLocale: preferredLocale);
    
    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      _history.add({"role": "user", "content": message});

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {
              "role": "system", 
              "content": "${AppConstants.systemPrompt}\n\nCRITICAL RULE: The user's query is in $targetLanguage. You MUST respond entirely in $targetLanguage, regardless of the language of the Constitutional Context provided below.\n\nRelevant Constitutional Context:\n$context"
            },
            ..._history,
          ],
          "temperature": 0.7,
          "max_tokens": 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiContent = data['choices'][0]['message']['content'];
        
        _history.add({"role": "assistant", "content": aiContent});
        return aiContent;
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown API Error';
        
        if (response.statusCode == 401 || response.statusCode == 403) {
           return "🔑 **API Configuration Issue**\n\nThere was an error connecting to the AI service (Invalid API Key). Please check your setup.\n\n**Constitutional Context:**\n$context";
        }

        if (context.isNotEmpty) {
          return "⚠️ **AI Service Busy**\n\nThe AI is currently unavailable ($errorMessage), but here is the official constitutional text:\n\n$context";
        }
        throw Exception('Groq API Error: ${response.body}');
      }
    } catch (e) {
      // Check if it's a network error
      final errorStr = e.toString().toLowerCase();
      final isNetworkError = errorStr.contains('socketexception') || 
                             errorStr.contains('httpexception') || 
                             errorStr.contains('connection failed');

      if (isNetworkError) {
        if (context.isNotEmpty) {
          return "📡 **Offline Mode**\n\nYou are currently offline. Here is the relevant Constitutional text:\n\n$context";
        } else {
          return "📡 **Offline Mode**\n\nYou are offline and I couldn't find a specific Article for \"$message\".\n\n**Try:**\n* Searching for a specific Article number (e.g., \"Article 21\").\n* Checking your internet connection for a full AI response.";
        }
      }

      if (context.isNotEmpty) {
        return "⚠️ **Connection Error**\n\nI encountered an issue reaching the AI ($e). Here is the relevant text:\n\n$context";
      }
      return "⚠️ **Service Error**\n\nI couldn't reach the AI or find local context. Please try again later.\n\n(Error: $e)";
    }
  }

  void resetChat() {
    _history.clear();
  }
}
