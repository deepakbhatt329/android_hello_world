#!/usr/bin/env bash
set -e

USER_HOME=$(eval echo ~$username)
echo "▶️ Starting VNC + noVNC..."
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf >"$USER_HOME/supervisord.log" 2>&1 &

sleep 3
echo "✅ VNC/noVNC running (http://localhost:6080)"

echo "▶️ Launching Android Studio..."
"$USER_HOME/android-studio/bin/studio.sh" >"$USER_HOME/android-studio.log" 2>&1 &
echo "✅ Android Studio started (view on port 6080 browser preview)"
