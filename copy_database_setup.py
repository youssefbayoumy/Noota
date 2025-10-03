#!/usr/bin/env python3
"""
Script to copy database setup content to clipboard
Run this script to copy the database setup SQL to your clipboard
"""

import pyperclip
import os

def copy_database_setup():
    """Copy the database setup SQL to clipboard"""
    
    # Read the setup_database.sql file
    try:
        with open('database/setup_database.sql', 'r', encoding='utf-8') as file:
            content = file.read()
        
        # Copy to clipboard
        pyperclip.copy(content)
        print("✅ Database setup SQL copied to clipboard!")
        print("📋 You can now paste it directly into your Supabase SQL Editor")
        print("\n📝 Next steps:")
        print("1. Go to https://supabase.com/dashboard")
        print("2. Select your project: xkffzkwrcnbuzvgaxrgy")
        print("3. Click 'SQL Editor' in the left sidebar")
        print("4. Click 'New Query'")
        print("5. Paste the content (Ctrl+V)")
        print("6. Click 'Run' to execute the SQL")
        
    except FileNotFoundError:
        print("❌ Error: database/setup_database.sql file not found")
        print("Make sure you're running this script from the project root directory")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    copy_database_setup()

