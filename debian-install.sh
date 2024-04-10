#!/bin/bash

ROOT_DIR=$(dirname $(readlink -f "$0"))
CURRENT_DIR=$(pwd)
GIT_USER_NAME=
GIT_USER_EMAIL=
SOCKS5_HOST=192.168.0.242
SOCKS5_PORT=1080
HPROXY_HOST=$SOCKS5_HOST
HPROXY_PORT=1081

PIPEWIRE=0

export http_proxy=$HPROXY_HOST:$HPROXY_PORT
export https_proxy=$HPROXY_HOST:$HPROXY_PORT

sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade

print() {
  printf "\n========================================================\n"
  printf "$1"
  printf "\n========================================================\n"
}

apt_get() {
  sudo apt-get install -y $@
  if [ "$?" -ne 0 ] ; then exit; fi
}

INSTALL=apt_get

setup_sounds() {
  # Install sound
  # After install, you can:
  #  1) Loading modules by: alsactl init
  #  2) Adjust volume by: alsamixer
  #  3) Play sound by: aplay /usr/share/sounds/alsa/Noise.wav
  #  4) Play input from MIDI port by: aplaymidi
  #  5) See https://wiki.debian.org/ALSA
  print "Setup sounds"

  # $INSTALL alsa-utils apulse
  # alsactl init
  if [ "$PIPEWIRE" -eq "1" ] ; then
    $INSTALL pipewire-audio pulseaudio-utils playerctl alsa-utils
    systemctl --user --now enable wireplumber.service
    systemctl --user --now enable pipewire pipewire-pulse wireplumber
  else
    $INSTALL pulseaudio pulseaudio-utils
    systemctl --user --now enable pulseaudio.service
  fi

  $INSTALL playerctl
}

setup_light() {
  # Control backlights and other lights
  # * Get the current backlight brightness in percent
  #       light -G or light
  # * Increase backlight brightness by 5 percent:
  #       light -A 5
  # * Set the minimum cap to 2 in raw value on the sysfs/backlight/acpi_video0
  #   device:
  #       light -Nrs "sysfs/backlight/acpi_video0" 2
  # * List Available devices:
  #       light -Nrs "sysfs/backlight/acpi_video0" 2
  # * Activate the Num. Lock keyboard LED, here sysfs/leds/input3::numlock
  #   is used, but this varies between different systems:
  #       light -Srs "sysfs/leds/input3::numlock" 1
  print "Setup light control"
  $INSTALL light
  light -G or light
}

setup_base_utils() {
  print "Setup base utils"
  $INSTALL bat ncat curl tree zip unzip
  $INSTALL ripgrep fzf fd-find
  $INSTALL zsh
}

setup_build_essential() {
  print "Setup build and development essential tools"
  $INSTALL build-essential autoconf-archive libtool pkg-config \
      gdb gdbserver meson cmake scdoc gettext
  $INSTALL universal-ctags bear
}

setup_git() {
  print "Setup git"
  $INSTALL git
  if [ ! -f "$HOME/.gitconfig" ] ; then
    git config --global core.editor "nvim"
    git config --global pull.rebase true
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
  fi
}

clone_dotfles() {
  print "Clone dotfiles"
  if [ ! -d "$HOME/workspace/dotfiles" ] ; then
    mkdir -p $HOME/workspace
    git clone https://github.com/GangZhuo/dotfiles.git $HOME/workspace/dotfiles
    if [ "$?" -ne 0 ] ; then exit; fi
  fi
}

setup_tmux() {
  print "Setup tmux"
  $INSTALL tmux
  if [ ! -d "$HOME/.config/tmux" ] ; then
    mkdir -p $HOME/.config
    cd $HOME/.config
    ln -sf ../workspace/dotfiles/.config/tmux tmux
    cd "$CURRENT_DIR"
  fi
}

setup_python() {
  print "Setup python"
  $INSTALL libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev libncursesw5-dev \
    xz-utils tk-dev libxml2-dev libxmlsec1-dev \
    libffi-dev liblzma-dev
  if [ ! -d "$HOME/.pyenv" ] ; then
    curl https://pyenv.run | bash
    if [ "$?" -ne 0 ] ; then exit; fi
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    pyenv install 3
    if [ "$?" -ne 0 ] ; then exit; fi
    pyenv global 3
    eval "$(pyenv init -)"
    cd "$CURRENT_DIR"
  fi
}

