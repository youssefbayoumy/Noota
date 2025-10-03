-- Private Classes App Database Schema
-- This file contains all the table definitions for the Private Classes App

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- CORE USER MANAGEMENT TABLES
-- =============================================

-- Profiles table (extends Supabase auth.users)
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

-- Parent-child relationships
CREATE TABLE parent_child_relationships (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  parent_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  child_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  relationship_type TEXT DEFAULT 'parent' CHECK (relationship_type IN ('parent', 'guardian', 'relative')),
  is_primary BOOLEAN DEFAULT false,
  consent_given BOOLEAN DEFAULT false,
  consent_method TEXT CHECK (consent_method IN ('micro_payment', 'id_verification', 'manual')),
  consent_timestamp TIMESTAMP WITH TIME ZONE,
  consent_policy_version TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(parent_id, child_id)
);

-- =============================================
-- COURSE MANAGEMENT TABLES
-- =============================================

-- Course templates
CREATE TABLE course_templates (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  subject TEXT NOT NULL,
  level TEXT NOT NULL,
  syllabus JSONB,
  default_assessments JSONB,
  default_schedule_rules JSONB,
  default_policies JSONB,
  created_by UUID REFERENCES profiles(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Courses
CREATE TABLE courses (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  subject TEXT NOT NULL,
  level TEXT NOT NULL,
  teacher_id UUID REFERENCES profiles(id) NOT NULL,
  template_id UUID REFERENCES course_templates(id),
  cover_image_url TEXT,
  pricing_model TEXT NOT NULL CHECK (pricing_model IN ('full_after_enroll', 'pay_per_session')),
  price DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'EGP',
  max_capacity INTEGER DEFAULT 30,
  current_enrollments INTEGER DEFAULT 0,
  waitlist_enabled BOOLEAN DEFAULT false,
  location_type TEXT NOT NULL CHECK (location_type IN ('in_person', 'online', 'hybrid')),
  location_address TEXT,
  location_coordinates POINT,
  geofence_radius INTEGER, -- in meters
  online_link TEXT,
  refund_policy TEXT,
  teacher_approval_required BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Course enrollments
CREATE TABLE course_enrollments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES profiles(id), -- For students under 18
  enrollment_status TEXT DEFAULT 'pending' CHECK (enrollment_status IN ('pending', 'approved', 'rejected', 'cancelled')),
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded', 'failed')),
  payment_amount DECIMAL(10,2),
  payment_currency TEXT DEFAULT 'EGP',
  payment_method TEXT,
  payment_reference TEXT,
  enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  approved_at TIMESTAMP WITH TIME ZONE,
  cancelled_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(course_id, student_id)
);

-- =============================================
-- SESSION MANAGEMENT TABLES
-- =============================================

-- Sessions
CREATE TABLE sessions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  session_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  duration_minutes INTEGER NOT NULL,
  location_type TEXT NOT NULL CHECK (location_type IN ('in_person', 'online', 'hybrid')),
  location_address TEXT,
  location_coordinates POINT,
  online_link TEXT,
  max_attendees INTEGER,
  current_attendees INTEGER DEFAULT 0,
  status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Session bookings
CREATE TABLE session_bookings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES profiles(id), -- For students under 18
  booking_status TEXT DEFAULT 'confirmed' CHECK (booking_status IN ('confirmed', 'cancelled', 'no_show')),
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded', 'failed')),
  payment_amount DECIMAL(10,2),
  payment_currency TEXT DEFAULT 'EGP',
  payment_method TEXT,
  payment_reference TEXT,
  booked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  cancelled_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(session_id, student_id)
);

-- =============================================
-- ATTENDANCE MANAGEMENT TABLES
-- =============================================

-- Attendance records
CREATE TABLE attendance_records (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  teacher_id UUID REFERENCES profiles(id) NOT NULL,
  attendance_type TEXT NOT NULL CHECK (attendance_type IN ('qr_scan', 'offline_scan', 'backup_code', 'manual')),
  attendance_status TEXT NOT NULL CHECK (attendance_status IN ('present', 'absent', 'late', 'excused')),
  scan_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  location_coordinates POINT, -- Snapshot for geofence validation
  qr_code_data TEXT, -- For QR scan validation
  backup_code TEXT, -- For backup code attendance
  reason TEXT, -- For backup code or excused absences
  notes TEXT,
  device_id TEXT, -- For device tracking
  is_synced BOOLEAN DEFAULT true, -- For offline sync
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(session_id, student_id)
);

-- Offline scan queue (for when teacher is offline)
CREATE TABLE offline_scan_queue (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  teacher_id UUID REFERENCES profiles(id) NOT NULL,
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  scan_data JSONB NOT NULL, -- Encrypted scan data
  device_id TEXT NOT NULL,
  scan_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_processed BOOLEAN DEFAULT false,
  processed_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- GRADING AND ASSESSMENT TABLES
-- =============================================

-- Assessments
CREATE TABLE assessments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  assessment_type TEXT NOT NULL CHECK (assessment_type IN ('quiz', 'exam', 'assignment', 'project', 'participation')),
  max_score DECIMAL(5,2) NOT NULL,
  weight DECIMAL(5,2) NOT NULL, -- Percentage weight in final grade
  due_date TIMESTAMP WITH TIME ZONE,
  is_published BOOLEAN DEFAULT false,
  created_by UUID REFERENCES profiles(id) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Student grades
CREATE TABLE student_grades (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  assessment_id UUID REFERENCES assessments(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  score DECIMAL(5,2),
  max_score DECIMAL(5,2) NOT NULL,
  grade_percentage DECIMAL(5,2),
  letter_grade TEXT,
  feedback TEXT,
  graded_by UUID REFERENCES profiles(id) NOT NULL,
  graded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(assessment_id, student_id)
);

-- Grade edit history
CREATE TABLE grade_edit_history (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  grade_id UUID REFERENCES student_grades(id) ON DELETE CASCADE,
  old_score DECIMAL(5,2),
  new_score DECIMAL(5,2),
  old_feedback TEXT,
  new_feedback TEXT,
  edit_reason TEXT NOT NULL,
  edited_by UUID REFERENCES profiles(id) NOT NULL,
  edited_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- PAYMENT AND FINANCIAL TABLES
-- =============================================

-- Payment transactions
CREATE TABLE payment_transactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) NOT NULL,
  transaction_type TEXT NOT NULL CHECK (transaction_type IN ('enrollment', 'session_booking', 'refund', 'payout')),
  related_id UUID, -- Course ID, session ID, etc.
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'EGP',
  payment_method TEXT NOT NULL,
  payment_provider TEXT NOT NULL,
  payment_reference TEXT UNIQUE,
  status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded')),
  failure_reason TEXT,
  processed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Teacher payouts
CREATE TABLE teacher_payouts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  teacher_id UUID REFERENCES profiles(id) NOT NULL,
  payout_period_start DATE NOT NULL,
  payout_period_end DATE NOT NULL,
  total_earnings DECIMAL(10,2) NOT NULL,
  platform_fee DECIMAL(10,2) NOT NULL,
  net_payout DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'EGP',
  payout_method TEXT NOT NULL,
  payout_reference TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  processed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- REVIEWS AND RATINGS TABLES
-- =============================================

-- Course reviews
CREATE TABLE course_reviews (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES profiles(id), -- For students under 18
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  is_anonymous BOOLEAN DEFAULT false,
  is_approved BOOLEAN DEFAULT false,
  is_flagged BOOLEAN DEFAULT false,
  flag_reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(course_id, student_id)
);

-- Teacher reviews
CREATE TABLE teacher_reviews (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  teacher_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES profiles(id), -- For students under 18
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  is_anonymous BOOLEAN DEFAULT false,
  is_approved BOOLEAN DEFAULT false,
  is_flagged BOOLEAN DEFAULT false,
  flag_reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(teacher_id, student_id)
);

-- =============================================
-- NOTIFICATION AND COMMUNICATION TABLES
-- =============================================

-- Notifications
CREATE TABLE notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  notification_type TEXT NOT NULL CHECK (notification_type IN ('session_reminder', 'grade_posted', 'payment_confirmation', 'attendance_alert', 'enrollment_update', 'system_alert')),
  related_id UUID, -- Course ID, session ID, etc.
  is_read BOOLEAN DEFAULT false,
  is_push_sent BOOLEAN DEFAULT false,
  is_email_sent BOOLEAN DEFAULT false,
  scheduled_at TIMESTAMP WITH TIME ZONE,
  sent_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- ADMIN AND AUDIT TABLES
-- =============================================

-- Consent logs
CREATE TABLE consent_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  parent_id UUID REFERENCES profiles(id) NOT NULL,
  child_id UUID REFERENCES profiles(id) NOT NULL,
  consent_action TEXT NOT NULL CHECK (consent_action IN ('given', 'withdrawn', 'updated')),
  consent_method TEXT NOT NULL CHECK (consent_method IN ('micro_payment', 'id_verification', 'manual')),
  policy_version TEXT NOT NULL,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Disputes and refunds
CREATE TABLE disputes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) NOT NULL,
  transaction_id UUID REFERENCES payment_transactions(id),
  dispute_type TEXT NOT NULL CHECK (dispute_type IN ('refund_request', 'payment_dispute', 'service_dispute')),
  reason TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'under_review', 'resolved', 'closed')),
  resolution TEXT,
  resolved_by UUID REFERENCES profiles(id),
  resolved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit logs
