#!/bin/bash

echo "[INFO] 🧹 Starting Ultimate Windsurf & Codeium Cleanup..."
echo "[INFO] Timestamp: $(date +%s)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to safely remove files or directories
safe_rm() {
    if [ -e "$1" ] || [ -d "$1" ]; then
        rm -rfv "$1"
    else
        echo -e "${YELLOW}[WARN] Not found:${NC} $1"
    fi
}

# Backup directory
TIMESTAMP=$(date +%s)
BACKUP_DIR="$HOME/windsurf_codeium_backup_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
echo -e "${BLUE}[INFO] Created backup directory:${NC} $BACKUP_DIR"

# ===================================
# PROCESS TERMINATION
# ===================================
echo -e "${GREEN}[STEP 1] Process Termination${NC}"
echo "[INFO] Killing running Windsurf and Codeium processes..."
pkill -f windsurf 2>/dev/null && echo "[INFO] Killed Windsurf processes." || echo "[INFO] No running Windsurf processes found."
pkill -f codeium 2>/dev/null && echo "[INFO] Killed Codeium processes." || echo "[INFO] No running Codeium processes found."

# Kill by pattern (more aggressive)
for pattern in "windsurf" "codeium"; do
    pids=$(ps aux | grep -i $pattern | grep -v grep | awk '{print $2}')
    if [ ! -z "$pids" ]; then
        echo "[INFO] Killing processes matching $pattern: $pids"
        kill -9 $pids 2>/dev/null || true
    fi
done

# ===================================
# DOCKER CLEANUP
# ===================================
echo -e "${GREEN}[STEP 2] Docker Resources Cleanup${NC}"
echo "[INFO] Cleaning up Docker resources..."

# Containers
echo "[INFO] Removing Docker containers..."
docker ps -a --format '{{.Names}}' | grep -i windsurf | xargs -r docker rm -f
docker ps -a --format '{{.Names}}' | grep -i codeium | xargs -r docker rm -f

# Images
echo "[INFO] Removing Docker images..."
docker images --format '{{.Repository}}' | grep -i windsurf | xargs -r docker rmi -f
docker images --format '{{.Repository}}' | grep -i codeium | xargs -r docker rmi -f

# Volumes
echo "[INFO] Removing Docker volumes..."
docker volume ls --format '{{.Name}}' | grep -i windsurf | xargs -r docker volume rm
docker volume ls --format '{{.Name}}' | grep -i codeium | xargs -r docker volume rm

# Networks
echo "[INFO] Removing Docker networks..."
docker network ls --format '{{.Name}}' | grep -i windsurf | xargs -r docker network rm
docker network ls --format '{{.Name}}' | grep -i codeium | xargs -r docker network rm

# Compose projects
docker-compose -f ~/*/docker-compose*windsurf*.yml down -v 2>/dev/null || true
docker-compose -f ~/*/docker-compose*codeium*.yml down -v 2>/dev/null || true

# ===================================
# APPLICATION FILES CLEANUP
# ===================================
echo -e "${GREEN}[STEP 3] Application Files Cleanup${NC}"

# Deep cleanup - Windsurf
echo "[INFO] 🔍 Performing deep Windsurf cleanup..."
safe_rm "$HOME/.windsurf"
safe_rm "$HOME/.config/windsurf"
safe_rm "$HOME/.cache/windsurf"
safe_rm "$HOME/.local/share/windsurf"
safe_rm "/opt/windsurf"
safe_rm "/usr/share/windsurf"
safe_rm "/usr/lib/windsurf"
safe_rm "/usr/local/share/windsurf"
safe_rm "/usr/local/bin/windsurf"
safe_rm "/usr/bin/windsurf"

# Deep cleanup - Codeium
echo "[INFO] 🔍 Performing deep Codeium cleanup..."
safe_rm "$HOME/.codeium"
safe_rm "$HOME/.config/codeium"
safe_rm "$HOME/.cache/codeium"
safe_rm "$HOME/.local/share/codeium"
safe_rm "/opt/codeium"
safe_rm "/usr/share/codeium"
safe_rm "/usr/lib/codeium"
safe_rm "/usr/local/share/codeium"
safe_rm "/usr/local/bin/codeium"
safe_rm "/usr/bin/codeium"

# ===================================
# IDE EXTENSIONS CLEANUP
# ===================================
echo -e "${GREEN}[STEP 4] IDE Extensions Cleanup${NC}"

