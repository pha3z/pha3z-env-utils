#James Houx Host Configs
#better ssh hosts management (original author James Houx 2024-2-7)
#utilizing 3 commands:
#  showhosts
#  myssh
#  usehosts
#These commands allow you to create folders to organize your ssh hosts, while having
#a convenient command to list hosts and connect to them.

#Preferred Workflow:
#'showhosts' to identify folder. Then: 'usehosts [foldername]' to make that config the active .ssh/config (via copy)
#Then 'ssh [hostname]' to connect to the host.

#Alternative workflow, if you don't want to overwrite .ssh/config:
#'showhosts' to identify folder. Then: 'showhosts [foldername]' to identify the host you want to connect to.
#Then 'myssh [foldername] [hostname]' to connect to the host. :)

#showhosts : List all ~/.ssh/ folders
#showhosts [foldername] : List all hosts in ~/.ssh/[foldername]/config
function showhosts() {
  if [ -z "$1" ]; then
    ls ~/.ssh/*/ | grep /: | sed 's/:$//' | sed 's|/$||' | sed 's/.*\///'
  else
    grep "^Host" ~/.ssh/$1/config | awk '{for (i=2; i<=NF; i++) print $i}'
  fi
}

#usehosts [foldername]
function usehosts(){
  cp ~/.ssh/$1/config ~/.ssh/config
  showhosts $1
}

#myssh [foldername] [hostname] ["optional_ssh_args"]
function myssh() {
  if [ -z "$1" ]; then
    echo 'Usage: myssh [foldername] [hostname] ["optional_ssh_args"]'
    echo 'If you pass additional args for the ssh command, wrap the whole section of args in double quotes. The section will be passed to 'ssh' cmd without alteration'
  else
    if [ -z "$3" ]; then
      ssh -F ~/.ssh/$1/config $2
    else
      ssh $3 -F ~/.ssh/$1/config $2
    fi
  fi
}
