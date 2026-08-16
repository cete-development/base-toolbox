#!/bin/bash

# ==============================================================================
# CONFIG SYNC MANAGER (v2)
# Manages profiles, shared configuration data, and safety snapshots.
# ==============================================================================

# Configuration
REPO_DIR="$HOME/.config_repo"
APPS_DIR="$REPO_DIR/apps"
PROFILES_DIR="$REPO_DIR/profiles"
SNAPSHOT_DIR="$REPO_DIR/.snapshots" # New: Directory for hardcopies
CONFIG_DIR="$HOME/.config"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ==============================================================================
# HELPERS
# ==============================================================================

usage() {
    echo -e "${GREEN}Config Sync Manager${NC}"
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  init                  Create the repository structure"
    echo "  create-profile <name> Create a new profile list (e.g., 'laptop-mint')"
    echo "  add <profile> <app>   Add an app to a profile"
    echo "  backup <profile>      Push configs from .config to Repo"
    echo "  restore <profile>     Pull configs from Repo to .config"
    echo "  list-profiles         List all available profiles"
    echo "  status <profile>      Show what apps are in a profile"
    echo "  clean-snapshots       Remove all stored snapshots"
    exit 1
}

log_info() { echo -e "[${BLUE}INFO${NC}] $1"; }
log_ok() { echo -e "[${GREEN}OK${NC}] $1"; }
log_warn() { echo -e "[${YELLOW}WARN${NC}] $1"; }
log_error() { echo -e "[${RED}ERROR${NC}] $1"; }

check_deps() {
    if ! command -v rsync &> /dev/null; then
        log_error "rsync is required for this script."
        exit 1
    fi
    if ! command -v tar &> /dev/null; then
        log_error "tar is required for hardcopy backups."
        exit 1
    fi
}

# ==============================================================================
# HARD COPY / SNAPSHOT LOGIC
# ==============================================================================

