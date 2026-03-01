#!/bin/bash

set -e

CONFIG_50="/etc/apt/apt.conf.d/50unattended-upgrades"
CONFIG_20="/etc/apt/apt.conf.d/20auto-upgrades"

echo "Checking for unattended-upgrades..."

sudo apt update
sudo apt install -y unattended-upgrades

echo ""
echo "Select system type:"
echo "1) Desktop"
echo "2) Server"
read -p "Enter choice (1 or 2): " system_type

DISTRO_ID=$(lsb_release -is)
DISTRO_CODENAME=$(lsb_release -cs)

echo "Configuring unattended-upgrades..."

sudo cp -v "$CONFIG_50" "/var/backups/$(basename "$CONFIG_50").$(date +%F-%H%M%S)"

sudo bash -c "cat > $CONFIG_50" <<EOF
Unattended-Upgrade::Allowed-Origins {
        "\${distro_id}:\${distro_codename}-security";
        "\${distro_id}:\${distro_codename}-updates";
};

Unattended-Upgrade::Package-Blacklist {
};

Unattended-Upgrade::Automatic-Reboot "$([[ "$system_type" == "2" ]] && echo "true" || echo "false")";
Unattended-Upgrade::Automatic-Reboot-Time "04:00";

Unattended-Upgrade::Mail "";
Unattended-Upgrade::MailOnlyOnError "false";
EOF

sudo bash -c "cat > $CONFIG_20" <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

echo ""
echo "Configuration complete."

if [[ "$system_type" == "1" ]]; then
	echo "Desktop setup applied:"
	echo "- Security updates"
	echo "- Normal updates"
	echo "- No auto reboot"
	echo "- No email notifications"
elif [[ "$system_type" == "2" ]]; then
	echo "Server setup applied:"
	echo "- Security updates"
	echo "- Normal updates"
	echo "- Auto reboot at 04:00 if required"
	echo "- No email notifications"
else
	echo "Invalid selection. Please verify configuration manually."
fi

echo ""
echo "You can test with:"
echo "sudo unattended-upgrade --dry-run --debug"
