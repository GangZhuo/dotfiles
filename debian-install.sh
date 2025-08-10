#!/bin/bash

ROOT_DIR=$(dirname $(readlink -f "$0"))
CURRENT_DIR=$(pwd)
CURRENT_USER=$(whoami)
GIT_USER_NAME=""
GIT_USER_EMAIL=""
SOCKS5_HOST=pear.lan
SOCKS5_PORT=1080
HPROXY_HOST=$SOCKS5_HOST
HPROXY_PORT=1081

UPDATE=0

PIPEWIRE=1

SWAY_SRC_ROOT=$HOME/workspace/swaywm

INSTALL=apt_get
MESON=$(which meson)

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
      gdb gdbserver cmake scdoc gettext
  $INSTALL meson
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
  rustup component add rust-analyzer
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

  pip install --upgrade meson || exit

  MESON=$(which meson)
  if [ -z "$MESON" ]; then exit; fi
}

setup_nodejs() {
  print "Setup nodejs"
  if [ ! -d "$HOME/.local/node" ] ; then
    mkdir -p $HOME/.local/bin
    cd $HOME/.local
    NODEJS_VER="v22.18.0"
    NODEJS_FILENAME="node-$NODEJS_VER-linux-x64"
    [ -f $NODEJS_FILENAME.tar.xz ] && rm $NODEJS_FILENAME.tar.xz
    [ -d $NODEJS_FILENAME ] && rm -rf $NODEJS_FILENAME
    wget -O $NODEJS_FILENAME.tar.xz \
      https://nodejs.org/dist/$NODEJS_VER/$NODEJS_FILENAME.tar.xz
    if [ "$?" -ne 0 ] ; then exit; fi
    tar -xf $NODEJS_FILENAME.tar.xz || exit
    mv $NODEJS_FILENAME node
    if [ "$?" -ne 0 ] ; then exit; fi
    rm $NODEJS_FILENAME.tar.xz
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
  if [ ! -d "$HOME/.local/nvim" ] || [ x"$UPDATE" == "x1" ] ; then
    mkdir -p $HOME/.local/bin
    cd $HOME/.local
    NVIM_FILENAME="nvim-linux-x86_64"
    [ -f $NVIM_FILENAME.tar.gz ] && rm $NVIM_FILENAME.tar.gz
    [ -d $NVIM_FILENAME ] && rm -rf $NVIM_FILENAME
    wget -O $NVIM_FILENAME.tar.gz \
      https://github.com/neovim/neovim/releases/latest/download/$NVIM_FILENAME.tar.gz
    if [ "$?" -ne 0 ] ; then exit; fi
    tar -xzf $NVIM_FILENAME.tar.gz
    mv nvim nvim.old
    mv $NVIM_FILENAME nvim
    if [ "$?" -ne 0 ] ; then
      rm -rf nvim
      mv nvim.old nvim
      exit;
    fi
    rm $NVIM_FILENAME.tar.gz
    rm -rf nvim.old
    cd $HOME/.local/bin
    ln -sf ../nvim/bin/nvim nvim
    cd "$CURRENT_DIR"
    pip install --upgrade pynvim || exit
    if [ "$?" -ne 0 ] ; then exit; fi
  else
    pip install --upgrade pynvim || exit
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
  if [ ! -x "$HOME/.local/bin/tree-sitter" ] || [ x"$UPDATE" == "x1" ] ; then
    mkdir -p $HOME/.local/bin
    cd $HOME/.local
    [ -f tree-sitter-linux-x64.gz ] && rm tree-sitter-linux-x64.gz
    wget -O tree-sitter-linux-x64.gz \
      https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz
    if [ "$?" -ne 0 ] ; then exit; fi
    gzip -d tree-sitter-linux-x64.gz
    rm -rf $HOME/.local/bin/tree-sitter
    mv tree-sitter-linux-x64 $HOME/.local/bin/tree-sitter
    if [ "$?" -ne 0 ] ; then exit; fi
    chmod a+x $HOME/.local/bin/tree-sitter
    cd "$CURRENT_DIR"
  else
    echo tree-sitter already installed
  fi
}

