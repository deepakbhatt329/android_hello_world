#!/usr/bin/env bash
set -e

APT_PACKAGES="wget unzip curl openjdk-17-jdk \
  tigervnc-standalone-server tigervnc-common \
  novnc websockify supervisor \
  libgl1-mesa-dev libxext6 libxrender1 libxtst6 libxi6 \
  xvfb dbus-x11 fonts-dejavu-core libgtk-3-0"

install_apt_packages() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get update
    for package in $APT_PACKAGES;
    do
        echo "installing package: $package..."
        sudo DEBIAN_FRONTEND=noninteractive apt-get  -y install "$package";
    done
}


# Pre-seed tzdata + keyboard
echo "tzdata tzdata/Areas select Etc" | sudo debconf-set-selections
echo "tzdata tzdata/Zones/Etc select UTC" | sudo debconf-set-selections
echo "keyboard-configuration keyboard-configuration/layoutcode string us" | sudo debconf-set-selections
echo "keyboard-configuration keyboard-configuration/variantcode string " | sudo debconf-set-selections

# Install packages non-interactively
echo "installing required packages"
install_apt_packages

# Android SDK setup
USER_HOME=$(eval echo ~$username)
export ANDROID_SDK_ROOT="$USER_HOME/Android/Sdk"
export ANDROID_HOME=${ANDROID_SDK_ROOT}
export PATH=${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:$PATH

# Setup display environment for VNC
export DISPLAY=:1
export XAUTHORITY=$HOME/.Xauthority

mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools
cd /tmp
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
unzip cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools
mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest
rm cmdline-tools.zip

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Android Studio setup
mkdir -p "$USER_HOME"
wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.1.1.12/android-studio-2024.1.1.12-linux.tar.gz -O android-studio.tar.gz
tar -xzf android-studio.tar.gz -C "$USER_HOME"
rm android-studio.tar.gz

# Set proper ownership for Android SDK and Studio
chown -R $USER:$USER "$USER_HOME/Android" "$USER_HOME/android-studio" 2>/dev/null || true

# Initialize VNC server configuration
mkdir -p $HOME/.vnc
cat <<EOF > $HOME/.vnc/config
geometry=1280x800
depth=24
EOF

# Create VNC startup script without password
cat <<EOF > $HOME/.vnc/xstartup
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec /etc/X11/xinit/xinitrc
EOF
chmod +x $HOME/.vnc/xstartup

# Supervisor config for VNC/noVNC
sudo mkdir -p /etc/supervisor/conf.d
cat <<EOF | sudo tee /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true
logfile=/tmp/supervisord.log
pidfile=/tmp/supervisord.pid

[program:vnc]
command=/usr/bin/vncserver :1 -geometry 1280x800 -depth 24 -SecurityTypes None
autostart=true
autorestart=true
user=$USER
stdout_logfile=/tmp/vnc.log
stderr_logfile=/tmp/vnc_error.log

[program:novnc]
command=/usr/share/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080
autostart=true
autorestart=true
user=$USER
stdout_logfile=/tmp/novnc.log
stderr_logfile=/tmp/novnc_error.log
EOF

echo "✅ Bootstrap complete. Android Studio + SDK installed."
