# SSH agent scripts for .bashrc and/or .bash_aliases
#----------------------------------------------------------------------------------------------------
#
# SSH agent scripts
#
#----------------------------------------------------------------------------------------------------
# Set SSH_ENV file
SSH_ENV="$HOME/.ssh/environment"

# Function for starting ssh agent and add keys from $HOME/.ssh/id_(rsa|dsa)
function start_agent() {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

function check_agent() {
  echo "SSH Agent age: $(( $(date +"%s") - $(stat -c "%Y" $SSH_ENV) )) second(s)"
  /usr/bin/ssh-add -l
}
#----------------------------------------------------------------------------------------------------
if [ -f "${SSH_ENV}" ]
  then
    . "${SSH_ENV}" > /dev/null

    # check the SSH_ENV file age and kill/remove it if older then 2 hours
    [ "$(( $(date +"%s") - $(stat -c "%Y" $SSH_ENV) ))" -gt "3600" ] && {
      kill ${SSH_AGENT_PID};
      rm ${SSH_ENV};
    }

     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
       start_agent;
     }
  else
    start_agent;
fi

# every time when within 1 hour window touch the SSH_ENV file to renew access check
touch ${SSH_ENV} > /dev/null
#----------------------------------------------------------------------------------------------------

