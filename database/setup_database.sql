-- Private Classes App - Complete Database Setup
-- Run this file in your Supabase SQL Editor to set up the entire database

-- =============================================
-- STEP 1: CREATE TABLES
-- =============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

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
  geofence_radius INTEGER,
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
  parent_id UUID REFERENCES profiles(id),
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
  parent_id UUID REFERENCES profiles(id),
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

-- Attendance records
CREATE TABLE attendance_records (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  teacher_id UUID REFERENCES profiles(id) NOT NULL,
  attendance_type TEXT NOT NULL CHECK (attendance_type IN ('qr_scan', 'offline_scan', 'backup_code', 'manual')),
  attendance_status TEXT NOT NULL CHECK (attendance_status IN ('present', 'absent', 'late', 'excused')),
  scan_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  location_coordinates POINT,
  qr_code_data TEXT,
  backup_code TEXT,
  reason TEXT,
  notes TEXT,
  device_id TEXT,
  is_synced BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(session_id, student_id)
);

-- Offline scan queue
CREATE TABLE offline_scan_queue (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  teacher_id UUID REFERENCES profiles(id) NOT NULL,
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  scan_data JSONB NOT NULL,
  device_id TEXT NOT NULL,
  scan_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_processed BOOLEAN DEFAULT false,
  processed_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Assessments
CREATE TABLE assessments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  assessment_type TEXT NOT NULL CHECK (assessment_type IN ('quiz', 'exam', 'assignment', 'project', 'participation')),
  max_score DECIMAL(5,2) NOT NULL,
  weight DECIMAL(5,2) NOT NULL,
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

-- Payment transactions
CREATE TABLE payment_transactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) NOT NULL,
  transaction_type TEXT NOT NULL CHECK (transaction_type IN ('enrollment', 'session_booking', 'refund', 'payout')),
  related_id UUID,
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

