# Load the basic buildserver post script.
source "$( dirname "${BASH_SOURCE[0]}" )/buildserver.post.sh"

# The vim on the new build servers is new enough. Getting the NFS vim to work was going poorly.
alias vi='vim'
EDITOR='/nfs/project/aarnone/OEL6/vim/current/bin/vim'

pathmunge "/nfs/project/aarnone/OEL6/vim/current/bin/"
pathmunge "/nfs/project/aarnone/OEL6/ctags/current/bin"
pathmunge "/nfs/project/aarnone/OEL6/tig/current/bin"
