# git clone https://github.com/ruizhaogit/dotfiles

## tmux
# download .tmux.conf
curl -fLo ~/.tmux.conf "https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/.tmux.conf"
# download tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# in tmux, press prefix + I (capital i, as in Install) to fetch the plugin.

# # build vim from source
# git clone https://github.com/vim/vim.git
# git checkout v8.2.4700 (for vimspector: git checkout v8.2.4797)(latest, git checkout v9.1.1744, v9.10)
# cd vim/src
# [sudo apt-get install python3.10-dev]
# (https://askubuntu.com/questions/1459694/can-not-find-python3-10-after-apt-get-installation
# apt install software-properties-common
# sudo apt install libncurses-dev
# (sudo apt install libncurses5)
# (add-apt-repository ppa:deadsnakes/ppa)
# make distclean
# [/configure --enable-python3interp --with-python3-command=/usr/bin/python3.10]
# [/configure --enable-python3interp --with-python3-command=/home/ubuntu/.vim/lib/python/bin/python3.11]

sudo apt install python3.10-dev -y
sudo apt install software-properties-common -y
sudo apt install libncurses-dev -y
curl -fLo ~/ruizhao/workspace/vim.tar.gz --create-dirs "https://github.com/vim/vim/archive/refs/tags/v9.1.2077.tar.gz"
cd ~/ruizhao/workspace
tar -xvzf ~/ruizhao/workspace/vim.tar.gz
cd ~/ruizhao/workspace/vim-9.1.2077
./configure --enable-python3interp --with-python3-command=/usr/bin/python3.10
make
sudo make install

## vim
# download .vimrc
curl -fLo ~/.vimrc "https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/.vimrc"
# install vim plugin manager
curl -fLo ~/.vim/autoload/plug.vim --create-dirs "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
# in vim, run :PlugInstall
curl -fLo ~/.vim/coc-settings.json --create-dirs "https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/rc_files/coc-settings.json"

# install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
# Set up fzf key bindings and fuzzy completion
# eval "$(fzf --bash)"

# install ripgrep
sudo apt-get install ripgrep

# https://github.com/universal-ctags/ctags
# brew install --HEAD universal-ctags/universal-ctags/universal-ctags
# or install without the internet
# git clone https://github.com/universal-ctags/ctags.git
# cd ctags
# sudo apt install autoconf pkg-config
# ./autogen.sh
# ./configure --prefix=/usr/local
# (sudo apt install make build-essential)
# make
# (sudo) make install (used root permission)

cd ~/ruizhao/workspace
git clone https://github.com/universal-ctags/ctags.git
cd ctags
sudo apt install autoconf pkg-config
sudo apt install make build-essential
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install

# install nvm for coc and gemini 
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
nvm install 20.18.1
nvm use 20.18.1
# npm install -g @google/gemini-cli

# update ~/.bashrc
echo "set -o vi" >> ~/.bashrc
echo "export TERM=xterm-256color" >> ~/.bashrc
echo 'eval "$(fzf --bash)"' >> ~/.bashrc

# kmonad on ubuntu
# Download the release binary
# https://github.com/kmonad/kmonad/releases
# chmod +x kmonad
# sudo cp ./kmonad /usr/bin/kmonad

# https://www.swe-devops.com/posts/kmonad-service-systemd/
# /etc/systemd/system/kmonad.service
# sudo systemctl daemon-reload
# sudo systemctl start kmonad
# sudo systemctl enable kmonad
# sudo systemctl status kmonad
# sudo systemctl stop kmonad
