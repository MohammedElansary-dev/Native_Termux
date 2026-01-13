#!/data/data/com.termux/files/usr/bin/bash

# ====================================================
#   ULTIMATE TERMUX XFCE4 INSTALLER & OPTIMIZER
# ====================================================
#  Features:
#  1. Installs Core XFCE4 + VNC + Audio + Tools
#  2. Adds: Dufs, P7zip, W3M, Chromium, Termux-API
#  3. Auto-configures Battery Monitor Panel
#  4. Sets up "Localsend" and "Smart Extract" aliases
#  5. Removes Bloat & Optimizes for Performance
# ====================================================

# --- UI Colors ---
R='\033[0;31m'   # Red
G='\033[0;32m'   # Green
C='\033[0;36m'   # Cyan
Y='\033[1;33m'   # Yellow
B='\033[1;34m'   # Blue
W='\033[0m'      # Reset

# --- Helper Functions ---
print_step() {
    echo -e "\n${B}┌─────────────────────────────────────────────┐${W}"
    echo -e "${B}│ STEP $1: $2 ${W}"
    echo -e "${B}└─────────────────────────────────────────────┘${W}"
}

# --- BANNER ---
clear
echo -e "${C}╔═════════════════════════════════════════════╗${W}"
echo -e "${C}║     TERMUX ULTIMATE DESKTOP INSTALLER       ║${W}"
echo -e "${C}║   XFCE4 • Performance Mode • Batt Monitor   ║${W}"
echo -e "${C}╚═════════════════════════════════════════════╝${W}"
echo ""
echo -e "This script will install a fully optimized environment:"
echo -e "  • ${G}System:${W} XFCE4, TigerVNC, PulseAudio, OpenSSH"
echo -e "  • ${G}Tools:${W}  Chromium, Dufs, P7zip, W3M, Termux-API"
echo -e "  • ${Y}Tweaks:${W} Performance Mode (No Shadows), Bloat Removed"
echo -e "  • ${Y}Panel:${W}  Custom layout with Battery Monitor"
echo ""
read -p "Type 'y' to start installation: " yn
if [[ $yn != [yY]* ]]; then exit; fi

# ==========================================================
# PHASE 1: SYSTEM PREP & NALA
# ==========================================================
print_step "1/5" "System Preparation"

# 1. Setup Storage
if [ ! -d "$HOME/storage" ]; then
    echo "Requesting storage permission..."
    termux-setup-storage
    sleep 2
fi

# 2. Install Nala
if ! command -v nala &> /dev/null; then
    echo "Installing Nala..."
    pkg install nala -y
fi

# 3. Create Basic Aliases
if ! grep -q "alias pkg='nala'" "$HOME/.bashrc" 2>/dev/null; then
    echo "alias pkg='nala'" >> "$HOME/.bashrc"
    echo "alias apt='nala'" >> "$HOME/.bashrc"
fi

# 4. Update System
echo -e "${B}[*] Updating System via Nala...${W}"
nala update
nala upgrade -y

# 5. Enable X11 Repo
if ! dpkg -s x11-repo >/dev/null 2>&1; then
    echo -e "${B}[*] Enabling X11 Repo...${W}"
    nala install x11-repo -y
fi

# ==========================================================
# PHASE 2: INSTALLATION (Merged Package List)
# ==========================================================
print_step "2/5" "Installing Packages"

# Combined Package List
PACKAGES="xfce4 tigervnc openssh pulseaudio pavucontrol xfce4-terminal feh \
dufs p7zip w3m chromium termux-api xfce4-genmon-plugin jq"

echo -e "${B}[*] Downloading Components...${W}"
echo -e "${Y}(This includes Desktop, Browser, API tools, and Utils)${W}"

# Attempt install
nala install $PACKAGES -y
if [ $? -ne 0 ]; then
    echo -e "${Y}[!] Nala reported an error. Attempting to fix broken packages...${W}"
    dpkg --configure -a
    pkg install $PACKAGES -y
fi

