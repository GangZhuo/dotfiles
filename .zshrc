# Export config directory as VHOME
if [ -z "$ZDOTDIR" ]; then
	export VHOME="$HOME"
else
	export VHOME="$ZDOTDIR"
fi

# $VHOME/.local/bin
if [ -d "$VHOME/.local/bin" ]; then
	if [[ "$PATH" != *"$VHOME/.local/bin"* ]]; then
		export PATH="$VHOME/.local/bin:$PATH"
	fi
fi

# $HOME/.local/bin
if [ -d "$HOME/.local/bin" ]; then
	if [[ "$PATH" != *"$HOME/.local/bin"* ]]; then
		export PATH="$HOME/.local/bin:$PATH"
	fi
fi

## pyenv
if [ -d "$HOME/.pyenv" ]; then
	export PYENV_ROOT="$HOME/.pyenv"
	if [[ "$PATH" != *"$PYENV_ROOT/bin"* ]]; then
		export PATH="$PYENV_ROOT/bin:$PATH"
	fi
	eval "$(pyenv init -)"
fi

# cargo
if [ -f "$HOME/.cargo/env" ]; then
	source "$HOME/.cargo/env"
fi

# Path to your oh-my-zsh installation.
if [ -d "$HOME/.oh-my-zsh" ]; then
	export ZSH="$HOME/.oh-my-zsh"
elif [ -d "/usr/local/share/oh-my-zsh" ]; then
	export ZSH="/usr/local/share/oh-my-zsh"
elif [ -d "/opt/share/oh-my-zsh" ]; then
	export ZSH="/opt/share/oh-my-zsh"
else
	export ZSH="$HOME/.oh-my-zsh"
fi

# Save .zsh_history, .z to $VHOME
# HISTFILE="$VHOME/.zsh_history"
# ZSHZ_DATA="$VHOME/.z"
#
# Save .zcompdump files to $HOME
# ZSH_COMPDUMP=$HOME/.zcompdump-$HOST

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set LS_COLORS
# See:
#   * https://linux.die.net/man/5/dir_colors
#   * https://linux.die.net/man/1/dircolors
#   * https://geoff.greer.fm/lscolors/
eval `dircolors -b ~/.dir_colors`

# Base16 Shell
#BASE16_SHELL="$HOME/.config/base16-shell/"
#[ -n "$PS1" ] && \
#    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
#        eval "$("$BASE16_SHELL/profile_helper.sh")"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	z
	zsh-autosuggestions
	extract
	web-search
	zsh-syntax-highlighting
	colored-man-pages
	colorize
	cp
)

# You should be install "zsh-autosuggestions" and "zsh-syntax-highlighting" by below commands:
#
# git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
#

source $ZSH/oh-my-zsh.sh

# User configuration

PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT+="%{$fg[green]%}$USER@%{$fg[green]%}%m"
PROMPT+=' %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Below are for which that $VHOME other than $HOME
# alias nvim="XDG_CONFIG_HOME=$VHOME/.config XDG_DATA_HOME=$VHOME/.local/share XDG_CACHE_HOME=$VHOME/.cache $VHOME/.local/nvim/bin/nvim"
# alias nvim="XDG_CONFIG_HOME=$VHOME/.config XDG_DATA_HOME=$VHOME/.local/share $VHOME/.local/nvim/bin/nvim"
# alias scp="/usr/bin/scp -i \"$VHOME/.ssh/id_ed25519\""
# alias ssh="/usr/bin/ssh  -F \"$VHOME/.ssh/config\""
# export GIT_SSH_COMMAND="/usr/bin/ssh -F \"$VHOME/.ssh/config\""
# export RIPGREP_CONFIG_PATH="$VHOME/.ripgreprc"  # Ripgrep

# This seeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
	OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
	zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
	zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# Logout tty and turn off monitor after 10 minutes
#if [ "$TERM" = "linux" ] && tty | egrep -q '^/dev/tty[[:digit:]]+$'
#then
#	export TMOUT=500
#	setterm --blank 10 --powerdown 12
#fi

#if [ -f /usr/bin/fcitx5 ]; then
#	export XMODIFIERS=@im=fcitx
#	export QT_IM_MODULE=fcitx
#	export GTK_IM_MODULE=fcitx
#fi

export IP4_GW=$(ip -4 route | grep default | awk '{print $3}' | head -n 1)
export SOCKS5_HOST=$IP4_GW
export SOCKS5_PORT=1080
export HPROXY_HOST=$IP4_GW
export HPROXY_PORT=1081

set_proxy() {
	export HTTP_PROXY=http://$HPROXY_HOST:$HPROXY_PORT
	export HTTPS_PROXY=$HTTP_PROXY
	export http_proxy=$HTTP_PROXY
	export https_proxy=$HTTPS_PROXY
}

unset_proxy() {
	unset HTTP_PROXY
	unset HTTPS_PROXY
	unset http_proxy
	unset https_proxy
}

# Examples
# set_buildenv() {
# 	export CPATH=/usr/local/include:/usr/include/oracle/21/client64
# 	export LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:/usr/lib/oracle/21/client64/lib
# 	export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/lib64/pkgconfig
# }
#
# unset_buildenv() {
# 	unset CPATH
# 	unset LIBRARY_PATH
# 	unset PKG_CONFIG_PATH
# }

# Set proxy at startup
# set_proxy

