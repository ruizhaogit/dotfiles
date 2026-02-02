# curl -o- https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/install.sh | bash

set -e

# Check if the command exists before running it
if command -v lsb_release >/dev/null 2>&1; then
    VERSION=$(lsb_release -sr)
    echo "Ubuntu version: $VERSION"
else
    echo "lsb_release command not found. Skipping..."
fi

# Check architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    echo "System is $ARCH"
else
    echo "System is $ARCH"
fi

# Confirmation (Works even via curl pipe)
read -p "Overwrite /etc/apt/sources.list with aliyun (x86_64) or ubuntu-ports (arm) Jammy sources? (y/n): " confirm < /dev/tty

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Backing up to /etc/apt/sources.list.bak..."
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    # Use 'tee' to overwrite the file with the aliyun block
    echo "Writing new sources..."
    if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        # http://ports.ubuntu.com/ubuntu-ports official ubuntu source for arm
        sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://ports.ubuntu.com/ubuntu-ports/ jammy main restricted universe multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ jammy main restricted universe multiverse

deb http://ports.ubuntu.com/ubuntu-ports/ jammy-updates main restricted universe multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ jammy-updates main restricted universe multiverse

deb http://ports.ubuntu.com/ubuntu-ports/ jammy-backports main restricted universe multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ jammy-backports main restricted universe multiverse

deb http://ports.ubuntu.com/ubuntu-ports/ jammy-security main restricted universe multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ jammy-security main restricted universe multiverse
EOF
    else
        # https://github.com/simdsoft/sources.list
        sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
EOF
    fi
    echo "Running apt update..."
    sudo apt update
    echo "Sources successfully updated to aliyun Jammy."
else
    echo "Using the default apt sources."
fi

## apt install pkgs
echo 'install pkgs'
# sudo apt update
# sudo apt install python3.10-dev -y
# sudo apt install software-properties-common -y
# sudo apt install libncurses-dev -y
# sudo apt install autoconf pkg-config -y
# sudo apt install make build-essential -y
# sudo apt install git -y
# sudo apt install rsync -y

# List of packages to check
PACKAGES=(
    "python3.10-dev"
    "python3-pip"
    "software-properties-common"
    "libncurses-dev"
    "autoconf"
    "pkg-config"
    "make"
    "build-essential"
    "git"
    "rsync"
    "curl"
    "unzip"
    "snapd"
    "tmux"
    "ripgrep"
    "ccls"
    "bear"
    "aria2"
)

# Array to store packages that actually need installing
TO_INSTALL=()

echo "Checking package status..."

for pkg in "${PACKAGES[@]}"; do
    if dpkg -s "$pkg" &>/dev/null; then
        echo "[✓] $pkg is already installed."
    else
        echo "[ ] $pkg is missing."
        TO_INSTALL+=("$pkg")
    fi
done

