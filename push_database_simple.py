#!/usr/bin/env python3
"""
Simple script to push database schema to Supabase
"""

import requests
import json

# Supabase configuration
SUPABASE_URL = "https://xkffzkwrcnbuzvgaxrgy.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhrZmZ6a3dyY25idXp2Z2F4cmd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzOTczNDMsImV4cCI6MjA3Mzk3MzM0M30.t9BGFXQy_MUdy6JUBQge_XsJ05GqpNekTvloEuM7jyo"

def test_connection():
    """Test connection to Supabase"""
    print("🔍 Testing connection to Supabase...")
    
    url = f"{SUPABASE_URL}/rest/v1/"
    headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}"
    }
    
    try:
        response = requests.get(url, headers=headers, timeout=10)
        if response.status_code == 200:
            print("✅ Connection successful!")
            return True
        else:
            print(f"❌ Connection failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Connection error: {e}")
        return False

def create_tables_via_api():
    """Create tables using Supabase REST API"""
    print("🏗️  Creating tables via REST API...")
    
    # Read the SQL file
    try:
        with open("database/setup_database.sql", "r", encoding="utf-8") as file:
            sql_content = file.read()
    except Exception as e:
        print(f"❌ Error reading SQL file: {e}")
        return False
    
    # Split into individual statements
    statements = [stmt.strip() for stmt in sql_content.split(';') if stmt.strip()]
    
    print(f"📊 Found {len(statements)} SQL statements")
    
    # Execute each statement
    success_count = 0
    
    for i, statement in enumerate(statements):
        if not statement or statement == ';':
            continue
            
        print(f"🔄 Executing statement {i+1}/{len(statements)}...")
        
        # Use Supabase's SQL execution endpoint
        url = f"{SUPABASE_URL}/rest/v1/rpc/exec_sql"
        headers = {
            "apikey": SUPABASE_ANON_KEY,
            "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "sql": statement
        }
        
        try:
            response = requests.post(url, headers=headers, json=payload, timeout=30)
            
            if response.status_code in [200, 201, 204]:
                print(f"✅ Statement {i+1} executed successfully")
                success_count += 1
            else:
                print(f"❌ Statement {i+1} failed: {response.status_code}")
                print(f"   Response: {response.text}")
                
        except Exception as e:
            print(f"❌ Error executing statement {i+1}: {e}")
    
    print(f"\n📈 Results: {success_count}/{len(statements)} statements executed successfully")
    return success_count > 0

def main():
    """Main function"""
    print("🚀 Private Classes App - Database Push")
    print("=" * 50)
    
    # Test connection
    if not test_connection():
        print("❌ Cannot connect to Supabase. Please check your configuration.")
        return
    
    # Create tables
    if create_tables_via_api():
        print("\n🎉 Database push completed!")
        print("\n🔍 Next steps:")
        print("1. Go to your Supabase dashboard")
        print("2. Check the 'Table Editor' to see your tables")
        print("3. Run this query to verify:")
        print("   SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';")
    else:
        print("\n❌ Database push failed!")
        print("💡 Try running the SQL manually in Supabase SQL Editor")

if __name__ == "__main__":
    main()

