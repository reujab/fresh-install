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
	sudo pacman --needed --noconfirm -S binutils fakeroot go git
	rm -rf yay
	git clone https://aur.archlinux.org/yay.git
	pushd yay
	makepkg -i --needed --noconfirm
	popd
	rm -rf yay
fi

# install all packages
yay --needed --noconfirm -S \
	arc-gtk-theme \
	balena-etcher \
	baobab \
	bat \
	code \
	cups \
	diff-so-fancy \
	eog \
	evince \
	exa \
	ffmpeg \
	file-roller \
	foomatic-db-{engine,gutenprint-ppds} \
	gdm \
	gedit \
	git-delta \
	gnome-backgrounds \
	gnome-browser-connector \
	gnome-calculator \
	gnome-control-center \
	gnome-keyring \
	gnome-logs \
	gnome-menus \
	gnome-screenshot \
	gnome-session \
	gnome-shell \
	gnome-shell-extensions \
	gnome-system-monitor \
	gnome-tweak-tool \
	google-chrome \
	gst-libav \
	gutenprint \
	htop \
	httpie \
	hub \
	libgit2 \
	libgnome-keyring \
	meld \
	minecraft-launcher \
	nautilus \
	neovim \
	net-tools \
	networkmanager \
	npm \
	ntfs-3g \
	numix-circle-icon-theme-git \
	openssh \
	os-prober \
	p7zip \
	python-neovim \
	rustup \
	steam \
	tokei \
	totem \
	transmission-gtk \
	unrar \
	vte-common \
	wget \
	wine \
	xclip \
	zsh \
	zsh-syntax-highlighting

# install dotfiles
git clone https://github.com/reujab/dotfiles.git || true
git clone https://github.com/ohmyzsh/ohmyzsh .oh-my-zsh || true
ln -fs dotfiles/.{alacritty.yml,eslintrc.yaml,gitconfig,vim{,rc},zshrc} .
ln -fns ../.vim .config/nvim
sudo ln -fs ~/.oh-my-zsh ~/dotfiles dotfiles/.{vim{,rc},zshrc} /root

# install neovim plugins
#nvim +PlugInstall +qa -E || true
#nvim +UpdateRemotePlugins +q

# configure gnome and apps
dconf write /org/gnome/shell/extensions/dash-to-dock/extend-height true
dconf write /org/gnome/shell/extensions/dash-to-dock/scroll-action "'cycle-windows'"
dconf write /org/gnome/shell/extensions/mediaplayer/indicator-position "'center'"
dconf write /org/gnome/shell/extensions/mediaplayer/status-text "'{trackArtist} — {trackTitle}'"
dconf write /org/gnome/shell/extensions/mediaplayer/status-type "'cover'"
dconf write /org/gnome/shell/extensions/mediaplayer/volume true
dconf write /org/gtk/settings/file-chooser/show-hidden true
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false
dconf write /org/gnome/shell/extensions/dash-to-dock/multi-monitor true
dconf write /org/gnome/shell/extensions/dash-to-dock/show-trash true
dconf write /org/gnome/shell/extensions/dash-to-dock/scroll-action "'switch-workspace'"
dconf write /org/gnome/desktop/wm/preferences/num-workspaces 2
dconf write /org/gnome/shell/extensions/multi-monitors-add-on/transfer-indicators "{'panel-favorites': 0}"
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
gsettings set org.gnome.shell favorite-apps "['google-chrome.desktop', 'org.gnome.Terminal.desktop', 'code-oss.desktop']"
gsettings set org.gnome.shell.overrides dynamic-workspaces false
sudo systemctl enable NetworkManager
sudo systemctl enable gdm
sudo systemctl enable cups

# change the shell to zsh
sudo chsh -s /usr/bin/zsh
sudo chsh -s /usr/bin/zsh "$USER"

# configure rustup
rustup default stable

echo success