-- Course reviews
CREATE TABLE course_reviews (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES profiles(id),
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
  parent_id UUID REFERENCES profiles(id),
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

-- Notifications
CREATE TABLE notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  notification_type TEXT NOT NULL CHECK (notification_type IN ('session_reminder', 'grade_posted', 'payment_confirmation', 'attendance_alert', 'enrollment_update', 'system_alert')),
  related_id UUID,
  is_read BOOLEAN DEFAULT false,
  is_push_sent BOOLEAN DEFAULT false,
  is_email_sent BOOLEAN DEFAULT false,
  scheduled_at TIMESTAMP WITH TIME ZONE,
  sent_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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

-- Disputes
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
-- STEP 2: CREATE INDEXES
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

-- =============================================
-- STEP 3: ENABLE ROW LEVEL SECURITY
-- =============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE parent_child_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE offline_scan_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_grades ENABLE ROW LEVEL SECURITY;
ALTER TABLE grade_edit_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_payouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE consent_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- =============================================
-- STEP 4: CREATE BASIC RLS POLICIES
-- =============================================

-- Profiles policies
CREATE POLICY "Users can read own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Course enrollments policies
CREATE POLICY "Students can read own enrollments" ON course_enrollments
    FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "Students can create enrollments" ON course_enrollments
    FOR INSERT WITH CHECK (student_id = auth.uid());

-- Attendance records policies
CREATE POLICY "Students can read own attendance" ON attendance_records
    FOR SELECT USING (student_id = auth.uid());

-- Student grades policies
CREATE POLICY "Students can read own grades" ON student_grades
    FOR SELECT USING (student_id = auth.uid());

-- Payment transactions policies
CREATE POLICY "Users can read own transactions" ON payment_transactions
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can create transactions" ON payment_transactions
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Notifications policies
CREATE POLICY "Users can read own notifications" ON notifications
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (user_id = auth.uid());

-- =============================================
-- STEP 5: CREATE UTILITY FUNCTIONS
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Function to calculate grade percentage
CREATE OR REPLACE FUNCTION calculate_grade_percentage(score DECIMAL, max_score DECIMAL)
RETURNS DECIMAL AS $$
BEGIN
    IF max_score = 0 THEN
        RETURN 0;
    END IF;
    RETURN ROUND((score / max_score) * 100, 2);
END;
$$ language 'plpgsql';

-- Function to get letter grade
CREATE OR REPLACE FUNCTION get_letter_grade(percentage DECIMAL)
RETURNS TEXT AS $$
BEGIN
    IF percentage >= 97 THEN RETURN 'A+';
    ELSIF percentage >= 93 THEN RETURN 'A';
    ELSIF percentage >= 90 THEN RETURN 'A-';
    ELSIF percentage >= 87 THEN RETURN 'B+';
    ELSIF percentage >= 83 THEN RETURN 'B';
    ELSIF percentage >= 80 THEN RETURN 'B-';
    ELSIF percentage >= 77 THEN RETURN 'C+';
    ELSIF percentage >= 73 THEN RETURN 'C';
    ELSIF percentage >= 70 THEN RETURN 'C-';
    ELSIF percentage >= 67 THEN RETURN 'D+';
    ELSIF percentage >= 63 THEN RETURN 'D';
    ELSIF percentage >= 60 THEN RETURN 'D-';
    ELSE RETURN 'F';
    END IF;
END;
$$ language 'plpgsql';

-- =============================================
-- STEP 6: CREATE TRIGGERS
-- =============================================

-- Update timestamps
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_courses_updated_at BEFORE UPDATE ON courses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sessions_updated_at BEFORE UPDATE ON sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- STEP 7: CREATE VIEWS
-- =============================================

-- Student dashboard view
CREATE VIEW student_dashboard_data AS
SELECT 
    p.id as student_id,
    p.first_name,
    p.last_name,
    COUNT(DISTINCT ce.course_id) as enrolled_courses,
    COUNT(DISTINCT sb.session_id) as upcoming_sessions,
    COUNT(DISTINCT ar.session_id) as attended_sessions,
    ROUND(AVG(sg.grade_percentage), 2) as average_grade
FROM profiles p
LEFT JOIN course_enrollments ce ON p.id = ce.student_id AND ce.enrollment_status = 'approved'
LEFT JOIN session_bookings sb ON p.id = sb.student_id AND sb.booking_status = 'confirmed'
LEFT JOIN attendance_records ar ON p.id = ar.student_id AND ar.attendance_status = 'present'
LEFT JOIN student_grades sg ON p.id = sg.student_id AND sg.is_published = TRUE
WHERE p.role = 'student'
GROUP BY p.id, p.first_name, p.last_name;

-- Teacher dashboard view
CREATE VIEW teacher_dashboard_data AS
SELECT 
    p.id as teacher_id,
    p.first_name,
    p.last_name,
    COUNT(DISTINCT c.id) as total_courses,
    COUNT(DISTINCT ce.student_id) as total_students,
    COUNT(DISTINCT s.id) as total_sessions,
    ROUND(AVG(cr.rating), 2) as average_rating,
    SUM(COALESCE(tp.net_payout, 0)) as total_earnings
FROM profiles p
LEFT JOIN courses c ON p.id = c.teacher_id
LEFT JOIN course_enrollments ce ON c.id = ce.course_id AND ce.enrollment_status = 'approved'
LEFT JOIN sessions s ON c.id = s.course_id
LEFT JOIN course_reviews cr ON c.id = cr.course_id AND cr.is_approved = TRUE
LEFT JOIN teacher_payouts tp ON p.id = tp.teacher_id AND tp.status = 'completed'
WHERE p.role = 'teacher'
GROUP BY p.id, p.first_name, p.last_name;

-- =============================================
-- COMPLETION MESSAGE
-- =============================================

DO $$
BEGIN
    RAISE NOTICE 'Private Classes App database setup completed successfully!';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Update your Supabase configuration in the Flutter app';
    RAISE NOTICE '2. Test the authentication flow';
    RAISE NOTICE '3. Add more detailed RLS policies as needed';
    RAISE NOTICE '4. Insert sample data for testing';
END $$;