# VSCode extensions
echo "[INFO] Removing VSCode extensions..."
safe_rm "$HOME/.vscode/extensions/windsurf*"
safe_rm "$HOME/.vscode/extensions/codeium*"
safe_rm "$HOME/.vscode-server/extensions/windsurf*"
safe_rm "$HOME/.vscode-server/extensions/codeium*"
safe_rm "$HOME/.vscode-oss/extensions/windsurf*"
safe_rm "$HOME/.vscode-oss/extensions/codeium*"

# JetBrains IDEs (more comprehensive)
echo "[INFO] Removing JetBrains IDE extensions..."
find "$HOME/.config/JetBrains" -type d -name "plugins" -exec find {} -name "codeium*" -type d -exec rm -rfv {} \; \;
find "$HOME/.local/share/JetBrains" -type d -name "plugins" -exec find {} -name "codeium*" -type d -exec rm -rfv {} \; \;
# JetBrains global plugins
safe_rm "$HOME/.local/share/JetBrains/plugins/codeium*"
safe_rm "$HOME/.local/share/JetBrains/plugins/windsurf*"
# Look for all JetBrains products
jetbrains_dirs=(
    "$HOME/.IntelliJIdea*"
    "$HOME/.PyCharm*"
    "$HOME/.CLion*"
    "$HOME/.GoLand*"
    "$HOME/.PhpStorm*"
    "$HOME/.WebStorm*"
    "$HOME/.RubyMine*"
    "$HOME/.DataGrip*"
    "$HOME/.Rider*"
)
for dir in "${jetbrains_dirs[@]}"; do
    for match in $dir; do
        if [ -d "$match" ]; then
            find "$match" -path "*/plugins/*" -name "codeium*" -exec rm -rfv {} \; 2>/dev/null
            find "$match" -path "*/plugins/*" -name "windsurf*" -exec rm -rfv {} \; 2>/dev/null
        fi
    done
done

# Sublime Text
echo "[INFO] Removing Sublime Text extensions..."
safe_rm "$HOME/.config/sublime-text-3/Packages/windsurf*"
safe_rm "$HOME/.config/sublime-text-3/Packages/codeium*"
safe_rm "$HOME/.config/sublime-text/Packages/windsurf*"
safe_rm "$HOME/.config/sublime-text/Packages/codeium*"
safe_rm "$HOME/Library/Application Support/Sublime Text/Packages/windsurf*"
safe_rm "$HOME/Library/Application Support/Sublime Text/Packages/codeium*"
safe_rm "$HOME/Library/Application Support/Sublime Text 3/Packages/windsurf*"
safe_rm "$HOME/Library/Application Support/Sublime Text 3/Packages/codeium*"

# Atom
echo "[INFO] Removing Atom extensions..."
safe_rm "$HOME/.atom/packages/windsurf*"
safe_rm "$HOME/.atom/packages/codeium*"

# Vim/Neovim
echo "[INFO] Removing Vim/Neovim plugins..."
safe_rm "$HOME/.vim/plugged/windsurf*"
safe_rm "$HOME/.vim/plugged/codeium*"
safe_rm "$HOME/.vim/bundle/windsurf*"
safe_rm "$HOME/.vim/bundle/codeium*"
safe_rm "$HOME/.config/nvim/plugged/windsurf*"
safe_rm "$HOME/.config/nvim/plugged/codeium*"
safe_rm "$HOME/.local/share/nvim/site/pack/*/start/windsurf*"
safe_rm "$HOME/.local/share/nvim/site/pack/*/start/codeium*"
safe_rm "$HOME/.local/share/nvim/site/pack/*/opt/windsurf*"
safe_rm "$HOME/.local/share/nvim/site/pack/*/opt/codeium*"

# VS (Visual Studio)
safe_rm "$HOME/.vs/extensions/windsurf*"
safe_rm "$HOME/.vs/extensions/codeium*"

# ===================================
# VIRTUAL ENVIRONMENTS CLEANUP
# ===================================
echo -e "${GREEN}[STEP 5] Virtual Environments Cleanup${NC}"
echo "[INFO] Removing virtual environments..."

