#!/usr/bin/env bash
# Ensures an Android emulator is running (boots one if not), then prints its device id.
# Used by launch.json preLaunchTask "Boot Android Emulator".

set -e
WORKSPACE="${1:-.}"
cd "$WORKSPACE/example" || exit 1

# IDE tasks often run without ANDROID_HOME
if [[ -z "${ANDROID_HOME:-}" ]]; then
  export ANDROID_HOME="${HOME}/Library/Android/sdk"
  if [[ ! -d "$ANDROID_HOME" ]]; then
    echo "Error: ANDROID_HOME not set and not found at $ANDROID_HOME" >&2
    exit 1
  fi
  echo "Using ANDROID_HOME=$ANDROID_HOME" >&2
fi

# If no Android emulator present yet, launch one and wait
DEVICES=$(flutter devices 2>&1) || true
has_android_emulator() { echo "$DEVICES" | grep -qi 'android' && echo "$DEVICES" | grep -qi 'emulator'; }
if ! has_android_emulator; then
  EMU_ID="Medium_Phone_API_35"
  AVAILABLE=$(flutter emulators 2>&1 | grep -E '^[a-zA-Z0-9_]+.*android' | head -1 | awk '{print $1}')
  [[ -n "$AVAILABLE" ]] && EMU_ID="$AVAILABLE"
  echo "Launching Android emulator: $EMU_ID" >&2
  flutter emulators --launch "$EMU_ID" || { echo "Error: Failed to launch emulator." >&2; exit 1; }
  echo "Waiting for emulator..." >&2
  MAX_WAIT=90
  WAITED=0
  while [[ $WAITED -lt $MAX_WAIT ]]; do
    DEVICES=$(flutter devices 2>&1) || true
    if has_android_emulator; then break; fi
    sleep 3
    WAITED=$((WAITED + 3))
    echo "  ... ($WAITED/$MAX_WAIT s)" >&2
  done
  if ! has_android_emulator; then
    echo "Warning: Emulator may not be ready yet." >&2
  fi
fi

# Print the Android emulator device id (stdout for callers that need it)
flutter devices --machine 2>/dev/null | python3 -c "
import sys, json
try:
    devices = json.load(sys.stdin)
    android = [d for d in devices if (d.get('targetPlatform') or '').startswith('android') and 'emulator' in d.get('id', '').lower()]
    if android:
        print(android[0]['id'])
        sys.exit(0)
except Exception:
    pass
# Fallback: parse flutter devices text output
import subprocess
r = subprocess.run(['flutter', 'devices'], capture_output=True, text=True, cwd='.')
for line in (r.stdout or '').split('\n'):
    if 'android' in line.lower() and 'emulator' in line:
        for part in line.split():
            if part.startswith('emulator-'):
                print(part)
                sys.exit(0)
" || true
