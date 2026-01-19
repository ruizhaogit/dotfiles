# curl -o- https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/install.sh | bash

# set -e

mkdir -p ~/ruizhao/workspace
cd ~/ruizhao/workspace 
git clone https://github.com/ruizhaogit/dotfiles

sudo apt install python3.10-dev -y
sudo apt install software-properties-common -y
sudo apt install libncurses-dev -y
sudo apt install autoconf pkg-config -y
sudo apt install make build-essential -y
sudo apt install ripgrep -y
python -m pip install --upgrade trzsz

## tmux
# download .tmux.conf
curl -fLo ~/.tmux.conf "https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/.tmux.conf"
# download tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

# # build vim from source
echo 'build vim from source'
curl -fLo ~/ruizhao/workspace/vim.tar.gz --create-dirs "https://github.com/vim/vim/archive/refs/tags/v9.1.2077.tar.gz"
cd ~/ruizhao/workspace
tar -xvzf ~/ruizhao/workspace/vim.tar.gz
cd ~/ruizhao/workspace/vim-9.1.2077
./configure --enable-python3interp --with-python3-command=/usr/bin/python3.10
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
git clone https://github.com/universal-ctags/ctags.git ~/ruizhao/workspace/ctags
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

# kmonad
# https://github.com/kmonad/kmonad/releases
echo 'install kmonad'
cd ~/ruizhao/workspace
curl -fLo ~/ruizhao/workspace/kmonad https://github.com/kmonad/kmonad/releases/download/0.4.4/kmonad
chmod +x kmonad
sudo cp ./kmonad /usr/bin/kmonad
sudo cp ~/ruizhao/workspace/dotfiles/kmonad/keymap/kmonad.service /etc/systemd/system/kmonad.service
echo 'install kmonad done'

# install fzf
echo 'install fzf'
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
echo 'install fzf done'

# install nvm for coc and gemini 
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 20.18.1
nvm use 20.18.1
npm install -g @google/gemini-cli
