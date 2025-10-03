-- Private Classes App Row Level Security (RLS) Policies
-- This file contains all the RLS policies for data security and access control

-- =============================================
-- ENABLE ROW LEVEL SECURITY
-- =============================================

-- Enable RLS on all tables
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
-- PROFILES TABLE POLICIES
-- =============================================

-- Users can read their own profile
CREATE POLICY "Users can read own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own profile (during signup)
CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Teachers can read profiles of their students
CREATE POLICY "Teachers can read student profiles" ON profiles
    FOR SELECT USING (
        role = 'teacher' AND EXISTS (
            SELECT 1 FROM courses c
            JOIN course_enrollments ce ON c.id = ce.course_id
            WHERE c.teacher_id = auth.uid() AND ce.student_id = profiles.id
        )
    );

-- Parents can read profiles of their children
CREATE POLICY "Parents can read child profiles" ON profiles
    FOR SELECT USING (
        role = 'parent' AND EXISTS (
            SELECT 1 FROM parent_child_relationships pcr
            WHERE pcr.parent_id = auth.uid() AND pcr.child_id = profiles.id
        )
    );

-- Admins can read all profiles
CREATE POLICY "Admins can read all profiles" ON profiles
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- =============================================
-- PARENT-CHILD RELATIONSHIPS POLICIES
-- =============================================

-- Parents can read their own relationships
CREATE POLICY "Parents can read own relationships" ON parent_child_relationships
    FOR SELECT USING (parent_id = auth.uid());

-- Parents can create relationships with their children
CREATE POLICY "Parents can create relationships" ON parent_child_relationships
    FOR INSERT WITH CHECK (parent_id = auth.uid());

-- Parents can update their own relationships
CREATE POLICY "Parents can update own relationships" ON parent_child_relationships
    FOR UPDATE USING (parent_id = auth.uid());

-- Admins can read all relationships
CREATE POLICY "Admins can read all relationships" ON parent_child_relationships
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- =============================================
-- COURSE TEMPLATES POLICIES
-- =============================================

-- Teachers can read all templates
CREATE POLICY "Teachers can read templates" ON course_templates
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'teacher')
    );

-- Teachers can create templates
CREATE POLICY "Teachers can create templates" ON course_templates
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'teacher')
    );

-- Teachers can update their own templates
CREATE POLICY "Teachers can update own templates" ON course_templates
    FOR UPDATE USING (created_by = auth.uid());

-- Admins can do everything with templates
CREATE POLICY "Admins can manage templates" ON course_templates
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- =============================================
-- COURSES POLICIES
-- =============================================

-- Teachers can read their own courses
CREATE POLICY "Teachers can read own courses" ON courses
    FOR SELECT USING (teacher_id = auth.uid());

-- Teachers can create courses
CREATE POLICY "Teachers can create courses" ON courses
    FOR INSERT WITH CHECK (teacher_id = auth.uid());

-- Teachers can update their own courses
CREATE POLICY "Teachers can update own courses" ON courses
    FOR UPDATE USING (teacher_id = auth.uid());

-- Students can read courses they're enrolled in
CREATE POLICY "Students can read enrolled courses" ON courses
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM course_enrollments ce
            WHERE ce.course_id = courses.id 
            AND ce.student_id = auth.uid()
            AND ce.enrollment_status = 'approved'
        )
    );

-- Parents can read courses their children are enrolled in
CREATE POLICY "Parents can read children's courses" ON courses
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM course_enrollments ce
            JOIN parent_child_relationships pcr ON ce.student_id = pcr.child_id
            WHERE ce.course_id = courses.id 
            AND pcr.parent_id = auth.uid()
            AND ce.enrollment_status = 'approved'
        )
    );

-- Anyone can read active courses (for browsing)
CREATE POLICY "Anyone can read active courses" ON courses
    FOR SELECT USING (is_active = true);

-- Admins can do everything with courses
CREATE POLICY "Admins can manage courses" ON courses
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- =============================================
-- COURSE ENROLLMENTS POLICIES
-- =============================================

-- Students can read their own enrollments
CREATE POLICY "Students can read own enrollments" ON course_enrollments
    FOR SELECT USING (student_id = auth.uid());

