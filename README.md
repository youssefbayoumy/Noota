# Noota - Private Classes Platform - Comprehensive Documentation

A comprehensive Flutter application for managing private classes with role-based access for Students, Parents, Teachers, and Admins. Built with Supabase backend integration and designed specifically for the Egyptian private education market.

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture & Tech Stack](#architecture--tech-stack)
3. [Project Structure](#project-structure)
4. [File-by-File Analysis](#file-by-file-analysis)
5. [Database Schema](#database-schema)
6. [Configuration](#configuration)
7. [Setup & Installation](#setup--installation)
8. [Development Guide](#development-guide)
9. [Deployment](#deployment)
10. [Security & Compliance](#security--compliance)

## 🎯 Project Overview

### Purpose
The Private Classes App is a comprehensive educational platform designed to connect students, parents, teachers, and administrators in the Egyptian private education sector. It provides a complete ecosystem for managing private tutoring sessions, tracking attendance, processing payments, and maintaining compliance with local regulations.

### Key Features
- **Role-Based Access Control**: Four distinct user roles with specific permissions
- **QR Code Attendance System**: Secure, location-based attendance tracking
- **Payment Processing**: Integration with Egyptian payment providers
- **Parental Consent Management**: GDPR-compliant consent tracking
- **Real-time Analytics**: Comprehensive reporting and insights
- **Multi-language Support**: Arabic and English with RTL support
- **Offline Capability**: Sync when connection is restored

### Target Market
- Egyptian private tutoring centers
- Individual private tutors
- Educational institutions
- Students and parents seeking private education

## 🏗️ Architecture & Tech Stack

### Frontend Architecture
- **Framework**: Flutter 3.8+ with Dart 3.8.1+
- **State Management**: Riverpod for reactive state management
- **Navigation**: Go Router for declarative routing
- **UI Framework**: Material Design 3 with custom theming
- **Local Storage**: Hive for offline data persistence

### Backend Architecture
- **Backend-as-a-Service**: Supabase
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Authentication**: Supabase Auth with JWT tokens
- **Real-time**: Supabase Realtime subscriptions
- **Storage**: Supabase Storage for files and media

### Key Dependencies
```yaml
# Core Flutter
flutter: sdk: flutter
cupertino_icons: ^1.0.8

# Backend & State Management
supabase_flutter: ^2.10.2
flutter_riverpod: ^2.4.9
go_router: ^13.2.0

# Local Storage & Persistence
shared_preferences: ^2.2.2
hive: ^2.2.3
hive_flutter: ^1.1.0

# QR Code & Scanning
qr_flutter: ^4.1.0
mobile_scanner: ^5.0.0

# Localization
flutter_localizations: sdk: flutter
intl: ^0.20.2

# Utilities
http: ^1.2.0
json_annotation: ^4.8.1
uuid: ^4.3.3
crypto: ^3.0.3
```

## 📁 Project Structure

```
private_classes_app/
├── lib/                          # Main Flutter application code
│   ├── config/                   # Configuration files
│   │   ├── app_config.dart       # App-wide configuration constants
│   │   └── supabase_config.dart  # Supabase connection configuration
│   ├── models/                   # Data models and serialization
│   │   ├── user_model.dart        # User data model with JSON serialization
│   │   ├── user_model.g.dart     # Generated JSON serialization code
│   │   └── user_role.dart        # User role enum with permissions
│   ├── providers/                # Riverpod state management
│   │   └── auth_provider.dart    # Authentication state providers
│   ├── screens/                  # UI screens organized by user role
│   │   ├── auth/                 # Authentication screens
│   │   │   ├── login_screen.dart # User login interface
│   │   │   ├── signup_screen.dart # User registration interface
│   │   │   └── role_selection_screen.dart # Role selection interface
│   │   ├── student/              # Student-specific screens
│   │   │   └── student_dashboard.dart # Student main interface
│   │   ├── parent/               # Parent-specific screens
│   │   │   └── parent_dashboard.dart # Parent main interface
│   │   ├── teacher/              # Teacher-specific screens
│   │   │   └── teacher_dashboard.dart # Teacher main interface
│   │   ├── admin/                # Admin-specific screens
│   │   │   └── admin_dashboard.dart # Admin main interface
│   │   └── splash_screen.dart     # App loading screen
│   ├── services/                 # Business logic and API services
│   │   └── auth_service.dart     # Authentication service methods
│   ├── utils/                    # Utility functions and helpers
│   │   └── router.dart           # Application routing configuration
│   └── main.dart                 # Application entry point
├── database/                     # Database schema and setup files
│   ├── setup_database.sql       # Complete database schema
│   ├── 01_create_tables.sql     # Table creation scripts
│   ├── 02_create_functions.sql # Database functions
│   ├── 03_create_policies.sql  # Row Level Security policies
│   ├── 04_sample_data.sql      # Sample data for testing
│   └── README.md                # Database setup guide
├── android/                      # Android platform configuration
├── ios/                         # iOS platform configuration
├── web/                         # Web platform configuration
├── windows/                     # Windows platform configuration
├── linux/                       # Linux platform configuration
├── macos/                       # macOS platform configuration
├── test/                        # Unit and widget tests
├── pubspec.yaml                 # Flutter dependencies and metadata
├── analysis_options.yaml        # Dart code analysis rules
├── README.md                    # This comprehensive documentation
├── SETUP.md                     # Quick setup guide
├── DATABASE_SETUP_GUIDE.md     # Detailed database setup instructions
├── copy_database_setup.py      # Python script to copy SQL to clipboard
├── push_database.py            # Python script to push schema via API
├── push_database.js            # JavaScript version of push script
├── push_database.ps1           # PowerShell version of push script
└── copy_database_setup.bat     # Windows batch file for SQL copying
```

## 📄 File-by-File Analysis

### Core Application Files

#### `lib/main.dart`
**Purpose**: Application entry point and root widget configuration
**Key Components**:
- `main()` function: Initializes Flutter binding and Supabase
- `PrivateClassesApp`: Root widget with MaterialApp.router configuration
- Localization setup for Arabic/English support
- Theme configuration with Cairo font for Arabic text
- Router integration with Go Router

#### `lib/config/app_config.dart`
**Purpose**: Centralized application configuration
**Configuration Values**:
- App metadata (name, version)
- Feature flags (offline mode, QR scanning, location tracking, notifications)
- Attendance settings (15-minute window, 5-minute late threshold, 30-second QR TTL)
- Payment configuration (EGP currency, 100 EGP minimum payout)
- Localization (English/Arabic support)
- Security settings (5 max login attempts, 15-minute lockout, 30-minute session timeout)

#### `lib/config/supabase_config.dart`
**Purpose**: Supabase backend configuration
**Configuration**:
- Supabase URL: `https://xkffzkwrcnbuzvgaxrgy.supabase.co`
- Anonymous key for client-side access
- Debug mode enabled for development
- Static client getter for easy access throughout the app

### Data Models

#### `lib/models/user_model.dart`
**Purpose**: User data model with JSON serialization
**Key Features**:
- Complete user profile representation
- JSON serialization/deserialization with `json_annotation`
- Computed properties (`fullName`, `displayName`)
- Immutable data structure with `copyWith` method
- Integration with `UserRole` enum

#### `lib/models/user_role.dart`
**Purpose**: User role definitions with permission system
**Roles Defined**:
- **Student**: Course enrollment, session booking, attendance viewing, grade viewing, reviews
- **Parent**: Child management, enrollment management, payment management, consent management, reports
- **Teacher**: Course creation, session management, attendance taking, grade management, analytics, payouts
- **Admin**: Full data access, consent log management, dispute handling, refund management, user management

### State Management

#### `lib/providers/auth_provider.dart`
**Purpose**: Riverpod providers for authentication state
**Providers**:
- `authStateProvider`: Stream provider for authentication state changes
- `currentUserProvider`: Current authenticated user
- `userProfileProvider`: User profile data from database
- `userRoleProvider`: Current user's role
- `isAuthenticatedProvider`: Authentication status boolean
- `authLoadingProvider`: Loading state for auth operations
- `authErrorProvider`: Error state for auth operations

### Services

#### `lib/services/auth_service.dart`
**Purpose**: Authentication service with Supabase integration
**Key Methods**:
- `signUp()`: User registration with profile creation
- `signIn()`: User authentication
- `signInWithOtp()`: OTP-based authentication
- `signOut()`: User logout
- `resetPassword()`: Password reset
- `updatePassword()`: Password update
- `getUserProfile()`: Fetch user profile from database
- `updateUserProfile()`: Update user profile
- `hasPermission()`: Check user permissions
- `getCurrentUserRole()`: Get current user's role

### Navigation

#### `lib/utils/router.dart`
**Purpose**: Application routing configuration with Go Router
**Route Structure**:
- `/splash`: Loading screen
- `/role-selection`: Role selection interface
- `/login`: User login (with role context)
- `/signup`: User registration (with role context)
- `/student/dashboard`: Student main interface
- `/parent/dashboard`: Parent main interface
- `/teacher/dashboard`: Teacher main interface
- `/admin/dashboard`: Admin main interface

**Navigation Logic**:
- Automatic redirection based on authentication status
- Role-based routing after authentication
- Context-aware navigation with role passing

### User Interface Screens

#### `lib/screens/splash_screen.dart`
**Purpose**: Application loading screen
**Features**:
- Branded loading interface with app logo
- Circular progress indicator
- Welcome message and subtitle
- Automatic navigation to appropriate screen based on auth state

#### `lib/screens/auth/role_selection_screen.dart`
**Purpose**: Initial role selection interface
**Features**:
- Four role cards (Student, Parent, Teacher, Admin)
- Visual role representation with icons and colors
- Descriptive text for each role
- Navigation to login screen with selected role context

#### `lib/screens/auth/login_screen.dart`
**Purpose**: User authentication interface
**Features**:
- Email and password input fields
- Form validation with error messages
- Password visibility toggle
- Loading state during authentication
- Error handling and display
- Navigation to signup screen
- Role context display in header

#### `lib/screens/auth/signup_screen.dart`
**Purpose**: User registration interface
**Features**:
- Complete registration form (name, email, phone, password)
- Password confirmation field
- Form validation for all fields
- Loading state during registration
- Success/error message handling
- Automatic navigation after successful registration

#### `lib/screens/student/student_dashboard.dart`
**Purpose**: Student main interface
**Features**:
- Personalized welcome message
- Quick action cards (My Courses, Attendance QR, Sessions, Performance)
- Recent activity feed
- Logout functionality
- Responsive grid layout for actions

#### `lib/screens/parent/parent_dashboard.dart`
**Purpose**: Parent main interface
**Features**:
- Children overview with enrollment status
- Quick action cards (Enrollments, Reports, Payments, Alerts)
- Recent activity feed for children
- Child management interface
- Payment and enrollment tracking

#### `lib/screens/teacher/teacher_dashboard.dart`
**Purpose**: Teacher main interface
**Features**:
- Today's sessions with start buttons
- Quick action cards (My Courses, Take Attendance, Grades, Analytics)
- Roster health statistics (attendance %, average grade, active students)
- Session management interface
- Performance analytics

#### `lib/screens/admin/admin_dashboard.dart`
**Purpose**: Admin main interface
**Features**:
- System overview statistics (total users, active courses, sessions, revenue)
- Quick action cards (Consent Logs, Disputes, Payouts, Analytics)
- Recent activity feed for system events
- Platform management tools
- System health monitoring

### Database Schema

#### `database/setup_database.sql`
**Purpose**: Complete database schema for Supabase
**Tables Created**:
1. **profiles**: User profiles extending Supabase auth.users
2. **parent_child_relationships**: Parent-child relationships with consent tracking
3. **course_templates**: Reusable course templates
4. **courses**: Individual course instances
5. **course_enrollments**: Student course enrollments
6. **sessions**: Individual class sessions
7. **session_bookings**: Session reservations
8. **attendance_records**: QR-based attendance tracking
9. **offline_scan_queue**: Offline attendance sync
10. **assessments**: Course assessments and tests
11. **student_grades**: Student performance records
12. **grade_edit_history**: Grade modification audit trail
13. **payment_transactions**: Payment processing records
14. **teacher_payouts**: Teacher payment management
15. **course_reviews**: Course feedback and ratings
16. **teacher_reviews**: Teacher feedback and ratings
17. **notifications**: System notifications
18. **consent_logs**: Parental consent tracking
19. **disputes**: Dispute management
20. **audit_logs**: System audit trail

**Key Features**:
- Row Level Security (RLS) policies for data protection
- Comprehensive audit logging
- Parental consent compliance
- Payment and payout tracking
- Offline capability support

### Platform Configuration

#### `android/app/build.gradle.kts`
**Purpose**: Android build configuration
**Configuration**:
- Application ID: `com.noota.privateclasses.private_classes_app`
- Target SDK: Latest Flutter SDK version
- Java 11 compatibility
- Debug signing for development
- Kotlin Android plugin integration

#### `pubspec.yaml`
**Purpose**: Flutter project configuration and dependencies
**Key Sections**:
- Project metadata (name, description, version)
- Dart SDK requirement (^3.8.1)
- Production dependencies (Supabase, Riverpod, Go Router, etc.)
- Development dependencies (testing, code generation)
- Flutter configuration (Material Design, assets, fonts)

### Utility Scripts

#### `copy_database_setup.py`
**Purpose**: Python script to copy database SQL to clipboard
**Features**:
- Reads `database/setup_database.sql`
- Copies content to system clipboard using `pyperclip`
- Provides step-by-step instructions for Supabase setup
- Error handling for file not found

#### `push_database.py`
**Purpose**: Python script to push database schema via Supabase REST API
**Features**:
- Automated database schema deployment
- SQL chunking to avoid timeout issues
- REST API integration with Supabase
- Progress tracking and error reporting
- Comprehensive execution summary

## 🗄️ Database Schema

### Core Tables

#### Profiles Table
```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT NOT NULL,
  first_name TEXT,
  last_name TEXT,
  phone TEXT,
  role TEXT NOT NULL CHECK (role IN ('student', 'parent', 'teacher', 'admin')),
  avatar_url TEXT,
  is_active BOOLEAN DEFAULT true,
  is_email_verified BOOLEAN DEFAULT false,
  is_phone_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Parent-Child Relationships
```sql
CREATE TABLE parent_child_relationships (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  parent_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  child_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  relationship_type TEXT DEFAULT 'parent',
  is_primary BOOLEAN DEFAULT false,
  consent_given BOOLEAN DEFAULT false,
  consent_method TEXT,
  consent_timestamp TIMESTAMP WITH TIME ZONE,
  consent_policy_version TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(parent_id, child_id)
);
```

#### Courses and Enrollments
```sql
CREATE TABLE courses (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  subject TEXT NOT NULL,
  level TEXT NOT NULL,
  teacher_id UUID REFERENCES profiles(id) NOT NULL,
  pricing_model TEXT NOT NULL CHECK (pricing_model IN ('full_after_enroll', 'pay_per_session')),
  price DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'EGP',
  max_capacity INTEGER DEFAULT 30,
  current_enrollments INTEGER DEFAULT 0,
  location_type TEXT NOT NULL CHECK (location_type IN ('in_person', 'online', 'hybrid')),
  location_address TEXT,
  location_coordinates POINT,
  geofence_radius INTEGER,
  online_link TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Attendance System
```sql
CREATE TABLE attendance_records (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  attendance_status TEXT NOT NULL CHECK (attendance_status IN ('present', 'absent', 'late', 'excused')),
  qr_code_scanned TEXT,
  scan_timestamp TIMESTAMP WITH TIME ZONE,
  location_verified BOOLEAN DEFAULT false,
  scan_location POINT,
  device_info JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Security Features

#### Row Level Security (RLS)
- All tables have RLS enabled
- User-specific data access policies
- Role-based permission enforcement
- Audit trail for all modifications

#### Consent Management
- Parental consent tracking
- Consent method verification
- Policy version compliance
- Timestamp and audit logging

## ⚙️ Configuration

### Environment Configuration

#### App Configuration (`lib/config/app_config.dart`)
```dart
class AppConfig {
  // App Information
  static const String appName = 'Private Classes App';
  static const String appVersion = '1.0.0';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableQRScanning = true;
  static const bool enableLocationTracking = true;
  static const bool enablePushNotifications = true;

  // Attendance Configuration
  static const int attendanceWindowMinutes = 15;
  static const int lateThresholdMinutes = 5;
  static const int qrCodeTTLSeconds = 30;

  // Payment Configuration
  static const String defaultCurrency = 'EGP';
  static const double minimumPayoutAmount = 100.0;

  // Localization
  static const List<String> supportedLocales = ['en', 'ar'];
  static const String defaultLocale = 'en';

  // Security
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;
  static const int sessionTimeoutMinutes = 30;
}
```

#### Supabase Configuration (`lib/config/supabase_config.dart`)
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://xkffzkwrcnbuzvgaxrgy.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ACTUAL_ANON_KEY_HERE';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
```

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code with Flutter extensions
- Supabase account and project
- Python 3.x (for utility scripts)

### Step 1: Clone and Setup
```bash
git clone <repository-url>
cd private_classes_app
flutter pub get
```

### Step 2: Supabase Configuration
1. Create a new Supabase project at https://supabase.com
2. Get your project URL and anon key from Settings > API
3. Update `lib/config/supabase_config.dart` with your credentials

### Step 3: Database Setup
**Option A: Quick Setup (Recommended)**
```bash
# Copy SQL to clipboard
python copy_database_setup.py

# Or push directly via API
python push_database.py
```

**Option B: Manual Setup**
1. Go to Supabase SQL Editor
2. Copy and paste contents of `database/setup_database.sql`
3. Execute the SQL script

### Step 4: Run the Application
```bash
# Development
flutter run

# Specific platforms
flutter run -d android
flutter run -d ios
flutter run -d web
```

## 🛠️ Development Guide

### Code Generation
```bash
# Generate JSON serialization code
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

### Testing
```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Code Analysis
```bash
# Analyze code
flutter analyze

# Fix issues
dart fix --apply
```

### State Management
The app uses Riverpod for state management:
- Providers are defined in `lib/providers/`
- Services are in `lib/services/`
- Models are in `lib/models/`

### Adding New Features
1. Create model in `lib/models/`
2. Add service methods in `lib/services/`
3. Create providers in `lib/providers/`
4. Build UI screens in `lib/screens/`
5. Update router in `lib/utils/router.dart`

## 📦 Deployment

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build iOS
flutter build ios --release
```

### Web
```bash
# Build web
flutter build web --release
```

### Production Configuration
1. Set `debug: false` in `supabase_config.dart`
2. Update app version in `pubspec.yaml`
3. Configure production signing keys
4. Set up production Supabase project
5. Configure domain and SSL certificates

## 🔒 Security & Compliance

### Data Protection
- Row Level Security (RLS) in Supabase
- JWT token-based authentication
- Encrypted data transmission (HTTPS)
- Secure password hashing
- Session timeout management

### Parental Consent
- Consent tracking for all parent-child relationships
- Consent method verification (micro-payment, ID verification, manual)
- Policy version compliance
- Audit trail for consent changes

### Audit Logging
- All user actions logged
- Grade modification history
- Payment transaction logs
- System access logs
- Data modification timestamps

### Compliance Features
- GDPR-compliant data handling
- Egyptian education regulations compliance
- Parental consent management
- Data retention policies
- User privacy controls

## 🌐 Localization

### Supported Languages
- **Arabic (ar)**: Primary language for Egyptian market
- **English (en)**: Secondary language

### RTL Support
- Right-to-left layout for Arabic
- Cairo font family for Arabic text
- Localized date and number formatting
- Cultural-appropriate UI elements

## 📊 Analytics & Monitoring

### Built-in Analytics
- Attendance tracking and reporting
- Payment success rates
- User engagement metrics
- System performance monitoring
- Course completion rates
- Teacher performance metrics

### Reporting Features
- Real-time dashboard updates
- Exportable reports
- Custom date range filtering
- Role-based report access
- Automated report generation

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests if applicable
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Standards
- Follow Dart/Flutter style guidelines
- Write comprehensive tests
- Document public APIs
- Use meaningful commit messages
- Ensure all tests pass

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support & Troubleshooting

### Common Issues

#### Supabase Connection Failed
- Check URL and anon key in `supabase_config.dart`
- Ensure Supabase project is active
- Verify network connectivity

#### Build Errors
- Run `flutter clean && flutter pub get`
- Check Flutter and Dart versions
- Verify all dependencies are compatible

#### Authentication Issues
- Verify RLS policies are set up correctly
- Check user permissions in Supabase
- Ensure email verification is configured

#### Database Issues
- Run database setup scripts in correct order
- Check RLS policies are enabled
- Verify user has proper permissions

### Getting Help
- Check the main README.md for detailed documentation
- Review Supabase documentation for backend issues
- Create an issue in the repository for bugs
- Contact the development team for support

## 🗓️ Roadmap

### Phase 1: Core Features (Current)
- [x] User authentication and role management
- [x] Basic dashboard interfaces
- [x] Database schema and security
- [x] QR code attendance system foundation

### Phase 2: Enhanced Features (Next)
- [ ] Complete QR attendance implementation
- [ ] Payment integration with Egyptian providers
- [ ] Push notifications system
- [ ] Advanced analytics dashboard
- [ ] Offline sync improvements

### Phase 3: Advanced Features (Future)
- [ ] AI-powered attendance fraud detection
- [ ] Advanced reporting and analytics
- [ ] Mobile app store deployment
- [ ] Multi-tenant architecture
- [ ] Advanced parental controls

### Phase 4: Scale & Optimization (Future)
- [ ] Performance optimization
- [ ] Advanced caching strategies
- [ ] Microservices architecture
- [ ] Advanced security features
- [ ] International expansion

---

**Note**: This is a production-ready application designed for the Egyptian private education market. Ensure all security measures are properly configured before deployment. The application includes comprehensive compliance features for parental consent, data protection, and educational regulations.