CREATE TABLE audit_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  action TEXT NOT NULL,
  resource_type TEXT NOT NULL,
  resource_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- Profiles indexes
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_profiles_phone ON profiles(phone);

-- Course indexes
CREATE INDEX idx_courses_teacher ON courses(teacher_id);
CREATE INDEX idx_courses_subject ON courses(subject);
CREATE INDEX idx_courses_level ON courses(level);
CREATE INDEX idx_courses_active ON courses(is_active);

-- Enrollment indexes
CREATE INDEX idx_enrollments_course ON course_enrollments(course_id);
CREATE INDEX idx_enrollments_student ON course_enrollments(student_id);
CREATE INDEX idx_enrollments_status ON course_enrollments(enrollment_status);

-- Session indexes
CREATE INDEX idx_sessions_course ON sessions(course_id);
CREATE INDEX idx_sessions_date ON sessions(session_date);
CREATE INDEX idx_sessions_status ON sessions(status);

-- Attendance indexes
CREATE INDEX idx_attendance_session ON attendance_records(session_id);
CREATE INDEX idx_attendance_student ON attendance_records(student_id);
CREATE INDEX idx_attendance_teacher ON attendance_records(teacher_id);
CREATE INDEX idx_attendance_timestamp ON attendance_records(scan_timestamp);

-- Grade indexes
CREATE INDEX idx_grades_assessment ON student_grades(assessment_id);
CREATE INDEX idx_grades_student ON student_grades(student_id);
CREATE INDEX idx_grades_published ON student_grades(is_published);

-- Payment indexes
CREATE INDEX idx_payments_user ON payment_transactions(user_id);
CREATE INDEX idx_payments_status ON payment_transactions(status);
CREATE INDEX idx_payments_type ON payment_transactions(transaction_type);

-- Notification indexes
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(notification_type);
CREATE INDEX idx_notifications_read ON notifications(is_read);

-- Audit log indexes
CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_created ON audit_logs(created_at);
