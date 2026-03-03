rename_host() {
    local NEW_HOSTNAME="$1"

    # ---- Validation ----
    if [ -z "$NEW_HOSTNAME" ]; then
        echo "Usage: rename_host <new-hostname>"
        return 1
    fi

    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root (use sudo)"
        return 1
    fi

    # RFC 1123 hostname validation
    if [[ ! "$NEW_HOSTNAME" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$ ]]; then
        echo "Invalid hostname."
        echo "Rules:"
        echo " - 1–63 characters"
        echo " - Letters, numbers, hyphens only"
        echo " - Cannot start or end with hyphen"
        return 1
    fi

    local OLD_HOSTNAME
    OLD_HOSTNAME=$(hostname)

    if [ "$OLD_HOSTNAME" = "$NEW_HOSTNAME" ]; then
        echo "Hostname is already set to $NEW_HOSTNAME"
        return 0
    fi

    echo "Old hostname: $OLD_HOSTNAME"
    echo "New hostname: $NEW_HOSTNAME"

    # ---- Backup ----
    local TS
    TS=$(date +%F_%H-%M-%S)

    mkdir -p /var/backups
    cp /etc/hosts /var/backups/hosts.backup.$TS
    cp /etc/hostname /var/backups/hostname.backup.$TS 2>/dev/null

    echo "Backups created in /var/backups/"

    # ---- Set System Hostname ----
    if command -v hostnamectl >/dev/null 2>&1; then
        hostnamectl set-hostname "$NEW_HOSTNAME"
    else
        hostname "$NEW_HOSTNAME"
    fi

    echo "$NEW_HOSTNAME" > /etc/hostname

    # ---- Update /etc/hosts safely ----
    # Replace only non-comment lines
    sed -i "/^[^#]/ s/\b$OLD_HOSTNAME\b/$NEW_HOSTNAME/g" /etc/hosts

    echo "Hostname successfully changed to $NEW_HOSTNAME"
}