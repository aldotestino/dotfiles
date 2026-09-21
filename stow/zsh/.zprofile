# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/aldotestino/.docker/bin"
# End of Docker Desktop section.

# Homebrew uses /opt/homebrew on Apple Silicon and /usr/local on Intel Macs.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
