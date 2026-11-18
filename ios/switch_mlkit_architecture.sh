#!/bin/bash
set -e

PODS_DIR="${PODS_ROOT:-$(dirname "$0")/Pods}"

if [ "$PLATFORM_NAME" = "iphonesimulator" ]; then
    echo "[switch_mlkit] Switching MLKit frameworks to iOS Simulator architecture..."
    for fw in MLImage MLKitCommon MLKitVision; do
        SIM_FILE="${PODS_DIR}/${fw}/Frameworks/${fw}.framework/${fw}.sim"
        TARGET_FILE="${PODS_DIR}/${fw}/Frameworks/${fw}.framework/${fw}"
        if [ -f "$SIM_FILE" ]; then
            cp -f "$SIM_FILE" "$TARGET_FILE"
        fi
    done
else
    echo "[switch_mlkit] Switching MLKit frameworks to iOS Device architecture..."
    for fw in MLImage MLKitCommon MLKitVision; do
        ORIG_FILE="${PODS_DIR}/${fw}/Frameworks/${fw}.framework/${fw}.orig"
        TARGET_FILE="${PODS_DIR}/${fw}/Frameworks/${fw}.framework/${fw}"
        if [ -f "$ORIG_FILE" ]; then
            cp -f "$ORIG_FILE" "$TARGET_FILE"
        fi
    done
fi