# ==========================================================
# PHASE 3: CONFIGURATION (VNC, Audio, Aliases)
# ==========================================================
print_step "3/5" "Configuration"

# 1. Setup VNC xstartup (Audio Fix Included)
mkdir -p "$HOME/.vnc"
cat > "$HOME/.vnc/xstartup" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
## STARTUP SCRIPT

# 1. Audio Fix (TCP Mode)
pulseaudio --kill > /dev/null 2>&1
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

# 2. Start Desktop
xrdb "\$HOME/.Xresources"
startxfce4
EOF
chmod +x "$HOME/.vnc/xstartup"

# 2. Setup Pulse Config
mkdir -p "$HOME/.config/pulse"

# 3. SSH Keys
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    ssh-keygen -A > /dev/null 2>&1
fi

# 4. Add Advanced Aliases (Dufs & Smart Extract)
echo -e "${B}[*] Adding Smart Aliases (.bashrc)...${W}"

# Add Dufs alias if not present
if ! grep -q "alias localsend" "$HOME/.bashrc"; then
    echo "alias localsend='dufs -A -b 0.0.0.0 ~'" >> "$HOME/.bashrc"
fi

# Add Smart Extract Function
cat >> "$HOME/.bashrc" << 'EOF'

# Smart Extract Function
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1   ;;
            *.tar.gz)    tar xzf $1   ;;
            *.bz2)       bunzip2 $1   ;;
            *.rar)       7z x $1      ;;
            *.gz)        gunzip $1    ;;
            *.tar)       tar xf $1    ;;
            *.tbz2)      tar xjf $1   ;;
            *.tgz)       tar xzf $1   ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1;;
            *.7z)        7z x $1      ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
alias x='extract'
EOF

# ==========================================================
# PHASE 4: OPTIMIZATION & BATTERY MONITOR
# ==========================================================
print_step "4/5" "Optimizing & Customizing Panel"

# --- A. BLOAT REMOVAL ---
echo -e "${Y}[*] Removing bloatware (FileRoller, Screensaver)...${W}"
# We remove these to save space and resources
pkg remove file-roller xfce4-power-manager xfce4-screensaver tumbler -y > /dev/null 2>&1

# --- B. MENU CLEANUP ---
echo -e "${Y}[*] Hiding useless menu icons...${W}"
DIR="$HOME/.local/share/applications"
mkdir -p "$DIR"
# Hide VTE and Debian icons
for app in vte debian-uxterm debian-xterm; do
    echo "[Desktop Entry]
    Type=Application
    Name=HiddenApp
    NoDisplay=true" > "$DIR/$app.desktop"
done

# --- C. BATTERY MONITOR SETUP ---
echo -e "${B}[*] Configuring Battery Monitor Plugin...${W}"

# 1. Create the Battery Script
cat > "$PREFIX/bin/battery.sh" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
# Get battery info (requires Termux:API app)
BAT_DATA=\$(termux-battery-status)
PERC=\$(echo \$BAT_DATA | jq -r '.percentage')
STATUS=\$(echo \$BAT_DATA | jq -r '.status')

# Icons
if [[ "\$STATUS" == "CHARGING" || "\$STATUS" == "FULL" ]]; then
    ICON="⚡"
else
    ICON="🔋"
fi

# Output for GenMon
echo "<txt>\${ICON} \${PERC}%</txt>"
echo "<tool>Status: \${STATUS}</tool>"
EOF
chmod +x "$PREFIX/bin/battery.sh"

# 2. Overwrite Panel Configuration (XML)
# This forces the panel to load: Menu, Tasklist, Separator, BATTERY, Clock
mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"

cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="32"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/> <!-- Menu -->
        <value type="int" value="2"/> <!-- Tasklist -->
        <value type="int" value="3"/> <!-- Separator -->
        <value type="int" value="4"/> <!-- BATTERY -->
        <value type="int" value="5"/> <!-- Clock -->
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="applicationsmenu"/>
    <property name="plugin-2" type="string" value="tasklist">
      <property name="grouping" type="bool" value="true"/>
    </property>
    <property name="plugin-3" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-4" type="string" value="genmon">
      <property name="command" type="string" value="battery.sh"/>
      <property name="use-label" type="bool" value="false"/>
      <property name="interval" type="int" value="60000"/>
      <property name="font" type="string" value="Sans Bold 10"/>
    </property>
    <property name="plugin-5" type="string" value="clock"/>
  </property>
