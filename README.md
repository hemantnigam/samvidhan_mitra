# 🇮🇳 Samvidhan Mitra (Constitutional Friend)

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)](https://firebase.google.com/)

**Samvidhan Mitra** is an AI-powered Flutter application designed to bridge the gap between complex legal language and the common citizen. It serves as a simplified, conversational guide to the Constitution of India, fostering constitutional literacy across the nation.

---

## 🌟 Key Features

### 🤖 AI-Powered Assistant
- **Bilingual Conversations:** Ask questions in English, Hindi, or Hinglish.
- **Simplified Explanations:** Our advanced AI breaks down complex legal articles into "bol-chal" (conversational) language.
- **Context-Aware:** Understands the relationship between different Articles, Parts, and Schedules.

### 🔍 Smart Offline Search
- **Instant Access:** Search any Article by its number (e.g., "Article 21") or keyword without an internet connection.
- **Lightning Fast:** Uses Hive, a local NoSQL database, for near-instant search results.

### 🚨 Emergency SOS System
- **One-Tap Helplines:** Integrated access to essential national services:
  - 👮 Police (100)
  - 👩 Women Helpline (1091)
  - 👶 Child Helpline (1098)
  - 🚑 Disaster Management (108)

### 📅 Article of the Day
- **Daily Learning:** Get a hand-picked constitutional insight every day to build your knowledge step-by-step.

### 🔒 Privacy & Performance
- **Local Storage:** Your chat history and search data stay on your device.
- **Optimized UI:** Smooth 120Hz support and a "Paper White" aesthetic for comfortable long-term reading.

---

## 🛠 Tech Stack

- **Framework:** Flutter (3.12.0+)
- **State Management:** Provider
- **Local Database:** Hive (for Articles & Chat history)
- **AI Integration:** Google Gemini API / Custom LLM (via `ai_service.dart`)
- **Voice Features:** Speech-to-Text & Flutter TTS
- **Utilities:** `flutter_dotenv` for environment variables, `url_launcher` for SOS calls.

---

## 🧠 AI Architecture

Samvidhan Mitra uses a sophisticated hybrid architecture to ensure legal accuracy while maintaining a friendly conversational tone.

### 1. Large Language Model (LLM)
- **Model:** `llama-3.3-70b-versatile` (via Groq API)
- **Reasoning:** Selected for its high performance in complex reasoning and multilingual capabilities, ensuring it can handle legal nuances in Hindi, English, and Hinglish.

### 2. Retrieval-Augmented Generation (RAG)
To prevent "hallucinations" (the AI making up laws), we use a custom RAG system:
- **Local Knowledge Base:** The entire Constitution is stored locally in `assets/constitution.json`.
- **Semantic Retrieval:** When a user asks a question, the app performs a weighted keyword search to find the top 3 most relevant Articles.
- **Context Injection:** These official Articles are injected into the AI's prompt as "Ground Truth," ensuring the response is based strictly on the actual law.

### 3. Smart Bilingual Fallback
- **Language Detection:** The system automatically detects if a query is in Hindi or English and forces the AI to respond in the same language.
- **Offline Mode:** If the internet is unavailable, the system bypasses the AI and directly shows the official constitutional text from the local database, ensuring the app remains useful in remote areas.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed on your machine.
- An Android/iOS device or emulator.
- (Optional) A `.env` file with your AI API keys.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/samvidhan_mitra.git
   cd samvidhan_mitra
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment:**
   Create a `.env` file in the root directory and add your keys:
   ```env
   AI_API_KEY=your_key_here
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## ⚖️ Source of Information & Disclaimer

### Source
The constitutional text and legal data used in this application are sourced from the **Official Website of the Legislative Department, Ministry of Law and Justice, Government of India**.
- **URL:** [https://legislative.gov.in/constitution-of-india/](https://legislative.gov.in/constitution-of-india/)

### Disclaimer
**Samvidhan Mitra is an independent educational tool.** 
- It is **NOT** an official government application.
- It is **NOT** affiliated with, authorized by, or endorsed by the Government of India or any legal entity.
- The information provided is for educational purposes only and **does not constitute legal advice**. For legal matters, please consult a qualified legal professional.

---

## 🤝 Contributing
Contributions are welcome! If you'd like to improve the AI prompts, add more languages, or fix a bug:
1. Fork the project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## 📜 License
Distributed under the MIT License. See `LICENSE` for more information.

---
*Created with ❤️ for the citizens of India.*
