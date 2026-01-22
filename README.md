# dotfiles

```
curl -o- https://raw.githubusercontent.com/ruizhaogit/dotfiles/refs/heads/main/install.sh | bash
```

```
ls /dev/input/by-id  
```
edit kmonad/keymap/tutorial.kbd

/etc/systemd/system/kmonad.service  
```
sudo systemctl daemon-reload  
```
```
sudo systemctl start kmonad  
```
```
sudo systemctl enable kmonad  
```
```
sudo systemctl status kmonad  
```
```
sudo systemctl stop kmonad  
```

install tabby terminal on ubuntu:  
download .deb from https://github.com/Eugeny/tabby  
sudo dpkg -i *.deb  
install trzsz plugin: https://github.com/trzsz/tabby-trzsz  

configure proxy for ubuntu apt install  
sudo vim /etc/apt/apt.conf  
Acquire::http::Proxy "http://username:password@yourproxyaddress:proxyport";  