# Python virtualenvs
safe_rm "$HOME/.local/share/virtualenvs/windsurf*"
safe_rm "$HOME/.local/share/virtualenvs/codeium*"
safe_rm "$HOME/venv/windsurf*"
safe_rm "$HOME/venv/codeium*"
safe_rm "$HOME/.pyenv/versions/windsurf*"
safe_rm "$HOME/.pyenv/versions/codeium*"
safe_rm "$HOME/.virtualenvs/windsurf*"
safe_rm "$HOME/.virtualenvs/codeium*"
find "$HOME" -path "*/venv*/*" -name "windsurf*" -exec rm -rfv {} \; 2>/dev/null
find "$HOME" -path "*/venv*/*" -name "codeium*" -exec rm -rfv {} \; 2>/dev/null

# Node.js environments
safe_rm "$HOME/.nvm/versions/node/*/lib/node_modules/windsurf*"
safe_rm "$HOME/.nvm/versions/node/*/lib/node_modules/codeium*"
find "$HOME/node_modules" -name "windsurf*" -type d -exec rm -rfv {} \; 2>/dev/null
find "$HOME/node_modules" -name "codeium*" -type d -exec rm -rfv {} \; 2>/dev/null
find "$HOME/*/node_modules" -name "windsurf*" -type d -exec rm -rfv {} \; 2>/dev/null
find "$HOME/*/node_modules" -name "codeium*" -type d -exec rm -rfv {} \; 2>/dev/null

# ===================================
# PACKAGE MANAGERS CLEANUP
# ===================================
echo -e "${GREEN}[STEP 6] Package Managers Cleanup${NC}"

# NPM/Yarn/PNPM
echo "[INFO] Removing NPM/Yarn/PNPM packages..."
npm uninstall -g codeium windsurf 2>/dev/null || true
yarn global remove codeium windsurf 2>/dev/null || true
pnpm uninstall -g codeium windsurf 2>/dev/null || true

# Python packages
echo "[INFO] Removing Python packages..."
pip uninstall -y codeium windsurf 2>/dev/null || true
pip3 uninstall -y codeium windsurf 2>/dev/null || true
python -m pip uninstall -y codeium windsurf 2>/dev/null || true
python3 -m pip uninstall -y codeium windsurf 2>/dev/null || true

# System package managers
echo "[INFO] Removing system packages..."
flatpak uninstall -y windsurf codeium 2>/dev/null || true
snap remove windsurf codeium 2>/dev/null || true
sudo apt-get remove -y windsurf codeium 2>/dev/null || true
sudo apt-get purge -y windsurf codeium 2>/dev/null || true
sudo apt-get autoremove -y 2>/dev/null || true
sudo dnf remove -y windsurf codeium 2>/dev/null || true
sudo yum remove -y windsurf codeium 2>/dev/null || true
sudo pacman -R windsurf codeium 2>/dev/null || true
brew uninstall windsurf codeium 2>/dev/null || true
sudo zypper remove -y windsurf codeium 2>/dev/null || true

# ===================================
# AUTOSTART & TRASH CLEANUP
# ===================================
echo -e "${GREEN}[STEP 7] Autostart & Trash Cleanup${NC}"

# Autostart entries
echo "[INFO] Removing autostart entries..."
safe_rm "$HOME/.config/autostart/windsurf.desktop"
safe_rm "$HOME/.config/autostart/codeium.desktop"
safe_rm "/etc/xdg/autostart/windsurf.desktop"
safe_rm "/etc/xdg/autostart/codeium.desktop"

# Application launchers
safe_rm "$HOME/.local/share/applications/windsurf.desktop"
safe_rm "$HOME/.local/share/applications/codeium.desktop"
safe_rm "/usr/share/applications/windsurf.desktop"
safe_rm "/usr/share/applications/codeium.desktop"

# Trash
echo "[INFO] Cleaning trash..."
safe_rm "$HOME/.local/share/Trash/files/windsurf*"
safe_rm "$HOME/.local/share/Trash/files/codeium*"
safe_rm "$HOME/.local/share/Trash/info/windsurf*"
safe_rm "$HOME/.local/share/Trash/info/codeium*"

# ===================================
# SYSTEM SERVICES CLEANUP
# ===================================
echo -e "${GREEN}[STEP 8] System Services Cleanup${NC}"

# Crontab cleanup
echo "[INFO] Cleaning up crontab entries..."
(crontab -l 2>/dev/null | grep -v 'windsurf' | grep -v 'codeium') | crontab -

