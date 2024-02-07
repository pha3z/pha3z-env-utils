#better ssh hosts management (original author James Houx 2024-2-7)
#using two commands: 
#  showhosts
#  myssh
#These commands allow you to create folders to organize your ssh hosts, while having
#a convenient command to list hosts and connect to them.

#Use showhosts and showhosts [foldername] to identify the host you want to connect to.
#Then use 'myssh [hostname]' to connect to the host. :)

#showhosts : List all ~/.ssh/ folders
#showhosts [foldername] : List all hosts in ~/.ssh/[foldername]/config
function showhosts() {
if [ -z "$1" ]; then
    ls ~/.ssh// | grep /: | sed 's/:$//' | sed 's|/$||' | sed 's/.\///'
  else
    grep "^Host" ~/.ssh/$1/config | awk '{for (i=2; i<=NF; i++) print $i}'
  fi
}

#myssh [foldername] [hostname]
function myssh() {
  ssh -F ~/.ssh/$1/config $2
}
