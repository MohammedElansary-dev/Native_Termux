# Ultimate Termux XFCE Desktop Installer

A fast, fully automated, and optimized script to install a full-featured XFCE4 desktop environment on your Android device using Termux.

This installer merges system setup, optimization, and tool installation into **one single script**. It sets up VNC, SSH, Audio, and useful utilities like a file server and smart extractor automatically.

## ✨ Features

-   **All-in-One Setup:** Installs XFCE4, VNC, Audio, and Tools in one go.
-   **Performance First:** The desktop launches in "Performance Mode" by default (16-bit color, no shadows, solid background) for maximum speed and low latency.
-   **Battery Monitor:** Includes a custom panel plugin to show Android battery percentage (requires Termux:API).
-   **Bloat-Free:** Automatically removes useless packages (screensavers, power managers) and hides broken menu icons.
-   **Smart Tools Included:**
    -   **File Sharing:** Host files over Wi-Fi with one command.
    -   **Smart Extract:** Extract any archive (`.zip`, `.tar`, `.rar`, etc.) without remembering flags.
    -   **Web Browsing:** Chromium and W3M installed.
-   **Audio Fix:** PulseAudio over TCP is configured automatically.

## 📋 Prerequisites

1.  **Termux (F-Droid):** The Play Store version is broken. Install from [F-Droid](https://f-droid.org/en/packages/com.termux/).
2.  **Termux:API App (F-Droid):** **Required** for the battery icon to work. Install it from [F-Droid](https://f-droid.org/en/packages/com.termux.api/).
3.  **Android Device:** Works on Android 8+.
4.  **Phantom Process Killer:** You **must disable** this feature on Android 12+, or the desktop will crash after 10-20 minutes (Instructions below).

## 🚀 Installation

Open Termux and run these commands:

1.  **Update Termux & Install Git:**
    ```bash
    pkg update && pkg upgrade -y
    pkg install git -y
    ```

2.  **Clone the Repository:**
    ```bash
    git clone https://github.com/MohammedElansary-dev/Native_Termux
    ```

3.  **Run the Installer:**
    ```bash
    cd Native_Termux
    bash setup_termux_desktop.sh
    ```

The script will handle everything: installing packages, setting up the panel, cleaning bloat, and configuring aliases.

---

## 🛠 Post-Installation Steps

After the script finishes, you **must** set your security credentials:

1.  **Set VNC Password (for Desktop Access):**
    ```bash
    vncpasswd
    ```
    *(Type a password. When asked for "view-only", type `n`.)*

2.  **Set User Password (for SSH Access):**
    ```bash
    passwd
    ```

---

## 🎮 How to Use

### 1. Start the Desktop
Simply type:
```bash
sd
```
This launches the **Standard Desktop (Performance Mode)**. It is optimized for speed (Wireframe dragging enabled, Compositor disabled).

### 2. Connect via VNC
1.  Open **TigerVNC** or **RealVNC** on your PC/Tablet.
2.  Connect to the **IP Address** shown in the terminal (e.g., `192.168.1.X:5901`).
3.  Use the password you set earlier.

### 3. Using the New Tools

#### 🔋 Battery Monitor
If you installed the **Termux:API** app on your phone, you will see a battery icon and percentage in the XFCE panel.
*   *Note:* If it says "0%" or missing, open the Termux:API app once to initialize permissions.

#### 📂 File Sharing (Localsend/Dufs)
Want to share files from your phone to other devices on the Wi-Fi?
Type:
```bash
localsend
```
Then open the IP address shown (e.g., `http://192.168.1.X:5000`) on any other device's browser to download/upload files.

#### 📦 Smart Extract
Don't remember the command to unzip a `.tar.gz` or `.7z`? Just use `x`:
```bash
x filename.zip
x archive.tar.gz
```
The script automatically detects the file type and runs the correct extraction command.

---

## ⚠️ Troubleshooting

### Random Crashes (Signal 9) / Phantom Process Killer
If the desktop crashes after ~10 minutes, it is Android 12+'s **Phantom Process Killer**.

**The Fix (Wireless - No PC needed):**
1.  Connect your phone to Wi-Fi.
2.  Install ADB: `pkg install android-tools -y`
3.  Go to **Developer Options** -> Enable **Wireless Debugging**.
4.  Select "Pair device with pairing code".
5.  In Termux: `adb pair IP:PORT` (Enter code).
6.  In Termux: `adb connect IP:PORT` (Use the port from the main menu, not pairing).
7.  **Run this command:**
    ```bash
    adb shell device_config put activity_manager max_phantom_processes 2147483647
    ```
    *(To verify, run: `adb shell device_config get activity_manager max_phantom_processes`. It should return `2147483647`).*

### VNC Black Screen / Connection Refused
-   Make sure you typed `sd` to start the server.
-   Ensure you are connecting to port **5901**.
-   If `sd` fails to start, run `vncserver -kill :1` and try again.

---

## 🖼 Recommended VNC Settings
For the best experience on TigerVNC:

<img width="576" height="442" alt="Screenshot 2026-01-07 230528" src="https://github.com/user-attachments/assets/d3da0e39-5df1-4fa9-9733-4d8f052db2da" />

