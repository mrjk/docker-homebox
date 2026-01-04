#!/bin/bash
set -eu -o pipefail

debug () {
  echo "INIT JEZ HOME"
  echo $PWD
  id -u
  groups
  echo "INIT JEZ HOME EOF"
}


log ()
{
  echo "$@"
}

export BASHRC_FILE=~/.bashrc
export BASHRC_DIR=~/.local/bashrc.d

configure_bash ()
{
  if grep -q "$BASHRC_DIR" ~/.bashrc 2>/dev/null; then
    log INFO "Bashrc already configured to load $BASHRC_DIR files"
    return 0
  fi

  echo >> $BASHRC_FILE
  echo "# Enable loading of files in $BASHRC_DIR" >> $BASHRC_FILE
  echo "if compgen -G "$BASHRC_DIR/*.sh" > /dev/null; then" >> $BASHRC_FILE
  echo "  . $BASHRC_DIR/*.sh" >> $BASHRC_FILE
  echo "fi" >> $BASHRC_FILE

  mkdir "$BASHRC_DIR"

  log INFO "Bashrc configured to load $BASHRC_DIR files"
}

configure_omb ()
{
  cp /usr/share/oh-my-bash/bashrc ~/.bashrc
  log INFO "Oh-my-bash configured to load on shell"
}

configure_mise () 
{
  BASH_CONF=$BASHRC_DIR/20_mise.sh

  if [ -f "$BASH_CONF" ]; then
    log INFO "Mise already configured"
    return 0
  fi

  echo 'eval "$(/usr/local/bin/mise activate bash)"' >> $BASH_CONF
  log INFO "Mise configured to load $BASH_CONF file"
}

configure_homebrew ()
{
  BASH_CONF=$BASHRC_DIR/20_homebrew.sh

  if [ -f "$BASH_CONF" ]; then
    log INFO "Homebrew already configured"
    return 0
  fi

  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $BASH_CONF
  log INFO "Homebrew configured to load $BASH_CONF file"
}

final ()
{
  echo "All build tools correctly installed as $app_username"
}

# set -x
#debug
configure_omb

# V1
#configure_bash
#configure_homebrew
#configure_mise
#final

