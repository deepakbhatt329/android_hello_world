# Android Studio setup with CDEs

## Aim 

Developer should be able to work with android studios with Cloud Dev environment. This setup provides a complete Android development environment in a containerized cloud development environment (CDE) with VNC-based remote desktop access to Android Studio.

## Design

### Android Studio VNC Access Architecture

Android Studio runs as a GUI application inside the container and is accessed remotely through VNC (Virtual Network Computing) technology:

**VNC Server Setup:**
- **TigerVNC Server**: Creates a virtual desktop environment on display `:1` within the container
- **Resolution**: Configured to run at 1280x800 with 24-bit color depth
- **Authentication**: Runs without password for development convenience
- **X11 Environment**: Provides the graphical display server required for Android Studio's GUI

**Remote Access Methods:**

1. **Web Browser Access (Port 6080):**
   - **noVNC Proxy**: Translates VNC protocol to WebSocket for browser compatibility
   - **Access**: Navigate to `http://localhost:6080` in any modern web browser
   - **Benefits**: No additional software required, works on any device with a browser
   - **Use Case**: Quick access, cross-platform compatibility

2. **Direct VNC Client Access (Port 5901):**
   - **Native VNC**: Direct connection to TigerVNC server
   - **Access**: Connect VNC client to `localhost:5901`
   - **Benefits**: Better performance, lower latency, native keyboard/mouse handling
   - **Use Case**: Intensive development work, better responsiveness

**Process Management:**
- **Supervisor Daemon**: Automatically starts and monitors VNC server and noVNC proxy
- **Auto-restart**: Services automatically restart if they crash
- **Logging**: VNC and noVNC logs captured for troubleshooting

**Android Studio Integration:**
- Android Studio launches automatically when the container starts
- Runs within the VNC desktop environment as a standard GUI application
- Full IDE functionality available including debugging, emulator support, and project management
- Display output is captured by VNC server and transmitted to remote clients

## Setup

### Necessary tools to install 

The setup automatically installs the following components through the bootstrap script:

**System Dependencies:**
- `openjdk-17-jdk` - Java Development Kit 17 for Android development
- `wget`, `unzip`, `curl` - Download and extraction utilities
- `tigervnc-standalone-server`, `tigervnc-common` - VNC server for remote desktop access
- `novnc`, `websockify` - Web-based VNC client for browser access
- `supervisor` - Process management for VNC services
- `libgl1-mesa-dev`, `libxext6`, `libxrender1`, `libxtst6`, `libxi6` - Graphics libraries for Android Studio
- `xvfb`, `dbus-x11` - X11 display server components
- `fonts-dejavu-core`, `libgtk-3-0` - UI fonts and GTK libraries

**Android Development Tools:**
- Android SDK Command Line Tools (version 11076708)
- Android SDK Platform Tools
- Android Platform API 34
- Android Build Tools 34.0.0
- Android Studio 2024.1.1.12

**Network Configuration:**
- Port 6080: noVNC web interface for browser-based access
- Port 5901: VNC server for direct VNC client connections

### Devcontainer file

The `.devcontainer/devcontainer.json` configuration provides:

**Base Image:** `mcr.microsoft.com/vscode/devcontainers/universal:2`
- Pre-configured development environment with common tools

**Volume Mounts:**
- `android-sdks` → `/home/vscode/Android/Sdk` - Persistent Android SDK storage
- `gradle-cache` → `/home/vscode/.gradle` - Persistent Gradle cache for faster builds

**Port Forwarding:**
- Port 6080: Web-based VNC access via noVNC
- Port 5901: Direct VNC client access

**VS Code Extensions:**
- `vscjava.vscode-java-pack` - Java development tools
- `redhat.java` - Java language support
- `ms-vscode.cpptools` - C++ tools for NDK development

**Lifecycle Commands:**
- `postCreateCommand`: Runs bootstrap script once after container creation
- `postStartCommand`: Runs startup script every time container starts

### Scripts 

**Bootstrap Script (`bootstrap-android.sh`):**
- **Purpose**: One-time setup executed after container creation
- **Key Functions**:
  - Installs system packages and dependencies
  - Downloads and configures Android SDK (API 34, Build Tools 34.0.0)
  - Downloads and extracts Android Studio 2024.1.1.12
  - Configures VNC server with 1280x800 resolution, 24-bit depth
  - Sets up supervisor daemon for process management
  - Accepts Android SDK licenses automatically
  - Configures proper file permissions

**Startup Script (`start-android-studio.sh`):**
- **Purpose**: Executed every time the container starts
- **Key Functions**:
  - Starts VNC server via supervisor daemon
  - Launches noVNC web proxy on port 6080
  - Starts Android Studio GUI application
  - Provides status logging for troubleshooting

**Technical Implementation Details:**
- VNC server runs without password authentication for development convenience
- Supervisor manages VNC and noVNC processes with auto-restart capability
- Android Studio logs are captured to `~/android-studio.log`
- VNC/noVNC logs are available in `/tmp/` directory
- Environment variables: `ANDROID_SDK_ROOT`, `ANDROID_HOME`, `PATH` configured automatically

## How to Use

### For Developers

1. **Container Startup:**
   ```bash
   # Container automatically executes bootstrap (first time) and startup scripts
   # Wait 2-3 minutes for complete initialization
   ```

2. **Access Android Studio:**
   - **Browser Access**: Navigate to `http://localhost:6080` in your web browser
   - **VNC Client**: Connect to `localhost:5901` using any VNC client
   - **Resolution**: Default 1280x800, configurable in bootstrap script

3. **Development Workflow:**
   - Android SDK is pre-installed at `/home/vscode/Android/Sdk`
   - Gradle cache is persistent across container restarts
   - Import existing Android projects or create new ones
   - Build, debug, and test Android applications normally

4. **Troubleshooting:**
   - Check logs: `~/android-studio.log`, `/tmp/vnc.log`, `/tmp/novnc.log`
   - Restart services: Container restart will re-run startup script
   - VNC issues: Verify ports 5901 and 6080 are accessible

### For Program Managers

**Environment Benefits:**
- **Standardization**: Consistent Android development environment across team
- **Rapid Onboarding**: New developers get fully configured environment in minutes
- **Resource Efficiency**: Cloud-based resources scale as needed
- **Maintenance**: Centralized updates and dependency management

**Resource Requirements:**
- **CPU**: Minimum 2 cores, recommended 4+ cores for optimal Android Studio performance
- **Memory**: Minimum 4GB RAM, recommended 8GB+ for large projects
- **Storage**: ~3GB for base setup, additional space for projects and builds
- **Network**: Stable internet connection for initial setup and ongoing development

**Access Methods:**
- **Web Browser**: No additional software required, works on any device
- **VNC Client**: Better performance for intensive development work
- **VS Code Integration**: Code editing with full IntelliSense support

**Monitoring and Logs:**
- Container startup logs available through CDE platform
- Application logs captured in user home directory
- VNC service logs in `/tmp/` for connection troubleshooting

## References

- [Android Studio Official Documentation](https://developer.android.com/studio)
- [Android SDK Command Line Tools](https://developer.android.com/studio/command-line)
- [Development Containers Specification](https://containers.dev/)
- [noVNC Web-based VNC Client](https://novnc.com/)
- [TigerVNC Server Documentation](https://tigervnc.org/) 

