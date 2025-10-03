-- Private Classes App Database Functions
-- This file contains all the database functions, triggers, and stored procedures

-- =============================================
-- UTILITY FUNCTIONS
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Function to generate 6-character link code for student activation
CREATE OR REPLACE FUNCTION generate_link_code()
RETURNS TEXT AS $$
BEGIN
    RETURN upper(substring(md5(random()::text) from 1 for 6));
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

-- Function to get letter grade based on percentage
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
-- COURSE MANAGEMENT FUNCTIONS
-- =============================================

-- Function to check course capacity before enrollment
CREATE OR REPLACE FUNCTION check_course_capacity()
RETURNS TRIGGER AS $$
DECLARE
    course_capacity INTEGER;
    current_enrollments INTEGER;
BEGIN
    SELECT max_capacity, current_enrollments 
    INTO course_capacity, current_enrollments
    FROM courses 
    WHERE id = NEW.course_id;
    
    IF current_enrollments >= course_capacity THEN
        RAISE EXCEPTION 'Course is at maximum capacity';
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Function to update course enrollment count
CREATE OR REPLACE FUNCTION update_course_enrollment_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.enrollment_status = 'approved' THEN
        UPDATE courses 
        SET current_enrollments = current_enrollments + 1 
        WHERE id = NEW.course_id;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.enrollment_status != 'approved' AND NEW.enrollment_status = 'approved' THEN
            UPDATE courses 
            SET current_enrollments = current_enrollments + 1 
            WHERE id = NEW.course_id;
        ELSIF OLD.enrollment_status = 'approved' AND NEW.enrollment_status != 'approved' THEN
            UPDATE courses 
            SET current_enrollments = current_enrollments - 1 
            WHERE id = NEW.course_id;
        END IF;
    ELSIF TG_OP = 'DELETE' AND OLD.enrollment_status = 'approved' THEN
        UPDATE courses 
        SET current_enrollments = current_enrollments - 1 
        WHERE id = OLD.course_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- =============================================
-- ATTENDANCE FUNCTIONS
-- =============================================

