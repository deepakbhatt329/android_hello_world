#!/usr/bin/env bash
set -e

APT_PACKAGES="wget unzip curl openjdk-17-jdk \
  tigervnc-standalone-server tigervnc-common \
  novnc websockify supervisor \
  libgl1-mesa-dev libxext6 libxrender1 libxtst6 libxi6"

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

mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools
cd /tmp
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
unzip cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools
mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest
rm cmdline-tools.zip

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Android Studio setup
wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.1.1.12/android-studio-2024.1.1.12-linux.tar.gz -O android-studio.tar.gz
tar -xzf android-studio.tar.gz -C "$USER_HOME/.android"
rm android-studio.tar.gz

# Supervisor config for VNC/noVNC
sudo mkdir -p /etc/supervisor/conf.d
cat <<EOF | sudo tee /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true

[program:vnc]
command=/usr/bin/vncserver :1 -geometry 1280x800 -depth 24
autostart=true
autorestart=true
user="$USER"

[program:novnc]
command=/usr/share/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080
autostart=true
autorestart=true
user="$USER"
EOF

echo "✅ Bootstrap complete. Android Studio + SDK installed."