-- Students can create enrollments
CREATE POLICY "Students can create enrollments" ON course_enrollments
    FOR INSERT WITH CHECK (student_id = auth.uid());

-- Parents can read their children's enrollments
CREATE POLICY "Parents can read children's enrollments" ON course_enrollments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM parent_child_relationships pcr
            WHERE pcr.child_id = course_enrollments.student_id
            AND pcr.parent_id = auth.uid()
        )
    );

-- Teachers can read enrollments for their courses
CREATE POLICY "Teachers can read course enrollments" ON course_enrollments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = course_enrollments.course_id
            AND c.teacher_id = auth.uid()
        )
    );

-- Teachers can update enrollment status
CREATE POLICY "Teachers can update enrollment status" ON course_enrollments
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = course_enrollments.course_id
            AND c.teacher_id = auth.uid()
        )
    );

-- Admins can do everything with enrollments
CREATE POLICY "Admins can manage enrollments" ON course_enrollments
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- =============================================
-- SESSIONS POLICIES
-- =============================================

-- Teachers can read sessions for their courses
CREATE POLICY "Teachers can read course sessions" ON sessions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = sessions.course_id
            AND c.teacher_id = auth.uid()
        )
    );

-- Teachers can create sessions for their courses
CREATE POLICY "Teachers can create sessions" ON sessions
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = sessions.course_id
            AND c.teacher_id = auth.uid()
        )
    );

-- Teachers can update sessions for their courses
CREATE POLICY "Teachers can update course sessions" ON sessions
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = sessions.course_id
            AND c.teacher_id = auth.uid()
        )
    );

-- Students can read sessions they're enrolled in
CREATE POLICY "Students can read enrolled sessions" ON sessions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM course_enrollments ce
            WHERE ce.course_id = sessions.course_id
            AND ce.student_id = auth.uid()
            AND ce.enrollment_status = 'approved'
        )
    );

-- Parents can read sessions their children are enrolled in
CREATE POLICY "Parents can read children's sessions" ON sessions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM course_enrollments ce
            JOIN parent_child_relationships pcr ON ce.student_id = pcr.child_id
            WHERE ce.course_id = sessions.course_id
            AND pcr.parent_id = auth.uid()
            AND ce.enrollment_status = 'approved'
        )
    );

-- Admins can do everything with sessions
CREATE POLICY "Admins can manage sessions" ON sessions
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- =============================================
-- ATTENDANCE RECORDS POLICIES
-- =============================================

-- Teachers can read attendance for their sessions
CREATE POLICY "Teachers can read session attendance" ON attendance_records
    FOR SELECT USING (teacher_id = auth.uid());

-- Teachers can create attendance records
CREATE POLICY "Teachers can create attendance" ON attendance_records
    FOR INSERT WITH CHECK (teacher_id = auth.uid());

-- Teachers can update attendance records
CREATE POLICY "Teachers can update attendance" ON attendance_records
    FOR UPDATE USING (teacher_id = auth.uid());

-- Students can read their own attendance
CREATE POLICY "Students can read own attendance" ON attendance_records
    FOR SELECT USING (student_id = auth.uid());

-- Parents can read their children's attendance
CREATE POLICY "Parents can read children's attendance" ON attendance_records
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM parent_child_relationships pcr
            WHERE pcr.child_id = attendance_records.student_id
            AND pcr.parent_id = auth.uid()
        )
    );

-- Admins can do everything with attendance
CREATE POLICY "Admins can manage attendance" ON attendance_records
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- =============================================
-- STUDENT GRADES POLICIES
-- =============================================

-- Teachers can read grades for their courses
CREATE POLICY "Teachers can read course grades" ON student_grades
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM assessments a
            JOIN courses c ON a.course_id = c.id
            WHERE a.id = student_grades.assessment_id
            AND c.teacher_id = auth.uid()
        )
    );

-- Teachers can create grades
CREATE POLICY "Teachers can create grades" ON student_grades
    FOR INSERT WITH CHECK (graded_by = auth.uid());

-- Teachers can update grades
CREATE POLICY "Teachers can update grades" ON student_grades
    FOR UPDATE USING (graded_by = auth.uid());

