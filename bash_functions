alias apt-get='apt-cyg'
alias tmux='rm -rf /tmp/tmux* && tmux'

SSH_ENV="$HOME/.ssh/environment"

# Function for starting ssh agent and add keys from $HOME/.ssh/id_(rsa|dsa)
start_ssh-agent() {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
}

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
