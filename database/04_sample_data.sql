-- Private Classes App Sample Data
-- This file contains sample data for testing and development

-- =============================================
-- SAMPLE PROFILES
-- =============================================

-- Insert sample profiles (these would normally be created through Supabase Auth)
-- Note: In production, these would be created through the signup process

-- Sample Teachers
INSERT INTO profiles (id, email, first_name, last_name, phone, role, is_email_verified, is_phone_verified) VALUES
('11111111-1111-1111-1111-111111111111', 'ahmed.hassan@example.com', 'Ahmed', 'Hassan', '+201234567890', 'teacher', true, true),
('22222222-2222-2222-2222-222222222222', 'fatma.ali@example.com', 'Fatma', 'Ali', '+201234567891', 'teacher', true, true),
('33333333-3333-3333-3333-333333333333', 'mohamed.ibrahim@example.com', 'Mohamed', 'Ibrahim', '+201234567892', 'teacher', true, true);

-- Sample Students
INSERT INTO profiles (id, email, first_name, last_name, phone, role, is_email_verified, is_phone_verified) VALUES
('44444444-4444-4444-4444-444444444444', 'omar.student@example.com', 'Omar', 'Student', '+201234567893', 'student', true, false),
('55555555-5555-5555-5555-555555555555', 'nour.student@example.com', 'Nour', 'Student', '+201234567894', 'student', true, false),
('66666666-6666-6666-6666-666666666666', 'youssef.student@example.com', 'Youssef', 'Student', '+201234567895', 'student', true, false);

-- Sample Parents
INSERT INTO profiles (id, email, first_name, last_name, phone, role, is_email_verified, is_phone_verified) VALUES
('77777777-7777-7777-7777-777777777777', 'parent1@example.com', 'Ahmed', 'Parent', '+201234567896', 'parent', true, true),
('88888888-8888-8888-8888-888888888888', 'parent2@example.com', 'Sara', 'Parent', '+201234567897', 'parent', true, true);

-- Sample Admin
INSERT INTO profiles (id, email, first_name, last_name, phone, role, is_email_verified, is_phone_verified) VALUES
('99999999-9999-9999-9999-999999999999', 'admin@privateclasses.com', 'Admin', 'User', '+201234567898', 'admin', true, true);

-- =============================================
-- PARENT-CHILD RELATIONSHIPS
-- =============================================

INSERT INTO parent_child_relationships (parent_id, child_id, relationship_type, is_primary, consent_given, consent_method, consent_timestamp, consent_policy_version) VALUES
('77777777-7777-7777-7777-777777777777', '44444444-4444-4444-4444-444444444444', 'parent', true, true, 'id_verification', NOW(), '1.0'),
('88888888-8888-8888-8888-888888888888', '55555555-5555-5555-5555-555555555555', 'parent', true, true, 'id_verification', NOW(), '1.0'),
('88888888-8888-8888-8888-888888888888', '66666666-6666-6666-6666-666666666666', 'parent', true, true, 'id_verification', NOW(), '1.0');

-- =============================================
-- COURSE TEMPLATES
-- =============================================

INSERT INTO course_templates (name, description, subject, level, syllabus, default_assessments, default_schedule_rules, default_policies, created_by) VALUES
('Mathematics Grade 10', 'Comprehensive mathematics course for grade 10 students', 'Mathematics', 'Grade 10', 
 '{"topics": ["Algebra", "Geometry", "Trigonometry", "Statistics"], "duration_weeks": 16}',
 '{"assessments": [{"name": "Quiz 1", "type": "quiz", "weight": 20}, {"name": "Midterm Exam", "type": "exam", "weight": 30}, {"name": "Final Exam", "type": "exam", "weight": 50}]}',
 '{"schedule": "weekly", "duration_minutes": 90, "max_absences": 3}',
 '{"attendance_required": true, "late_policy": "15_minutes", "refund_policy": "full_refund_7_days"}',
 '11111111-1111-1111-1111-111111111111'),

('Physics Grade 11', 'Advanced physics course covering mechanics and thermodynamics', 'Physics', 'Grade 11',
 '{"topics": ["Mechanics", "Thermodynamics", "Waves", "Electricity"], "duration_weeks": 20}',
 '{"assessments": [{"name": "Lab Reports", "type": "assignment", "weight": 25}, {"name": "Midterm Exam", "type": "exam", "weight": 35}, {"name": "Final Exam", "type": "exam", "weight": 40}]}',
 '{"schedule": "weekly", "duration_minutes": 120, "max_absences": 2}',
 '{"attendance_required": true, "late_policy": "10_minutes", "refund_policy": "partial_refund_14_days"}',
 '22222222-2222-2222-2222-222222222222'),

