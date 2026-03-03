#!/bin/bash
# install.sh - Install dots-fedora dotfiles with proper symlink handling

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
CONFIG_DIR="$HOME_DIR/.config"

echo "Installing dotfiles from $DOTFILES_DIR..."
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Function to symlink entire directory contents (not the directory itself)
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

# ============================================================
# HOME DIRECTORY DOTFILES
# ============================================================
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
echo "Installing application configurations..."
mkdir -p "$CONFIG_DIR"

# Helix editor config
if [ -d "$DOTFILES_DIR/helix" ]; then
    link_file "$DOTFILES_DIR/helix" "$CONFIG_DIR/helix"
    echo ""
fi

# Kitty terminal config
if [ -d "$DOTFILES_DIR/kitty" ]; then
    link_file "$DOTFILES_DIR/kitty" "$CONFIG_DIR/kitty"
    echo ""
fi

# ============================================================
# VERIFICATION
# ============================================================
echo "Verifying installation..."
echo ""

# Check if symlinks exist
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
echo -e "${GREEN}✓ Dotfiles installed successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review ~/.bashrc to ensure it looks correct"
echo "  2. Run: source ~/.bashrc"
echo "  3. Test: echo \$PATH, which starship, which zoxide"
echo ""
echo "To uninstall, run:"
echo "  rm ~/.bashrc ~/.bash_aliases ~/.bashrc.d"
echo "  rm -rf ~/.config/helix ~/.config/kitty"
