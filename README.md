# Samvidhan Mitra (संविधान मित्र)

**Samvidhan Mitra** (Constitution Friend) is an AI-powered Flutter application designed to make the Constitution of India accessible and understandable for everyone. It provides a simple, conversational interface where users can ask questions about their rights, duties, and constitutional provisions in their preferred language.

> *"Constitution for Everyone"*

## 🚀 Features

- **Conversational AI**: Powered by **Llama-3.3-70b-versatile** via **Groq API** for accurate and simple explanations of constitutional concepts.
- **Bilingual Support**: Full support for **English**, **Hindi**, and **Hinglish**. The AI automatically matches the user's input language.
- **Voice Interaction**:
  - **Speech-to-Text (STT)**: Ask questions naturally using your voice (Powered by `speech_to_text`).
  - **Text-to-Speech (TTS)**: Listen to the AI's responses with high-quality, localized Indian voices (Powered by `flutter_tts`).
- **Local History**: Chat history is saved locally using **Hive** database, allowing you to revisit previous conversations.
- **Simple Explanations**: Concepts are broken down into easy-to-understand language, avoiding dense legal jargon.
- **Markdown Rendering**: AI responses are beautifully formatted with Markdown for better readability.
- **Modern UI**: A clean, responsive interface built with **Material 3** and **Google Fonts (Mukta)**.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **AI Model**: Llama-3.3-70b-versatile (via [Groq API](https://groq.com/))
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Database**: [Hive](https://pub.dev/packages/hive)
- **Typography**: [Google Fonts (Mukta)](https://fonts.google.com/specimen/Mukta)
- **Utilities**: 
  - `speech_to_text` for voice input
  - `flutter_tts` for voice output
  - `flutter_dotenv` for environment management
  - `flutter_markdown` for rich text rendering

## 📦 Installation & Setup

### Prerequisites

- Flutter SDK (latest version recommended)
- Android Studio or VS Code
- A Groq API Key (Get it from [Groq Cloud Console](https://console.groq.com/))

### Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/samvidhan_mitra.git
   cd samvidhan_mitra
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**:
   Create a `.env` file in the root directory and add your API keys:
   ```env
   AI_API_KEY=your_groq_api_key_here
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## 🎨 UI & Design

The app features a clean, India-inspired color palette:
- **Primary Blue**: `#1A365D` (Representing trust and professionalism)
- **Accent Saffron**: `#FF9933` (Representing vibrancy)
- **Accent Green**: `#138808` (Representing growth)
- **Typography**: Uses the **Mukta** font family for excellent readability in both English and Hindi.

## 📄 License & Disclaimer

This project is for educational purposes. All constitutional information provided is for awareness and does not constitute legal advice. For legal matters, please consult a qualified legal professional.

---
Developed with ❤️ for a more constitutional-aware India.
