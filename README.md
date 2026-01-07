# 👁️ Smart Vision Features

<div align="center">

![App Logo](assets/eye.png)

**An AI-Powered Assistant for Visually Impaired Individuals**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## 📖 Overview

**Smart Vision Features** is a comprehensive mobile application designed to empower visually impaired individuals by leveraging cutting-edge AI technology. The app provides real-time scene understanding, object detection, safety alerts, and text extraction capabilities, all delivered through an intuitive voice-first interface with Text-to-Speech (TTS) feedback.

The application combines computer vision APIs with accessibility-focused design to create an inclusive experience that helps users navigate and understand their surroundings independently.

---

## ✨ Features

### 🔍 **Scene Detection**
- Analyzes the environment and provides detailed scene descriptions
- Helps users understand their surroundings contextually
- Voice-activated for hands-free operation

### 🎯 **Object Detection**
- Identifies and locates objects within the camera's view
- Provides real-time feedback on detected items
- Useful for finding specific objects in unfamiliar environments

### ⚠️ **Safety Alerts**
- Identifies potential hazards in the user's environment
- Proactive warnings for obstacles and dangerous situations
- Critical for safe navigation in new spaces

### 📝 **Text Extraction (OCR)**
- Extracts and reads text from images using Optical Character Recognition
- Perfect for reading signs, labels, documents, and product packaging
- Converts visual text into spoken words instantly

### 🎤 **Voice Control**
- Complete voice command support for hands-free operation
- Speech-to-Text input for seamless interaction
- Natural language processing for intuitive commands

### 🔊 **Text-to-Speech Integration**
- Real-time audio feedback for all features
- Adjustable speech rate and pitch
- Clear and natural voice output

### 📳 **Haptic Feedback**
- Vibration patterns for important notifications
- Tactile confirmation of actions
- Enhanced accessibility through multi-sensory feedback

---

## 🛠️ Tech Stack

### **Frontend**
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language

### **State Management**
- **Flutter BLoC (Cubit)** - Predictable state management pattern
- Clean separation of business logic and UI

### **Core Packages**
| Package | Purpose |
|---------|---------|
| `camera` | Real-time camera access and image capture |
| `image_picker` | Image selection from gallery |
| `flutter_tts` | Text-to-Speech conversion |
| `speech_to_text` | Voice command recognition |
| `http` | API communication |
| `flutter_bloc` | State management |
| `permission_handler` | Runtime permissions management |
| `vibration` | Haptic feedback |
| `lottie` | Animated illustrations |
| `nb_utils` | Utility functions and widgets |

### **Backend/API**
- RESTful API endpoints for AI processing
- Image upload and processing pipeline
- Endpoints:
  - `/scene-detection` - Scene analysis
  - `/detect-objects` - Object detection
  - `/safety-alerts` - Hazard identification
  - `/extract-text` - OCR processing

---

## 🏗️ Architecture

The app follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── cubit/                    # State Management (BLoC Pattern)
│   ├── object_cubit.dart    # Business logic for AI features
│   └── object_state.dart    # State definitions
├── models/
│   └── object_model.dart    # Data models for API responses
├── services/
│   └── service.dart         # API service layer
├── screens/
│   ├── splash.dart          # Splash screen with TTS welcome
│   ├── onboarding.dart      # Interactive onboarding flow
│   └── home.dart            # Main feature interface
└── main.dart                # App entry point
```

### **State Management Flow**
```
User Action → Cubit → API Service → State Update → UI Rebuild
```

### **Key Design Patterns**
- **BLoC (Business Logic Component)**: Separates business logic from UI
- **Repository Pattern**: Abstracts data layer through ApiService
- **Observer Pattern**: BLoC state subscription for reactive UI updates

---

## 📂 Folder Structure

```
vision_aid/
│
├── assets/                       # Static assets
│   ├── eye.png                  # App logo
│   ├── virus-search.png         # Scene detection icon
│   ├── tracking.png             # Object detection icon
│   ├── reminder.png             # Safety alerts icon
│   └── [onboarding animations]  # Lottie files
│
├── lib/
│   ├── cubit/
│   │   ├── object_cubit.dart   # Cubit for feature state management
│   │   └── object_state.dart   # State classes
│   │
│   ├── home.dart               # Main feature screen
│   ├── onboarding.dart         # Tutorial screens
│   ├── splash.dart             # Initial loading screen
│   ├── service.dart            # API communication layer
│   ├── object_model.dart       # Response data models
│   └── main.dart               # Application entry point
│
├── test/                       # Unit and widget tests
├── pubspec.yaml               # Project dependencies
└── README.md                  # You are here!
```

---

## 🚀 How to Run the Project

### **Prerequisites**
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extensions
- An Android or iOS device/emulator

### **Installation Steps**

1. **Clone the repository**
```bash
git clone https://github.com/soha131/vision_aid.git
cd vision_aid
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure API Endpoint**
   - Open `lib/service.dart`
   - Update the base URL to your API server:
   ```dart
   final Uri url = Uri.parse("http://YOUR_API_IP:8000/$endpoint");
   ```

4. **Run the app**
```bash
flutter run
```

### **Permissions Required**
The app requires the following permissions:
- 📷 **Camera** - For capturing images
- 🎤 **Microphone** - For voice commands
- 📳 **Vibration** - For haptic feedback

---

## 🧪 Testing

### **Run Tests**
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/cubit/object_cubit_test.dart
```

### **Testing Strategy**
- **Unit Tests**: Business logic and state management (Cubit tests)
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end feature testing

---

## 🎨 User Interface

### **Accessibility-First Design**
- **Voice Guidance**: Every screen provides audio feedback
- **Swipe Navigation**: Easy gesture-based feature selection
- **Double-Tap Activation**: Consistent interaction pattern
- **High Contrast**: Visual elements designed for low vision users
- **Minimal Cognitive Load**: Simple, predictable interface

### **Onboarding Flow**
Interactive tutorial with:
- Animated Lottie illustrations
- Step-by-step feature explanation
- Voice narration for each screen
- Page indicators for orientation

---

## 🔮 Future Improvements

### **Planned Features**
- [ ] **Offline Mode** - Local AI models for core features
- [ ] **Multi-language Support** - TTS and STT in multiple languages
- [ ] **Face Recognition** - Identify known contacts
- [ ] **Currency Detection** - Identify bills and denominations
- [ ] **Color Recognition** - Describe colors of objects
- [ ] **Navigation Assistant** - Turn-by-turn directions
- [ ] **Emergency SOS** - Quick access to emergency contacts
- [ ] **Cloud Sync** - Save and sync user preferences

### **Technical Enhancements**
- [ ] Enhanced error handling and offline caching
- [ ] Reduce API latency with edge computing
- [ ] Implement CI/CD pipeline
- [ ] Add analytics and crash reporting
- [ ] Improve battery optimization
- [ ] Add widget tests coverage

---

## 🪄 App Preview


![App Demo](assets/screenshots/demo.gif)

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to the branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

### **Contribution Guidelines**
- Follow the existing code style
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Thanks to the Flutter and Dart communities for excellent documentation
- Computer vision APIs that power the AI features
- Open-source contributors who make projects like this possible
- The accessibility community for valuable feedback and insights

---

## 📞 Support

If you encounter any issues or have questions:

1. **Check the [Issues](https://github.com/yourusername/vision_aid/issues)** page
2. **Open a new issue** with detailed information
3. **Contact the developer** directly via email

---

<div align="center">

**⭐ If you find this project helpful, please consider giving it a star! ⭐**

Made with ❤️ for accessibility

</div>
