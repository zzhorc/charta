#!/usr/bin/env bash
# Charta Theme Installer

set -euo pipefail

RAW_BASE="${CHARTA_RAW_BASE:-https://raw.githubusercontent.com/zzhorc/charta/main}"
RAW_BASE="${RAW_BASE%/}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_SUFFIX="$(date +%Y%m%d%H%M%S)-$$"
INSTALL_STARSHIP=false
INSTALL_KAKU=false
INSTALL_GHOSTTY=false
INSTALL_WARP=false
INSTALL_ALACRITTY=false
INSTALL_ITERM2=false

echo "Starting installation of Charta Theme..."
echo "Using source: $RAW_BASE"

show_menu() {
    echo ""
    echo "Choose components to install:"
    echo "  1. Starship prompt"
    echo "  2. Kaku"
    echo "  3. Ghostty"
    echo "  4. Warp"
    echo "  5. Alacritty"
    echo "  6. iTerm2"
    echo "  7. All"
    echo ""
    echo "Enter one or more numbers separated by commas or spaces, for example: 1,3,4"
}

read_selection() {
    if [ -n "${CHARTA_COMPONENTS:-}" ]; then
        echo "$CHARTA_COMPONENTS"
        return
    fi

    local selection

    if [ -r /dev/tty ] && [ -w /dev/tty ]; then
        show_menu > /dev/tty
        printf "Selection: " > /dev/tty
        IFS= read -r selection < /dev/tty
        echo "$selection"
        return
    fi

    if [ -t 0 ]; then
        show_menu >&2
        printf "Selection: " >&2
        IFS= read -r selection
        echo "$selection"
        return
    fi

    echo "Error: no interactive terminal found." >&2
    echo "Set CHARTA_COMPONENTS to install non-interactively, for example:" >&2
    echo "  CHARTA_COMPONENTS=starship,ghostty bash <(curl -fsSL $RAW_BASE/install.sh)" >&2
    exit 1
}

select_all() {
    INSTALL_STARSHIP=true
    INSTALL_KAKU=true
    INSTALL_GHOSTTY=true
    INSTALL_WARP=true
    INSTALL_ALACRITTY=true
    INSTALL_ITERM2=true
}

select_components() {
    local selection="$1"
    local token

    selection="$(printf "%s" "$selection" | tr '[:upper:],' '[:lower:] ')"

    if [ -z "$(printf "%s" "$selection" | tr -d '[:space:]')" ]; then
        echo "Error: no components selected." >&2
        exit 1
    fi

    for token in $selection; do
        case "$token" in
            1|starship|prompt)
                INSTALL_STARSHIP=true
                ;;
            2|kaku)
                INSTALL_KAKU=true
                ;;
            3|ghostty)
                INSTALL_GHOSTTY=true
                ;;
            4|warp)
                INSTALL_WARP=true
                ;;
            5|alacritty)
                INSTALL_ALACRITTY=true
                ;;
            6|iterm2|iterm)
                INSTALL_ITERM2=true
                ;;
            7|all)
                select_all
                ;;
            *)
                echo "Error: unknown component '$token'." >&2
                exit 1
                ;;
        esac
    done
}

print_selected_components() {
    echo ""
    echo "Selected components:"
    [ "$INSTALL_STARSHIP" = true ] && echo " - Starship prompt"
    [ "$INSTALL_KAKU" = true ] && echo " - Kaku"
    [ "$INSTALL_GHOSTTY" = true ] && echo " - Ghostty"
    [ "$INSTALL_WARP" = true ] && echo " - Warp"
    [ "$INSTALL_ALACRITTY" = true ] && echo " - Alacritty"
    [ "$INSTALL_ITERM2" = true ] && echo " - iTerm2"
    echo ""
}

