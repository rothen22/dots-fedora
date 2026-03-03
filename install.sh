#!/bin/bash
# install.sh - Install dots-fedora dotfiles and required tools

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
CONFIG_DIR="$HOME_DIR/.config"

echo "Installing dotfiles and tools from $DOTFILES_DIR..."
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to create symlink
link_file() {
    local source="$1"
    local target="$2"
    
    # Check if source exists
    if [ ! -e "$source" ]; then
        echo -e "${RED}✗ Source not found: $source${NC}"
        return 1
    fi
    
    # If target is a symlink, remove it
    if [ -L "$target" ]; then
        echo -e "${GREEN}✓ Already linked: $target${NC}"
        return 0
    fi
    
    # If target exists (and is not a symlink), back it up
    if [ -e "$target" ]; then
        echo -e "${YELLOW}⚠ Backing up existing: $target → $target.bak${NC}"
        mv "$target" "$target.bak"
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"
    
    # Create symlink
    ln -s "$source" "$target"
    echo -e "${GREEN}✓ Linked: $target${NC}"
}

# Function to symlink entire directory contents
link_dir_contents() {
    local source_dir="$1"
    local target_dir="$2"
    
    if [ ! -d "$source_dir" ]; then
        echo -e "${RED}✗ Source directory not found: $source_dir${NC}"
        return 1
    fi
    
    mkdir -p "$target_dir"
    
    # Symlink each file in the directory
    for file in "$source_dir"/*; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")
            local target="$target_dir/$filename"
            
            # Remove if symlink already exists
            if [ -L "$target" ]; then
                echo -e "${GREEN}✓ Already linked: $target${NC}"
            # Back up if regular file exists
            elif [ -e "$target" ]; then
                echo -e "${YELLOW}⚠ Backing up existing: $target → $target.bak${NC}"
                mv "$target" "$target.bak"
                ln -s "$file" "$target"
                echo -e "${GREEN}✓ Linked: $target${NC}"
            else
                ln -s "$file" "$target"
                echo -e "${GREEN}✓ Linked: $target${NC}"
            fi
        fi
    done
}

# Function to check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Function to install package
install_package() {
    local package="$1"
    local name="${2:-$package}"
    
    if command_exists "$name"; then
        echo -e "${GREEN}✓ $name already installed${NC}"
    else
        echo -e "${YELLOW}Installing $name...${NC}"
        sudo dnf install -y "$package"
        echo -e "${GREEN}✓ $name installed${NC}"
    fi
}

# ============================================================
# INSTALL TOOLS & PACKAGES
# ============================================================
echo -e "${BLUE}=== Installing Tools & Packages ===${NC}"
echo ""

# Check if dnf is available
if ! command_exists dnf; then
    echo -e "${RED}✗ dnf not found. This script requires Fedora/RHEL.${NC}"
    exit 1
fi

# Core utilities
echo -e "${BLUE}Core Utilities:${NC}"
install_package "git" "git"
install_package "curl" "curl"
install_package "wget" "wget"
install_package "unzip" "unzip"
echo ""

# Shell & prompt
echo -e "${BLUE}Shell & Prompt:${NC}"
install_package "bash" "bash"
install_package "starship" "starship"
install_package "zoxide" "zoxide"
echo ""

# Terminal
echo -e "${BLUE}Terminal:${NC}"
install_package "kitty" "kitty"
echo ""

# Editors
echo -e "${BLUE}Editors:${NC}"
install_package "helix" "hx"
echo ""

# File utilities
echo -e "${BLUE}File Utilities:${NC}"
install_package "lsd" "lsd"
install_package "bat" "bat"
echo ""

# Optional: Add more tools here
echo -e "${BLUE}Optional Development Tools:${NC}"
echo -e "${YELLOW}Install development tools? (y/n)${NC}"
read -r install_dev

if [[ "$install_dev" =~ ^[Yy]$ ]]; then
    install_package "gcc" "gcc"
    install_package "make" "make"
    install_package "nodejs" "node"
    install_package "npm" "npm"
    install_package "python3" "python3"
    install_package "git-core" "git"
fi

echo ""

# ============================================================
# HOME DIRECTORY DOTFILES
# ============================================================
echo -e "${BLUE}=== Installing Dotfiles ===${NC}"
echo ""

echo "Installing home directory dotfiles..."
link_file "$DOTFILES_DIR/.bashrc" "$HOME_DIR/.bashrc"
link_file "$DOTFILES_DIR/.bash_aliases" "$HOME_DIR/.bash_aliases"
echo ""

# ============================================================
# .bashrc.d MODULAR CONFIGS
# ============================================================
echo "Installing modular bash configurations..."
link_dir_contents "$DOTFILES_DIR/.bashrc.d" "$HOME_DIR/.bashrc.d"
echo ""

# ============================================================
# APPLICATION CONFIGS
# ============================================================
echo -e "${BLUE}=== Installing Application Configs ===${NC}"
echo ""

mkdir -p "$CONFIG_DIR"

# Helix editor config
if [ -d "$DOTFILES_DIR/helix" ]; then
    echo "Installing helix config..."
    link_file "$DOTFILES_DIR/helix" "$CONFIG_DIR/helix"
    echo ""
fi

# Kitty terminal config
if [ -d "$DOTFILES_DIR/kitty" ]; then
    echo "Installing kitty config..."
    link_file "$DOTFILES_DIR/kitty" "$CONFIG_DIR/kitty"
    echo ""
fi

# ============================================================
# VERIFICATION
# ============================================================
echo -e "${BLUE}=== Verification ===${NC}"
echo ""

echo "Dotfiles:"
if [ -L "$HOME_DIR/.bashrc" ] || [ -f "$HOME_DIR/.bashrc" ]; then
    echo -e "${GREEN}✓ .bashrc${NC}"
else
    echo -e "${RED}✗ .bashrc not found${NC}"
fi

if [ -L "$HOME_DIR/.bash_aliases" ] || [ -f "$HOME_DIR/.bash_aliases" ]; then
    echo -e "${GREEN}✓ .bash_aliases${NC}"
else
    echo -e "${RED}✗ .bash_aliases not found${NC}"
fi

if [ -d "$HOME_DIR/.bashrc.d" ]; then
    count=$(ls -1 "$HOME_DIR/.bashrc.d" 2>/dev/null | wc -l)
    echo -e "${GREEN}✓ .bashrc.d ($count files)${NC}"
else
    echo -e "${RED}✗ .bashrc.d not found${NC}"
fi

echo ""
echo "Application Configs:"
if [ -d "$CONFIG_DIR/helix" ]; then
    echo -e "${GREEN}✓ helix config${NC}"
else
    echo -e "${YELLOW}⚠ helix config not installed${NC}"
fi

if [ -d "$CONFIG_DIR/kitty" ]; then
    echo -e "${GREEN}✓ kitty config${NC}"
else
    echo -e "${YELLOW}⚠ kitty config not installed${NC}"
fi

echo ""
echo "Tools:"
command_exists starship && echo -e "${GREEN}✓ starship${NC}" || echo -e "${YELLOW}✗ starship${NC}"
command_exists zoxide && echo -e "${GREEN}✓ zoxide${NC}" || echo -e "${YELLOW}✗ zoxide${NC}"
command_exists kitty && echo -e "${GREEN}✓ kitty${NC}" || echo -e "${YELLOW}✗ kitty${NC}"
command_exists hx && echo -e "${GREEN}✓ helix${NC}" || echo -e "${YELLOW}✗ helix${NC}"
command_exists lsd && echo -e "${GREEN}✓ lsd${NC}" || echo -e "${YELLOW}✗ lsd${NC}"
command_exists bat && echo -e "${GREEN}✓ bat${NC}" || echo -e "${YELLOW}✗ bat${NC}"

echo ""
echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.bashrc"
echo "  2. Configure kitty: hx ~/.config/kitty/kitty.conf"
echo "  3. Configure helix: hx ~/.config/helix/config.toml"
echo ""
echo "Useful commands:"
echo "  dotcommit 'message' - Commit dotfiles"
echo "  dotpush             - Push dotfiles"
echo ""
