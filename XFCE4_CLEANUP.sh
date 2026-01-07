#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#      XFCE4 PERFORMANCE & CLEANUP TOOL
# ==========================================

# Colors
R='\033[0;31m'
G='\033[0;32m'
C='\033[0;36m'
Y='\033[1;33m'
W='\033[0m'

clear
echo -e "${C}========================================${W}"
echo -e "${C}      XFCE4 OPTIMIZER FOR TERMUX        ${W}"
echo -e "${C}========================================${W}"
echo -e "Select an option:"
echo -e "  1. ${G}Full Optimization${W} (Graphics + Bloat + Menu Fix)"
echo -e "  2. ${Y}Graphics Only${W} (Fix VNC Lag/Shadows)"
echo -e "  3. ${Y}Bloat Only${W} (Remove FileRoller/VTE icons)"
echo ""
read -p "Enter choice [1-3]: " choice

# --- FUNCTION: GRAPHICS ---
optimize_graphics() {
    echo -e "\n${C}[*] Optimizing Graphics for VNC...${W}"

    # 1. Disable Compositor (Removes Shadows & Transparency)
    echo -e "  - Disabling Compositor..."
    xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s false 2>/dev/null
    xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null

    # 2. Wireframe Dragging (Reduces lag when moving windows)
    echo -e "  - Enabling Wireframe Dragging..."
    xfconf-query -c xfwm4 -p /general/box_move -n -t bool -s true 2>/dev/null
    xfconf-query -c xfwm4 -p /general/box_move -s true 2>/dev/null
    xfconf-query -c xfwm4 -p /general/box_resize -n -t bool -s true 2>/dev/null
    xfconf-query -c xfwm4 -p /general/box_resize -s true 2>/dev/null

    # 3. Solid Background (Removes Wallpaper image)
    echo -e "  - Setting Solid Background..."
    # Clear image
    for i in $(xfconf-query -c xfce4-desktop -l | grep "last-image"); do
        xfconf-query -c xfce4-desktop -p "$i" -s "" 2>/dev/null
    done
    # Set style to Solid Color (0)
    for i in $(xfconf-query -c xfce4-desktop -l | grep "image-style"); do
        xfconf-query -c xfce4-desktop -p "$i" -s 0 2>/dev/null
    done
    # Set Color to Teal/Grey
    for i in $(xfconf-query -c xfce4-desktop -l | grep "rgba1"); do
        xfconf-query -c xfce4-desktop -p "$i" -n -t double -t double -t double -t double -s 0.2 -s 0.3 -s 0.4 -s 1.0 2>/dev/null
    done
}

# --- FUNCTION: BLOAT REMOVAL ---
remove_bloat() {
    echo -e "\n${C}[*] Removing Bloatware...${W}"

    # 1. Remove File Roller (Archive Manager)
    if dpkg -s file-roller >/dev/null 2>&1; then
        echo -e "${Y}  - Removing File Roller...${W}"
        pkg remove file-roller -y > /dev/null 2>&1
    fi

    # 2. Remove Power Manager & Screensaver
    echo -e "${Y}  - Removing Power Manager & Screensaver...${W}"
    pkg remove xfce4-power-manager xfce4-screensaver -y > /dev/null 2>&1

    # 3. Remove Tumbler (Thumbnail Generator)
    echo -e "${Y}  - Removing Thumbnailer (Tumbler)...${W}"
    pkg remove tumbler -y > /dev/null 2>&1
}

# --- FUNCTION: MENU CLEANUP ---
fix_menus() {
    echo -e "\n${C}[*] Cleaning App Menu...${W}"

    # We cannot uninstall 'libvte' because xfce4-terminal needs it.
    # Instead, we HIDE the 'VTE' icons from the menu.
    
    DIR="$HOME/.local/share/applications"
    mkdir -p "$DIR"

    # Hide VTE Test App
    echo -e "${G}  - Hiding VTE Test apps...${W}"
    echo "[Desktop Entry]
    Type=Application
    Name=VTE
    NoDisplay=true" > "$DIR/vte.desktop"

    # Hide other common useless icons if they exist
    echo "[Desktop Entry]
    Type=Application
    Name=Debian
    NoDisplay=true" > "$DIR/debian-uxterm.desktop"
    
    echo "[Desktop Entry]
    Type=Application
    Name=XTerm
    NoDisplay=true" > "$DIR/debian-xterm.desktop"
}

# --- EXECUTION LOGIC ---
case $choice in
    1)
        optimize_graphics
        remove_bloat
        fix_menus
        ;;
    2)
        optimize_graphics
        ;;
    3)
        remove_bloat
        fix_menus
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

echo -e "\n${G}✔ OPTIMIZATION COMPLETE.${W}"
echo -e "Restart your desktop (vncserver -kill :1) to see changes."
