#!/bin/bash -e

cd

IFS=$'\n' palette=($(curl -s https://gist.githubusercontent.com/reujab/656c01678f7229e7d5b6141960649a9d/raw))
tilixProfile=2b7c4080-0ddd-46c5-8f23-563fd3ba789d

if [[ -f /etc/fedora-release ]]; then
  version=25

  # fedora update
  sudo dnf update -y

  # fedora install
  sudo dnf copr -y enable dperson/neovim
  sudo dnf copr -y enable region51/chrome-gnome-shell
  sudo dnf copr -y enable rok/cdemu
  sudo dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$version.noarch.rpm
  sudo dnf install -y http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$version.noarch.rpm
  sudo dnf install -y http://folkswithhats.org/repo/$version/RPMS/noarch/folkswithhats-release-1.0.1-1.fc$version.noarch.rpm

  sudo dnf install -y arc-theme automake chromium cmake fedy fedy-multimedia-codecs ffmpeg gcc-c++ gnome-tweak-tool golang{,-godoc} htop httpie iotop kernel-devel meld nmap nodejs numix-icon-theme-circle pithos python3-neovim redshift-gtk synaptics texlive texlive-{eqparbox,moresize,pgfplots} tilix vlc wine wireshark-gtk xclip xdotool zsh zsh-syntax-highlighting
	sudo npm install -g yarn

  set +e

  sudo dnf install -y chrome-gnome-shell
  sudo dnf install -y gcdemu
  sudo dnf install -y neovim
  sudo systemctl disable firewalld
  sudo systemctl stop firewalld

  set -e

  # fedora configure
  sudo dnf remove -y evolution gnome-{calendar,clocks,contacts,documents,font-viewer,logs,maps,weather} seahorse setroubleshoot shotwell || true
  sudo sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/selinux/config

  grep defaultyes /etc/dnf/dnf.conf > /dev/null || sudo tee -a /etc/dnf/dnf.conf > /dev/null << EOF
defaultyes=True
EOF
elif [[ -f /etc/arch-release ]]; then
  # arch update
  grep '^\[multilib\]$' /etc/pacman.conf > /dev/null || sudo tee -a /etc/pacman.conf > /dev/null << EOF
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF

  sudo pacman --noconfirm -Syu

  # arch install
  sudo pacman --needed --noconfirm -S base-devel expac git yajl

  git clone https://aur.archlinux.org/cower.git

  cd cower

  makepkg -i --needed --noconfirm --skippgpcheck

  cd

  git clone https://aur.archlinux.org/pacaur.git

  cd pacaur

  makepkg -i --needed --noconfirm

  cd

  # ffmpeg python3-neovim texlive-{eqparbox,moresize,pgfplots} pithos
  pacaur --needed --noconfirm --noedit -S \
    arc-gtk-theme \
    chromium \
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
    redshift \
    texlive-bin \
    tilix-bin \
    vlc \
    wine \
    wireshark-gtk \
    xclip \
    xdotool \
    xf86-input-synaptics \
    yarn \
    zsh \
    zsh-syntax-highlighting

  # arch configure
  sudo systemctl enable NetworkManager
  sudo systemctl enable gdm

  # arch clean
  rm -fr pacaur
  rm -fr cower
fi

# install
sudo yarn global install electron eslint shiba tern

# configure
GOPATH=/tmp go get github.com/reujab/gse/gse
dconf write /com/gexperts/Tilix/control-click-titlebar true
dconf write /com/gexperts/Tilix/focus-follow-mouse true
dconf write /com/gexperts/Tilix/profiles/$tilixProfile/background-color "${palette[2]}"
dconf write /com/gexperts/Tilix/profiles/$tilixProfile/foreground-color "${palette[1]}"
dconf write /com/gexperts/Tilix/profiles/$tilixProfile/palette "${palette[0]}"
dconf write /com/gexperts/Tilix/profiles/$tilixProfile/use-theme-colors false
dconf write /com/gexperts/Tilix/theme-varient "'dark'"
dconf write /org/gnome/shell/extensions/mediaplayer/indicator-position "'center'"
dconf write /org/gnome/shell/extensions/mediaplayer/status-text "'{trackArtist} — {trackTitle}'"
dconf write /org/gnome/shell/extensions/mediaplayer/status-type "'cover'"
dconf write /org/gnome/shell/extensions/mediaplayer/volume true
dconf write /org/gtk/settings/file-chooser/show-hidden true
git clone --depth 1 https://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh || true
git clone --recursive https://github.com/reujab/dotfiles.git || true
git clone https://github.com/powerline/fonts.git || true
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
gsettings set org.gnome.shell favorite-apps "['google-chrome.desktop', 'com.gexperts.Tilix.desktop']"
gsettings set org.gnome.shell.overrides dynamic-workspaces false
ln -fs dotfiles/.{{npm,vim,zsh}rc,eslintrc.yaml,gitconfig,vim} .
mkdir -p .config .config/autostart .config/gtk-3.0
sudo chsh -s /bin/zsh
sudo chsh -s /bin/zsh chris
sudo ln -fs ~/.oh-my-zsh ~/dotfiles dotfiles/.{{vim,zsh}rc,vim} /root
sudo mkdir -p /root/.config
sudo systemctl enable sshd
sudo systemctl start sshd

/tmp/bin/gse enable alternate-tab@gnome-shell-extensions.gcampax.github.com apps-menu@gnome-shell-extensions.gcampax.github.com places-menu@gnome-shell-extensions.gcampax.github.com
/tmp/bin/gse install 4 55 307 1031
fonts/install.sh
ln -fns ../.vim .config/nvim
nvim +PluginInstall +qa -E || true
zsh -ci clean

nvim +UpdateRemotePlugins +q

cat > .config/autostart/bing-background.desktop << EOF
[Desktop Entry]
Type=Application
Name=Bing Background
Exec=go/bin/bing-background
EOF

cat > .config/gtk-3.0/bookmarks << EOF
file://$HOME/Documents
file://$HOME/Downloads
file://$HOME/Music
file://$HOME/Pictures
file://$HOME/reujab Go
file://$HOME/js JavaScript
EOF

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

# clean
rmdir Videos Public Templates || true
sudo rm -fr .bash* .cache .local/share/applications .mozilla /etc/{ba,z}shrc /root/.{*sh*,cache,npm} /tmp/dash-to-dock /usr/share/applications/{lash-panel,wine*,yelp}.desktop fonts
