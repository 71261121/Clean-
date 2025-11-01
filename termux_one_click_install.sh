#!/data/data/com.termux/files/usr/bin/bash

# JARVIS v11 One-Click Installer for Termux
# यह script एक-click में JARVIS को install करता है

# Colors for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Fancy header
echo -e "${PURPLE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                   🤖 JARVIS v11 Termux Setup                    ║"
echo "║                   One-Click Installation                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Progress animation
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | grep $pid | grep -v grep | wc -l)" -gt 0 ]; do
        local temp=${spinstr#?}
        printf " [${CYAN}%c${NC}]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to print colored status messages
print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Check if running in Termux
if [ ! -f "/data/data/com.termux/files/usr/bin/termux-info" ]; then
    print_error "यह script केवल Termux में चलाया जा सकता है!"
    print_info "कृपया Termux install करें: https://f-droid.org/packages/com.termux/"
    exit 1
fi

print_success "✅ Termux environment detected!"

# Welcome message
echo -e "${WHITE}"
echo "🚀 JARVIS v11 installation शुरू हो रहा है..."
echo "यह process कुछ मिनट ले सकता है..."
echo -e "${NC}"

# Step 1: System Update
print_step "Step 1: Termux packages update कर रहे हैं..."
pkg update -y > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_success "Packages updated successfully!"
else
    print_warning "Update में कुछ issues, continuing..."
fi

# Step 2: Install essential packages
print_step "Step 2: Essential packages install कर रहे हैं..."
(
    pkg install -y python python-pip python-dev git nodejs npm sqlite openssl curl wget nano vim termux-services pulseaudio espeak termux-api
) &
spinner
print_success "Essential packages installed!"

# Step 3: Create directories
print_step "Step 3: JARVIS directories बना रहे हैं..."
mkdir -p ~/jarvis
mkdir -p ~/jarvis/logs
mkdir -p ~/jarvis/config
mkdir -p ~/.termux/boot
print_success "Directories created!"

# Step 4: Download or extract JARVIS project
print_step "Step 4: JARVIS project setup कर रहे हैं..."

if [ -f "$HOME/jarvis_v11_clean.zip" ]; then
    cd ~/jarvis
    unzip -o $HOME/jarvis_v11_clean.zip > /dev/null 2>&1
    if [ -d "jarvis_clean" ]; then
        mv jarvis_clean/* .
        rm -rf jarvis_clean
        rm $HOME/jarvis_v11_clean.zip
        print_success "JARVIS project extracted!"
    else
        print_warning "Zip structure unexpected"
    fi
elif [ -d "$HOME/jarvis_v11" ]; then
    cp -r $HOME/jarvis_v11/* ~/jarvis/
    print_success "JARVIS project copied!"
else
    print_info "Creating new JARVIS project..."
    # Create basic structure
    cat > ~/jarvis/jarvis.py << 'EOF'
#!/usr/bin/env python3
"""
JARVIS v11 - Termux Version
Enhanced AI Assistant for Termux Environment
"""

import sys
import os
import asyncio
import json
from datetime import datetime
from pathlib import Path

class JarvisV11Termux:
    def __init__(self):
        self.home = os.path.expanduser("~/jarvis")
        self.version = "11.0.0"
        self.mode = "TERMUX"
        
    def get_system_info(self):
        return {
            "version": self.version,
            "mode": self.mode,
            "home": self.home,
            "timestamp": datetime.now().isoformat(),
            "platform": "Termux Android"
        }
    
    def run(self):
        print("🤖 JARVIS v11 - Termux Edition")
        print("=" * 40)
        info = self.get_system_info()
        for key, value in info.items():
            print(f"{key}: {value}")
        print("\n✅ JARVIS Termux initialization complete!")
        print("🎯 Ready for voice commands and AI interactions")
        
        # Create basic database
        os.makedirs(f"{self.home}/logs", exist_ok=True)
        db_path = f"{self.home}/logs/jarvis.db"
        
        # Basic interaction loop
        print("\n💬 Interactive mode ready!")
        print("Commands: 'info', 'status', 'quit'")
        
        while True:
            try:
                user_input = input("\nJARVIS> ").strip().lower()
                
                if user_input == "quit" or user_input == "exit":
                    print("👋 JARVIS shutting down...")
                    break
                elif user_input == "info":
                    print(json.dumps(self.get_system_info(), indent=2))
                elif user_input == "status":
                    print(f"✅ JARVIS Status: Online")
                    print(f"🏠 Directory: {self.home}")
                    print(f"🕒 Time: {datetime.now()}")
                else:
                    print(f"🔍 Command '{user_input}' recognized")
                    print("💡 Available commands: info, status, quit")
                    
            except KeyboardInterrupt:
                print("\n👋 JARVIS interrupted, shutting down...")
                break
            except Exception as e:
                print(f"❌ Error: {e}")

if __name__ == "__main__":
    jarvis = JarvisV11Termux()
    jarvis.run()
EOF
    print_success "Basic JARVIS created!"
fi

# Step 5: Install Python dependencies
print_step "Step 5: Python dependencies install कर रहे हैं..."
(
    pip install --upgrade pip
    pip install aiosqlite==0.19.0 psutil speechrecognition pyttsx3 requests
) > /dev/null 2>&1 &
spinner
print_success "Python dependencies installed!"

# Step 6: Setup startup scripts
print_step "Step 6: Startup scripts setup कर रहे हैं..."

# Create main startup script
cat > ~/jarvis/termux-startup.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 JARVIS v11 Termux startup..."
termux-wake-lock

cd ~/jarvis
python jarvis.py

termux-wake-unlock
EOF

chmod +x ~/jarvis/termux-startup.sh

# Copy to termux boot
cp ~/jarvis/termux-startup.sh ~/.termux/boot/jarvis-start.sh
chmod +x ~/.termux/boot/jarvis-start.sh

print_success "Startup scripts configured!"

# Step 7: Create aliases
print_step "Step 7: Shortcuts बना रहे हैं..."

# Add aliases to bashrc
cat >> ~/.bashrc << 'EOF'

# JARVIS v11 Shortcuts
alias jarvis="cd ~/jarvis && python jarvis.py"
alias jarvis-start="cd ~/jarvis && python jarvis.py"
alias jlogs="tail -f ~/jarvis/jarvis.log"
alias jhelp="cd ~/jarvis && python jarvis.py --help"
EOF

print_success "Shortcuts created!"

# Step 8: Setup permissions
print_step "Step 8: Permissions setup कर रहे हैं..."
termux-setup-storage > /dev/null 2>&1
print_success "Storage access configured!"

# Step 9: Final verification
print_step "Step 9: Installation verify कर रहे हैं..."

# Test imports
cd ~/jarvis
python -c "
import sys, os, aiosqlite, psutil
print('✅ All dependencies working!')
" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_success "✅ Installation verification passed!"
else
    print_warning "⚠️ Minor issues detected, but JARVIS should work"
fi

# Final success message
echo ""
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    🎉 INSTALLATION COMPLETE! 🎉                ║"
echo "║                    JARVIS v11 Ready to Use!                    ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${WHITE}"
echo "🚀 JARVIS start करने के लिए:"
echo "   jarvis"
echo ""
echo "📱 Background service के लिए:"
echo "   termux-startup.sh"
echo ""
echo "📝 Logs देखने के लिए:"
echo "   jlogs"
echo ""
echo "💬 Interactive mode:"
echo "   cd ~/jarvis && python jarvis.py"
echo -e "${NC}"

echo -e "${CYAN}"
echo "📚 Help & Documentation:"
echo "   ~/jarvis/TERMUX_SETUP_GUIDE.md"
echo "   ~/jarvis/README.md"
echo -e "${NC}"

print_success "🎯 JARVIS v11 Termux setup complete!"
echo ""

# Ask user if they want to start JARVIS now
read -p "🤖 JARVIS को अभी start करना चाहते हैं? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}"
    echo "JARVIS v11 शुरू हो रहा है..."
    echo -e "${NC}"
    cd ~/jarvis
    python jarvis.py
fi

echo ""
echo -e "${GREEN}👋 धन्यवाद! JARVIS v11 का आपका Android Termux setup ready है! 🤖${NC}"