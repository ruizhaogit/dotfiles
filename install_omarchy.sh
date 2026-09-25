#!/bin/bash

# install_omarchy.sh
# Script to install dotfiles and dependencies on Omarchy system
# Sourced from install.sh and adapted for Arch Linux / Omarchy

set -e

# Detect AUTO_YES flag for unattended testing
AUTO_YES=false
for arg in "$@"; do
    if [[ "$arg" == "-y" || "$arg" == "--yes" ]]; then
        AUTO_YES=true
    fi
done

confirm_action() {
    local prompt="$1"
    local skip_on_auto="${2:-false}"
    if [ "$AUTO_YES" = true ]; then
        if [ "$skip_on_auto" = true ]; then
            echo "$prompt (y/n): n [Auto-skipped in non-interactive mode]"
            return 1
        fi
        echo "$prompt (y/n): y"
        return 0
    fi
    read -p "$prompt (y/n): " confirm < /dev/tty
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

echo "=========================================="
echo "Starting Omarchy setup..."
echo "=========================================="

# Create target workspace directory
mkdir -p ~/ruizhao/workspace

ARCH=$(uname -m)
echo "System architecture: $ARCH"

# Base Packages List mapped from Ubuntu to Arch Linux
PACKAGES=(
    "python-pip"
    "ncurses"
    "autoconf"
    "pkgconf"
    "make"
    "base-devel"
    "git"
    "rsync"
    "curl"
    "unzip"
    "tmux"
    "ripgrep"
    "ccls"
    "bear"
    "glow"
)

TO_INSTALL=()
echo "Checking package status..."
for pkg in "${PACKAGES[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null || pacman -Qg "$pkg" &>/dev/null; then
        echo "[✓] $pkg is already installed."
    else
        echo "[ ] $pkg is missing."
        TO_INSTALL+=("$pkg")
    fi
done

if [ ${#TO_INSTALL[@]} -ne 0 ]; then
    if confirm_action "Install missing pkgs?"; then
        echo "------------------------------------------"
        echo "Installing missing packages: ${TO_INSTALL[*]}"
        if ! omarchy pkg add "${TO_INSTALL[@]}"; then
            echo "omarchy pkg add failed. Trying individual manual pacman installation..."
            for pkg in "${TO_INSTALL[@]}"; do
                echo "Installing $pkg..."
                sudo pacman -S --noconfirm --needed "$pkg" || true
            done
        fi
    fi
else
    echo "------------------------------------------"
    echo "All standard dependencies are already satisfied."
fi

if confirm_action "Install trzsz?"; then
    echo "Attempting to install trzsz from AUR..."
    if ! omarchy pkg aur add trzsz; then
        echo "AUR installation of trzsz failed. Falling back to pip..."
        python3 -m pip install --user --upgrade trzsz --break-system-packages || python3 -m pip install --upgrade trzsz || true
    fi
fi

if confirm_action "Install jupytext for vim?"; then
    echo "Attempting to install jupytext from AUR..."
    if ! omarchy pkg aur add python-jupytext; then
        echo "AUR installation of python-jupytext failed. Falling back to pip..."
        pip install --user jupytext --break-system-packages || pip install jupytext || true
    fi
    echo "Install jupytext for vim: done."
fi

if confirm_action "Download dotfiles?"; then
    # check if we are currently executing from inside a dotfiles folder in the workspace
    CURRENT_DIR=$(pwd)
    if [[ "$CURRENT_DIR" == *"/workspace/dotfiles"* ]]; then
        echo "We are currently running this script from inside the dotfiles folder ($CURRENT_DIR)."
        echo "Skipping redownloading dotfiles to avoid deleting the active repository."
    else
        mkdir -p ~/ruizhao/workspace
        cd ~/ruizhao/workspace 
        rm -rf dotfiles-main
        rm -rf dotfiles
        curl -fLo dotfiles.zip https://github.com/ruizhaogit/dotfiles/archive/refs/heads/main.zip
        unzip dotfiles.zip
        mv dotfiles-main dotfiles
    fi
fi

if confirm_action "Use rsync to copy files?" "true"; then
    echo "input ip and username"
    read -p "Enter Remote IP Address: " remote_ip < /dev/tty
    read -p "Enter Username: " username < /dev/tty
    echo "start copy"
    mkdir -p ~/.vim/plugged
    mkdir -p ~/.vim/autoload
    mkdir -p ~/.tmux/plugins
    cd ~
    rsync -avzR "$username@$remote_ip":.tmux/plugins/tpm.zip \
    :.tmux/plugins/tmux-continuum \
    :.tmux/plugins/tmux-resurrect \
    :.vimrc \
    :.vim/autoload/plug.vim \
    :.vim/coc-settings.json \
    :.config/coc \
    :.vim/plugged \
    :.fzf.zip \
    :ruizhao/workspace/vim.tar.gz \
    :ruizhao/workspace/ctags.zip \
    :ruizhao/workspace/nvm.tar.gz \
    :.fzf \
    ~/
    sudo scp "$username@$remote_ip":~/.fzf/bin/fzf /usr/bin/
    echo "copy done"
fi

if confirm_action "Download tmux conf and plugins?"; then
    ## tmux
    # download .tmux.conf (use local if exists, otherwise curl)
    FILE="$HOME/.tmux.conf"
    if [ ! -f "$FILE" ]; then
        if [ -f "$HOME/workspace/dotfiles/rc_files/.tmux.conf" ]; then
            cp "$HOME/workspace/dotfiles/rc_files/.tmux.conf" ~/.tmux.conf
        elif [ -f "$HOME/ruizhao/workspace/dotfiles/rc_files/.tmux.conf" ]; then
            cp "$HOME/ruizhao/workspace/dotfiles/rc_files/.tmux.conf" ~/.tmux.conf
        else
            curl -fLo ~/.tmux.conf "https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/.tmux.conf"
        fi
    fi
    # download tmux plugin manager
    FILE="$HOME/.tmux/plugins/tpm.zip"
    if [ ! -f "$FILE" ]; then
        echo "$FILE" does not exist, start downloading.
        curl -fLo ~/.tmux/plugins/tpm.zip --create-dirs https://github.com/tmux-plugins/tpm/archive/refs/heads/master.zip
    fi
    cd ~/.tmux/plugins/
    rm -rf tpm-master
    rm -rf tpm
    unzip tpm.zip
    mv tpm-master tpm
    # If this fails, the script continues because 'true' always succeeds
    DIR="$HOME/.tmux/plugins/tmux-continuum"
    if [ ! -d "$DIR" ]; then
        ~/.tmux/plugins/tpm/bin/install_plugins || true
    fi
fi

if confirm_action "Install and configure Vim and plugins?"; then
    # Make sure vim is installed (Omarchy standard)
    if ! command -v vim >/dev/null 2>&1; then
        echo "Installing vim..."
        omarchy pkg add vim
    fi

    # Set up ~/.vimrc and autoload/plug.vim, etc.
    FILE="$HOME/.vimrc"
    if [ ! -f "$FILE" ]; then
        echo "Installing vim plugins..."
        # download .vimrc (use local one if exists, otherwise curl)
        if [ -f "$HOME/workspace/dotfiles/rc_files/.vimrc" ]; then
            cp "$HOME/workspace/dotfiles/rc_files/.vimrc" ~/.vimrc
        elif [ -f "$HOME/ruizhao/workspace/dotfiles/rc_files/.vimrc" ]; then
            cp "$HOME/ruizhao/workspace/dotfiles/rc_files/.vimrc" ~/.vimrc
        else
            curl -fLo ~/.vimrc "https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/.vimrc"
        fi

        # install vim plugin manager
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
        
        # download coc-settings.json (use local if exists, otherwise curl)
        if [ -f "$HOME/workspace/dotfiles/rc_files/coc-settings.json" ]; then
            mkdir -p ~/.vim
            cp "$HOME/workspace/dotfiles/rc_files/coc-settings.json" ~/.vim/coc-settings.json
        elif [ -f "$HOME/ruizhao/workspace/dotfiles/rc_files/coc-settings.json" ]; then
            mkdir -p ~/.vim
            cp "$HOME/ruizhao/workspace/dotfiles/rc_files/coc-settings.json" ~/.vim/coc-settings.json
        else
            curl -fLo ~/.vim/coc-settings.json --create-dirs "https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/coc-settings.json"
        fi

        # Install plugins non-interactively
        vim -es -u ~/.vimrc +'PlugInstall --sync' +qa < /dev/null || true
        
        # install markdown preview plugin based on glow
        curl -fLo ~/.vim/plugin/markdown-preview.vim --create-dirs "https://raw.githubusercontent.com/ruizhaogit/glowing-vim-markdown-preview/refs/heads/main/markdown-preview.vim"
        echo "Vim plugin installation done."
    else
        echo "~/.vimrc already exists. Skipping config..."
    fi
fi

if confirm_action "Install universal-ctags?"; then
    echo "Installing universal-ctags..."
    if ! omarchy pkg add ctags; then
        echo "omarchy pkg add ctags failed. Trying manual compilation from source..."
        cd ~/ruizhao/workspace
        FILE="$HOME/ruizhao/workspace/ctags.zip"
        if [ ! -f "$FILE" ]; then
            curl -fLo ctags.zip https://github.com/universal-ctags/ctags/archive/refs/heads/master.zip
        fi
        rm -rf ctags-master
        rm -rf ctags
        unzip ctags.zip
        mv ctags-master ctags
        cd ~/ruizhao/workspace/ctags
        ./autogen.sh
        ./configure --prefix=/usr/local
        make
        sudo make install
    fi
    echo "universal-ctags installation done."
fi

if confirm_action "Update bashrc?"; then
    # update ~/.bashrc
    echo "set -o vi" >> ~/.bashrc
    echo "export TERM=xterm-256color" >> ~/.bashrc
    echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash' >> ~/.bashrc
    ## show git branch in bash
    echo 'parse_git_branch() {
         git branch 2> /dev/null | sed -e '\''/^[^*]/d'\'' -e '\''s/* \(.*\)/(\1)/'\''
    }
    export PS1="\u@\h \w \[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "' >> ~/.bashrc
fi

if confirm_action "Install kmonad?"; then
    ## kmonad
    # https://github.com/kmonad/kmonad/releases
    echo 'install kmonad'
    cd ~/ruizhao/workspace
    curl -fLo ~/ruizhao/workspace/kmonad https://github.com/kmonad/kmonad/releases/download/0.4.4/kmonad
    chmod +x kmonad
    sudo rm -f /usr/bin/kmonad
    sudo cp ./kmonad /usr/bin/kmonad

    mkdir -p ~/ruizhao/workspace/dotfiles/kmonad/keymap
    
    if [ -f "$HOME/workspace/dotfiles/kmonad/keymap/tutorial.kbd" ]; then
        cp "$HOME/workspace/dotfiles/kmonad/keymap/tutorial.kbd" ~/ruizhao/workspace/dotfiles/kmonad/keymap/tutorial.kbd
    elif [ -f "$HOME/ruizhao/workspace/dotfiles/kmonad/keymap/tutorial.kbd" ]; then
        cp "$HOME/ruizhao/workspace/dotfiles/kmonad/keymap/tutorial.kbd" ~/ruizhao/workspace/dotfiles/kmonad/keymap/tutorial.kbd
    else
        curl -fLo ~/ruizhao/workspace/dotfiles/kmonad/keymap/tutorial.kbd https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/kmonad/keymap/tutorial.kbd
    fi

    if [ -f "$HOME/workspace/dotfiles/kmonad/keymap/kmonad.service" ]; then
        cp "$HOME/workspace/dotfiles/kmonad/keymap/kmonad.service" ~/ruizhao/workspace/dotfiles/kmonad/keymap/kmonad.service
    elif [ -f "$HOME/ruizhao/workspace/dotfiles/kmonad/keymap/kmonad.service" ]; then
        cp "$HOME/ruizhao/workspace/dotfiles/kmonad/keymap/kmonad.service" ~/ruizhao/workspace/dotfiles/kmonad/keymap/kmonad.service
    else
        curl -fLo ~/ruizhao/workspace/dotfiles/kmonad/keymap/kmonad.service https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/kmonad/keymap/kmonad.service
    fi

    if [ -d /dev/input/by-id ]; then
        KBD_NAME=$(ls /dev/input/by-id | grep -- -kbd | head -n 1)
        if [ -n "$KBD_NAME" ]; then
            sed -i "4c input  (device-file \"/dev/input/by-id/${KBD_NAME}\")" ~/ruizhao/workspace/dotfiles/kmonad/keymap/tutorial.kbd || true
        fi
    fi
    sed -i "s|~|$HOME|" ~/ruizhao/workspace/dotfiles/kmonad/keymap/kmonad.service || true

    sudo cp ~/ruizhao/workspace/dotfiles/kmonad/keymap/kmonad.service /etc/systemd/system/kmonad.service || true
    echo 'install kmonad done'
fi

if confirm_action "Install fzf?"; then
    # install fzf
    echo 'install fzf'
    cd ~
    FILE="$HOME/.fzf.zip"
    if [ ! -f "$FILE" ]; then
        curl -fLo ~/.fzf.zip https://github.com/junegunn/fzf/archive/refs/heads/master.zip
    fi
    rm -rf fzf-master
    rm -rf .fzf
    unzip .fzf.zip
    mv fzf-master .fzf
    ~/.fzf/install --all
    echo 'install fzf done'
fi

if confirm_action "Config git?"; then
    # git config
    git config --global pager.color false || true
    git config --global pager.show 'vim -R -' || true
    git config --global core.editor "$(which vim 2>/dev/null || echo vim)" || true
    git config --global diff.tool vimdiff || true
    git config --global mergetool.fugitive.cmd 'vim -f -c "Gvdiffsplit!" "$MERGED"' || true
    git config --global merge.tool fugitive || true
    git config --global mergetool.keepBackup false || true
fi

if confirm_action "Install nvm and nodejs?"; then
    # install nvm for coc and gemini 
    cd ~/ruizhao/workspace
    FILE="$HOME/ruizhao/workspace/nvm.tar.gz"
    if [ ! -f "$FILE" ]; then
        curl -fLo ~/ruizhao/workspace/nvm.tar.gz --create-dirs "https://github.com/nvm-sh/nvm/archive/refs/tags/v0.40.3.tar.gz"
    fi
    tar -xvzf ~/ruizhao/workspace/nvm.tar.gz
    cd ~/ruizhao/workspace/nvm-0.40.3
    cp -r ~/ruizhao/workspace/nvm-0.40.3 ~/.nvm
    cd ~/.nvm
    \. ~/.nvm/nvm.sh
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.bashrc
    nvm install 20.18.1
    nvm use 20.18.1
fi

if confirm_action "Install coc extensions?"; then
    vim -es -u ~/.vimrc +'CocInstall -sync coc-json coc-vimlsp coc-pyright' +qa < /dev/null || true
fi

if confirm_action "Install gemini?"; then
    npm install -g @google/gemini-cli || sudo npm install -g @google/gemini-cli || true
fi

if confirm_action "Install claude code?"; then
    npm install -g @anthropic-ai/claude-code || sudo npm install -g @anthropic-ai/claude-code || true
fi

echo "=========================================="
echo "Omarchy setup completed successfully!"
echo "=========================================="