fetch_file() {
    local source_path="$1"
    local output_path="$2"
    local url="$RAW_BASE/$source_path"

    if command -v curl >/dev/null 2>&1; then
        if ! curl -fsSL "$url" -o "$output_path"; then
            rm -f "$output_path"
            echo "Error: failed to download $url" >&2
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -qO "$output_path" "$url"; then
            rm -f "$output_path"
            echo "Error: failed to download $url" >&2
            exit 1
        fi
    else
        echo "Error: curl or wget is required to download Charta files." >&2
        exit 1
    fi
}

backup_file() {
    local target_path="$1"

    if [ -f "$target_path" ]; then
        local backup_path="$target_path.bak.$BACKUP_SUFFIX"
        echo "Backing up $target_path to $backup_path"
        mv "$target_path" "$backup_path"
    fi
}

install_file() {
    local source_path="$1"
    local target_path="$2"
    local tmp_path

    echo "Installing $target_path"
    mkdir -p "$(dirname "$target_path")"
    tmp_path="$(mktemp "$target_path.tmp.XXXXXX")"
    fetch_file "$source_path" "$tmp_path"
    backup_file "$target_path"
    mv "$tmp_path" "$target_path"
}

select_components "$(read_selection)"
print_selected_components

if [ "$INSTALL_STARSHIP" = true ]; then
    install_file "prompt/starship.toml" "$CONFIG_DIR/starship.toml"
fi

if [ "$INSTALL_KAKU" = true ]; then
    install_file "terminals/kaku/kaku.lua" "$CONFIG_DIR/kaku/kaku.lua"
fi

if [ "$INSTALL_GHOSTTY" = true ]; then
    install_file "terminals/ghostty/Charta-Light" "$CONFIG_DIR/ghostty/themes/Charta-Light"
    install_file "terminals/ghostty/Charta-Dark" "$CONFIG_DIR/ghostty/themes/Charta-Dark"
fi

if [ "$INSTALL_WARP" = true ]; then
    install_file "terminals/warp/charta_light.yaml" "$HOME/.warp/themes/charta_light.yaml"
    install_file "terminals/warp/charta_dark.yaml" "$HOME/.warp/themes/charta_dark.yaml"
fi

if [ "$INSTALL_ALACRITTY" = true ]; then
    install_file "terminals/alacritty/charta_light.toml" "$CONFIG_DIR/alacritty/themes/charta_light.toml"
    install_file "terminals/alacritty/charta_dark.toml" "$CONFIG_DIR/alacritty/themes/charta_dark.toml"
fi

if [ "$INSTALL_ITERM2" = true ]; then
    install_file "terminals/iterm2/Charta-Light.itermcolors" "$CONFIG_DIR/charta/iterm2/Charta-Light.itermcolors"
    install_file "terminals/iterm2/Charta-Dark.itermcolors" "$CONFIG_DIR/charta/iterm2/Charta-Dark.itermcolors"
fi

echo ""
echo "Charta files installed successfully."
echo "Remote install command:"
echo "  bash <(curl -fsSL $RAW_BASE/install.sh)"
echo "Non-interactive example:"
echo "  CHARTA_COMPONENTS=starship,ghostty bash <(curl -fsSL $RAW_BASE/install.sh)"
echo ""
echo "Notes:"
[ "$INSTALL_STARSHIP" = true ] && echo " - Starship config is installed to $CONFIG_DIR/starship.toml"
[ "$INSTALL_KAKU" = true ] && echo " - Kaku config is installed to $CONFIG_DIR/kaku/kaku.lua"
[ "$INSTALL_GHOSTTY" = true ] && echo " - Ghostty themes are installed to $CONFIG_DIR/ghostty/themes/"
[ "$INSTALL_WARP" = true ] && echo " - Warp themes are installed to $HOME/.warp/themes/"
[ "$INSTALL_ALACRITTY" = true ] && echo " - Alacritty themes are installed to $CONFIG_DIR/alacritty/themes/"
[ "$INSTALL_ITERM2" = true ] && echo " - iTerm2 presets are downloaded to $CONFIG_DIR/charta/iterm2/ for manual import"
echo ""
echo "Installation complete. Enjoy Charta!"
