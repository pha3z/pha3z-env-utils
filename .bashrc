#showhosts command (original author James Houx 2024-2-7)
#This command allows you to create folders to organize your ssh hosts, while having
#a convenient command to list everything you've configured.
#Invoking parameterless 'showhosts' will list all of your ~/.ssh folders
#Invoking 'showhosts [foldername] will lists all hosts in [foldername]/config
#You can then use 'ssh [hostname] to connect to the host. :)
#Usage:
#Create folders in ~/.ssh
#In each folder add a config file following the standard .ssh/config format. Name the file 'config'
#The command has two ways to invoke it:
#showhosts
#showhosts [foldername]
function showhosts() {
if [ -z "$1" ]; then
    ls ~/.ssh// | grep /: | sed 's/:$//' | sed 's|/$||' | sed 's/.\///'
  else
    grep "^Host" ~/.ssh/$1/config | awk '{for (i=2; i<=NF; i++) print $i}'
  fi
}