-- Students can read their own grades
CREATE POLICY "Students can read own grades" ON student_grades
    FOR SELECT USING (student_id = auth.uid());

-- Parents can read their children's grades
CREATE POLICY "Parents can read children's grades" ON student_grades
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM parent_child_relationships pcr
            WHERE pcr.child_id = student_grades.student_id
            AND pcr.parent_id = auth.uid()
        )
    );

-- Admins can do everything with grades
CREATE POLICY "Admins can manage grades" ON student_grades
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- =============================================
-- PAYMENT TRANSACTIONS POLICIES
-- =============================================

-- Users can read their own transactions
CREATE POLICY "Users can read own transactions" ON payment_transactions
    FOR SELECT USING (user_id = auth.uid());

-- Users can create transactions
CREATE POLICY "Users can create transactions" ON payment_transactions
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Admins can read all transactions
CREATE POLICY "Admins can read all transactions" ON payment_transactions
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- =============================================
-- NOTIFICATIONS POLICIES
-- =============================================

-- Users can read their own notifications
CREATE POLICY "Users can read own notifications" ON notifications
    FOR SELECT USING (user_id = auth.uid());

-- Users can update their own notifications
CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (user_id = auth.uid());

-- System can create notifications
CREATE POLICY "System can create notifications" ON notifications
    FOR INSERT WITH CHECK (true);

-- =============================================
-- REVIEWS POLICIES
-- =============================================

-- Students can read reviews for courses they're enrolled in
CREATE POLICY "Students can read course reviews" ON course_reviews
    FOR SELECT USING (
        student_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM course_enrollments ce
            WHERE ce.course_id = course_reviews.course_id
            AND ce.student_id = auth.uid()
            AND ce.enrollment_status = 'approved'
        )
    );

-- Students can create reviews for courses they're enrolled in
CREATE POLICY "Students can create course reviews" ON course_reviews
    FOR INSERT WITH CHECK (
        student_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM course_enrollments ce
            WHERE ce.course_id = course_reviews.course_id
            AND ce.student_id = auth.uid()
            AND ce.enrollment_status = 'approved'
        )
    );

-- Students can update their own reviews
CREATE POLICY "Students can update own reviews" ON course_reviews
    FOR UPDATE USING (student_id = auth.uid());

-- Parents can read reviews for courses their children are enrolled in
CREATE POLICY "Parents can read children's course reviews" ON course_reviews
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM parent_child_relationships pcr
            WHERE pcr.child_id = course_reviews.student_id
            AND pcr.parent_id = auth.uid()
        )
    );

-- Teachers can read reviews for their courses
CREATE POLICY "Teachers can read course reviews" ON course_reviews
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = course_reviews.course_id
            AND c.teacher_id = auth.uid()
        )
    );

-- Admins can do everything with reviews
CREATE POLICY "Admins can manage reviews" ON course_reviews
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- =============================================
-- CONSENT LOGS POLICIES
-- =============================================

-- Parents can read their own consent logs
CREATE POLICY "Parents can read own consent logs" ON consent_logs
    FOR SELECT USING (parent_id = auth.uid());

-- System can create consent logs
CREATE POLICY "System can create consent logs" ON consent_logs
    FOR INSERT WITH CHECK (true);

-- Admins can read all consent logs
CREATE POLICY "Admins can read all consent logs" ON consent_logs
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- =============================================
-- DISPUTES POLICIES
-- =============================================

-- Users can read their own disputes
CREATE POLICY "Users can read own disputes" ON disputes
    FOR SELECT USING (user_id = auth.uid());

-- Users can create disputes
CREATE POLICY "Users can create disputes" ON disputes
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Users can update their own disputes
CREATE POLICY "Users can update own disputes" ON disputes
    FOR UPDATE USING (user_id = auth.uid());

-- Admins can do everything with disputes
CREATE POLICY "Admins can manage disputes" ON disputes
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- =============================================
-- AUDIT LOGS POLICIES
-- =============================================

-- Only admins can read audit logs
CREATE POLICY "Admins can read audit logs" ON audit_logs
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- System can create audit logs
CREATE POLICY "System can create audit logs" ON audit_logs
    FOR INSERT WITH CHECK (true);
