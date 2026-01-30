# curl -o- https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/install.sh | bash

# set -e

# clone dotfiles
mkdir -p ~/ruizhao/workspace
cd ~/ruizhao/workspace 
# git clone https://github.com/ruizhaogit/dotfiles
curl -fLo dotfiles.zip https://github.com/ruizhaogit/dotfiles/archive/refs/heads/main.zip
unzip dotfiles.zip
mv dotfiles-main dotfiles

# Check architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    echo "System is ARM ($ARCH)"
    IS_ARM=true
else
    echo "System is not ARM ($ARCH)"
    IS_ARM=false
fi

## apt install pkgs
echo 'install pkgs'
sudo apt update
sudo apt install python3.10-dev -y
sudo apt install software-properties-common -y
sudo apt install libncurses-dev -y
sudo apt install autoconf pkg-config -y
sudo apt install make build-essential -y
sudo apt install git -y
sudo apt install rsync -y
python -m pip install --upgrade trzsz

if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    # # install ripgrep
    # mkdir -p ~/ruizhao/workspace/ripgrep
    # cd ~/ruizhao/workspace/ripgrep
    # curl -fLO https://github.com/BurntSushi/ripgrep/releases/download/15.1.0/ripgrep-15.1.0-aarch64-unknown-linux-gnu.tar.gz
    # tar -xvf ripgrep-15.1.0-aarch64-unknown-linux-gnu.tar.gz 
    # sudo mv ripgrep-15.1.0-aarch64-unknown-linux-gnu/rg /usr/local/bin/
    # sudo snap install ccls --classic
    # sudo apt install tmux --classic
    sudo pacman -S ripgrep
    sudo pacman -S ccls
    sudo pacman -S bear
    sudo pacman -S tmux
else
    sudo apt install ripgrep -y
    sudo apt install ccls -y
    sudo apt install bear -y
    sudo apt install tmux -y
fi

echo 'install pkgs done'

## tmux
# download .tmux.conf
curl -fLo ~/.tmux.conf "https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/.tmux.conf"
# download tmux plugin manager
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
curl -fLo ~/.tmux/plugins/tpm.zip https://github.com/tmux-plugins/tpm/archive/refs/heads/master.zip
cd ~/.tmux/plugins/
unzip tpm.zip
mv tpm-master tpm
~/.tmux/plugins/tpm/bin/install_plugins

## build vim from source
echo 'build vim from source'
curl -fLo ~/ruizhao/workspace/vim.tar.gz --create-dirs "https://github.com/vim/vim/archive/refs/tags/v9.1.2077.tar.gz"
cd ~/ruizhao/workspace
tar -xvzf ~/ruizhao/workspace/vim.tar.gz
cd ~/ruizhao/workspace/vim-9.1.2077
./configure --enable-python3interp --with-python3-command=/usr/bin/python3
make
sudo make install
echo 'build vim from source done'

## vim
# download .vimrc
echo 'install vim plugins'
curl -fLo ~/.vimrc "https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/.vimrc"
# install vim plugin manager
curl -fLo ~/.vim/autoload/plug.vim --create-dirs "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
curl -fLo ~/.vim/coc-settings.json --create-dirs "https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/coc-settings.json"
# vim +'PlugInstall --sync' +qa
vim -es -u ~/.vimrc +'PlugInstall --sync' +qa < /dev/null
echo 'install vim plugins done'

# install universal-ctags
echo 'install universal-ctags'
# git clone https://github.com/universal-ctags/ctags.git ~/ruizhao/workspace/ctags
cd ~/ruizhao/workspace
curl -fLo ctags.zip https://github.com/universal-ctags/ctags/archive/refs/heads/master.zip
unzip ctags.zip
mv ctags-master ctags
cd ~/ruizhao/workspace/ctags
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install
echo 'install universal-ctags done'

# update ~/.bashrc
echo "set -o vi" >> ~/.bashrc
echo "export TERM=xterm-256color" >> ~/.bashrc
echo 'eval "$(fzf --bash)"' >> ~/.bashrc

## kmonad
# https://github.com/kmonad/kmonad/releases
echo 'install kmonad'
cd ~/ruizhao/workspace
curl -fLo ~/ruizhao/workspace/kmonad https://github.com/kmonad/kmonad/releases/download/0.4.4/kmonad
chmod +x kmonad
sudo cp ./kmonad /usr/bin/kmonad

KBD_NAME=$(ls /dev/input/by-id | grep -- -kbd | head -n 1)
if [ -n "$KBD_NAME" ]; then
    sed -i "4c input  (device-file \"/dev/input/by-id/${KBD_NAME}\")" ~/ruizhao/workspace/dotfiles/kmonad/keymap/tutorial.kbd
fi
sed -i "s|~|$HOME|" ~/ruizhao/workspace/dotfiles/kmonad/keymap/kmonad.service

sudo cp ~/ruizhao/workspace/dotfiles/kmonad/keymap/kmonad.service /etc/systemd/system/kmonad.service
echo 'install kmonad done'

# install fzf
echo 'install fzf'
# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
cd ~
curl -fLo ~/fzf.zip https://github.com/junegunn/fzf/archive/refs/heads/master.zip
unzip fzf.zip
mv fzf-master .fzf
~/.fzf/install --all
echo 'install fzf done'

# git config
git config --global pager.color false
git config --global pager.show 'vim -R -'
git config --global core.editor $(which vim)
git config --global diff.tool vimdiff
git config --global mergetool.fugitive.cmd 'vim -f -c "Gvdiffsplit!" "$MERGED"'
git config --global merge.tool fugitive
git config --global mergetool.keepBackup false

# install nvm for coc and gemini 
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 20.18.1
nvm use 20.18.1
npm install -g @google/gemini-cli
