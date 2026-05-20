#!/usr/bin/env bash
set -e

VNC_HOME="${VNC_HOME:-$HOME}"
if [ -z "${VNC_PASSWORD:-}" ]; then
  echo "ERROR: VNC_PASSWORD must be set when ENABLE_VNC=true"
  exit 1
fi

mkdir -p "${VNC_HOME}/.vnc"
if [ ! -f "${VNC_HOME}/.vnc/passwd" ]; then
  echo "${VNC_PASSWORD}" | vncpasswd -f > "${VNC_HOME}/.vnc/passwd"
  chmod 600 "${VNC_HOME}/.vnc/passwd"
fi

# Ensure a lightweight VNC session (Openbox + Xterm)
# If xstartup "exec"s xterm, closing the terminal ends the whole session.
if [ -f "${VNC_HOME}/.vnc/xstartup" ] && grep -qE '^\s*exec\s+xterm\b' "${VNC_HOME}/.vnc/xstartup"; then
  rm -f "${VNC_HOME}/.vnc/xstartup"
fi

if [ ! -f "${VNC_HOME}/.vnc/xstartup" ]; then
  cat > "${VNC_HOME}/.vnc/xstartup" <<'EOF'
#!/usr/bin/env bash
set -e

xsetroot -solid "#1b1b1b" || true
xset -dpms || true
xset s off || true
xset s noblank || true

# Minimal Openbox menu so you can relaunch a terminal after closing it.
mkdir -p "${HOME}/.config/openbox"
if [ ! -f "${HOME}/.config/openbox/menu.xml" ]; then
  cat > "${HOME}/.config/openbox/menu.xml" <<'MENU'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="Openbox">
    <item label="Terminal">
      <action name="Execute"><command>xterm -fa "DejaVu Sans Mono" -fs 12</command></action>
    </item>
    <item label="RViz2">
      <action name="Execute"><command>bash -lc 'source /opt/ros/humble/setup.bash &amp;&amp; rviz2'</command></action>
    </item>
    <separator />
    <item label="Exit">
      <action name="Exit" />
    </item>
  </menu>
</openbox_menu>
MENU
fi

# Start a terminal, but keep the WM as the session's foreground process.
xterm -fa "DejaVu Sans Mono" -fs 12 &
exec openbox-session
EOF
  chmod +x "${VNC_HOME}/.vnc/xstartup"
fi

VNC_DISPLAY="${VNC_DISPLAY:-:1}"
if ! [[ "${VNC_DISPLAY}" =~ ^:[0-9]{1,3}$ ]]; then
  echo "ERROR: VNC_DISPLAY must be of the form :N (e.g. :1, :10). Got: ${VNC_DISPLAY}"
  exit 1
fi

NOVNC_PORT="${NOVNC_PORT:-6080}"
if ! [[ "${NOVNC_PORT}" =~ ^[0-9]+$ ]] || (( NOVNC_PORT < 1 || NOVNC_PORT > 65535 )); then
  echo "ERROR: NOVNC_PORT must be an integer in 1-65535. Got: ${NOVNC_PORT}"
  exit 1
fi

# 10# forces base-10 so values like ":08" don't get parsed as (invalid) octal.
VNC_PORT=$((5900 + 10#${VNC_DISPLAY#:}))

export DISPLAY="${VNC_DISPLAY}"
vncserver "${VNC_DISPLAY}" -geometry "${VNC_RESOLUTION}" -depth 24

/usr/lib/novnc/utils/novnc_proxy --vnc "localhost:${VNC_PORT}" --listen "${NOVNC_PORT}"