# If the list of packages to install is not empty
if [ ${#TO_INSTALL[@]} -ne 0 ]; then
    echo "------------------------------------------"
    echo "Installing missing packages: ${TO_INSTALL[*]}"
    sudo apt update
    sudo apt install -y "${TO_INSTALL[@]}"

    # read -p "Install ripgrep binary? (y/n): " confirm < /dev/tty
    # if [[ "$confirm" =~ ^[Yy]$ ]]; then
    #     # install ripgrep
    #     mkdir -p ~/ruizhao/workspace/ripgrep
    #     cd ~/ruizhao/workspace/ripgrep
    #     curl -fLO https://github.com/BurntSushi/ripgrep/releases/download/15.1.0/ripgrep-15.1.0-aarch64-unknown-linux-gnu.tar.gz
    #     tar -xvf ripgrep-15.1.0-aarch64-unknown-linux-gnu.tar.gz 
    #     sudo mv ripgrep-15.1.0-aarch64-unknown-linux-gnu/rg /usr/local/bin/
    # fi
    #
    # read -p "Build tmux? (y/n): " confirm < /dev/tty
    # if [[ "$confirm" =~ ^[Yy]$ ]]; then
    #     # install tmux
    #     cd ~/ruizhao/workspace
    #     curl -fLO https://github.com/tmux/tmux/releases/download/3.6a/tmux-3.6a.tar.gz
    #     tar -xvzf tmux-3.6a.tar.gz
    #     cd tmux-3.6a/
    #     ./configure && make
    #     sudo make install
    # fi
    #
    # read -p "Build ccls? (y/n): " confirm < /dev/tty
    # if [[ "$confirm" =~ ^[Yy]$ ]]; then
    #     # install ccls
    #     cd ~/ruizhao/workspace
    #     curl -fLO https://github.com/MaskRay/ccls/archive/refs/tags/0.20250815.1.tar.gz
    #     tar -xvzf 0.20250815.1.tar.gz
    #     cd ccls-0.20250815.1/
    #     cmake -S. -BRelease
    #     cmake --build Release --target install
    # fi
    #
    # read -p "Install bear via snap? (y/n): " confirm < /dev/tty
    # if [[ "$confirm" =~ ^[Yy]$ ]]; then
    #     sudo snap install bear --classic
    # fi

    ## use snap to install pkgs
    # sudo snap install ripgrep --classic
    # sudo snap install tmux --classic
    # sudo snap install ccls --classic
    # sudo snap install bear --classic

    ## use pacman to install pkgs
    # sudo pacman -S ripgrep
    # sudo pacman -S tmux
    # sudo pacman -S ccls
    # sudo pacman -S bear
else
    echo "------------------------------------------"
    echo "All dependencies are already satisfied."
fi

read -p "Install trzsz? (y/n): " confirm < /dev/tty
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    python3 -m pip install --upgrade trzsz
fi

echo 'install pkgs done'

read -p "Download dotfiles? (y/n): " confirm < /dev/tty
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    # clone dotfiles
    mkdir -p ~/ruizhao/workspace
    cd ~/ruizhao/workspace 
    # git clone https://github.com/ruizhaogit/dotfiles
    rm -rf dotfiles-main
    rm -rf dotfiles
    curl -fLo dotfiles.zip https://github.com/ruizhaogit/dotfiles/archive/refs/heads/main.zip
    # aria2c -x 16 -s 16 -k 1M --allow-overwrite=true --auto-file-renaming=false -d ~/ruizhao/workspace -o dotfiles.zip https://github.com/ruizhaogit/dotfiles/archive/refs/heads/main.zip
    unzip dotfiles.zip
    mv dotfiles-main dotfiles
fi

read -p "Use scp to copy files? (y/n): " confirm < /dev/tty
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "input ip and username"
    read -p "Enter Remote IP Address: " remote_ip < /dev/tty
    read -p "Enter Username: " username < /dev/tty
    echo "start copy"
    cd ~
    rsync -avzR "$username@$remote_ip":\
    "~/.tmux/plugins/tpm.zip" \
    ":~/.tmux/plugins/tmux-continuum" \
    ":~/.tmux/plugins/tmux-resurrect" \
    ":~/ruizhao/workspace/vim.tar.gz" \
    ":~/ruizhao/workspace/ctags.zip" \
    ":~/ruizhao/workspace/nvm.tar.gz" \
    ":~/.fzf.zip" \
    ":~/.vimrc" \
    ":~/.vim/autoload/plug.vim" \
    ":~/.vim/coc-settings.json" \
    ":~/.vim/plugins" \
    ./
    echo "copy done"
fi

read -p "Download tmux conf and plugins? (y/n): " confirm < /dev/tty
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    ## tmux
    # download .tmux.conf
    FILE="$HOME/.tmux.conf"
    if [ ! -f "$FILE" ]; then
        curl -fLo ~/.tmux.conf "https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/.tmux.conf"
        # aria2c -x 16 -s 16 -k 1M --allow-overwrite=true --auto-file-renaming=false -d ~/ -o .tmux.conf https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/.tmux.conf
    fi
    # download tmux plugin manager
    # git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    FILE="$HOME/.tmux/plugins/tpm.zip"
    if [ ! -f "$FILE" ]; then
        echo "$FILE" does not exist, start downloading.
        curl -fLo ~/.tmux/plugins/tpm.zip --create-dirs https://github.com/tmux-plugins/tpm/archive/refs/heads/master.zip
    fi
    # aria2c -x 16 -s 16 -k 1M --allow-overwrite=true --auto-file-renaming=false -d ~/.tmux/plugins -o tpm.zip https://github.com/tmux-plugins/tpm/archive/refs/heads/master.zip
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

read -p "Download build vim and install plugins? (y/n): " confirm < /dev/tty
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    ## build vim from source
    echo 'build vim from source'
    FILE="$HOME/ruizhao/workspace/vim.tar.gz"
    if [ ! -f "$FILE" ]; then
        curl -fLo ~/ruizhao/workspace/vim.tar.gz --create-dirs "https://github.com/vim/vim/archive/refs/tags/v9.1.2077.tar.gz"
    fi
    # aria2c -x 16 -s 16 -k 1M --allow-overwrite=true --auto-file-renaming=false -d ~/ruizhao/workspace -o vim.tar.gz https://github.com/vim/vim/archive/refs/tags/v9.1.2077.tar.gz
    cd ~/ruizhao/workspace
    tar -xvzf ~/ruizhao/workspace/vim.tar.gz
    cd ~/ruizhao/workspace/vim-9.1.2077
    ./configure --enable-python3interp --with-python3-command=/usr/bin/python3
    make
    sudo make install
    echo 'build vim from source done'

    FILE="$HOME/.vimrc"
    if [ ! -f "$FILE" ]; then
        ## vim
        # download .vimrc
        echo 'install vim plugins'
        curl -fLo ~/.vimrc "https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/.vimrc"
        # install vim plugin manager
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
        curl -fLo ~/.vim/coc-settings.json --create-dirs "https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/coc-settings.json"
        # vim +'PlugInstall --sync' +qa
        vim -es -u ~/.vimrc +'PlugInstall --sync' +qa < /dev/null || true
        echo 'install vim plugins done'
    fi
fi

read -p "Install universal-ctags? (y/n): " confirm < /dev/tty
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    # install universal-ctags
    echo 'install universal-ctags'
    # git clone https://github.com/universal-ctags/ctags.git ~/ruizhao/workspace/ctags
    cd ~/ruizhao/workspace
    FILE="$HOME/ruizhao/workspace/ctags.zip"
    if [ ! -f "$FILE" ]; then
        curl -fLo ctags.zip https://github.com/universal-ctags/ctags/archive/refs/heads/master.zip
    fi
    # aria2c -x 16 -s 16 -k 1M --allow-overwrite=true --auto-file-renaming=false -d ~/ruizhao/workspace -o ctags.zip https://github.com/universal-ctags/ctags/archive/refs/heads/master.zip
    rm -rf ctags-master
    rm -rf ctags
    unzip ctags.zip
    mv ctags-master ctags
    cd ~/ruizhao/workspace/ctags
    ./autogen.sh
    ./configure --prefix=/usr/local
    make
    sudo make install
    echo 'install universal-ctags done'
fi

read -p "Update bashrc? (y/n): " confirm < /dev/tty
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    # update ~/.bashrc
    echo "set -o vi" >> ~/.bashrc
    echo "export TERM=xterm-256color" >> ~/.bashrc
    # echo 'eval "$(fzf --bash)"' >> ~/.bashrc
fi

read -p "Install kmonad? (y/n): " confirm < /dev/tty
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    ## kmonad
    # https://github.com/kmonad/kmonad/releases
    echo 'install kmonad'
    cd ~/ruizhao/workspace
    curl -fLo ~/ruizhao/workspace/kmonad https://github.com/kmonad/kmonad/releases/download/0.4.4/kmonad
    chmod +x kmonad
    sudo cp ./kmonad /usr/bin/kmonad

    mkdir -p ~/ruizhao/workspace/dotfiles/kmonad/keymap
    curl -fLo ~/ruizhao/workspace/dotfiles/kmonad/keymap/tutorial.kbd https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/kmonad/keymap/tutorial.kbd
    curl -fLo ~/ruizhao/workspace/dotfiles/kmonad/keymap/kmonad.service https://github.com/ruizhaogit/dotfiles/blob/main/kmonad/keymap/kmonad.service

    KBD_NAME=$(ls /dev/input/by-id | grep -- -kbd | head -n 1)
    if [ -n "$KBD_NAME" ]; then
        sed -i "4c input  (device-file \"/dev/input/by-id/${KBD_NAME}\")" ~/ruizhao/workspace/dotfiles/kmonad/keymap/tutorial.kbd
    fi
    sed -i "s|~|$HOME|" ~/ruizhao/workspace/dotfiles/kmonad/keymap/kmonad.service

    sudo cp ~/ruizhao/workspace/dotfiles/kmonad/keymap/kmonad.service /etc/systemd/system/kmonad.service
    echo 'install kmonad done'
fi

read -p "Install fzf? (y/n): " confirm < /dev/tty
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    # install fzf
    echo 'install fzf'
    # git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    cd ~
    FILE="$HOME/.fzf.zip"
    if [ ! -f "$FILE" ]; then
        curl -fLo ~/.fzf.zip https://github.com/junegunn/fzf/archive/refs/heads/master.zip
        # aria2c -x 16 -s 16 -k 1M --allow-overwrite=true --auto-file-renaming=false -d ~/ -o .fzf.zip https://github.com/junegunn/fzf/archive/refs/heads/master.zip
    fi
    rm -rf fzf-master
    rm -rf .fzf
    unzip .fzf.zip
    mv fzf-master .fzf
    ~/.fzf/install --all
    echo 'install fzf done'
fi

# git config
git config --global pager.color false
git config --global pager.show 'vim -R -'
git config --global core.editor $(which vim)
git config --global diff.tool vimdiff
git config --global mergetool.fugitive.cmd 'vim -f -c "Gvdiffsplit!" "$MERGED"'
git config --global merge.tool fugitive
git config --global mergetool.keepBackup false

read -p "Install nvm and nodejs? (y/n): " confirm < /dev/tty
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    # install nvm for coc and gemini 
    # curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    cd ~/ruizhao/workspace
    FILE="$HOME/ruizhao/workspace/nvm.tar.gz"
    if [ ! -f "$FILE" ]; then
        curl -fLo ~/ruizhao/workspace/nvm.tar.gz --create-dirs "https://github.com/nvm-sh/nvm/archive/refs/tags/v0.40.3.tar.gz"
        # aria2c -x 16 -s 16 -k 1M --allow-overwrite=true --auto-file-renaming=false -d ~/ruizhao/workspace -o nvm.tar.gz https://github.com/nvm-sh/nvm/archive/refs/tags/v0.40.3.tar.gz
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

read -p "Install gemini? (y/n): " confirm < /dev/tty
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    npm install -g @google/gemini-cli
fi
