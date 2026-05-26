#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  dotfiles_setup.sh — push your config files to a private GitHub repo
#
#  SETUP:
#    1. Create a NEW private repo on GitHub called "dotfiles"
#    2. Run this script: bash ~/dotfiles_setup.sh
# ─────────────────────────────────────────────────────────────

GITHUB_USER="mrizzo"             # Your GitHub username
REPO_NAME="dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RED='\033[0;31m'
RESET='\033[0m'

echo ""
echo -e "${BOLD}${CYAN}Dotfiles Setup${RESET}"
echo "────────────────────────────────────────"

# ── Create dotfiles directory ─────────────────────────────────
mkdir -p "$DOTFILES_DIR"
cd "$DOTFILES_DIR"

# ── Initialize git repo ───────────────────────────────────────
if [ ! -d ".git" ]; then
  git init
  git branch -M main
  git remote add origin "git@github.com:$GITHUB_USER/$REPO_NAME.git"
  echo -e "${GREEN}✓ Git repo initialized${RESET}"
fi

# ── Copy dotfiles into the repo ───────────────────────────────
copy_dotfile() {
  local file="$1"
  local name="$2"
  if [ -f "$HOME/$file" ]; then
    cp "$HOME/$file" "$DOTFILES_DIR/$name"
    echo -e "  ${GREEN}✓${RESET} Copied $file"
  else
    echo -e "  ${RED}–${RESET} Skipped $file (not found)"
  fi
}

echo -e "\n${BOLD}Copying config files...${RESET}"
copy_dotfile ".zshrc"      ".zshrc"
copy_dotfile ".bashrc"     ".bashrc"
copy_dotfile ".gitconfig"  ".gitconfig"
copy_dotfile ".vimrc"      ".vimrc"
copy_dotfile ".zsh_history" ".zsh_history"

# Copy SSH config (NOT the keys — just the config file)
if [ -f "$HOME/.ssh/config" ]; then
  cp "$HOME/.ssh/config" "$DOTFILES_DIR/ssh_config"
  echo -e "  ${GREEN}✓${RESET} Copied .ssh/config (as ssh_config)"
fi

# ── Create a .gitignore ───────────────────────────────────────
cat > "$DOTFILES_DIR/.gitignore" << 'EOF'
# Never commit SSH private keys
id_rsa
id_ed25519
*.pem
*.key

# macOS
.DS_Store
EOF

# ── Create a simple README ────────────────────────────────────
cat > "$DOTFILES_DIR/README.md" << EOF
# dotfiles

My personal config files. Backed up $(date +%Y-%m-%d).

## Files
- \`.zshrc\` — shell config
- \`.gitconfig\` — git config
- \`.vimrc\` — vim config
- \`ssh_config\` — SSH config (rename to ~/.ssh/config to restore)

## Restore on a new machine
\`\`\`bash
git clone git@github.com:$GITHUB_USER/$REPO_NAME.git ~/.dotfiles
cp ~/.dotfiles/.zshrc ~/.zshrc
cp ~/.dotfiles/.gitconfig ~/.gitconfig
cp ~/.dotfiles/ssh_config ~/.ssh/config
\`\`\`
EOF

# ── Commit and push ───────────────────────────────────────────
echo -e "\n${BOLD}Committing to GitHub...${RESET}"
git add -A
git commit -m "dotfiles backup $(date +%Y-%m-%d)"
git push -u origin main

echo ""
echo "────────────────────────────────────────"
echo -e "${GREEN}${BOLD}✓ Dotfiles pushed to github.com/$GITHUB_USER/$REPO_NAME${RESET}"
echo ""
echo -e "${BOLD}To update anytime:${RESET}"
echo "  bash ~/dotfiles_setup.sh"
echo ""
echo -e "${BOLD}To restore on a new Mac:${RESET}"
echo "  git clone git@github.com:$GITHUB_USER/$REPO_NAME.git ~/.dotfiles"
echo ""
