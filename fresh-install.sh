#!/bin/bash -e

# cd into ~
cd

# enable multilib repositories
grep '^\[multilib\]$' /etc/pacman.conf > /dev/null || sudo tee -a /etc/pacman.conf > /dev/null << EOF
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF

# enable colors in pacman and yay
sudo sed -i 's/#Color/Color/' /etc/pacman.conf

# update all packages
sudo pacman --noconfirm -Syu

# install yay
if ! which yay; then
	git clone https://aur.archlinux.org/yay.git
	pushd yay
	makepkg -i --needed --noconfirm
	popd
	rm -fr yay
fi

# install all packages
yay --needed --noconfirm -S \
	alacritty-git \
	arc-gtk-theme \
	audacity \
	bat \
	chrome-gnome-shell-git \
	code \
	cups \
	diff-so-fancy \
	easytag \
	exa \
	ffmpeg \
	firefox \
	foomatic-db-{engine,gutenprint-ppds} \
	gdm \
	gnome \
	gnome-tweak-tool \
	go \
	go-tools \
	google-chrome \
	gst-libav \
	gutenprint \
	hexyl \
	htop \
	httpie \
	iotop \
	libgit2 \
	libgnome-keyring \
	libreoffice-fresh \
	meld \
	neovim \
	net-tools \
	networkmanager \
	nmap \
	nodejs \
	npm \
	ntfs-3g \
	numix-circle-icon-theme-git \
	obs-studio \
	openssh \
	p7zip \
	python-grip \
	python-neovim \
	ranger \
	texlive-most \
	tokei \
	transmission-gtk \
	unrar \
	wget \
	wine \
	xclip \
	xdotool \
	xf86-input-synaptics \
	youtube-dl \
	zsh \
	zsh-syntax-highlighting \
	zsh-you-should-use

# # install and enable gnome shell extensions
GOPATH=/tmp go get github.com/reujab/gse/gse
# Frippery Panel Favorites, Media player indicator, Dash to Dock, TopIcons Plus
/tmp/bin/gse install 4 55 307 1031
/tmp/bin/gse enable alternate-tab@gnome-shell-extensions.gcampax.github.com apps-menu@gnome-shell-extensions.gcampax.github.com places-menu@gnome-shell-extensions.gcampax.github.com

# install dotfiles
git clone --recursive https://github.com/reujab/dotfiles.git || true
ln -fs dotfiles/.{eslintrc.yaml,gitconfig,vim{,rc},zshrc} .
ln -fns ../.vim .config/nvim
sudo ln -fs ~/.oh-my-zsh ~/dotfiles dotfiles/.{vim{,rc},zshrc} /root

# install neovim plugins
nvim +PlugInstall +qa -E || true
nvim +UpdateRemotePlugins +q

# install patched Code New Roman font
git clone https://github.com/ryanoasis/nerd-fonts --depth 1
nerd-fonts/font-patcher -qcsl "nerd-fonts/src/unpatched-fonts/CodeNewRoman/Code New Roman-Regular.otf"
rm -fr nerd-fonts
mkdir -p .local/share/fonts
mv "Code New Roman Nerd Font Complete Mono.otf" ".local/share/fonts/Code New Roman.otf"
fc-cache -fv

# configure gnome and apps
dconf write /com/gexperts/Tilix/control-click-titlebar true
dconf write /com/gexperts/Tilix/focus-follow-mouse true
dconf write /com/gexperts/Tilix/theme-varient "'dark'"
dconf write /org/gnome/shell/extensions/dash-to-dock/extend-height true
dconf write /org/gnome/shell/extensions/dash-to-dock/scroll-action "'cycle-windows'"
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
gsettings set org.gnome.desktop.interface monospace-font-name "CodeNewRoman Nerd Font Mono 11"
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
gsettings set org.gnome.desktop.wm.preferences num-workspaces 5
gsettings set org.gnome.nautilus.icon-view default-zoom-level small
gsettings set org.gnome.settings-daemon.plugins.xsettings antialiasing rgba
gsettings set org.gnome.settings-daemon.plugins.xsettings hinting slight
gsettings set org.gnome.shell favorite-apps "['google-chrome.desktop', 'com.gexperts.Tilix.desktop']"
gsettings set org.gnome.shell.overrides dynamic-workspaces false
sudo systemctl enable NetworkManager
sudo systemctl enable gdm
sudo systemctl enable org.cups.cupsd
sudo systemctl enable sshd
sudo systemctl start sshd

# change the shell to zsh
sudo chsh -s /usr/bin/zsh
sudo chsh -s /usr/bin/zsh "$USER"

# install bing-background
go get github.com/reujab/bing-background
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
file://$HOME/Downloads
file://$HOME/Music
file://$HOME/Pictures
file://$HOME/code Code
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

# install silver
cargo install silver

# clean
rmdir Documents Public Templates Videos || true
sudo rm -fr .bash* .cache .local/share/applications
