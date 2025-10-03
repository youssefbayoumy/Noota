#!/usr/bin/env python3
"""
Push database schema to Supabase using REST API
"""

import requests
import json
import os
from pathlib import Path

# Supabase configuration
SUPABASE_URL = "https://xkffzkwrcnbuzvgaxrgy.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhrZmZ6a3dyY25idXp2Z2F4cmd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzOTczNDMsImV4cCI6MjA3Mzk3MzM0M30.t9BGFXQy_MUdy6JUBQge_XsJ05GqpNekTvloEuM7jyo"

def read_sql_file(file_path):
    """Read SQL file content"""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return file.read()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None

def execute_sql_via_api(sql_content):
    """Execute SQL via Supabase REST API"""
    url = f"{SUPABASE_URL}/rest/v1/rpc/exec_sql"
    
    headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal"
    }
    
    # Split SQL into smaller chunks to avoid timeout
    sql_chunks = sql_content.split(';')
    sql_chunks = [chunk.strip() + ';' for chunk in sql_chunks if chunk.strip()]
    
    results = []
    
    for i, chunk in enumerate(sql_chunks):
        if not chunk.strip() or chunk.strip() == ';':
            continue
            
        print(f"Executing chunk {i+1}/{len(sql_chunks)}...")
        
        payload = {
            "sql": chunk
        }
        
        try:
            response = requests.post(url, headers=headers, json=payload, timeout=30)
            
            if response.status_code == 200:
                print(f"✅ Chunk {i+1} executed successfully")
                results.append(True)
            else:
                print(f"❌ Chunk {i+1} failed: {response.status_code} - {response.text}")
                results.append(False)
                
        except Exception as e:
            print(f"❌ Error executing chunk {i+1}: {e}")
            results.append(False)
    
    return results

def main():
    """Main function to push database schema"""
    print("🚀 Starting database push to Supabase...")
    print(f"📡 Target: {SUPABASE_URL}")
    
    # Read the complete database setup file
    setup_file = Path("database/setup_database.sql")
    
    if not setup_file.exists():
        print("❌ setup_database.sql not found!")
        return
    
    print("📖 Reading database schema...")
    sql_content = read_sql_file(setup_file)
    
    if not sql_content:
        print("❌ Failed to read SQL file!")
        return
    
    print(f"📊 SQL file size: {len(sql_content)} characters")
    print("🔄 Executing SQL commands...")
    
    # Execute SQL
    results = execute_sql_via_api(sql_content)
    
    # Summary
    successful = sum(results)
    total = len(results)
    
    print(f"\n📈 Execution Summary:")
    print(f"✅ Successful: {successful}/{total}")
    print(f"❌ Failed: {total - successful}/{total}")
    
    if successful == total:
        print("🎉 Database schema pushed successfully!")
        print("\n🔍 Verify by running this query in Supabase SQL Editor:")
        print("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;")
    else:
        print("⚠️  Some commands failed. Check the output above for details.")
        print("💡 You may need to run the SQL manually in Supabase SQL Editor.")

if __name__ == "__main__":
    main()

