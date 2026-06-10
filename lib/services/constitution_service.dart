import 'dart:convert';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class ConstitutionService {
  List<dynamic>? _cachedConstitution;

  Future<void> load() async {
    if (_cachedConstitution != null) return;
    try {
      final String response = await rootBundle.loadString('assets/constitution.json');
      _cachedConstitution = json.decode(response);
    } catch (e) {
      _cachedConstitution = [];
    }
  }

  Map<String, dynamic>? getDailyArticle() {
    if (_cachedConstitution == null || _cachedConstitution!.isEmpty) return null;
    
    // Select an article based on the current day of the year
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final articleId = AppConstants.featuredArticleIds[dayOfYear % AppConstants.featuredArticleIds.length];
    
    return getArticleById(articleId);
  }

  List<dynamic> search(String query) {
    if (_cachedConstitution == null) return [];
    
    final q = query.toLowerCase();
    return _cachedConstitution!.where((entry) {
      final text = entry['text'].toString().toLowerCase();
      final id = entry['id'].toString().toLowerCase();
      return text.contains(q) || id.contains(q);
    }).toList();
  }

  Map<String, dynamic>? getArticleById(String id) {
    if (_cachedConstitution == null) return null;
    final searchId = id.toLowerCase();
    try {
      // First try exact match
      return _cachedConstitution!.firstWhere(
        (entry) => entry['id'].toString().toLowerCase() == searchId,
        // Then fallback to contains if no exact match found
        orElse: () => _cachedConstitution!.firstWhere(
          (entry) => entry['id'].toString().toLowerCase().contains(searchId),
        ),
      );
    } catch (e) {
      return null;
    }
  }
}
