#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  backup.sh — lean rsync backup to any external drive
#
#  USAGE:
#    bash backup.sh <destination-path>
#    bash backup.sh /Volumes/SanDisk
#    bash backup.sh /Volumes/MyPassport
#    bash backup.sh /mnt/nas/backup
#
#  SCHEDULE (runs daily at 9am):
#    crontab -e
#    0 9 * * * /bin/bash $HOME/backup.sh /Volumes/SanDisk >> $HOME/.backup.log 2>&1
# ─────────────────────────────────────────────────────────────

# ── Config ────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Require a drive name argument
if [ -z "$1" ]; then
  echo -e "${RED}Usage: bash backup.sh <destination-path>${RESET}"
  echo -e "  Example: bash backup.sh /Volumes/SanDisk"
  echo -e "  Example: bash backup.sh /mnt/nas/backup"
  echo ""
  echo -e "Available volumes:"
  ls /Volumes/
  exit 1
fi

DEST="$1/Backup/$(hostname -s)"
LOG="$HOME/.backup.log"

# ── What to back up ───────────────────────────────────────────
SOURCES=(
  "$HOME/Documents"
  "$HOME/Desktop"
  "$HOME/Pictures"
  "$HOME/Downloads"
  "$HOME/.ssh"
  "$HOME/.zshrc"
  "$HOME/.gitconfig"
  "$HOME/.zsh_history"
)

# ── Check destination is accessible ──────────────────────────
if [ ! -d "$1" ]; then
  echo -e "${RED}✗ Destination '$1' is not accessible. Skipping backup.${RESET}"
  echo "$(date): SKIPPED — destination not accessible: $1" >> "$LOG"
  exit 1
fi

# ── Create destination ────────────────────────────────────────
mkdir -p "$DEST"

echo ""
echo -e "${BOLD}${CYAN}Starting backup → $DEST${RESET}"
echo -e "${CYAN}$(date)${RESET}"
echo "────────────────────────────────────────"

START=$(date +%s)

# ── Run rsync for each source ─────────────────────────────────
for SOURCE in "${SOURCES[@]}"; do
  if [ -e "$SOURCE" ]; then
    echo -e "\n${BOLD}Backing up:${RESET} $SOURCE"
    rsync -ah --progress --delete \
      --exclude='.DS_Store' \
      --exclude='*.tmp' \
      --exclude='node_modules/' \
      --exclude='*.pyc' \
      --exclude='.Trash/' \
      "$SOURCE" "$DEST/"
  else
    echo -e "${RED}  Skipping $SOURCE (not found)${RESET}"
  fi
done

# ── Done ──────────────────────────────────────────────────────
END=$(date +%s)
ELAPSED=$((END - START))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

echo ""
echo "────────────────────────────────────────"
echo -e "${GREEN}${BOLD}✓ Backup complete in ${MINUTES}m ${SECONDS}s${RESET}"
echo -e "  Saved to: $DEST"
echo "$(date): SUCCESS (${MINUTES}m ${SECONDS}s)" >> "$LOG"

# Show backup size
du -sh "$DEST" 2>/dev/null | awk '{print "  Total size: "$1}'
echo ""

# ─────────────────────────────────────────────────────────────
#  TO SCHEDULE THIS AUTOMATICALLY (runs daily at 9am):
#
#  1. Open Terminal and run:
#       crontab -e
#
#  2. Add this line (swap in your actual destination path):
#       0 9 * * * /bin/bash $HOME/backup.sh /Volumes/SanDisk >> $HOME/.backup.log 2>&1
#
#  3. Save and exit
#
#  View backup log anytime:
#       cat ~/.backup.log
# ─────────────────────────────────────────────────────────────
