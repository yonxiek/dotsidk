#!/bin/bash

# --- Настройки путей ---
# Безопасное определение папки репозитория (где лежит скрипт)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
BACKUP_DIR="$HOME/.config/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# --- Цвета для красивого вывода ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Без цвета

echo -e "${BLUE}--- Начинаю установку конфигов ---${NC}\n"

# 1. Установка Oh-My-Zsh (если нет)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}Установка Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo -e "${GREEN}✔ Oh-My-Zsh уже установлен.${NC}"
fi

# 2. Установка плагинов Zsh
echo -e "${BLUE}Проверка плагинов Zsh...${NC}"
mkdir -p "$ZSH_PLUGINS_DIR"
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
fi
echo -e "${GREEN}✔ Плагины Zsh готовы.${NC}\n"

# 3. Симлинки для конфигов (Вместо копирования)
CONFIG_FOLDERS=("hypr" "waybar" "kitty" "fuzzel" "dunst" "nvim")
mkdir -p "$HOME/.config"

echo -e "${BLUE}Установка конфигов (создание симлинков)...${NC}"
for folder in "${CONFIG_FOLDERS[@]}"; do
    SRC="$DOTFILES_DIR/configs/$folder"
    DEST="$HOME/.config/$folder"

    if [ -d "$SRC" ]; then
        # Если существует реальная папка (не симлинк), делаем бэкап
        if [ -d "$DEST" ] && [ ! -L "$DEST" ]; then
            echo -e "${YELLOW}  > Делаю бэкап старого $folder в $BACKUP_DIR...${NC}"
            mkdir -p "$BACKUP_DIR"
            mv "$DEST" "$BACKUP_DIR/"
        # Если это старый симлинк, просто удаляем его
        elif [ -L "$DEST" ]; then
            rm "$DEST"
        fi
        
        # Создаем симлинк
        ln -s "$SRC" "$DEST"
        echo -e "${GREEN}✔ $folder настроен!${NC}"
    else
        echo -e "${RED}✖ Папка $folder не найдена в репозитории!${NC}"
    fi
done

# 4. Симлинк для .zshrc
echo -e "\n${BLUE}Настройка .zshrc...${NC}"
ZSHRC_SRC="$DOTFILES_DIR/configs/.zshrc"
ZSHRC_DEST="$HOME/.zshrc"

if [ -f "$ZSHRC_SRC" ]; then
    if [ -f "$ZSHRC_DEST" ] && [ ! -L "$ZSHRC_DEST" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$ZSHRC_DEST" "$BACKUP_DIR/"
    elif [ -L "$ZSHRC_DEST" ]; then
        rm "$ZSHRC_DEST"
    fi
    ln -s "$ZSHRC_SRC" "$ZSHRC_DEST"
    echo -e "${GREEN}✔ .zshrc настроен!${NC}"
else
    echo -e "${RED}✖ .zshrc не найден в репозитории!${NC}"
fi

echo -e "\n${GREEN}--- Готово! Перезапусти терминал (или напиши 'exec zsh'). ---${NC}"
