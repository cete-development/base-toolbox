#!/bin/bash

# Bluetooth Distance Logger using bluetoothctl

# === Configuration ===
MEASURED_POWER=-59      # RSSI at 1 meter
ENV_FACTOR=2            # Path loss exponent: 2=open, 2.7–4 indoors
LOG_FILE="btctl_distance_log.txt"
SCAN_DURATION=10        # Seconds to scan per round
SLEEP_BETWEEN_SCANS=5   # Seconds between scan rounds

# === Check Required Tools ===
for tool in bluetoothctl bc rfkill; do
    if ! command -v "$tool" &>/dev/null; then
        echo "❌ Tool '$tool' is not installed."
        exit 1
    fi
done

# === Ensure Bluetooth is On ===
if ! rfkill list bluetooth | grep -q "Soft blocked: no"; then
    echo "❌ Bluetooth is disabled. Enable it with: rfkill unblock bluetooth"
    exit 1
fi

# === Start Logging ===
echo "📄 Logging to $LOG_FILE"
echo "Bluetooth Distance Log - $(date)" > "$LOG_FILE"
echo "===================================" >> "$LOG_FILE"

trap 'echo -e "\n🛑 Exiting..."; exit 0' SIGINT

# === Main Loop ===
while true; do
    echo -e "\n🔍 Scanning at $(date)" | tee -a "$LOG_FILE"

    # Start scanning
    bluetoothctl <<EOF > /tmp/btctl_scan_raw.txt
power on
# agent on
scan on
EOF

    sleep "$SCAN_DURATION"

    # Stop scanning
    bluetoothctl scan off &>/dev/null

    # # Extract MAC and RSSI lines
    # grep -E 'Device ([A-F0-9:]{17})' /tmp/btctl_scan_raw.txt | while read -r line; do
    #     mac=$(echo "$line" | awk '{print $2}')
    #     name=$(echo "$line" | cut -d ' ' -f3-)
    #     rssi=$(echo "$line" | grep -o 'RSSI: *-*[0-9]*' | awk '{print $2}')
    #
    #     # Skip if no RSSI
    #     [[ -z "$rssi" ]] && continue
    #
    #     # Estimate distance
    #     distance=$(echo "scale=2; 10 ^ (($MEASURED_POWER - $rssi) / (10 * $ENV_FACTOR))" | bc -l)
    #     [[ -z "$name" ]] && name="(Unnamed)"
    #
    #     echo "$name [$mac]  RSSI: $rssi dBm  ≈ ${distance}m" | tee -a "$LOG_FILE"
    # done

    sleep "$SLEEP_BETWEEN_SCANS"
done