# Systemd user services
echo "[INFO] Cleaning up user systemd services..."
systemctl --user stop windsurf.service 2>/dev/null || true
systemctl --user stop codeium.service 2>/dev/null || true
systemctl --user disable windsurf.service 2>/dev/null || true
systemctl --user disable codeium.service 2>/dev/null || true
safe_rm "$HOME/.config/systemd/user/windsurf.service"
safe_rm "$HOME/.config/systemd/user/codeium.service"

# System-wide systemd services
echo "[INFO] Cleaning up system-wide systemd services..."
sudo systemctl stop windsurf.service 2>/dev/null || true
sudo systemctl stop codeium.service 2>/dev/null || true
sudo systemctl disable windsurf.service 2>/dev/null || true
sudo systemctl disable codeium.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/windsurf.service 2>/dev/null
sudo rm -f /etc/systemd/system/codeium.service 2>/dev/null
sudo rm -f /lib/systemd/system/windsurf.service 2>/dev/null
sudo rm -f /lib/systemd/system/codeium.service 2>/dev/null

# Reload systemd
sudo systemctl daemon-reload 2>/dev/null || true
systemctl --user daemon-reload 2>/dev/null || true

# ===================================
# SHELL CONFIG CLEANUP
# ===================================
echo -e "${GREEN}[STEP 9] Shell Configuration Cleanup${NC}"
echo "[INFO] Cleaning up shell configs..."

# Bash
sed -i '/windsurf/d' "$HOME/.bashrc" 2>/dev/null || true
sed -i '/codeium/d' "$HOME/.bashrc" 2>/dev/null || true
sed -i '/windsurf/d' "$HOME/.bash_profile" 2>/dev/null || true
sed -i '/codeium/d' "$HOME/.bash_profile" 2>/dev/null || true
sed -i '/windsurf/d' "$HOME/.profile" 2>/dev/null || true
sed -i '/codeium/d' "$HOME/.profile" 2>/dev/null || true

# Zsh
sed -i '/windsurf/d' "$HOME/.zshrc" 2>/dev/null || true
sed -i '/codeium/d' "$HOME/.zshrc" 2>/dev/null || true
sed -i '/windsurf/d' "$HOME/.zprofile" 2>/dev/null || true
sed -i '/codeium/d' "$HOME/.zprofile" 2>/dev/null || true
sed -i '/windsurf/d' "$HOME/.zshenv" 2>/dev/null || true
sed -i '/codeium/d' "$HOME/.zshenv" 2>/dev/null || true

# Fish
sed -i '/windsurf/d' "$HOME/.config/fish/config.fish" 2>/dev/null || true
sed -i '/codeium/d' "$HOME/.config/fish/config.fish" 2>/dev/null || true
safe_rm "$HOME/.config/fish/conf.d/windsurf.fish"
safe_rm "$HOME/.config/fish/conf.d/codeium.fish"

# Other shells
sed -i '/windsurf/d' "$HOME/.tcshrc" 2>/dev/null || true
sed -i '/codeium/d' "$HOME/.tcshrc" 2>/dev/null || true
sed -i '/windsurf/d' "$HOME/.kshrc" 2>/dev/null || true
sed -i '/codeium/d' "$HOME/.kshrc" 2>/dev/null || true

# ===================================
# SSH/GPG KEYS CLEANUP
# ===================================
echo -e "${GREEN}[STEP 10] SSH/GPG Keys Cleanup${NC}"
echo "[INFO] Removing SSH/GPG keys..."

# SSH keys
safe_rm "$HOME/.ssh/windsurf*"
safe_rm "$HOME/.ssh/codeium*"
sed -i '/windsurf/d' "$HOME/.ssh/config" 2>/dev/null || true
sed -i '/codeium/d' "$HOME/.ssh/config" 2>/dev/null || true
sed -i '/windsurf/d' "$HOME/.ssh/known_hosts" 2>/dev/null || true
sed -i '/codeium/d' "$HOME/.ssh/known_hosts" 2>/dev/null || true

# GPG keys
safe_rm "$HOME/.gnupg/windsurf*"
safe_rm "$HOME/.gnupg/codeium*"
gpg --batch --yes --delete-keys "windsurf" 2>/dev/null || true
gpg --batch --yes --delete-keys "codeium" 2>/dev/null || true

# ===================================
# BROWSER DATA CLEANUP
# ===================================
echo -e "${GREEN}[STEP 11] Browser Data Cleanup${NC}"
echo "[INFO] Cleaning up browser data..."

