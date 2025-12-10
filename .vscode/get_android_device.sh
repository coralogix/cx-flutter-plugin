#!/bin/bash
cd "${1:-.}/example" || exit 1
flutter devices --machine 2>/dev/null | python3 -c "
import sys, json
try:
    devices = json.load(sys.stdin)
    android_devices = [d for d in devices if d.get('targetPlatform') == 'android' and 'emulator' in d.get('id', '').lower()]
    if android_devices:
        print(android_devices[0]['id'])
        sys.exit(0)
except:
    pass
# Fallback: try to get from flutter devices output
import subprocess
result = subprocess.run(['flutter', 'devices'], capture_output=True, text=True, cwd='${1:-.}/example')
for line in result.stdout.split('\n'):
    if 'android' in line.lower() and 'emulator' in line:
        parts = line.split()
        for part in parts:
            if part.startswith('emulator-'):
                print(part)
                sys.exit(0)
"