</channel>
EOF

# ==========================================================
# PHASE 5: CREATE LAUNCHER (Performance Mode)
# ==========================================================
print_step "5/5" "Creating Launcher (sd)"

# Creating 'sd' but with 'sdl' (Lite) logic as requested
cat > "$PREFIX/bin/sd" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
set -e
# Cleanup previous sessions
vncserver -kill :1 > /dev/null 2>&1 || true
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1
sshd > /dev/null 2>&1 || true

# Start VNC (16-bit Depth for Speed)
echo "Starting Optimized Desktop..."
vncserver :1 -geometry 1280x720 -depth 16 -name "Termux XFCE" > /dev/null 2>&1

# Apply Performance Settings (No Compositor, Wireframe Drag)
export DISPLAY=:1
sleep 2
xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s false > /dev/null 2>&1
xfconf-query -c xfwm4 -p /general/use_compositing -s false > /dev/null 2>&1
xfconf-query -c xfwm4 -p /general/box_move -n -t bool -s true > /dev/null 2>&1
xfconf-query -c xfwm4 -p /general/box_move -s true > /dev/null 2>&1

# Solid Background (Saves RAM)
for i in \$(xfconf-query -c xfce4-desktop -l | grep "last-image"); do
    xfconf-query -c xfce4-desktop -p "\$i" -s "" 2>/dev/null
done

# Get IP
WIFI_IP=\$(ifconfig 2>/dev/null | grep -A 1 "wlan0" | grep "inet" | awk '{print \$2}')
[ -z "\$WIFI_IP" ] && WIFI_IP="127.0.0.1"

clear
echo -e "\033[1;36m╔═══════════════════════════════════════════╗\033[0m"
echo -e "\033[1;36m║      TERMUX DESKTOP (Performance Mode)    ║\033[0m"
echo -e "\033[1;36m╚═══════════════════════════════════════════╝\033[0m"
echo -e " \033[1;32m● Connect at: \033[1;33m\$WIFI_IP:5901\033[0m"
echo ""
EOF
chmod +x "$PREFIX/bin/sd"

# ==========================================================
# FINAL SUMMARY
# ==========================================================
source "$HOME/.bashrc"
clear
FINAL_IP=$(ifconfig 2>/dev/null | grep -A 1 "wlan0" | grep "inet" | awk '{print $2}')
[ -z "$FINAL_IP" ] && FINAL_IP="Check Wi-Fi"

echo -e "${C}╔═════════════════════════════════════════════╗${W}"
echo -e "${C}║           INSTALLATION COMPLETE!            ║${W}"
echo -e "${C}╚═════════════════════════════════════════════╝${W}"
echo ""
echo -e "${Y}IMPORTANT STEPS:${W}"
if [ ! -f "$HOME/.vnc/passwd" ]; then
    echo -e "1. Set VNC Password:      ${B}vncpasswd${W}"
else
    echo -e "1. VNC Password:          [Set]"
fi
echo -e "2. Set User Password:     ${B}passwd${W}"
echo ""
echo -e "${Y}BATTERY ICON REQUIREMENT:${W}"
echo -e "   You MUST install the app ${G}'Termux:API'${W} from"
echo -e "   F-Droid or Play Store for the battery icon to work."
echo ""
echo -e "${Y}NEW COMMANDS:${W}"
echo -e "  Type ${G}sd${W}         -> Start Desktop (Performance Mode)"
echo -e "  Type ${G}x file.zip${W} -> Extract any archive"
echo -e "  Type ${G}localsend${W}  -> Share files over Wi-Fi"
echo ""
echo -e "${Y}YOUR IP:${W} ${G}$FINAL_IP${W}"
echo ""