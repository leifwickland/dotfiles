# Load the basic buildserver post script.
source "$( dirname "${BASH_SOURCE[0]}" )/buildserver.post.sh"

# The vim on the new build servers is new enough. Getting the NFS vim to work was going poorly.
alias vi='vim'
EDITOR='/nfs/project/aarnone/OEL6/vim/current/bin/vim'

for i in /nfs/project/aarnone/OEL6/*/current/bin; do 
  pathmunge "$i"
done
