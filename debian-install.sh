#!/bin/bash

ROOT_DIR=$(dirname $(readlink -f "$0"))
CURRENT_DIR=$(pwd)
CURRENT_USER=$(whoami)
GIT_USER_NAME=
GIT_USER_EMAIL=
SOCKS5_HOST=127.0.0.1
SOCKS5_PORT=1080
HPROXY_HOST=$SOCKS5_HOST
HPROXY_PORT=1081

PIPEWIRE=0

export http_proxy=$HPROXY_HOST:$HPROXY_PORT
export https_proxy=$HPROXY_HOST:$HPROXY_PORT

print() {
  printf "\n========================================================\n"
  printf "$1"
  printf "\n========================================================\n"
}

upgrade_os() {
  print "Upgrade os"
  sudo apt-get update
  sudo apt-get upgrade
  sudo apt-get dist-upgrade
}

apt_get() {
  #sudo apt-get install --no-install-recommends -y $@
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
  $INSTALL ripgrep fzf fd-find htop
  $INSTALL zsh
}

setup_build_essential() {
  print "Setup build and development essential tools"
  $INSTALL build-essential autoconf-archive libtool pkg-config \
      gdb gdbserver meson cmake scdoc gettext
  $INSTALL universal-ctags bear
}

setup_rustup() {
  print "Setup rustup"
  if [ ! -d "$HOME/.rustup" ] ; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  else
    echo rustup already installed
  fi
  source "$HOME/.cargo/env"
}

setup_git() {
  print "Setup git"
  $INSTALL git

  print "Configure git"
  if [ ! -f "$HOME/.gitconfig" ] ; then
    git config --global core.editor "nvim"
    git config --global pull.rebase true
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
  else
    echo git already configured
  fi
}

clone_dotfles() {
  print "Clone dotfiles"
  if [ ! -d "$HOME/workspace/dotfiles" ] ; then
    mkdir -p $HOME/workspace
    git clone https://github.com/GangZhuo/dotfiles.git $HOME/workspace/dotfiles
    if [ "$?" -ne 0 ] ; then exit; fi
  else
    echo dotfiles already cloned
  fi
}

setup_tmux() {
  print "Setup tmux"
  $INSTALL tmux

  print "Configure tmux"
  if [ ! -d "$HOME/.config/tmux" ] ; then
    mkdir -p $HOME/.config
    cd $HOME/.config
    ln -sf ../workspace/dotfiles/.config/tmux tmux
    cd "$CURRENT_DIR"
  else
    echo tmux already configured
  fi
}

setup_ohmyzsh() {
  print "Setup ohmyzsh"
  $INSTALL zsh
  if [ ! -d "$HOME/.oh-my-zsh" ] ; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    if [ "$?" -ne 0 ] ; then exit; fi
    rm -rf $HOME/.zshrc
    cd $HOME
    ln -sf workspace/dotfiles/.zshrc .zshrc
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    if [ "$?" -ne 0 ] ; then exit; fi
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    if [ "$?" -ne 0 ] ; then exit; fi
    print "Change your shell:"
    echo input password for $CURRENT_DIR
    chsh --shell /usr/bin/zsh
    if [ "$?" -ne 0 ] ; then exit; fi
    cd "$CURRENT_DIR"
  else
    echo ohmyzsh already installed
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
  else
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    echo python already installed
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
    export PATH="$HOME/.local/bin:$PATH"
    cd "$CURRENT_DIR"
  else
    export PATH="$HOME/.local/bin:$PATH"
    echo nodejs already installed
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
    pip install pynvim
    if [ "$?" -ne 0 ] ; then exit; fi
  else
    echo neovim already installed
  fi

  print "Configure neovim"
  if [ ! -d "$HOME/.config/nvim" ] ; then
    if [ ! -d "$HOME/workspace/nvim-config" ] ; then
      mkdir -p $HOME/workspace
      git clone https://github.com/GangZhuo/nvim-config.git $HOME/workspace/nvim-config
      if [ "$?" -ne 0 ] ; then exit; fi
      cd "$CURRENT_DIR"
    fi
    mkdir -p $HOME/.config
    cd $HOME/.config
    ln -sf ../workspace/nvim-config nvim
    cd "$CURRENT_DIR"
    if [ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ] ; then
      mkdir -p $HOME/.local/share/nvim/lazy
      git clone \
        --filter=blob:none \
        https://github.com/folke/lazy.nvim.git \
        --branch=stable \
        $HOME/.local/share/nvim/lazy/lazy.nvim
      if [ "$?" -ne 0 ] ; then exit; fi
    fi
  else
    echo neovim already configured
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
  else
    echo tree-sitter already installed
  fi
}