-- Function to validate QR code attendance
CREATE OR REPLACE FUNCTION validate_qr_attendance(
    p_session_id UUID,
    p_student_id UUID,
    p_qr_data TEXT,
    p_teacher_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    session_exists BOOLEAN;
    student_enrolled BOOLEAN;
    session_start_time TIMESTAMP;
    session_end_time TIMESTAMP;
    current_time TIMESTAMP := NOW();
BEGIN
    -- Check if session exists and is active
    SELECT EXISTS(
        SELECT 1 FROM sessions s
        WHERE s.id = p_session_id 
        AND s.status IN ('scheduled', 'in_progress')
    ) INTO session_exists;
    
    IF NOT session_exists THEN
        RETURN FALSE;
    END IF;
    
    -- Check if student is enrolled in the course
    SELECT EXISTS(
        SELECT 1 FROM course_enrollments ce
        JOIN sessions s ON s.course_id = ce.course_id
        WHERE s.id = p_session_id 
        AND ce.student_id = p_student_id
        AND ce.enrollment_status = 'approved'
    ) INTO student_enrolled;
    
    IF NOT student_enrolled THEN
        RETURN FALSE;
    END IF;
    
    -- Check if attendance is within time window
    SELECT s.session_date + s.start_time, s.session_date + s.end_time
    INTO session_start_time, session_end_time
    FROM sessions s
    WHERE s.id = p_session_id;
    
    -- Allow 15 minutes before and 30 minutes after
    IF current_time < (session_start_time - INTERVAL '15 minutes') OR 
       current_time > (session_end_time + INTERVAL '30 minutes') THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END;
$$ language 'plpgsql';

-- Function to process offline scan queue
CREATE OR REPLACE FUNCTION process_offline_scans(p_teacher_id UUID)
RETURNS INTEGER AS $$
DECLARE
    processed_count INTEGER := 0;
    scan_record RECORD;
BEGIN
    FOR scan_record IN 
        SELECT * FROM offline_scan_queue 
        WHERE teacher_id = p_teacher_id 
        AND is_processed = FALSE
        ORDER BY scan_timestamp ASC
    LOOP
        BEGIN
            -- Process the scan data
            INSERT INTO attendance_records (
                session_id,
                student_id,
                teacher_id,
                attendance_type,
                attendance_status,
                scan_timestamp,
                qr_code_data,
                device_id,
                is_synced
            ) VALUES (
                (scan_record.scan_data->>'session_id')::UUID,
                (scan_record.scan_data->>'student_id')::UUID,
                p_teacher_id,
                'offline_scan',
                'present',
                scan_record.scan_timestamp,
                scan_record.scan_data->>'qr_data',
                scan_record.device_id,
                TRUE
            );
            
            -- Mark as processed
            UPDATE offline_scan_queue 
            SET is_processed = TRUE, processed_at = NOW()
            WHERE id = scan_record.id;
            
            processed_count := processed_count + 1;
            
        EXCEPTION WHEN OTHERS THEN
            -- Log error and continue
            UPDATE offline_scan_queue 
            SET error_message = SQLERRM
            WHERE id = scan_record.id;
        END;
    END LOOP;
    
    RETURN processed_count;
END;
$$ language 'plpgsql';

-- =============================================
-- GRADING FUNCTIONS
-- =============================================

-- Function to calculate final grade for a student in a course
CREATE OR REPLACE FUNCTION calculate_final_grade(p_course_id UUID, p_student_id UUID)
RETURNS DECIMAL AS $$
DECLARE
    final_grade DECIMAL(5,2) := 0;
    total_weight DECIMAL(5,2) := 0;
    assessment_record RECORD;
BEGIN
    FOR assessment_record IN
        SELECT 
            a.weight,
            COALESCE(sg.grade_percentage, 0) as grade_percentage
        FROM assessments a
        LEFT JOIN student_grades sg ON a.id = sg.assessment_id AND sg.student_id = p_student_id
        WHERE a.course_id = p_course_id 
        AND a.is_published = TRUE
        AND (sg.is_published = TRUE OR sg.is_published IS NULL)
    LOOP
        final_grade := final_grade + (assessment_record.grade_percentage * assessment_record.weight / 100);
        total_weight := total_weight + assessment_record.weight;
    END LOOP;
    
    IF total_weight > 0 THEN
        RETURN ROUND(final_grade, 2);
    ELSE
        RETURN 0;
    END IF;
END;
$$ language 'plpgsql';

-- Function to auto-calculate grade percentage and letter grade
CREATE OR REPLACE FUNCTION auto_calculate_grade()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate percentage
    NEW.grade_percentage := calculate_grade_percentage(NEW.score, NEW.max_score);
    
    -- Calculate letter grade
    NEW.letter_grade := get_letter_grade(NEW.grade_percentage);
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- =============================================
-- NOTIFICATION FUNCTIONS
-- =============================================

-- Function to create notification
CREATE OR REPLACE FUNCTION create_notification(
    p_user_id UUID,
    p_title TEXT,
    p_message TEXT,
    p_notification_type TEXT,
    p_related_id UUID DEFAULT NULL,
    p_scheduled_at TIMESTAMP DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    notification_id UUID;
BEGIN
    INSERT INTO notifications (
        user_id,
        title,
        message,
        notification_type,
        related_id,
        scheduled_at
    ) VALUES (
        p_user_id,
        p_title,
        p_message,
        p_notification_type,
        p_related_id,
        p_scheduled_at
    ) RETURNING id INTO notification_id;
    
    RETURN notification_id;
END;
$$ language 'plpgsql';

-- Function to send grade notification
CREATE OR REPLACE FUNCTION notify_grade_posted()
RETURNS TRIGGER AS $$
DECLARE
    student_name TEXT;
    course_title TEXT;
    parent_id UUID;
BEGIN
    -- Get student and course info
    SELECT p.first_name, c.title
    INTO student_name, course_title
    FROM profiles p
    JOIN assessments a ON a.id = NEW.assessment_id
    JOIN courses c ON c.id = a.course_id
    WHERE p.id = NEW.student_id;
    
    -- Get parent ID if student is under 18
    SELECT pc.parent_id INTO parent_id
    FROM parent_child_relationships pc
    WHERE pc.child_id = NEW.student_id
    AND pc.is_primary = TRUE
    LIMIT 1;
    
    -- Notify student
    PERFORM create_notification(
        NEW.student_id,
        'New Grade Posted',
        'Your grade for ' || course_title || ' has been posted.',
        'grade_posted',
        NEW.assessment_id
    );
    
    -- Notify parent if exists
    IF parent_id IS NOT NULL THEN
        PERFORM create_notification(
            parent_id,
            'Grade Posted for ' || student_name,
            'A new grade has been posted for ' || student_name || ' in ' || course_title || '.',
            'grade_posted',
            NEW.assessment_id
        );
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- =============================================
-- AUDIT FUNCTIONS
-- =============================================

-- Function to log audit trail
CREATE OR REPLACE FUNCTION log_audit_trail()
RETURNS TRIGGER AS $$
DECLARE
    old_values JSONB;
    new_values JSONB;
BEGIN
    -- Convert OLD and NEW records to JSONB
    IF TG_OP = 'DELETE' THEN
        old_values := to_jsonb(OLD);
        new_values := NULL;
    ELSIF TG_OP = 'INSERT' THEN
        old_values := NULL;
        new_values := to_jsonb(NEW);
    ELSE
        old_values := to_jsonb(OLD);
        new_values := to_jsonb(NEW);
    END IF;
    
    -- Insert audit log
    INSERT INTO audit_logs (
        user_id,
        action,
        resource_type,
        resource_id,
        old_values,
        new_values
    ) VALUES (
        COALESCE(NEW.id, OLD.id), -- Use record ID as user context
        TG_OP,
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        old_values,
        new_values
    );
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- =============================================
-- TRIGGERS
-- =============================================

-- Update timestamps
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_courses_updated_at BEFORE UPDATE ON courses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sessions_updated_at BEFORE UPDATE ON sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Course enrollment triggers
CREATE TRIGGER check_course_capacity_trigger BEFORE INSERT ON course_enrollments
    FOR EACH ROW EXECUTE FUNCTION check_course_capacity();

CREATE TRIGGER update_enrollment_count_trigger AFTER INSERT OR UPDATE OR DELETE ON course_enrollments
    FOR EACH ROW EXECUTE FUNCTION update_course_enrollment_count();

-- Grade calculation triggers
CREATE TRIGGER auto_calculate_grade_trigger BEFORE INSERT OR UPDATE ON student_grades
    FOR EACH ROW EXECUTE FUNCTION auto_calculate_grade();

CREATE TRIGGER notify_grade_posted_trigger AFTER INSERT ON student_grades
    FOR EACH ROW EXECUTE FUNCTION notify_grade_posted();

-- Audit triggers (for sensitive tables)
CREATE TRIGGER audit_profiles_trigger AFTER INSERT OR UPDATE OR DELETE ON profiles
    FOR EACH ROW EXECUTE FUNCTION log_audit_trail();

CREATE TRIGGER audit_courses_trigger AFTER INSERT OR UPDATE OR DELETE ON courses
    FOR EACH ROW EXECUTE FUNCTION log_audit_trail();

CREATE TRIGGER audit_payments_trigger AFTER INSERT OR UPDATE OR DELETE ON payment_transactions
    FOR EACH ROW EXECUTE FUNCTION log_audit_trail();

-- =============================================
-- VIEWS FOR COMMON QUERIES
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

-- Parent dashboard view
CREATE VIEW parent_dashboard_data AS
SELECT 
    p.id as parent_id,
    p.first_name,
    p.last_name,
    COUNT(DISTINCT pcr.child_id) as children_count,
    COUNT(DISTINCT ce.course_id) as children_courses,
    COUNT(DISTINCT n.id) as unread_notifications
FROM profiles p
LEFT JOIN parent_child_relationships pcr ON p.id = pcr.parent_id
LEFT JOIN course_enrollments ce ON pcr.child_id = ce.student_id AND ce.enrollment_status = 'approved'
LEFT JOIN notifications n ON p.id = n.user_id AND n.is_read = FALSE
WHERE p.role = 'parent'
GROUP BY p.id, p.first_name, p.last_name;
