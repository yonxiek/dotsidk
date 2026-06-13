#!/bin/bash

DOTFILES_DIR=$(pwd)
ZSH_PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

echo "--- Начинаю установку конфигов ---"

# 1. Установка Oh-My-Zsh (если нет)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Установка Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 2. Установка плагинов Zsh (автодополнения и подсветка)
mkdir -p "$ZSH_PLUGINS_DIR"
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
fi

# 3. Копирование конфигов
CONFIG_FOLDERS=("hypr" "waybar" "kitty" "fuzzel" "dunst" "nvim" "gtk-3.0" "gtk-4.0")
mkdir -p ~/.config

for folder in "${CONFIG_FOLDERS[@]}"; do
    if [ -d "$DOTFILES_DIR/.config/$folder" ]; then
        echo "Ставлю конфиг: $folder"
        rm -rf "$HOME/.config/$folder" # Удаляем старое, чтобы не было путаницы
        cp -r "$DOTFILES_DIR/.config/$folder" "$HOME/.config/"
    fi
done

# 4. Копирование .zshrc
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    echo "Ставлю .zshrc"
    cp "$DOTFILES_DIR/.zshrc" "$HOME/"
fi

# 5. Тема курсора
mkdir -p ~/.icons/default
if [ -f "$DOTFILES_DIR/.icons/default/index.theme" ]; then
    cp "$DOTFILES_DIR/.icons/default/index.theme" "$HOME/.icons/default/"
fi

echo "--- Готово! Перезапусти терминал. ---"
