#James Houx Host Configs
#better ssh hosts management (original author James Houx 2024-2-7)
#utilizing 2 commands:
#  showhosts
#  usehosts
#These commands allow you to create folders to organize your ssh hosts, while having
#a convenient command to list hosts and connect to them.

#How to Use:
#'showhosts' to identify folder. Then: 'usehosts [foldername]' to make that config the active .ssh/config (via copy)
#Then 'ssh [hostname]' to connect to the host.

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
