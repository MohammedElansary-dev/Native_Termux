
# Termux XFCE Desktop Installer

A fast, minimal, and automated script to install a full-featured XFCE4 desktop environment on your Android device using Termux. This script sets up everything you need for a functional remote desktop, including VNC, SSH, and a working audio fix.

<img width="498" height="283" alt="Screenshot_20260107-225743" src="https://github.com/user-attachments/assets/eb4cbc70-53cd-4edd-b4b5-38d0a955f8c2" />

## Features

-   **Minimal & Fast:** Installs only the core XFCE4 components.
-   **Nala Package Manager:** Uses `nala` for a faster, more user-friendly installation with clear progress and dependency resolution.
-   **VNC Server Ready:** Automatically configures TigerVNC for remote desktop access.
-   **SSH Server Ready:** Installs and configures OpenSSH for secure terminal access.
-   **Audio Out-of-the-Box:** Implements the standard PulseAudio over TCP fix, allowing desktop audio to play through your phone's speakers.
-   **Dual Launch Modes:**
    -   `sd` (Standard Desktop): Launches in full 24-bit color with visual effects.
    -   `sdl` (Lite Desktop): Launches in 16-bit color with effects disabled for maximum performance and low latency.
-   **User-Friendly Dashboard:** The launch scripts provide a clean dashboard showing your IP address and connection details.

## Prerequisites

1.  **Termux from F-Droid:** The Google Play Store version of Termux is obsolete and **will not work**. You must install Termux from [F-Droid](https://f-droid.org/en/packages/com.termux/).
2.  **Android Device:** Works on most modern Android devices.
3.  **Wi-Fi Connection:** Required for downloading packages.
4. **Disable** Phantom Process Killer (can work without it but you will see random crashes)

## Installation

Open Termux and run these commands one by one.

1.  **Update Termux:**
    ```bash
    pkg update && pkg upgrade -y
    ```

2.  **Install Git:**
    ```bash
    pkg install git -y
    ```

3.  **Clone this Repository:**
    ```bash
    git clone https://github.com/MohammedElansary-dev/Native_Termux
    ```

4.  **Navigate to the Directory:**
    ```bash
    cd Native_Termux
    ```

5.  **Run the Installer:**
    ```bash
    bash native_termux_install.sh
    ```

The script will guide you through the installation process.

## Post-Installation: CRITICAL FIRST STEPS

After the script finishes, you **must** set your passwords.

1.  **Set VNC Password (for Desktop Access):**
    ```bash
    vncpasswd
    ```
    *(Enter a password. When asked about a "view-only password", type `n` and press Enter.)*

2.  **Set User Password (for SSH Access):**
    ```bash
    passwd
    ```
    *(Enter a password for your user account.)*

3. **Run XFCE4_CLEANUP.sh script**
```bash
bash XFCE4_CLEANUP.sh
```

## How to Use

### Starting the Desktop

You have two options to start your desktop environment:

-   **Standard Mode (High Quality):**
    ```bash
    sd
    ```
-   **Lite Mode (High Speed / Low Latency):**
    ```bash
    sdl
    ```
After running either command, a dashboard will appear showing your phone's IP address.

### Connecting via VNC (Remote Desktop)

1.  Download a VNC Viewer on your PC or another device. (Recommended: [TigerVNC](https://github.com/TigerVNC/tigervnc/releases), RealVNC).
2.  Create a new connection.
3.  **Address:** Enter the IP address shown in the Termux dashboard, followed by `:5901`.
    -   Example: `192.168.1.10:5901`
4.  Connect and enter the password you set with `vncpasswd`.
5. for best performance on TigerVNC use these settings

<img width="576" height="442" alt="Screenshot 2026-01-07 230528" src="https://github.com/user-attachments/assets/d3da0e39-5df1-4fa9-9733-4d8f052db2da" />


### Connecting via SSH (Remote Terminal)

1.  Find your username by typing `whoami` in Termux.
2.  On your PC, open a terminal (PowerShell, CMD, or Linux/Mac Terminal).
3.  Use the following command, replacing the username and IP:
    ```bash
    ssh -p 8022 your_username@your_phone_ip
    ```
    -   Example: `ssh -p 8022 u0_a123@192.168.1.10`
4.  Enter the password you set with `passwd`.

## Troubleshooting

### Random Crashes or "Signal 9" Error

If your desktop closes randomly, it is because of Android's **Phantom Process Killer**, a feature in Android 12+ that aggressively terminates background apps.

**To fix this permanently, you must run this command from a PC using ADB:**

1.  Enable "USB Debugging" in your phone's Developer Options.
2.  Connect your phone to your PC.
3.  Run this command on your PC:
    ```bash
    adb shell device_config put activity_manager max_phantom_processes 2147483647
    ```

This command only needs to be run once.

### Slow Performance / Lag

-   Use the **`sdl`** (Lite) command to launch the desktop. It's significantly faster.
-   For the lowest possible latency, connect your phone to your PC with a **USB cable** and enable **USB Tethering**. The `sdl` dashboard will show you the USB IP address to connect to.

