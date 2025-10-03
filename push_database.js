// Push database schema to Supabase using JavaScript
const fs = require('fs');
const { createClient } = require('@supabase/supabase-js');

// Supabase configuration
const supabaseUrl = 'https://xkffzkwrcnbuzvgaxrgy.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhrZmZ6a3dyY25idXp2Z2F4cmd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzOTczNDMsImV4cCI6MjA3Mzk3MzM0M30.t9BGFXQy_MUdy6JUBQge_XsJ05GqpNekTvloEuM7jyo';

// Create Supabase client
const supabase = createClient(supabaseUrl, supabaseKey);

async function pushDatabase() {
    console.log('🚀 Starting database push to Supabase...');
    
    try {
        // Read SQL file
        const sqlContent = fs.readFileSync('database/setup_database.sql', 'utf8');
        console.log(`📖 Read SQL file: ${sqlContent.length} characters`);
        
        // Split into statements
        const statements = sqlContent.split(';').filter(stmt => stmt.trim());
        console.log(`📊 Found ${statements.length} SQL statements`);
        
        // Execute each statement
        let successCount = 0;
        
        for (let i = 0; i < statements.length; i++) {
            const statement = statements[i].trim();
            if (!statement) continue;
            
            console.log(`🔄 Executing statement ${i + 1}/${statements.length}...`);
            
            try {
                // Use Supabase's SQL execution function
                const { data, error } = await supabase.rpc('exec_sql', {
                    sql: statement
                });
                
                if (error) {
                    console.log(`❌ Statement ${i + 1} failed:`, error.message);
                } else {
                    console.log(`✅ Statement ${i + 1} executed successfully`);
                    successCount++;
                }
            } catch (err) {
                console.log(`❌ Error executing statement ${i + 1}:`, err.message);
            }
        }
        
        console.log(`\n📈 Results: ${successCount}/${statements.length} statements executed successfully`);
        
        if (successCount > 0) {
            console.log('🎉 Database push completed!');
            console.log('\n🔍 Next steps:');
            console.log('1. Go to your Supabase dashboard');
            console.log('2. Check the Table Editor to see your tables');
            console.log('3. Run this query to verify:');
            console.log('   SELECT table_name FROM information_schema.tables WHERE table_schema = \'public\';');
        } else {
            console.log('❌ No statements executed successfully');
        }
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    }
}

// Run the function
pushDatabase();