setup_nodejs() {
  print "Setup nodejs"
  if [ ! -d "$HOME/.local/node" ] ; then
    mkdir -p $HOME/.local/bin
    cd $HOME/.local
    [ -f node-v20.12.0-linux-x64.tar.gz ] && rm node-v20.12.0-linux-x64.tar.gz
    [ -d node-v20.12.0-linux-x64 ] && rm -rf node-v20.12.0-linux-x64
    wget -O node-v20.12.0-linux-x64.tar.gz \
      https://nodejs.org/dist/v20.12.0/node-v20.12.0-linux-x64.tar.gz
    if [ "$?" -ne 0 ] ; then exit; fi
    tar -xzf node-v20.12.0-linux-x64.tar.gz
    mv node-v20.12.0-linux-x64 node
    if [ "$?" -ne 0 ] ; then exit; fi
    rm node-v20.12.0-linux-x64.tar.gz
    cd $HOME/.local/bin
    ln -sf ../node/bin/node node
    ln -sf ../node/bin/npm npm
    ln -sf ../node/bin/npx npx
    cd "$CURRENT_DIR"
  fi
}

setup_neovim() {
  print "Setup neovim"
  if [ ! -d "$HOME/.local/nvim" ] ; then
    mkdir -p $HOME/.local/bin
    cd $HOME/.local
    [ -f nvim-linux64.tar.gz ] && rm nvim-linux64.tar.gz
    [ -d nvim-linux64 ] && rm -rf nvim-linux64
    wget -O nvim-linux64.tar.gz \
      https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    if [ "$?" -ne 0 ] ; then exit; fi
    tar -xzf nvim-linux64.tar.gz
    mv nvim-linux64 nvim
    if [ "$?" -ne 0 ] ; then exit; fi
    rm nvim-linux64.tar.gz
    cd $HOME/.local/bin
    ln -sf ../nvim/bin/nvim nvim
    cd "$CURRENT_DIR"
  fi
  if [ ! -d "$HOME/workspace/nvim-config" ] ; then
    mkdir -p $HOME/workspace
    git clone https://github.com/GangZhuo/nvim-config.git $HOME/workspace/nvim-config
    if [ "$?" -ne 0 ] ; then exit; fi
    cd "$CURRENT_DIR"
  fi
  if [ ! -d "$HOME/.config/nvim" ] ; then
    mkdir -p $HOME/.config
    cd $HOME/.config
    ln -sf ../workspace/nvim-config nvim
    cd "$CURRENT_DIR"
  fi
  if [ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ] ; then
    mkdir -p $HOME/.local/share/nvim/lazy
    git clone \
      --filter=blob:none \
      https://github.com/folke/lazy.nvim.git \
      --branch=stable \
      $HOME/.local/share/nvim/lazy/lazy.nvim
    if [ "$?" -ne 0 ] ; then exit; fi
  fi
}

setup_treesitter() {
  print "Setup tree-sitter"
  if [ ! -x "$HOME/.local/bin/tree-sitter" ] ; then
    mkdir -p $HOME/.local/bin
    cd $HOME/.local
    [ -f tree-sitter-linux-x64.gz ] && rm tree-sitter-linux-x64.gz
    wget -O tree-sitter-linux-x64.gz \
      https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz
    if [ "$?" -ne 0 ] ; then exit; fi
    gzip -d tree-sitter-linux-x64.gz
    mv tree-sitter-linux-x64 $HOME/.local/bin/tree-sitter
    if [ "$?" -ne 0 ] ; then exit; fi
    chmod a+x $HOME/.local/bin/tree-sitter
    cd "$CURRENT_DIR"
  fi
}

