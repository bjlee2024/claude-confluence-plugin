#!/bin/bash
set -e

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$PLUGIN_DIR/skills"
HOOKS_FILE="$PLUGIN_DIR/hooks/hooks.json"

echo "=== Claude Confluence Plugin Installer ==="
echo ""

# Check for target: global or project
TARGET="${1:-global}"

if [ "$TARGET" = "global" ]; then
    SKILLS_DEST="$HOME/.claude/skills"
    SETTINGS_FILE="$HOME/.claude/settings.json"
    echo "Installing globally to ~/.claude/ ..."
elif [ "$TARGET" = "project" ]; then
    SKILLS_DEST=".claude/skills"
    SETTINGS_FILE=".claude/settings.json"
    echo "Installing to project directory .claude/ ..."
else
    echo "Usage: ./install.sh [global|project]"
    echo "  global  - Install to ~/.claude/ (default)"
    echo "  project - Install to ./.claude/"
    exit 1
fi

# --- 1. Skills ---
mkdir -p "$SKILLS_DEST/confluence-init"
mkdir -p "$SKILLS_DEST/confluence"
cp "$SKILLS_DIR/confluence-init/SKILL.md" "$SKILLS_DEST/confluence-init/"
cp "$SKILLS_DIR/confluence/SKILL.md" "$SKILLS_DEST/confluence/"

echo ""
echo "Installed skills:"
echo "  - $SKILLS_DEST/confluence-init/SKILL.md"
echo "  - $SKILLS_DEST/confluence/SKILL.md"

# --- 2. Hooks ---
SETTINGS_DIR="$(dirname "$SETTINGS_FILE")"
mkdir -p "$SETTINGS_DIR"

if ! command -v node &>/dev/null; then
    echo ""
    echo "[!] node not found. Skipping hooks installation."
    echo "    Manually merge $HOOKS_FILE into $SETTINGS_FILE"
else
    node -e "
const fs = require('fs');

const hooksFile = process.argv[1];
const settingsFile = process.argv[2];

// Read plugin hooks
const pluginConfig = JSON.parse(fs.readFileSync(hooksFile, 'utf8'));
const pluginHooks = pluginConfig.hooks || {};

// Read existing settings (or create empty)
let settings = {};
try {
    settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'));
} catch {
    // File doesn't exist or is invalid — start fresh
}

// Ensure hooks object
if (!settings.hooks) {
    settings.hooks = {};
}

// Merge each hook event (e.g. PreToolUse, PostToolUse)
for (const [event, pluginEntries] of Object.entries(pluginHooks)) {
    if (!settings.hooks[event]) {
        settings.hooks[event] = [];
    }

    for (const entry of pluginEntries) {
        // Skip if an entry with the same description already exists
        const exists = settings.hooks[event].some(
            (e) => e.description === entry.description
        );
        if (!exists) {
            settings.hooks[event].push(entry);
        }
    }
}

fs.writeFileSync(settingsFile, JSON.stringify(settings, null, 2) + '\n');
" "$HOOKS_FILE" "$SETTINGS_FILE"

    echo ""
    echo "Installed hooks to $SETTINGS_FILE:"
    echo "  - Confluence Constitution: Block create/update/delete without user confirmation"
fi

# --- 3. Check confluence-cli ---
echo ""
echo "Available commands:"
echo "  /confluence-init  - Confluence CLI setup"
echo "  /confluence       - Confluence operations"
echo ""

if ! command -v confluence &>/dev/null; then
    echo "[!] confluence-cli is not installed."
    echo "    Run: npm install -g confluence-cli"
    echo "    Or use /confluence-init in Claude Code to set up."
else
    echo "[OK] confluence-cli is installed: $(which confluence)"
fi

echo ""
echo "Installation complete!"