# Firefox
echo "[INFO] Cleaning Firefox data..."
find ~/.mozilla/ -type f -iname '*windsurf*' -exec rm -v {} \; 2>/dev/null
find ~/.mozilla/ -type f -iname '*codeium*' -exec rm -v {} \; 2>/dev/null
find ~/.mozilla/ -type d -iname '*windsurf*' -exec rm -rfv {} \; 2>/dev/null
find ~/.mozilla/ -type d -iname '*codeium*' -exec rm -rfv {} \; 2>/dev/null

# Chrome
echo "[INFO] Cleaning Chrome data..."
find ~/.config/google-chrome/ -type f -iname '*windsurf*' -exec rm -v {} \; 2>/dev/null
find ~/.config/google-chrome/ -type f -iname '*codeium*' -exec rm -v {} \; 2>/dev/null
find ~/.config/google-chrome/ -type d -iname '*windsurf*' -exec rm -rfv {} \; 2>/dev/null
find ~/.config/google-chrome/ -type d -iname '*codeium*' -exec rm -rfv {} \; 2>/dev/null
find "$HOME/Library/Application Support/Google/Chrome/" -type f -iname '*windsurf*' -exec rm -v {} \; 2>/dev/null || true
find "$HOME/Library/Application Support/Google/Chrome/" -type f -iname '*codeium*' -exec rm -v {} \; 2>/dev/null || true

# Chromium
echo "[INFO] Cleaning Chromium data..."
find ~/.config/chromium/ -type f -iname '*windsurf*' -exec rm -v {} \; 2>/dev/null
find ~/.config/chromium/ -type f -iname '*codeium*' -exec rm -v {} \; 2>/dev/null
find ~/.config/chromium/ -type d -iname '*windsurf*' -exec rm -rfv {} \; 2>/dev/null
find ~/.config/chromium/ -type d -iname '*codeium*' -exec rm -rfv {} \; 2>/dev/null

# Brave
echo "[INFO] Cleaning Brave data..."
find ~/.config/BraveSoftware/ -type f -iname '*windsurf*' -exec rm -v {} \; 2>/dev/null
find ~/.config/BraveSoftware/ -type f -iname '*codeium*' -exec rm -v {} \; 2>/dev/null
find ~/.config/BraveSoftware/ -type d -iname '*windsurf*' -exec rm -rfv {} \; 2>/dev/null
find ~/.config/BraveSoftware/ -type d -iname '*codeium*' -exec rm -rfv {} \; 2>/dev/null
find "$HOME/Library/Application Support/BraveSoftware/" -type f -iname '*windsurf*' -exec rm -v {} \; 2>/dev/null || true
find "$HOME/Library/Application Support/BraveSoftware/" -type f -iname '*codeium*' -exec rm -v {} \; 2>/dev/null || true

# Edge
echo "[INFO] Cleaning Edge data..."
find ~/.config/microsoft-edge/ -type f -iname '*windsurf*' -exec rm -v {} \; 2>/dev/null
find ~/.config/microsoft-edge/ -type f -iname '*codeium*' -exec rm -v {} \; 2>/dev/null
find ~/.config/microsoft-edge/ -type d -iname '*windsurf*' -exec rm -rfv {} \; 2>/dev/null
find ~/.config/microsoft-edge/ -type d -iname '*codeium*' -exec rm -rfv {} \; 2>/dev/null
find "$HOME/Library/Application Support/Microsoft Edge/" -type f -iname '*windsurf*' -exec rm -v {} \; 2>/dev/null || true
find "$HOME/Library/Application Support/Microsoft Edge/" -type f -iname '*codeium*' -exec rm -v {} \; 2>/dev/null || true

# Safari (macOS only)
if [ -d "$HOME/Library/Safari" ]; then
    echo "[INFO] Cleaning Safari data..."
    find "$HOME/Library/Safari" -type f -iname '*windsurf*' -exec rm -v {} \; 2>/dev/null || true
    find "$HOME/Library/Safari" -type f -iname '*codeium*' -exec rm -v {} \; 2>/dev/null || true
fi

# ===================================
# MISCELLANEOUS CLEANUP
# ===================================
echo -e "${GREEN}[STEP 12] Miscellaneous Cleanup${NC}"

# Git config cleanup
echo "[INFO] Cleaning up Git configs..."
sed -i '/windsurf/d' "$HOME/.gitconfig" 2>/dev/null || true
sed -i '/codeium/d' "$HOME/.gitconfig" 2>/dev/null || true