setup_sway() {
  print "Setup sway"
  $INSTALL sway swaybg swayidle swaylock waybar swayimg
  $INSTALL wl-clipboard
  $INSTALL wofi
  $INSTALL jq
  $INSTALL pavucontrol
  $INSTALL fonts-font-awesome

  # Screencasts
  $INSTALL wf-recorder

  # Media Player
  $INSTALL mpv

  # Music Player
  $INSTALL mpd

  # Office
  # $INSTALL libreoffice-gtk3

  # File manager
  # $INSTALL --no-install-recommends nautilus

  # Build mako
  $INSTALL libcairo2-dev libpango1.0-dev \
      libsystemd-dev libgdk-pixbuf2.0-dev \
      dbus libnotify-bin

  # Screenshots: swappy + grim + slurp
  $INSTALL grim slurp

  # Dependencies to build swappy, https://github.com/jtheoof/swappy
  #
  # Swppy is a Wayland native snapshot editing tool, inspired by Snappy on macOS.
  #
  # Build command:
  # ```
  # meson setup build --buildtype=release --prefix $HOME/.local
  # meson compile -C build
  # meson install -C build
  # ```
  $INSTALL libcairo2-dev libpango1.0-dev libgtk-3-dev

  # Dependencies to build sway, https://github.com/vcrhonek/hwdata.git
  $INSTALL glslang-tools libcairo2-dev libcap-dev libdbus-1-dev \
      libdisplay-info-dev libevdev-dev libgdk-pixbuf2.0-dev \
      libinput-dev libjson-c-dev libliftoff-dev libpam0g-dev \
      libpango1.0-dev libpcre2-dev libpixman-1-dev libseat-dev \
      libsystemd-dev libvulkan-dev libwayland-dev libwayland-egl1 \
      libwlroots-dev libxcb-ewmh-dev libxkbcommon-dev \
      xwayland hwdata \
      meson pkgconf scdoc tree wayland-protocols

  mkdir -p $HOME/workspace
  if [ ! -d "$HOME/workspace/wayland" ] ; then
    git clone https://gitlab.freedesktop.org/wayland/wayland.git $HOME/workspace/wayland
    if [ "$?" -ne 0 ] ; then exit; fi
  fi
  if [ ! -d "$HOME/workspace/wayland-protocols" ] ; then
    git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git $HOME/workspace/wayland-protocols
    if [ "$?" -ne 0 ] ; then exit; fi
  fi

  # Build mako
  if [ ! -d "$HOME/workspace/mako" ] ; then
    git clone https://github.com/emersion/mako.git $HOME/workspace/mako
    if [ "$?" -ne 0 ] ; then exit; fi
  fi
  cd $HOME/workspace/mako || exit
  mkdir -p subprojects
  cd subprojects || exit
  if [ ! -d "wayland" ] ; then
    ln -sf ../../wayland wayland
  fi
  if [ ! -d "wayland-protocols" ] ; then
    ln -sf ../../wayland-protocols wayland-protocols
  fi
  cd $HOME/workspace/mako
  if [ ! -d "build" ] ; then
    meson setup build --buildtype=release
    if [ "$?" -ne 0 ] ; then exit; fi
  fi
  meson compile -C build
  if [ "$?" -ne 0 ] ; then exit; fi
  sudo meson install -C build
  if [ "$?" -ne 0 ] ; then exit; fi

  # Build swappy
  if [ ! -d "$HOME/workspace/swappy" ] ; then
    git clone https://github.com/jtheoof/swappy.git $HOME/workspace/swappy
    if [ "$?" -ne 0 ] ; then exit; fi
  fi
  cd $HOME/workspace/swappy || exit
  if [ ! -d "build" ] ; then
    meson setup build --buildtype=release
    if [ "$?" -ne 0 ] ; then exit; fi
  fi
  meson compile -C build
  if [ "$?" -ne 0 ] ; then exit; fi
  sudo meson install -C build
  if [ "$?" -ne 0 ] ; then exit; fi

  # Build sway
  if [ ! -d "$HOME/workspace/sway" ] ; then
    git clone https://github.com/swaywm/sway.git $HOME/workspace/sway
    if [ "$?" -ne 0 ] ; then exit; fi
  fi
  cd $HOME/workspace/sway || exit
  mkdir -p subprojects
  cd subprojects || exit
  if [ ! -d "wayland" ] ; then
    ln -sf ../../wayland wayland
  fi
  if [ ! -d "wayland-protocols" ] ; then
    ln -sf ../../wayland-protocols wayland-protocols
  fi
  if [ ! -d "libdisplay-info" ] ; then
    git clone https://gitlab.freedesktop.org/emersion/libdisplay-info.git libdisplay-info
    if [ "$?" -ne 0 ] ; then exit; fi
  fi
  if [ ! -d "libdrm" ] ; then
    git clone https://gitlab.freedesktop.org/mesa/drm.git libdrm
    if [ "$?" -ne 0 ] ; then exit; fi
      sed -i "/meson.get_compiler('c')/ i \
add_project_arguments([\n\
  '-Wno-stringop-truncation',\n\
  '-Wno-error=packed',\n\
  '-Wno-error=array-bounds',\n\
  '-Wno-error=maybe-uninitialized',\n\
  ], language : 'c')\n" libdrm/meson.build
  fi
  if [ ! -d "libliftoff" ] ; then
    git clone https://gitlab.freedesktop.org/emersion/libliftoff.git libliftoff
    if [ "$?" -ne 0 ] ; then exit; fi
  fi
  if [ ! -d "seatd" ] ; then
    git clone https://git.sr.ht/~kennylevinsen/seatd seatd
    if [ "$?" -ne 0 ] ; then exit; fi
  fi
  if [ ! -d "wlroots" ] ; then
    git clone https://gitlab.freedesktop.org/wlroots/wlroots.git wlroots
    if [ "$?" -ne 0 ] ; then exit; fi
  fi
  cd $HOME/workspace/sway
  if [ ! -d "build" ] ; then
    meson setup build --buildtype=release
    if [ "$?" -ne 0 ] ; then exit; fi
  fi
  meson compile -C build
  if [ "$?" -ne 0 ] ; then exit; fi
  sudo meson install -C build
  if [ "$?" -ne 0 ] ; then exit; fi

  sudo ldconfig -v
}

