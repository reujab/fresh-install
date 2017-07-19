#!/bin/bash -e

# cd into ~
cd

# enable multilib repositories
grep '^\[multilib\]$' /etc/pacman.conf > /dev/null || sudo tee -a /etc/pacman.conf > /dev/null << EOF
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF

# update all packages
sudo pacman --noconfirm -Syu

# install pacaur
sudo pacman --needed --noconfirm -S base-devel expac git yajl
git clone https://aur.archlinux.org/cower.git
pushd cower
makepkg -i --needed --noconfirm --skippgpcheck
rm -fr cower
popd
git clone https://aur.archlinux.org/pacaur.git
pushd pacaur
makepkg -i --needed --noconfirm
popd
rm -fr pacaur

# install all packages
pacaur --needed --noconfirm --noedit -S \
	arc-gtk-theme \
	chromium \
	fish \
	gdm \
	gnome \
	gnome-tweak-tool \
	go \
	go-tools \
	gst-libav \
	htop \
	httpie \
	iotop \
	meld \
	neovim \
	networkmanager \
	nmap \
	numix-circle-icon-theme-git \
	openssh \
	pithos \
	python-neovim \
	redshift \
	texlive-bin \
	tilix-bin \
	vlc \
	wine \
	wireshark-gtk \
	xclip \
	xdotool \
	xf86-input-synaptics \
	yarn
sudo yarn global add eslint tern

# install and enable gnome shell extensions
GOPATH=/tmp go get github.com/reujab/gse/gse
# Frippery Panel Favorites, Media player indicator, Dash to Dock, TopIcons Plus
/tmp/bin/gse install 4 55 307 1031
/tmp/bin/gse enable alternate-tab@gnome-shell-extensions.gcampax.github.com apps-menu@gnome-shell-extensions.gcampax.github.com places-menu@gnome-shell-extensions.gcampax.github.com

# install dotfiles
git clone --recursive https://github.com/reujab/dotfiles.git || true
ln -fs dotfiles/.{eslintrc.yaml,gitconfig,vim{,rc}} .
ln -fns ../.vim .config/nvim
ln -fs ../dotfiles/fish .config
sudo ln -fs ~/dotfiles dotfiles/.vim dotfiles/.vimrc /root

# install neovim plugins
nvim +PlugInstall +qa -E || true
nvim +UpdateRemotePlugins +q

# configure gnome and apps
dconf write /com/gexperts/Tilix/control-click-titlebar true
dconf write /com/gexperts/Tilix/focus-follow-mouse true
dconf write /com/gexperts/Tilix/theme-varient "'dark'"
dconf write /org/gnome/shell/extensions/mediaplayer/indicator-position "'center'"
dconf write /org/gnome/shell/extensions/mediaplayer/status-text "'{trackArtist} — {trackTitle}'"
dconf write /org/gnome/shell/extensions/mediaplayer/status-type "'cover'"
dconf write /org/gnome/shell/extensions/mediaplayer/volume true
dconf write /org/gtk/settings/file-chooser/show-hidden true
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:swapescape', 'terminate:ctrl_alt_bksp']"
gsettings set org.gnome.desktop.interface clock-format 12h
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.interface gtk-key-theme Emacs
gsettings set org.gnome.desktop.interface gtk-theme Arc
gsettings set org.gnome.desktop.interface icon-theme Numix-Circle
gsettings set org.gnome.desktop.interface monospace-font-name "DejaVu Sans Mono for Powerline Book 11"
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
gsettings set org.gnome.desktop.wm.preferences num-workspaces 2
gsettings set org.gnome.nautilus.icon-view default-zoom-level small
gsettings set org.gnome.settings-daemon.plugins.xsettings antialiasing rgba
gsettings set org.gnome.settings-daemon.plugins.xsettings hinting slight
gsettings set org.gnome.shell favorite-apps "['chromium.desktop', 'com.gexperts.Tilix.desktop']"
gsettings set org.gnome.shell.overrides dynamic-workspaces false
sudo systemctl enable NetworkManager
sudo systemctl enable gdm
sudo systemctl enable sshd
sudo systemctl start sshd

# change the shell to fish
sudo chsh -s /usr/bin/fish
sudo chsh -s /usr/bin/fish "$USER"

# run bing-background on login
mkdir -p .config/autostart
cat > .config/autostart/bing-background.desktop << EOF
[Desktop Entry]
Type=Application
Name=Bing Background
Exec=go/bin/bing-background
EOF

# set nautilus bookmarks
mkdir -p .config/gtk-3.0
cat > .config/gtk-3.0/bookmarks << EOF
file://$HOME/Documents
file://$HOME/Downloads
file://$HOME/Music
file://$HOME/Pictures
file://$HOME/reujab Go
file://$HOME/js JavaScript
EOF

# enable vertical and horizontal edge scroll
sudo tee /etc/X11/xorg.conf.d/00-synaptics.conf > /dev/null << EOF
Section "InputClass"
	Identifier "synaptics"
	Driver "synaptics"
	MatchIsTouchpad "on"
	Option "TapButton1" "1"
	Option "VertEdgeScroll" "on"
	Option "HorizEdgeScroll" "on"
EndSection
EOF

# install One Dark tilix color scheme
mkdir -p .config/tilix/schemes
curl https://gist.githubusercontent.com/reujab/241da27b02fc13be5e18f76ff5270378/raw/f86c7a5f0b2a6ccdf913be4a9174ff9871dec263/One%2520Dark.json > "$HOME/.config/tilix/schemes/One Dark.json"

# clean
rmdir Videos Public Templates || true
sudo rm -fr .bash* .cache .local/share/applications