prompt_hardcopy() {
    local mode="$1" # "backup" or "restore"
    local profile_name="$2"
    
    echo -n "Create a safety hardcopy (archive) before ${mode}? [y/N]: "
    read ans
    
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        mkdir -p "$SNAPSHOT_DIR"
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        
        if [ "$mode" == "backup" ]; then
            # We are about to overwrite the REPO. Let's snapshot the Repo.
            local snapshot_file="${SNAPSHOT_DIR}/repo_pre_backup_${timestamp}.tar.gz"
            log_info "Snapshotting Repository ($APPS_DIR)..."
            
            # We only care about the 'apps' folder contents for safety
            tar -czf "$snapshot_file" -C "$REPO_DIR" apps 2>/dev/null
            
            if [ $? -eq 0 ]; then
                local size=$(du -h "$snapshot_file" | cut -f1)
                log_ok "Repository snapshot saved ($size)."
            else
                log_warn "Snapshot failed (might be empty), proceeding anyway."
            fi
            
        elif [ "$mode" == "restore" ]; then
            # We are about to overwrite .CONFIG. Let's snapshot .config.
            # Note: We only snapshot the apps relevant to THIS profile to save space/time.
            local snapshot_file="${SNAPSHOT_DIR}/config_pre_restore_${profile_name}_${timestamp}.tar.gz"
            log_info "Snapshotting current .config (profile apps only)..."
            
            # Create a temporary file list for tar
            local tmp_list=$(mktemp)
            local found_items=0
            
            # Parse profile to find what exists in .config currently
            while IFS= read -r app; do
                app=$(echo "$app" | sed 's/^[ \t]*//;s/[ \t]*$//')
                if [[ -z "$app" || "$app" =~ ^# ]]; then continue; fi
                
                if [ -e "$CONFIG_DIR/$app" ]; then
                    echo "$app" >> "$tmp_list"
                    ((found_items++))
                fi
            done < "$PROFILES_DIR/${profile_name}.txt"
            
            if [ "$found_items" -gt 0 ]; then
                tar -czf "$snapshot_file" -C "$CONFIG_DIR" -T "$tmp_list" 2>/dev/null
                rm "$tmp_list"
                
                if [ $? -eq 0 ]; then
                    local size=$(du -h "$snapshot_file" | cut -f1)
                    log_ok ".Config snapshot saved ($size)."
                else
                    log_warn "Snapshot failed."
                fi
            else
                log_info "No existing apps found in .config for this profile. Skipping snapshot."
                rm "$tmp_list"
            fi
        fi
    fi
}

# ==============================================================================
# CORE LOGIC
# ==============================================================================

cmd_init() {
    if [ -d "$REPO_DIR" ]; then
        log_warn "Repository already exists at $REPO_DIR"
        return
    fi
    
    log_info "Initializing repository at $REPO_DIR..."
    mkdir -p "$APPS_DIR"
    mkdir -p "$PROFILES_DIR"
    mkdir -p "$SNAPSHOT_DIR" # Ensure snapshot dir exists
    
    local sample="$PROFILES_DIR/example.txt"
    echo "# List folders from .config to manage" > "$sample"
    echo "nvim" >> "$sample"
    echo "fish" >> "$sample"
    
    log_ok "Repository initialized."
}

cmd_create_profile() {
    local profile_name="$1"
    if [ -z "$profile_name" ]; then log_error "Please provide a profile name."; usage; fi
    
    local profile_file="$PROFILES_DIR/${profile_name}.txt"
    if [ -f "$profile_file" ]; then
        log_warn "Profile '$profile_name' already exists."
    else
        touch "$profile_file"
        log_ok "Created profile: $profile_name"
    fi
    
    echo -n "Open $profile_file to edit now? (y/N): "
    read ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} "$profile_file"
    fi
}

cmd_add() {
    local profile_name="$1"
    local app_name="$2"
    if [ -z "$profile_name" ] || [ -z "$app_name" ]; then log_error "Usage: $0 add <profile_name> <app_folder_name>"; exit 1; fi
    
    local profile_file="$PROFILES_DIR/${profile_name}.txt"
    if [ ! -f "$profile_file" ]; then log_error "Profile '$profile_name' does not exist."; exit 1; fi
    
    if grep -qx "$app_name" "$profile_file"; then
        log_warn "'$app_name' is already in '$profile_name'."
    else
        echo "$app_name" >> "$profile_file"
        log_ok "Added '$app_name' to '$profile_name'."
    fi
}

cmd_backup() {
    local profile_name="$1"
    local profile_file="$PROFILES_DIR/${profile_name}.txt"
    
    if [ ! -f "$profile_file" ]; then log_error "Profile '$profile_name' not found."; exit 1; fi

    log_info "Preparing backup for profile: $profile_name"
    
    # 1. Safety Prompt
    prompt_hardcopy "backup" "$profile_name"
    
    # 2. Execute Backup
    log_info "Syncing .config -> Repo..."
    local count=0
    
    while IFS= read -r app; do
        app=$(echo "$app" | sed 's/^[ \t]*//;s/[ \t]*$//')
        if [[ -z "$app" || "$app" =~ ^# ]]; then continue; fi

        local src="$CONFIG_DIR/$app"
        local dst="$APPS_DIR/$app"
        
        if [ ! -e "$src" ]; then
            log_warn "Skipping '$app' (not found in .config)"
            continue
        fi

        mkdir -p "$dst"
        rsync -av "$src/" "$dst/" --delete
        
        if [ $? -eq 0 ]; then ((count++)); else log_error "Failed to sync $app"; fi
    done < "$profile_file"
    
    log_ok "Backup complete. $count app(s) synced."
}

cmd_restore() {
    local profile_name="$1"
    local profile_file="$PROFILES_DIR/${profile_name}.txt"
    
    if [ ! -f "$profile_file" ]; then log_error "Profile '$profile_name' not found."; exit 1; fi
    
    log_warn "Preparing restore for profile: $profile_name"
    
    # 1. Safety Prompt
    prompt_hardcopy "restore" "$profile_name"

    # 2. Confirm Restore
    echo -n "Proceed with restore? This overwrites files in .config [y/N]: "
    read confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then log_info "Aborted."; exit 0; fi

    # 3. Execute Restore
    log_info "Syncing Repo -> .config..."
    local count=0
    
    while IFS= read -r app; do
        app=$(echo "$app" | sed 's/^[ \t]*//;s/[ \t]*$//')
        if [[ -z "$app" || "$app" =~ ^# ]]; then continue; fi

        local src="$APPS_DIR/$app"
        local dst="$CONFIG_DIR/$app"
        
        if [ ! -d "$src" ]; then
            log_warn "Skipping '$app' (not found in Repo)"
            continue
        fi
        
        mkdir -p "$dst"
        rsync -av --delete "$src/" "$dst/"
        
        if [ $? -eq 0 ]; then ((count++)); fi
    done < "$profile_file"
    
    log_ok "Restore complete. $count app(s) restored."
}

cmd_list_profiles() {
    echo "Available Profiles:"
    if [ ! -d "$PROFILES_DIR" ]; then log_warn "No profiles found."; return; fi
    ls -1 "$PROFILES_DIR" | sed 's/.txt$//'
}

cmd_status() {
    local profile_name="$1"
    local profile_file="$PROFILES_DIR/${profile_name}.txt"
    if [ ! -f "$profile_file" ]; then log_error "Profile '$profile_name' not found."; exit 1; fi
    echo "Apps in profile '$profile_name':"
    cat "$profile_file" | grep -v "^#" | grep -v "^$"
}

cmd_clean_snapshots() {
    if [ -d "$SNAPSHOT_DIR" ] && [ "$(ls -A $SNAPSHOT_DIR)" ]; then
        echo -n "Delete all snapshots in $SNAPSHOT_DIR? [y/N]: "
        read ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            rm -rf "${SNAPSHOT_DIR:?}"/*
            log_ok "Snapshots cleaned."
        fi
    else
        log_info "No snapshots to clean."
    fi
}

# ==============================================================================
# MAIN
# ==============================================================================

check_deps

case "$1" in
    init) cmd_init ;;
    create-profile) cmd_create_profile "$2" ;;
    add) cmd_add "$2" "$3" ;;
    backup) cmd_backup "$2" ;;
    restore) cmd_restore "$2" ;;
    list-profiles) cmd_list_profiles ;;
    status) cmd_status "$2" ;;
    clean-snapshots) cmd_clean_snapshots ;;
    *) usage ;;
esac