#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#      TERMUX DESKTOP: MINIMAL INSTALLER
# ==========================================
#  Features: Core XFCE Only + Audio + VNC
#  No plugins, no extras, no bloat.
# ==========================================

# --- UI Colors ---
R='\033[0;31m'   # Red
G='\033[0;32m'   # Green
C='\033[0;36m'   # Cyan
Y='\033[1;33m'   # Yellow
B='\033[1;34m'   # Blue
W='\033[0m'      # Reset

# --- Helper Functions ---
check_status() {
    if [ $? -ne 0 ]; then
        echo -e "${R}✖ [ERROR] Step failed: $1${W}"
        # We don't exit here because Nala might throw errors 
        # even if the fallback succeeded. We let the user decide.
        echo -e "${Y}  (If Nala said 'Falling back', this might be fine.)${W}"
        sleep 3
    fi
}

print_step() {
    echo -e "\n${B}┌─────────────────────────────────────────────┐${W}"
    echo -e "${B}│ STEP $1: $2 ${W}"
    echo -e "${B}└─────────────────────────────────────────────┘${W}"
}

# --- BANNER ---
clear
echo -e "${C}╔═════════════════════════════════════════════╗${W}"
echo -e "${C}║      TERMUX DESKTOP MINIMAL INSTALLER       ║${W}"
echo -e "${C}║       Core XFCE4 • VNC • SSH • Audio        ║${W}"
echo -e "${C}╚═════════════════════════════════════════════╝${W}"
echo ""
echo -e "This script installs ONLY the essentials:"
echo -e "  1. XFCE4 Core (No Goodies/Plugins)"
echo -e "  2. TigerVNC & OpenSSH"
echo -e "  3. PulseAudio & Pavucontrol"
echo -e "  4. XFCE4 Terminal"
echo ""
read -p "Type 'y' to start: " yn
if [[ $yn != [yY]* ]]; then exit; fi

# ==========================================================
# PHASE 1: SYSTEM PREP & NALA
# ==========================================================
print_step "1/4" "System Preparation"

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

# 3. Create Aliases
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
# PHASE 2: INSTALLATION (Essentials Only)
# ==========================================================
print_step "2/4" "Installing Packages"

# Standard minimal packages
PACKAGES="xfce4 tigervnc openssh pulseaudio pavucontrol xfce4-terminal"

echo -e "${B}[*] Downloading Core Components...${W}"
echo -e "${Y}(Nala will show progress details below)${W}"

# Attempt install. If it fails due to network, we run dpkg --configure -a to fix partials
nala install $PACKAGES -y
if [ $? -ne 0 ]; then
    echo -e "${Y}[!] Nala reported an error. Attempting to fix broken packages...${W}"
    dpkg --configure -a
    pkg install $PACKAGES -y
fi

# ==========================================================
# PHASE 3: CONFIGURATION
# ==========================================================
print_step "3/4" "Configuration"

# 1. Setup VNC xstartup
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
    echo -e "${G}✔ SSH Keys generated.${W}"
fi

# ==========================================================
# PHASE 4: CREATE LAUNCHERS
# ==========================================================
print_step "4/4" "Creating Launchers (sd & sdl)"

# --- LAUNCHER 1: sd (Standard Quality) ---
cat > "$PREFIX/bin/sd" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
set -e
# Cleanup
vncserver -kill :1 > /dev/null 2>&1 || true
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1
# SSH
sshd > /dev/null 2>&1 || true

# Enable Compositor
export DISPLAY=:1
xfconf-query -c xfwm4 -p /general/use_compositing -s true > /dev/null 2>&1 || true

# Start VNC (High Quality - 24 bit)
echo "Starting Standard Desktop..."
vncserver :1 -geometry 1280x720 -depth 24 -name "Termux XFCE" > /dev/null 2>&1

# Get IP (Suppressing /proc permission errors)
IP=\$(ifconfig 2>/dev/null | grep -A 1 "wlan0" | grep "inet" | awk '{print \$2}')
if [ -z "\$IP" ]; then IP="127.0.0.1"; fi

clear
echo -e "\033[1;36m╔═══════════════════════════════════════════╗\033[0m"
echo -e "\033[1;36m║      STANDARD DESKTOP (High Quality)      ║\033[0m"
echo -e "\033[1;36m╚═══════════════════════════════════════════╝\033[0m"
echo -e " \033[1;32m● ONLINE: \033[1;33m\$IP:5901\033[0m"
echo ""
EOF
chmod +x "$PREFIX/bin/sd"

# --- LAUNCHER 2: sdl (Lite/Speed) ---
cat > "$PREFIX/bin/sdl" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
set -e
# Cleanup
vncserver -kill :1 > /dev/null 2>&1 || true
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1
sshd > /dev/null 2>&1 || true

# Start VNC (Low Color Depth for Speed - 16 bit)
echo "Starting Lite Desktop (Performance Mode)..."
vncserver :1 -geometry 1280x720 -depth 16 -name "Termux XFCE Lite" > /dev/null 2>&1

# Disable Visual Effects
export DISPLAY=:1
sleep 2
xfconf-query -c xfwm4 -p /general/use_compositing -s false > /dev/null 2>&1 || true
# Enable Wireframe Dragging (Speed)
xfconf-query -c xfwm4 -p /general/box_move -s true > /dev/null 2>&1 || true

WIFI_IP=\$(ifconfig 2>/dev/null | grep -A 1 "wlan0" | grep "inet" | awk '{print \$2}')
USB_IP=\$(ifconfig 2>/dev/null | grep -A 1 "rndis0" | grep "inet" | awk '{print \$2}')
[ -z "\$WIFI_IP" ] && WIFI_IP="No Wi-Fi"
[ -z "\$USB_IP" ] && USB_IP="No USB"

clear
echo -e "\033[1;33m╔═══════════════════════════════════════════╗\033[0m"
echo -e "\033[1;33m║       LITE DESKTOP (High Speed)           ║\033[0m"
echo -e "\033[1;33m╚═══════════════════════════════════════════╝\033[0m"
echo -e " \033[1;32m● WIFI: \033[1;33m\$WIFI_IP:5901\033[0m"
echo -e " \033[1;32m● USB:  \033[1;33m\$USB_IP:5901 (Fastest)\033[0m"
echo ""
EOF
chmod +x "$PREFIX/bin/sdl"

# ==========================================================
# FINAL SUMMARY
# ==========================================================
clear
# Fixed Syntax Error Here and added 2>/dev/null to hide warnings
FINAL_IP=$(ifconfig 2>/dev/null | grep -A 1 "wlan0" | grep "inet" | awk '{print $2}')
if [ -z "$FINAL_IP" ]; then FINAL_IP="Check Wi-Fi"; fi

echo -e "${C}╔═════════════════════════════════════════════╗${W}"
echo -e "${C}║           INSTALLATION COMPLETE!            ║${W}"
echo -e "${C}╚═════════════════════════════════════════════╝${W}"
echo ""
echo -e "${Y}CRITICAL STEP: SET PASSWORDS${W}"
if [ ! -f "$HOME/.vnc/passwd" ]; then
    echo -e "1. Set VNC Password now:  ${B}vncpasswd${W}"
else
    echo -e "1. VNC Password:          [Set]"
fi
echo -e "2. Set User Password:     ${B}passwd${W}"
echo ""
echo -e "${Y}HOW TO START:${W}"
echo -e "  Type ${G}sd${W}  -> Standard Mode"
echo -e "  Type ${Y}sdl${W} -> Speed Mode"
echo ""
echo -e "${Y}YOUR IP ADDRESS:${W} ${G}$FINAL_IP${W}"
echo ""