git_clone() {
  DEST_DIR=$1
  BRANCH=$2
  SRC_URL=$3
  if [ -z "$SRC_URL" ]; then
    SRC_URL=$BRANCH
    BRANCH=
  fi
  if [ -z "$BRANCH" ]; then
    print "Clone $DEST_DIR"
  else
    print "Clone $DEST_DIR (branch: $BRANCH)"
  fi
  if [ ! -d "$DEST_DIR" ] ; then
    mkdir -p "$(dirname "$DEST_DIR")"
    git clone "$SRC_URL" "$DEST_DIR"
    if [ "$?" -ne 0 ] ; then exit; fi
    if [ ! -z "$BRANCH" ]; then
      CUR_DIR=$(pwd)
      cd "$DEST_DIR" || exit
      git checkout $BRANCH
      if [ "$?" -ne 0 ] ; then exit; fi
      cd "$CUR_DIR"
    fi
    git submodule update --init --recursive || exit
    return 1
  elif [ x"$UPDATE" == "x1" ] ; then
    CUR_DIR=$(pwd)
    cd "$DEST_DIR" || exit
    if [ ! -z "$BRANCH" ]; then
      git checkout $BRANCH || exit
      git pull --autostash origin $BRANCH || exit
    else
      git pull --autostash || exit
    fi
    git submodule update --init --recursive || exit
    cd "$CUR_DIR"
    return 2
  fi
  return 0
}

