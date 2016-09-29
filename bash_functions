#----------------------------------------------------------------------------------------------------
# Start new Tmux session if none exist else attach to existing one
#----------------------------------------------------------------------------------------------------
if [ $TERM != "screen-256color" ] && [ $TERM != "screen" ] && [ ! -z "$PS1" ]; then
  tmux -S /tmp/tmux-shared-nslot attach -t nslot 2>/dev/null >/dev/null || {
#  tmux -S /tmp/nlot-shared attach -t nslot 2>/dev/null >/dev/null || { 
    find /tmp -user nslot -name "tmux*" -exec rm -rf {} \; 2>/dev/null
#    tmux -S /tmp/nlot-shared new -s nslot
    tmux -S /tmp/tmux-shared-nslot new -s nslot
    exit
  }
fi

#----------------------------------------------------------------------------------------------------
# Use your SSH Agent.
# Unload keys after 30 minutes
#----------------------------------------------------------------------------------------------------
SSH_ENV="$HOME/.ssh/environment"

#----------------------------------------------------------------------------------------------------
# Function for starting a dedicated ssh agent.
start_ssh-agent() {
  echo "Initialising new SSH agent..."
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
  echo succeeded
  chmod 600 "${SSH_ENV}"
  . "${SSH_ENV}" > /dev/null
}

#----------------------------------------------------------------------------------------------------
# Check for running ssh-agent.
#  add keys when needed.
check_ssh-add() {
  if [ "$DESKTOP_SESSION" == "" ]; then
    if [ -f "${SSH_ENV}" ]
      then
        . "${SSH_ENV}" > /dev/null
        ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
          start_ssh-agent;
        }
      else
        start_ssh-agent;
    fi

    if [[ `ssh-add -l` != *id_?sa* ]]; then 
      ssh-add -t 1800
    fi
  fi
}

#----------------------------------------------------------------------------------------------------
# Functions for redirecting tools through function check_ssh-add
slogin() { 
  check_ssh-add
  /usr/bin/slogin $@
}

ssh() {
  check_ssh-add
  /usr/bin/ssh $@
}

scp() {
  check_ssh-add
  /usr/bin/scp $@
}

sftp() {
  check_ssh-add
  /usr/bin/sftp $@
}