setup_sway() {
  print "Setup sway"
  $INSTALL sway swaybg swayidle swaylock waybar swayimg sway-backgrounds
  $INSTALL foot foot-terminfo
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

  # Build sway
  print "Build and install sway"
  if [ ! -x "/usr/local/bin/sway" ] ; then
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
        # $ROOT_DIR/patches/drm-patch.sh "$HOME/workspace/sway/subprojects/libdrm/meson.build"
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
    if [ ! -x "/usr/local/bin/start_sway.sh" ] ; then
      #sudo cp $HOME/workspace/dotfiles/.local/bin/start_sway.sh \
      #  /usr/local/bin/start_sway.sh
      cat <<EOOF | sudo tee /usr/local/bin/start_sway.sh &> /dev/null
#!/usr/bin/env bash
set -euo pipefail

# Export all variables
set -a
# Call the systemd generator that reads all files in environment.d
source /dev/fd/0 <<EOF
$(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
EOF
set +a

exec sway $@
EOOF
      sudo chmod a+x /usr/local/bin/start_sway.sh
      if [ "$?" -ne 0 ] ; then exit; fi
    fi
  else
    echo sway already installed
  fi

  # Build mako
  print "Build and install mako"
  if [ ! -x "/usr/local/bin/mako" ] ; then
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
  else
    echo mako already installed
  fi

  # Build swappy
  print "Build and install swappy"
  if [ ! -x "/usr/local/bin/swappy" ] ; then
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
  else
    echo swappy already installed
  fi

  sudo ldconfig

  print "Configure sway"
  mkdir -p $HOME/.config
  cd $HOME/.config
  list="environment.d foot mako sway waybar wofi"
  for f in $list ; do
    if [ ! -d "$f" ] ; then
      ln -sf ../workspace/dotfiles/.config/$f $f
    else
      echo $f already configured
    fi
  done

  cd "$CURRENT_DIR"
}

setup_greetd() {
  setup_rustup
  print "Setup greetd"

  if [ ! -x "/usr/local/bin/greetd" ] ; then
    if [ ! -d "$HOME/workspace/greetd" ] ; then
      git clone https://git.sr.ht/\~kennylevinsen/greetd \
        $HOME/workspace/greetd
      if [ "$?" -ne 0 ] ; then exit; fi
    fi

    cd $HOME/workspace/greetd

    # Compile greetd and agreety.
    cargo build --release
    if [ "$?" -ne 0 ] ; then exit; fi

    # Put things into place
    sudo cp target/release/{greetd,agreety} /usr/local/bin/
    sudo cp greetd.service /etc/systemd/system/greetd.service
    sudo cp /etc/pam.d/login /etc/pam.d/greetd
    sudo mkdir /etc/greetd
    sudo cp config.toml /etc/greetd/config.toml

    # Change vt to 3
    sudo sed -i 's/^vt = 1/vt = 3/' /etc/greetd/config.toml

    # Change command to sway
    sudo sed -i 's/^\(command = "agreety --cmd \/bin\/sh"\)/#\1\
command = "agreety --cmd \/usr\/local\/bin\/start_sway.sh"/' \
      /etc/greetd/config.toml

    # Create the greeter user
    sudo useradd -m -r -G video greeter
    sudo chmod -R go+r /etc/greetd/

    # When done, enable and start greetd
    sudo systemctl enable greetd

    cd "$CURRENT_DIR"
  else
    echo greetd already installed
  fi
}

setup_tuigreet() {
  setup_rustup
  print "Setup tuigreet"

  if [ ! -x "/usr/local/bin/tuigreet" ] ; then
    if [ ! -d "$HOME/workspace/tuigreet" ] ; then
      git clone https://github.com/apognu/tuigreet \
        $HOME/workspace/tuigreet
      if [ "$?" -ne 0 ] ; then exit; fi
    fi

    cd $HOME/workspace/tuigreet

    # Compile
    cargo build --release
    if [ "$?" -ne 0 ] ; then exit; fi

    # Put things into place
    sudo cp target/release/tuigreet /usr/local/bin
    sudo mkdir /var/cache/tuigreet
    sudo chown greeter:greeter /var/cache/tuigreet
    sudo chmod 0755 /var/cache/tuigreet

    if [ ! -x "/usr/local/bin/start_tuigreet.sh" ] ; then
      #sudo cp $HOME/workspace/dotfiles/.local/bin/start_tuigreet.sh \
      #  /usr/local/bin/start_tuigreet.sh
      cat <<EOOF | sudo tee /usr/local/bin/start_tuigreet.sh &> /dev/null
#!/bin/sh

exec tuigreet \\\
    --issue \\\
    --time --time-format "%Y-%m-%d %H:%M %w" \\\
    --power-shutdown 'sudo --non-interactive systemctl poweroff' \\\
    --power-reboot 'sudo --non-interactive systemctl reboot' \\\
    \$@
EOOF
      sudo chmod a+x /usr/local/bin/start_tuigreet.sh
      if [ "$?" -ne 0 ] ; then exit; fi

      # We need add below line into sudoers,
      # see https://github.com/apognu/tuigreet?tab=readme-ov-file#power-management
      #
      # %greeter ALL=NOPASSWD: /bin/systemctl poweroff, /bin/systemctl reboot
    fi

    # Change to use tuigreet
    sudo sed -i 's/^\(command = "agreety --cmd\) \(.*\)/command = "\/usr\/local\/bin\/start_tuigreet.sh --cmd \2/' \
      /etc/greetd/config.toml

    cd "$CURRENT_DIR"
  else
    echo tuigreet already installed
  fi
}

download_font() {
  f=$1
  u=$2
  if [ ! -f "/usr/local/share/fonts/$f" ] ; then
    if [ ! -f "$f" ] ; then
      wget -O "$f" "$u"
      if [ "$?" -ne 0 ] ; then exit; fi
    fi
    sudo cp "$f" "/usr/local/share/fonts/$f"
  else
    echo $f already installed
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

  print "Install Nerd Fonts"

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

  fc-cache -f
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
  # See https://blog.kelu.org/tech/2022/01/04/wifi-conn-with-nmcli.html
  $INSTALL network-manager
  $INSTALL network-manager-gnome
  # $INSTALL nm-tray
}

setup_virt_manager() {
  print "Setup virt-manager"
  $INSTALL virt-manager
  sudo usermod -aG libvirt $CURRENT_USER
}

upgrade_os
setup_sounds
setup_light
setup_base_utils
setup_build_essential
setup_git
clone_dotfles
setup_tmux
setup_ohmyzsh
setup_python
setup_nodejs
setup_neovim
setup_treesitter

setup_sway

setup_fonts
setup_fcitx5
setup_firefox
setup_network

setup_virt_manager

setup_greetd
setup_tuigreet

#setup_awesome
#setup_lightdm
#
#TODO: printer, sway greater

print "We need add below line into sudoers, \n\
see https://github.com/apognu/tuigreet?tab=readme-ov-file#power-management \n\
\n\
%%greeter ALL=NOPASSWD: /bin/systemctl poweroff, /bin/systemctl reboot\n\
\n\
You can using 'sudo visudo' command."

print "After rebooting, execute the 'sway' command to enter the desktop, \n\
and execute 'pavucontrol' to initialize the sound, and execute 'fcitx5-config-qt' \n\
to configure the input method, and execute 'nmcli' to configure the network.\n\
\n\
Completed!!!\n"