build_install_sway() {
  print "Build and install sway"

  git_clone "$SWAY_SRC_ROOT/wayland" 1.23 \
    https://gitlab.freedesktop.org/wayland/wayland.git
  git_clone "$SWAY_SRC_ROOT/wayland-protocols" 1.37 \
    https://gitlab.freedesktop.org/wayland/wayland-protocols.git
  git_clone "$SWAY_SRC_ROOT/libdisplay-info" \
    https://gitlab.freedesktop.org/emersion/libdisplay-info.git
  git_clone "$SWAY_SRC_ROOT/libdrm" \
    https://gitlab.freedesktop.org/mesa/drm.git
  if [ "$?" -eq 1 ] ; then
    # $ROOT_DIR/patches/drm-patch.sh "$HOME/workspace/sway/subprojects/libdrm/meson.build"
    sed -i "/meson.get_compiler('c')/ i \
      add_project_arguments([\n\
        '-Wno-stringop-truncation',\n\
        '-Wno-error=packed',\n\
        '-Wno-error=array-bounds',\n\
        '-Wno-error=maybe-uninitialized',\n\
        ], language : 'c')\n" "$SWAY_SRC_ROOT/libdrm/meson.build"
  fi
  git_clone "$SWAY_SRC_ROOT/libliftoff" \
    https://gitlab.freedesktop.org/emersion/libliftoff.git
  git_clone "$SWAY_SRC_ROOT/seatd" \
    https://git.sr.ht/~kennylevinsen/seatd
  git_clone "$SWAY_SRC_ROOT/libinput" \
    https://gitlab.freedesktop.org/libinput/libinput.git
  git_clone "$SWAY_SRC_ROOT/wlroots" 0.18 \
    https://gitlab.freedesktop.org/wlroots/wlroots.git
  git_clone "$SWAY_SRC_ROOT/sway" 818ea173\
    https://github.com/swaywm/sway.git
  if [ "$?" -eq 1 ] ; then
    sed -i "/'-Wvla',/ i \
      '-Wno-switch',\n" "$SWAY_SRC_ROOT/sway/meson.build"
  fi

  mkdir -p "$SWAY_SRC_ROOT/sway/subprojects"
  cd "$SWAY_SRC_ROOT/sway/subprojects" || exit
  if [ ! -d "wayland" ] ; then
    ln -sf ../../wayland wayland
  fi
  if [ ! -d "wayland-protocols" ] ; then
    ln -sf ../../wayland-protocols wayland-protocols
  fi
  if [ ! -d "wlroots" ] ; then
    ln -sf ../../wlroots wlroots
  fi
  if [ ! -d "libdisplay-info" ] ; then
    ln -sf ../../libdisplay-info libdisplay-info
  fi
  if [ ! -d "libdrm" ] ; then
    ln -sf ../../libdrm libdrm
  fi
  if [ ! -d "libliftoff" ] ; then
    ln -sf ../../libliftoff libliftoff
  fi
  if [ ! -d "seatd" ] ; then
    ln -sf ../../seatd seatd
  fi
  if [ ! -d "libinput" ] ; then
    ln -sf ../../libinput libinput
  fi

  if [ ! -x "/usr/local/bin/sway" ] || [ x"$UPDATE" == "x1" ] ; then
    cd $SWAY_SRC_ROOT/sway
    if [ ! -d "build" ] ; then
      $MESON setup build --buildtype=release
      if [ "$?" -ne 0 ] ; then exit; fi
    fi
    $MESON compile -C build
    if [ "$?" -ne 0 ] ; then exit; fi
    sudo $MESON install -C build
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
\$(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
EOF
set +a

exec sway \$@
EOOF
      sudo chmod a+x /usr/local/bin/start_sway.sh
      if [ "$?" -ne 0 ] ; then exit; fi
    fi
  else
    echo sway already installed
  fi

  cd "$CURRENT_DIR"
}

build_install_mako() {
  print "Build and install mako"

  git_clone "$SWAY_SRC_ROOT/mako" v1.9.0 \
      https://github.com/emersion/mako.git

  mkdir -p "$SWAY_SRC_ROOT/mako/subprojects"
  cd "$SWAY_SRC_ROOT/mako/subprojects" || exit
  if [ ! -d "wayland" ] ; then
    ln -sf ../../wayland wayland
  fi
  if [ ! -d "wayland-protocols" ] ; then
    ln -sf ../../wayland-protocols wayland-protocols
  fi

  if [ ! -x "/usr/local/bin/mako" ] || [ x"$UPDATE" == "x1" ] ; then
    cd $SWAY_SRC_ROOT/mako || exit
    if [ ! -d "build" ] ; then
      $MESON setup build --buildtype=release
      if [ "$?" -ne 0 ] ; then exit; fi
    fi
    $MESON compile -C build
    if [ "$?" -ne 0 ] ; then exit; fi
    sudo $MESON install -C build
    if [ "$?" -ne 0 ] ; then exit; fi
  else
    echo mako already installed
  fi

  cd "$CURRENT_DIR"
}

build_install_swappy() {
  print "Build and install swappy"

  git_clone "$SWAY_SRC_ROOT/swappy" \
      https://github.com/jtheoof/swappy.git

  if [ ! -x "/usr/local/bin/swappy" ] || [ x"$UPDATE" == "x1" ] ; then
    cd $SWAY_SRC_ROOT/swappy || exit
    if [ ! -d "build" ] ; then
      $MESON setup build --buildtype=release
      if [ "$?" -ne 0 ] ; then exit; fi
    fi
    $MESON compile -C build
    if [ "$?" -ne 0 ] ; then exit; fi
    sudo $MESON install -C build
    if [ "$?" -ne 0 ] ; then exit; fi
  else
    echo swappy already installed
  fi
}

config_sway() {
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
  $INSTALL mako-notifier

  # Screenshots: swappy + grim + slurp
  $INSTALL grim slurp
  $INSTALL swappy

  $INSTALL pcmanfm
  $INSTALL qalculate-gtk
  # $INSTALL gimp

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

  # Dependencies to build mako
  #$INSTALL libcairo2-dev libpango1.0-dev \
  #    libsystemd-dev libgdk-pixbuf2.0-dev \
  #    dbus libnotify-bin

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
  #$INSTALL libcairo2-dev libpango1.0-dev libgtk-3-dev

  # Dependencies to build sway, https://github.com/vcrhonek/hwdata.git
  #$INSTALL glslang-tools libcairo2-dev libcap-dev libdbus-1-dev \
  #    libdisplay-info-dev libevdev-dev libgdk-pixbuf2.0-dev \
  #    libjson-c-dev libliftoff-dev libpam0g-dev \
  #    libpango1.0-dev libpcre2-dev libpixman-1-dev libseat-dev \
  #    libsystemd-dev libvulkan-dev libwayland-dev libwayland-egl1 \
  #    libwlroots-dev libxcb-ewmh-dev libxkbcommon-dev \
  #    xwayland hwdata \
  #    pkgconf scdoc tree wayland-protocols
  #$INSTALL libinput-dev

  #build_install_sway
  #build_install_mako
  #build_install_swappy

  #sudo ldconfig

  config_sway

  cd "$CURRENT_DIR"
}

setup_greetd() {
  print "Setup greetd"
  $INSTALL greetd
}

build_setup_greetd() {
  setup_rustup
  print "Setup greetd"

  git_clone "$SWAY_SRC_ROOT/greetd" \
      https://git.sr.ht/\~kennylevinsen/greetd

  if [ ! -x "/usr/local/bin/greetd" ] || [ x"$UPDATE" == "x1" ] ; then
    cd $SWAY_SRC_ROOT/greetd

    # Compile greetd and agreety.
    cargo build --release
    if [ "$?" -ne 0 ] ; then exit; fi

    # Put things into place
    sudo cp target/release/{greetd,agreety} /usr/local/bin/

    if [ ! -f "/etc/systemd/system/greetd.service" ] ; then
      sudo cp greetd.service /etc/systemd/system/greetd.service
      sudo chmod a-x /etc/systemd/system/greetd.service
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
    fi

    cd "$CURRENT_DIR"
  else
    echo greetd already installed
  fi
}

setup_tuigreet() {
  setup_rustup
  print "Setup tuigreet"

  git_clone "$SWAY_SRC_ROOT/tuigreet" \
      https://github.com/apognu/tuigreet

  if [ ! -x "/usr/local/bin/tuigreet" ] || [ x"$UPDATE" == "x1" ] ; then
    cd $SWAY_SRC_ROOT/tuigreet

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

exec tuigreet \\
    --issue \\
    --time --time-format "%Y-%m-%d %H:%M %w" \\
    --power-shutdown 'sudo --non-interactive systemctl poweroff' \\
    --power-reboot 'sudo --non-interactive systemctl reboot' \\
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
  FONTS_DIR="$HOME/.fonts"
  if [ ! -f "$FONTS_DIR/$f" ] ; then
    if [ ! -f "$f" ] ; then
      wget -O "$f" "$u"
      if [ "$?" -ne 0 ] ; then exit; fi
    fi
    cp "$f" "$FONTS_DIR/$f"
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

setup_printer() {
  print "Setup printer"
  $INSTALL cups printer-driver-cups-pdf printer-driver-all
  print "Open http://localhost:631 to add p910nd printer\n\
  1. Open the CUPS web interface.\n\
  2. Select Add Printer.\n\
  3. Under Device, select AppSocket/JetDirect \n\
     (P910nd printers are NOT auto-detected by CUPS)\n\
  4. Under Connection, enter the following URI, using\n\
     the IP address of the server: socket://aaa.bbb.cc.dd:9100\n\
  5. Select the printer Make and Model as usual. If a driver\n\
      package like hplip_print is needed, you must first\n\
      install it on the client machine.\n\
  "
}

setup_wps() {
  print "Setup wps"

  $INSTALL qalculate-gtk

  # Install wps-fonts
  # https://github.com/udoyen/wps-fonts
  #
  # fc-cache -f -v

  # The wps office pdf reader is not working on Ubuntu 24.04
  # I also encountered this problem, unable to open pdf and
  # unable to convert other files to pdf. It was found that
  # there is no libtiff.so.5 in Ubuntu 23.04 and Ubuntu 24.04.
  # You can create a symlink to guide to libtiff.so.6
  #
  #   cd /usr/lib/x86_64-linux-gnu
  #   sudo ln -s libtiff.so.6 libtiff.so.5
  #
  # Sometimes when you want to use the APT command on Debian or
  # Ubuntu you see an error like below file '/var/cache/apt/archives/partial/
  # couldn't be accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied)
  #
  # If you face this error message during your installation or updates,
  # you can follow these steps and solve the issue.
  #
  #   sudo vi /etc/apt/apt.conf.d/10sandbox
  #
  # Add the following line to the file:
  #
  #   APT::Sandbox::User "root";
  #
  # Then save and close the editor, and try again to update or upgrade your
  # Debian/Ubuntu with the APT command.
}

setup_virt_manager() {
  print "Setup virt-manager"
  $INSTALL virt-manager qemu-kvm bridge-utils
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

#setup_rustup

setup_greetd
#setup_tuigreet

setup_sway

setup_fonts
setup_fcitx5
setup_firefox
setup_network
setup_printer

#setup_virt_manager

#setup_awesome
#setup_lightdm
#
#TODO: printer, sway greater

print "We need add below line into sudoers, \n\
see https://github.com/apognu/tuigreet?tab=readme-ov-file#power-management \n\
\n\
%%video ALL=NOPASSWD: /bin/systemctl poweroff, /bin/systemctl reboot, /bin/systemctl hibernate\n\
%%greeter ALL=NOPASSWD: /bin/systemctl poweroff, /bin/systemctl reboot, /bin/systemctl hibernate\n\
\n\
You can using 'sudo visudo' command."

print "After rebooting, execute the 'sway' command to enter the desktop, \n\
and execute 'pavucontrol' to initialize the sound, and execute 'fcitx5-config-qt' \n\
to configure the input method, and execute 'nmcli' to configure the network.\n\
\n\
Completed!!!\n"

