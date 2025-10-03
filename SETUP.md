# Setup Guide

## Supabase Configuration

### 1. Get Your Supabase Credentials

1. Go to your Supabase project dashboard: https://supabase.com/dashboard
2. Navigate to Settings > API
3. Copy your Project URL and anon/public key

### 2. Update Configuration

Edit `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://xkffzkwrcnbuzvgaxrgy.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ACTUAL_ANON_KEY_HERE';
  // ... rest of the configuration
}
```

### 3. Database Setup

Run the following SQL in your Supabase SQL Editor:

```sql
-- Create profiles table
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

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can read own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
```

## Running the App

### Development
```bash
flutter run
```

### Production Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## Troubleshooting

### Common Issues

1. **Supabase connection failed**
   - Check your URL and anon key
   - Ensure your Supabase project is active

2. **Build errors**
   - Run `flutter clean && flutter pub get`
   - Check Flutter and Dart versions

3. **Authentication issues**
   - Verify RLS policies are set up correctly
   - Check user permissions in Supabase

### Getting Help

- Check the main README.md for detailed documentation
- Review Supabase documentation for backend issues
- Create an issue in the repository for bugs