('English Literature', 'Classic and modern English literature analysis', 'English', 'Grade 12',
 '{"topics": ["Poetry", "Novels", "Drama", "Literary Analysis"], "duration_weeks": 18}',
 '{"assessments": [{"name": "Essay 1", "type": "assignment", "weight": 30}, {"name": "Presentation", "type": "project", "weight": 20}, {"name": "Final Essay", "type": "assignment", "weight": 50}]}',
 '{"schedule": "weekly", "duration_minutes": 90, "max_absences": 4}',
 '{"attendance_required": true, "late_policy": "20_minutes", "refund_policy": "full_refund_7_days"}',
 '33333333-3333-3333-3333-333333333333');

-- =============================================
-- COURSES
-- =============================================

INSERT INTO courses (title, description, subject, level, teacher_id, template_id, pricing_model, price, max_capacity, location_type, location_address, geofence_radius, refund_policy, is_active) VALUES
('Advanced Mathematics', 'Comprehensive mathematics course covering algebra, geometry, and trigonometry', 'Mathematics', 'Grade 10', 
 '11111111-1111-1111-1111-111111111111', (SELECT id FROM course_templates WHERE name = 'Mathematics Grade 10'),
 'full_after_enroll', 500.00, 25, 'in_person', '123 Tahrir Square, Cairo', 100, 'full_refund_7_days', true),

('Physics Fundamentals', 'Introduction to physics concepts and principles', 'Physics', 'Grade 11',
 '22222222-2222-2222-2222-222222222222', (SELECT id FROM course_templates WHERE name = 'Physics Grade 11'),
 'pay_per_session', 50.00, 20, 'hybrid', '456 Zamalek, Cairo', 150, 'partial_refund_14_days', true),

('English Literature Analysis', 'Deep dive into classic and modern English literature', 'English', 'Grade 12',
 '33333333-3333-3333-3333-333333333333', (SELECT id FROM course_templates WHERE name = 'English Literature'),
 'full_after_enroll', 400.00, 30, 'online', NULL, NULL, 'full_refund_7_days', true);

-- =============================================
-- COURSE ENROLLMENTS
-- =============================================

INSERT INTO course_enrollments (course_id, student_id, parent_id, enrollment_status, payment_status, payment_amount, payment_currency, payment_method, payment_reference) VALUES
((SELECT id FROM courses WHERE title = 'Advanced Mathematics'), '44444444-4444-4444-4444-444444444444', '77777777-7777-7777-7777-777777777777', 'approved', 'paid', 500.00, 'EGP', 'credit_card', 'PAY_001'),
((SELECT id FROM courses WHERE title = 'Physics Fundamentals'), '55555555-5555-5555-5555-555555555555', '88888888-8888-8888-8888-888888888888', 'approved', 'paid', 200.00, 'EGP', 'bank_transfer', 'PAY_002'),
((SELECT id FROM courses WHERE title = 'English Literature Analysis'), '66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888', 'approved', 'paid', 400.00, 'EGP', 'credit_card', 'PAY_003');

-- =============================================
-- SESSIONS
-- =============================================

INSERT INTO sessions (course_id, title, description, session_date, start_time, end_time, duration_minutes, location_type, location_address, max_attendees, status) VALUES
((SELECT id FROM courses WHERE title = 'Advanced Mathematics'), 'Algebra Basics', 'Introduction to algebraic expressions and equations', '2024-01-15', '10:00:00', '11:30:00', 90, 'in_person', '123 Tahrir Square, Cairo', 25, 'completed'),
((SELECT id FROM courses WHERE title = 'Advanced Mathematics'), 'Geometry Fundamentals', 'Basic geometric shapes and properties', '2024-01-22', '10:00:00', '11:30:00', 90, 'in_person', '123 Tahrir Square, Cairo', 25, 'scheduled'),
((SELECT id FROM courses WHERE title = 'Physics Fundamentals'), 'Mechanics Introduction', 'Basic concepts of motion and forces', '2024-01-16', '14:00:00', '16:00:00', 120, 'hybrid', '456 Zamalek, Cairo', 20, 'completed'),
((SELECT id FROM courses WHERE title = 'English Literature Analysis'), 'Poetry Analysis', 'Understanding poetic devices and themes', '2024-01-17', '16:00:00', '17:30:00', 90, 'online', NULL, 30, 'scheduled');

