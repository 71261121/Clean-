#!/usr/bin/env python3
"""
JARVIS v11 Database Fix for Termux
Termux में database connection की समस्या को fix करता है
"""

import os
import sys
import sqlite3
import logging
from pathlib import Path

def fix_jarvis_database():
    """JARVIS database को properly setup करता है"""
    
    print("🔧 JARVIS v11 Database Fix for Termux")
    print("=" * 50)
    
    # JARVIS directory में जाएं
    jarvis_dir = Path("jarvis_clean")
    if not jarvis_dir.exists():
        print("❌ jarvis_clean directory नहीं मिली!")
        print("कृपया पहले JARVAS को extract करें:")
        print("unzip jarvis_v11_clean.zip")
        return False
    
    os.chdir(jarvis_dir)
    print(f"📁 Working directory: {os.getcwd()}")
    
    # Logs directory बनाएं
    logs_dir = Path("logs")
    logs_dir.mkdir(exist_ok=True)
    
    # Database file path
    db_path = logs_dir / "jarvis.db"
    
    try:
        print("🗄️  Creating/Fixing database...")
        
        # Database connection बनाएं
        conn = sqlite3.connect(str(db_path))
        cursor = conn.cursor()
        
        # Command history table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS command_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp REAL,
                command TEXT,
                success BOOLEAN,
                execution_time REAL,
                output TEXT,
                error_message TEXT,
                danger_level INTEGER,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # System logs table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS system_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp REAL,
                level TEXT,
                component TEXT,
                message TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Settings table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS settings (
                key TEXT PRIMARY KEY,
                value TEXT,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Plugins table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS plugins (
                name TEXT PRIMARY KEY,
                version TEXT,
                enabled BOOLEAN,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Default settings insert करें
        default_settings = [
            ("voice_enabled", "true"),
            ("auto_start", "false"),
            ("log_level", "INFO"),
            ("theme", "default"),
            ("language", "en")
        ]
        
        for key, value in default_settings:
            cursor.execute("""
                INSERT OR IGNORE INTO settings (key, value) 
                VALUES (?, ?)
            """, (key, value))
        
        conn.commit()
        conn.close()
        
        print("✅ Database successfully created/fixed!")
        print(f"📊 Database location: {db_path}")
        
        # Database permissions check करें
        if os.access(db_path, os.R_OK | os.W_OK):
            print("✅ Database permissions: READ/WRITE OK")
        else:
            print("⚠️  Database permissions issue!")
            
        return True
        
    except Exception as e:
        print(f"❌ Database fix failed: {str(e)}")
        return False

def test_database_connection():
    """Database connection test करता है"""
    
    print("\n🧪 Testing database connection...")
    
    try:
        db_path = Path("logs/jarvis.db")
        conn = sqlite3.connect(str(db_path))
        cursor = conn.cursor()
        
        # Test query
        cursor.execute("SELECT COUNT(*) FROM command_history")
        count = cursor.fetchone()[0]
        
        conn.close()
        
        print(f"✅ Database connection test passed! ({count} records)")
        return True
        
    except Exception as e:
        print(f"❌ Database connection test failed: {str(e)}")
        return False

def fix_permissions():
    """File permissions को fix करता है"""
    
    print("\n🔒 Fixing file permissions...")
    
    try:
        # JARVIS files को executable बनाएं
        for file_path in Path(".").glob("*.py"):
            file_path.chmod(0o755)
            
        print("✅ File permissions fixed!")
        return True
        
    except Exception as e:
        print(f"❌ Permission fix failed: {str(e)}")
        return False

def main():
    """Main function"""
    
    print("🤖 JARVIS v11 Termux Database Fixer")
    print("=" * 40)
    
    # Check Python version
    print(f"🐍 Python version: {sys.version}")
    
    # Fix database
    db_success = fix_jarvis_database()
    
    # Test connection
    if db_success:
        test_database_connection()
    
    # Fix permissions
    fix_permissions()
    
    print("\n🎯 Next Steps:")
    print("1. Run: python jarvis.py")
    print("2. JARVIS should start without database errors")
    print("3. Type 'help' to see available commands")
    
    if db_success:
        print("\n✅ Database fix completed successfully!")
        print("🚀 JARVIS अब ready है!")
    else:
        print("\n❌ Database fix failed!")
        print("कृपया dependencies install करें: pip install aiosqlite")

if __name__ == "__main__":
    main()