download_font() {
  file=$1
  url=$2
  if [ ! -f "/usr/local/share/fonts/$file" ] ; then
    if [ ! -f "$file" ] ; then
      wget -O "$file" "$url"
      if [ "$?" -ne 0 ] ; then exit; fi
    fi
    sudo cp "$file" "/usr/local/share/fonts/$file"
  fi
}

setup_fonts() {
  print "Setup fonts"
  $INSTALL \
    fonts-noto \
    fonts-dejavu \
    fonts-terminus \
    fonts-wqy-microhei \
    fonts-wqy-zenhei \
    xfonts-wqy \
    fonts-arphic-ukai \
    fonts-arphic-uming \
    fonts-font-awesome

  mkdir -p $HOME/Downloads/fonts
  cd $HOME/Downloads/fonts

  styles="BoldItalic Bold Italic Regular"

  font="InconsolataLGCNerdFontMono"
  url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/InconsolataLGC"
  for style in $styles ; do
    download_font "$font-$style.ttf" "$url/$font-$style.ttf"
  done

  font="HackNerdFontMono"
  url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack"
  for style in $styles ; do
    download_font "$font-$style.ttf" "$url/$style/$font-$style.ttf"
  done

  fc-cache -fv
  cd "$CURRENT_DIR"
}

setup_awesome() {
  print "Setup awesome"
  $INSTALL xorg awesome
  $INSTALL alacritty fonts-dejavu
  $INSTALL unclutter mpc mpd scrot light xsel xbacklight
  $INSTALL fonts-terminus
  # $INSTALL xss-lock i3lock
  # $INSTALL picom

  # Below commands can power second monitor
  # xrandr
  # xrandr --output LVDS-1 --mode 1366x768 --rate 60
  # xrandr --output LVDS-1 --auto
  # xrandr --output VGA-1 --auto
}

setup_lightdm() {
  print "Setup lightdm"
  $INSTALL lightdm light-locker
  # $INSTALL accountsservice
  sudo systemctl enable lightdm.service
  # mkdir -p /etc/lightdm/lightdm.conf.d/
  # cp /opt/scripts/etc/lightdm/lightdm.conf.d/05_user_list.conf /etc/lightdm/lightdm.conf.d/05_user_list.conf
  # cp /opt/scripts/etc/lightdm/lightdm.conf.d/50-greeter-wrapper.conf /etc/lightdm/lightdm.conf.d/50-greeter-wrapper.conf
  # cp /opt/scripts/etc/lightdm/lightdm.conf.d/50-session-wrapper.conf /etc/lightdm/lightdm.conf.d/50-session-wrapper.conf
  # cp /opt/scripts/etc/lightdm/lightdm.conf.d/greeter-wrapper.sh /etc/lightdm/lightdm.conf.d/greeter-wrapper.sh
  # cp /opt/scripts/etc/lightdm/lightdm.conf.d/session-wrapper.sh /etc/lightdm/lightdm.conf.d/session-wrapper.sh
}

setup_fcitx5() {
  print "Setup fcitx5"
  $INSTALL fcitx5 fcitx5-chinese-addons fcitx5-material-color
  $INSTALL aspell nuspell
}

setup_firefox() {
  print "Setup firefox"
  $INSTALL firefox-esr
}

setup_network() {
  print "Setup network-manager"
  $INSTALL network-manager
  # $INSTALL nm-tray
}

setup_sounds
setup_light
setup_base_utils
setup_build_essential
setup_git
clone_dotfles
setup_tmux
setup_python
setup_nodejs
setup_neovim
setup_treesitter

setup_sway

setup_fonts
setup_fcitx5
setup_firefox
setup_network

#setup_awesome
#setup_lightdm

print "Completed!!!"

