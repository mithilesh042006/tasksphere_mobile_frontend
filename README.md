# 📱 TaskSphere Mobile App

A Flutter-based mobile application for TaskSphere - the simple task sharing platform inspired by messaging apps like WhatsApp.

## 🚀 Features

### ✅ **Implemented Features**

- **🔐 Authentication**
  - User registration with unique 8-digit User ID generation
  - Secure login with JWT token management
  - User profile management
  - User search by User ID

- **📋 Task Management**
  - Create tasks with title, description, priority, and due dates
  - Assign tasks to other users by searching their User ID
  - View tasks in organized tabs (All, Sent, Received)
  - Filter tasks by status (Pending, In Progress, Completed)
  - Update task status with quick action buttons
  - Visual priority and status indicators

- **🏠 Dashboard**
  - Welcome section with user information
  - Quick statistics overview (total, pending, in progress, completed tasks)
  - Quick action buttons for common operations
  - Recent activity placeholder

- **🔔 Notifications**
  - Notification list with read/unread status
  - Mark notifications as read
  - Mark all notifications as read
  - Notification statistics and badges
  - Different notification types with appropriate icons and colors

- **👤 Profile Management**
  - View user profile information
  - Display User ID, email, bio, and account settings
  - Logout functionality
  - Placeholder for profile editing and settings

- **🎨 UI/UX**
  - Material Design 3 with custom TaskSphere theme
  - Responsive design with proper loading states
  - Error handling with user-friendly messages
  - Bottom navigation for easy access to main features
  - Pull-to-refresh functionality
  - Smooth animations and transitions

## 🏗️ Architecture

### **Project Structure**
```
lib/
├── models/           # Data models (User, Task, Notification)
├── services/         # API services and business logic
├── screens/          # UI screens organized by feature
│   ├── auth/         # Authentication screens
│   ├── home/         # Dashboard and main screens
│   ├── tasks/        # Task management screens
│   ├── profile/      # Profile screens
│   └── notifications/ # Notification screens
├── widgets/          # Reusable UI components
├── utils/            # Utilities and theme
└── main.dart         # App entry point
```

### **Key Components**

- **API Client**: HTTP client with JWT token management
- **Services**: Authentication, Task, and Notification services
- **Models**: Strongly typed data models with JSON serialization
- **Theme**: Consistent design system with TaskSphere branding
- **Navigation**: Go Router for declarative routing
- **State Management**: Provider/Riverpod for state management

## 🛠️ Setup & Installation

### **Prerequisites**
- Flutter SDK (3.6.1+)
- Dart SDK
- Android Studio / VS Code
- TaskSphere Backend running on `http://localhost:8000`

### **Installation Steps**

1. **Clone the repository**
   ```bash
   cd tasksphere_frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   - Update `baseUrl` in `lib/services/api_client.dart`
   - For Android emulator: `http://10.0.2.2:8000`
   - For iOS simulator: `http://127.0.0.1:8000`
   - For physical device: `http://YOUR_COMPUTER_IP:8000`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (Chrome, Safari, Firefox)
- ✅ **Windows** (with Visual Studio toolchain)
- ✅ **macOS**
- ✅ **Linux**

## 🔧 Configuration

### **API Configuration**
Update the base URL in `lib/services/api_client.dart`:
```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL:8000';
```

### **Theme Customization**
Modify colors and styling in `lib/utils/theme.dart`:
```dart
static const Color primaryColor = Color(0xFF6366F1); // Indigo
static const Color secondaryColor = Color(0xFF10B981); // Emerald
```

## 🧪 Testing

### **Run Tests**
```bash
flutter test
```

### **Test Coverage**
```bash
flutter test --coverage
```

## 📦 Dependencies

### **Core Dependencies**
- `flutter`: Flutter SDK
- `http`: HTTP client for API calls
- `go_router`: Declarative routing
- `provider` / `riverpod`: State management
- `shared_preferences`: Local storage
- `flutter_secure_storage`: Secure token storage

### **UI Dependencies**
- `material_design_icons_flutter`: Additional icons
- `intl`: Internationalization and date formatting
- `cached_network_image`: Image caching
- `shimmer`: Loading animations

### **Development Dependencies**
- `flutter_test`: Testing framework
- `flutter_lints`: Code analysis

## 🚀 Deployment

### **Android**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### **iOS**
```bash
flutter build ios --release
```

### **Web**
```bash
flutter build web --release
```

## 🔮 Future Enhancements

- **Real-time Updates**: WebSocket integration for live notifications
- **File Attachments**: Support for task attachments
- **Calendar Integration**: Native calendar sync
- **Push Notifications**: Firebase Cloud Messaging
- **Offline Support**: Local database with sync
- **Dark Mode**: Complete dark theme implementation
- **Accessibility**: Enhanced accessibility features
- **Internationalization**: Multi-language support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Check the TaskSphere Backend documentation
- Open an issue in the repository
- Contact the development team

---

**TaskSphere Mobile** - Simple task sharing for mobile devices 📱✨
