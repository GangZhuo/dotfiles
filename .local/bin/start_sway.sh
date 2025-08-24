#!/usr/bin/env bash
#
# Copy from:
# [Environment variables done once]
# (https://curiouscoding.nl/linux/environment-variables/)
#
# Environment variables done once
# 30 June 2021 2-minute read
# Ragnar Groot Koerkamp
# linux • wayland
#
# Xrefs: [GitHub issue](https://github.com/systemd/systemd/issues/7641)
#
# One problem I had with my Sway setup is that setting environment variables
# in my config.fish (the Fish equivalent to .bashrc or .zshrc) is not always
# sufficient.
#
# In particular, I need my environment variables to be available in at least
# the following places:
#
#  * my Fish shell,
#  * applications launched from Sway (e.g. using keybindings),
#  * applications launched as a systemd service (e.g. the Emacs server daemon).
#
# Setting variables in the shell profile has the problem that they are not
# picked up by systemd services. Another option seems to be ~/.pam_environment,
# but this is deprecated (https://github.com/linux-pam/linux-pam/commit/ecd526743a27157c5210b0ce9867c43a2fa27784).
#
# One solution, coming from this GitHub issue (https://github.com/systemd/systemd/issues/7641),
# is to use environment.d provided by systemd, and import these variables into Sway:
#
#  1. Create the directory ~/.config/environment.d/.
#
#  2. Create one or more files containing variables.
#     E.g. wayland.conf containing:
#
#       ```
#       # Wayland configuration
#       GDK_BACKEND=wayland
#       XDG_SESSION_TYPE=wayland
#       SDL_VIDEO_DRIVER=wayland
#       ```
#
#  3. Instead of directly launching sway from your display manager or shell
#     config, create a wrapper script swayrun.sh, based on this comment
#     (https://github.com/systemd/systemd/issues/7641#issuecomment-693117066).
#     You could put this in e.g. /usr/local/bin/ or somewhere in your homedir.
#     This script calls a systemd generator to read all environment variables
#     set in environment.d and exports them.
#
#       ```
#       #!/usr/bin/env bash
#       set -euo pipefail
#
#       # Export all variables
#       set -a
#       # Call the systemd generator that reads all files in environment.d
#       source /dev/fd/0 <<EOF
#       $(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
#       EOF
#       set +a
#
#       exec sway
#       ```
#
#  4. In your display manager or shell config, replace exec sway by exec
#     ~/path/to/swayrun.sh.
#
# All your environment variables set in the environment.d directory will
# now be shared between your shell, Sway and systemd services.
#
# Note that I am currently only using this setup on my laptop - not on my server.
# I am not exactly sure how well this would work when SSHing. Currently Fish
# inherits all environment variables from Sway and does not set any of them
# itself. This works fine without SSH, but you may need to source the
# environment.d generator script from Fish as well. Since Fish uses a somewhat
# different syntax from Bash and Zsh, this in itself is not completely trivial
# so I have not yet looked into this.
#

set -euo pipefail

# Export all variables
set -a
# Call the systemd generator that reads all files in environment.d
source /dev/fd/0 <<EOF
$(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
EOF
set +a

exec sway $@

