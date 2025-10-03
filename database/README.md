# Private Classes App Database Schema

This directory contains the complete database schema and setup files for the Private Classes App.

## 📁 Files Overview

### 1. `01_create_tables.sql`
Contains all table definitions, indexes, and constraints for the database.

**Key Tables:**
- `profiles` - User profiles extending Supabase auth
- `parent_child_relationships` - Parent-child consent management
- `courses` - Course management and templates
- `course_enrollments` - Student enrollments
- `sessions` - Class sessions and scheduling
- `attendance_records` - QR code and manual attendance
- `student_grades` - Assessment and grading system
- `payment_transactions` - Payment processing
- `notifications` - User notifications
- `audit_logs` - System audit trail

### 2. `02_create_functions.sql`
Contains database functions, triggers, and stored procedures.

**Key Functions:**
- `validate_qr_attendance()` - QR code validation
- `process_offline_scans()` - Offline sync processing
- `calculate_final_grade()` - Grade calculations
- `create_notification()` - Notification system
- `log_audit_trail()` - Audit logging

### 3. `03_create_policies.sql`
Contains Row Level Security (RLS) policies for data access control.

**Security Features:**
- Role-based access control
- Parent-child data isolation
- Teacher-student data scoping
- Admin oversight capabilities

### 4. `04_sample_data.sql`
Contains sample data for testing and development.

**Sample Data Includes:**
- Test users (teachers, students, parents, admin)
- Course templates and courses
- Enrollments and sessions
- Attendance records and grades
- Payment transactions
- Notifications and reviews

## 🚀 Setup Instructions

### 1. Run in Supabase SQL Editor

Execute the files in order:

```sql
-- 1. Create tables and indexes
\i 01_create_tables.sql

-- 2. Create functions and triggers
\i 02_create_functions.sql

-- 3. Create RLS policies
\i 03_create_policies.sql

-- 4. Insert sample data (optional)
\i 04_sample_data.sql
```

### 2. Verify Setup

Check that all tables are created:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

### 3. Test RLS Policies

Verify that RLS is working:

```sql
-- Check RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = true;
```

## 🔒 Security Features

### Row Level Security (RLS)
- **Students**: Can only access their own data
- **Parents**: Can access their children's data
- **Teachers**: Can access their courses and students
- **Admins**: Full access to all data

### Data Protection
- Encrypted sensitive data
- Audit trail for all changes
- Consent management for minors
- Secure payment processing

## 📊 Key Features

### Attendance System
- QR code scanning with validation
- Offline sync capability
- Backup code attendance
- Geofence validation

### Grading System
- Flexible assessment types
- Weighted grading
- Grade history tracking
- Automatic calculations

### Payment Processing
- Multiple payment methods
- Transaction tracking
- Refund management
- Teacher payouts

### Notification System
- Real-time notifications
- Email and push support
- Parent notifications
- System alerts

## 🔧 Database Functions

### Attendance Functions
```sql
-- Validate QR attendance
SELECT validate_qr_attendance(session_id, student_id, qr_data, teacher_id);

-- Process offline scans
SELECT process_offline_scans(teacher_id);
```

### Grading Functions
```sql
-- Calculate final grade
SELECT calculate_final_grade(course_id, student_id);

-- Get letter grade
SELECT get_letter_grade(percentage);
```

### Notification Functions
```sql
-- Create notification
SELECT create_notification(user_id, title, message, type, related_id);
```

## 📈 Performance Optimization

### Indexes
- User role and email indexes
- Course and enrollment indexes
- Attendance timestamp indexes
- Payment status indexes

### Views
- `student_dashboard_data` - Student summary
- `teacher_dashboard_data` - Teacher summary
- `parent_dashboard_data` - Parent summary

## 🧪 Testing

### Sample Queries

```sql
-- Get student dashboard data
SELECT * FROM student_dashboard_data WHERE student_id = 'user_id';

-- Get teacher earnings
SELECT * FROM teacher_dashboard_data WHERE teacher_id = 'user_id';

-- Get parent notifications
SELECT * FROM notifications WHERE user_id = 'user_id' AND is_read = false;
```

## 🔄 Maintenance

### Regular Tasks
- Clean up old audit logs
- Process pending payments
- Sync offline attendance
- Send scheduled notifications

### Monitoring
- Check failed payments
- Monitor attendance anomalies
- Review consent logs
- Track system performance

## 📝 Notes

- All timestamps are in UTC
- Currency is stored as DECIMAL(10,2)
- UUIDs are used for all primary keys
- JSONB is used for flexible data storage
- Triggers maintain data consistency

## 🆘 Troubleshooting

### Common Issues
1. **RLS blocking queries**: Check user permissions
2. **Function errors**: Verify parameter types
3. **Trigger failures**: Check data constraints
4. **Performance issues**: Review indexes

### Support
- Check Supabase logs
- Review audit logs
- Test with sample data
- Contact development team