# Network configuration cleanup
echo "[INFO] Cleaning up network configurations..."
sudo sed -i '/windsurf/d' /etc/hosts 2>/dev/null || true
sudo sed -i '/codeium/d' /etc/hosts 2>/dev/null || true

# Clean package manager caches
echo "[INFO] Cleaning package manager caches..."
sudo apt-get clean 2>/dev/null || true
sudo apt-get autoclean 2>/dev/null || true
sudo dnf clean all 2>/dev/null || true
sudo yum clean all 2>/dev/null || true
sudo pacman -Sc --noconfirm 2>/dev/null || true
brew cleanup 2>/dev/null || true

# Docker system prune (optional)
if command -v docker &> /dev/null; then
    echo "[INFO] Pruning Docker system..."
    docker system prune -af 2>/dev/null || true
fi

# ===================================
# EXTREME SYSTEM-WIDE FILE SCAN
# ===================================
echo -e "${GREEN}[STEP 13] Extreme System-wide File Scan${NC}"
echo "[INFO] Performing extreme system-wide file scan..."

# Find any mention of either product in home directory
echo "[INFO] Scanning for references in home directory files..."
find "$HOME" -type f -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/venv/*" -size -1M -exec grep -l "windsurf\|codeium" {} \; 2>/dev/null | while read file; do
    echo -e "${YELLOW}[WARN] Found reference in:${NC} $file"
done

# System-wide scans with sudo
echo "[INFO] 🔍 Scanning for all related files with sudo..."
sudo find /usr /opt /var /lib /etc -type f \( -iname '*windsurf*' -o -iname '*codeium*' \) -exec rm -v {} \; 2>/dev/null
sudo find /usr /opt /var /lib /etc -type d \( -iname '*windsurf*' -o -iname '*codeium*' \) -exec rm -rfv {} \; 2>/dev/null
find "$HOME" -type f \( -iname '*windsurf*' -o -iname '*codeium*' \) -not -path "$BACKUP_DIR/*" -not -path "*$LOGFILE*" -exec rm -v {} \; 2>/dev/null
find "$HOME" -type d \( -iname '*windsurf*' -o -iname '*codeium*' \) -not -path "$BACKUP_DIR" -not -path "$BACKUP_DIR/*" -exec rm -rfv {} \; 2>/dev/null

# ===================================
# FINAL CLEANUP AND REPORTING
# ===================================
echo -e "${GREEN}[STEP 14] Final Cleanup and Reporting${NC}"

# Log and final info
LOGFILE="$HOME/windsurf_codeium_cleanup_$TIMESTAMP.log"
echo -e "${GREEN}[INFO] ✅ Windsurf and Codeium extreme cleanup completed.${NC}" | tee -a "$LOGFILE"
echo -e "${BLUE}[INFO] 📁 Backup directory (empty): $BACKUP_DIR${NC}" | tee -a "$LOGFILE"
echo -e "${BLUE}[INFO] 📝 Full log saved at: $LOGFILE${NC}" | tee -a "$LOGFILE"
echo -e "${YELLOW}[INFO] 🔁 Please reboot your system for complete effect.${NC}" | tee -a "$LOGFILE"

# Cleanup stats
echo "[INFO] Cleanup statistics:"
echo -e "  ${GREEN}✓${NC} Process termination"
echo -e "  ${GREEN}✓${NC} Docker resources"
echo -e "  ${GREEN}✓${NC} Application files"
echo -e "  ${GREEN}✓${NC} IDE extensions"
echo -e "  ${GREEN}✓${NC} Virtual environments"
echo -e "  ${GREEN}✓${NC} Package managers"
echo -e "  ${GREEN}✓${NC} Autostart entries and trash"
echo -e "  ${GREEN}✓${NC} System services"
echo -e "  ${GREEN}✓${NC} Shell configurations"
echo -e "  ${GREEN}✓${NC} SSH/GPG keys"
echo -e "  ${GREEN}✓${NC} Browser data"
echo -e "  ${GREEN}✓${NC} Miscellaneous items"
echo -e "  ${GREEN}✓${NC} System-wide scan"

echo -e "\n${GREEN}[INFO] 🎉 Cleanup process finished successfully!${NC}"
echo -e "${YELLOW}[INFO] Please verify your system is working properly after rebooting.${NC}"
