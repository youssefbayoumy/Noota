# 🚀 Database Setup Guide for Supabase

Follow these steps to set up your Private Classes App database in Supabase.

## Step 1: Access Supabase Dashboard

1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Sign in to your account
3. Select your project: `xkffzkwrcnbuzvgaxrgy`

## Step 2: Open SQL Editor

1. In your Supabase dashboard, click on **"SQL Editor"** in the left sidebar
2. Click **"New Query"** to create a new SQL query

## Step 3: Run the Database Setup

### Option A: Quick Setup (Recommended)
Copy and paste the entire contents of `database/setup_database.sql` into the SQL Editor and run it.

### Option B: Step-by-Step Setup
Run each file in order:

1. **First, run `01_create_tables.sql`**
2. **Then, run `02_create_functions.sql`**
3. **Next, run `03_create_policies.sql`**
4. **Finally, run `04_sample_data.sql`** (optional, for testing)

## Step 4: Verify Setup

Run this query to check if all tables were created:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

You should see these tables:
- profiles
- parent_child_relationships
- course_templates
- courses
- course_enrollments
- sessions
- session_bookings
- attendance_records
- offline_scan_queue
- assessments
- student_grades
- grade_edit_history
- payment_transactions
- teacher_payouts
- course_reviews
- teacher_reviews
- notifications
- consent_logs
- disputes
- audit_logs

## Step 5: Test RLS Policies

Run this query to verify Row Level Security is enabled:

```sql
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = true;
```

## Step 6: Test Your Flutter App

1. Make sure your Supabase configuration is correct in `lib/config/supabase_config.dart`
2. Run your Flutter app:
   ```bash
   flutter run -d web
   ```
3. Try to sign up with a new account
4. Check if the profile is created in the `profiles` table

## Troubleshooting

### If you get permission errors:
- Make sure you're logged in as the project owner
- Check that your Supabase project is active

### If tables don't appear:
- Check the SQL Editor for any error messages
- Make sure you ran the files in the correct order
- Try running the setup again

### If RLS policies don't work:
- Verify that RLS is enabled on all tables
- Check that the policies were created successfully
- Test with a sample user account

## Next Steps

After successful setup:

1. **Test Authentication**: Try signing up with different user roles
2. **Test Data Access**: Verify that users can only see their own data
3. **Add Sample Data**: Use the sample data file to populate test data
4. **Configure Email**: Set up email templates for authentication
5. **Set up Storage**: Configure file storage for avatars and course materials

## Support

If you encounter any issues:
1. Check the Supabase logs in your dashboard
2. Review the error messages in the SQL Editor
3. Verify your Supabase project settings
4. Contact the development team

---

**Note**: This database schema is designed for the Egyptian private education market with full compliance for parental consent and data protection.