-- =============================================
-- SESSION BOOKINGS
-- =============================================

INSERT INTO session_bookings (session_id, student_id, parent_id, booking_status, payment_status, payment_amount, payment_currency, payment_method, payment_reference) VALUES
((SELECT id FROM sessions WHERE title = 'Algebra Basics'), '44444444-4444-4444-4444-444444444444', '77777777-7777-7777-7777-777777777777', 'confirmed', 'paid', 50.00, 'EGP', 'credit_card', 'PAY_SESSION_001'),
((SELECT id FROM sessions WHERE title = 'Mechanics Introduction'), '55555555-5555-5555-5555-555555555555', '88888888-8888-8888-8888-888888888888', 'confirmed', 'paid', 50.00, 'EGP', 'bank_transfer', 'PAY_SESSION_002'),
((SELECT id FROM sessions WHERE title = 'Poetry Analysis'), '66666666-6666-6666-6666-666666666666', '88888888-8888-8888-8888-888888888888', 'confirmed', 'paid', 50.00, 'EGP', 'credit_card', 'PAY_SESSION_003');

-- =============================================
-- ATTENDANCE RECORDS
-- =============================================

INSERT INTO attendance_records (session_id, student_id, teacher_id, attendance_type, attendance_status, scan_timestamp, qr_code_data, reason) VALUES
((SELECT id FROM sessions WHERE title = 'Algebra Basics'), '44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'qr_scan', 'present', '2024-01-15 10:05:00', 'QR_DATA_001', NULL),
((SELECT id FROM sessions WHERE title = 'Mechanics Introduction'), '55555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', 'qr_scan', 'present', '2024-01-16 14:02:00', 'QR_DATA_002', NULL);

-- =============================================
-- ASSESSMENTS
-- =============================================

INSERT INTO assessments (course_id, title, description, assessment_type, max_score, weight, due_date, is_published, created_by) VALUES
((SELECT id FROM courses WHERE title = 'Advanced Mathematics'), 'Algebra Quiz 1', 'Basic algebraic expressions and equations', 'quiz', 20.00, 20.00, '2024-01-20 23:59:00', true, '11111111-1111-1111-1111-111111111111'),
((SELECT id FROM courses WHERE title = 'Physics Fundamentals'), 'Mechanics Lab Report', 'Analysis of motion experiments', 'assignment', 50.00, 25.00, '2024-01-25 23:59:00', true, '22222222-2222-2222-2222-222222222222'),
((SELECT id FROM courses WHERE title = 'English Literature Analysis'), 'Poetry Analysis Essay', 'Critical analysis of selected poems', 'assignment', 100.00, 30.00, '2024-01-30 23:59:00', true, '33333333-3333-3333-3333-333333333333');

-- =============================================
-- STUDENT GRADES
-- =============================================

INSERT INTO student_grades (assessment_id, student_id, score, max_score, grade_percentage, letter_grade, feedback, graded_by, is_published) VALUES
((SELECT id FROM assessments WHERE title = 'Algebra Quiz 1'), '44444444-4444-4444-4444-444444444444', 18.00, 20.00, 90.00, 'A-', 'Excellent work! Keep up the good progress.', '11111111-1111-1111-1111-111111111111', true),
((SELECT id FROM assessments WHERE title = 'Mechanics Lab Report'), '55555555-5555-5555-5555-555555555555', 42.00, 50.00, 84.00, 'B', 'Good analysis, but work on your conclusions.', '22222222-2222-2222-2222-222222222222', true);

-- =============================================
-- PAYMENT TRANSACTIONS
-- =============================================

INSERT INTO payment_transactions (user_id, transaction_type, related_id, amount, currency, payment_method, payment_provider, payment_reference, status, processed_at) VALUES
('77777777-7777-7777-7777-777777777777', 'enrollment', (SELECT id FROM courses WHERE title = 'Advanced Mathematics'), 500.00, 'EGP', 'credit_card', 'stripe', 'PAY_001', 'completed', NOW()),
('88888888-8888-8888-8888-888888888888', 'enrollment', (SELECT id FROM courses WHERE title = 'Physics Fundamentals'), 200.00, 'EGP', 'bank_transfer', 'fawry', 'PAY_002', 'completed', NOW()),
('88888888-8888-8888-8888-888888888888', 'enrollment', (SELECT id FROM courses WHERE title = 'English Literature Analysis'), 400.00, 'EGP', 'credit_card', 'stripe', 'PAY_003', 'completed', NOW());

-- =============================================
-- NOTIFICATIONS
-- =============================================

INSERT INTO notifications (user_id, title, message, notification_type, related_id, is_read) VALUES
('44444444-4444-4444-4444-444444444444', 'New Grade Posted', 'Your grade for Algebra Quiz 1 has been posted.', 'grade_posted', (SELECT id FROM assessments WHERE title = 'Algebra Quiz 1'), false),
('55555555-5555-5555-5555-555555555555', 'New Grade Posted', 'Your grade for Mechanics Lab Report has been posted.', 'grade_posted', (SELECT id FROM assessments WHERE title = 'Mechanics Lab Report'), false),
('77777777-7777-7777-7777-777777777777', 'Grade Posted for Omar', 'A new grade has been posted for Omar in Advanced Mathematics.', 'grade_posted', (SELECT id FROM assessments WHERE title = 'Algebra Quiz 1'), false),
('88888888-8888-8888-8888-888888888888', 'Grade Posted for Nour', 'A new grade has been posted for Nour in Physics Fundamentals.', 'grade_posted', (SELECT id FROM assessments WHERE title = 'Mechanics Lab Report'), false);

-- =============================================
-- COURSE REVIEWS
-- =============================================

INSERT INTO course_reviews (course_id, student_id, parent_id, rating, comment, is_anonymous, is_approved) VALUES
((SELECT id FROM courses WHERE title = 'Advanced Mathematics'), '44444444-4444-4444-4444-444444444444', '77777777-7777-7777-7777-777777777777', 5, 'Excellent course! The teacher explains everything very clearly.', false, true),
((SELECT id FROM courses WHERE title = 'Physics Fundamentals'), '55555555-5555-5555-5555-555555555555', '88888888-8888-8888-8888-888888888888', 4, 'Great course, very interactive and engaging.', false, true);

-- =============================================
-- TEACHER REVIEWS
-- =============================================

INSERT INTO teacher_reviews (teacher_id, student_id, parent_id, rating, comment, is_anonymous, is_approved) VALUES
('11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', '77777777-7777-7777-7777-777777777777', 5, 'Mr. Ahmed is an amazing teacher! Very patient and knowledgeable.', false, true),
('22222222-2222-2222-2222-222222222222', '55555555-5555-5555-5555-555555555555', '88888888-8888-8888-8888-888888888888', 4, 'Great teacher, makes physics fun and easy to understand.', false, true);

-- =============================================
-- CONSENT LOGS
-- =============================================

INSERT INTO consent_logs (parent_id, child_id, consent_action, consent_method, policy_version, ip_address) VALUES
('77777777-7777-7777-7777-777777777777', '44444444-4444-4444-4444-444444444444', 'given', 'id_verification', '1.0', '192.168.1.100'),
('88888888-8888-8888-8888-888888888888', '55555555-5555-5555-5555-555555555555', 'given', 'id_verification', '1.0', '192.168.1.101'),
('88888888-8888-8888-8888-888888888888', '66666666-6666-6666-6666-666666666666', 'given', 'id_verification', '1.0', '192.168.1.102');

-- =============================================
-- UPDATE COURSE ENROLLMENT COUNTS
-- =============================================

-- Update the current_enrollments count for courses
UPDATE courses SET current_enrollments = (
    SELECT COUNT(*) FROM course_enrollments 
    WHERE course_id = courses.id AND enrollment_status = 'approved'
);

-- =============================================
-- SAMPLE QUERIES FOR TESTING
-- =============================================

-- Example: Get all courses with their enrollment counts
-- SELECT c.title, c.current_enrollments, c.max_capacity, p.first_name || ' ' || p.last_name as teacher_name
-- FROM courses c
-- JOIN profiles p ON c.teacher_id = p.id
-- WHERE c.is_active = true;

-- Example: Get student attendance summary
-- SELECT p.first_name, p.last_name, COUNT(ar.id) as total_sessions, 
--        COUNT(CASE WHEN ar.attendance_status = 'present' THEN 1 END) as attended_sessions
-- FROM profiles p
-- LEFT JOIN attendance_records ar ON p.id = ar.student_id
-- WHERE p.role = 'student'
-- GROUP BY p.id, p.first_name, p.last_name;

-- Example: Get teacher earnings
-- SELECT p.first_name, p.last_name, SUM(tp.net_payout) as total_earnings
-- FROM profiles p
-- LEFT JOIN teacher_payouts tp ON p.id = tp.teacher_id
-- WHERE p.role = 'teacher' AND tp.status = 'completed'
-- GROUP BY p.id, p.first_name, p.last_name;
