# Load the basic buildserver post script.
source "$( dirname "${BASH_SOURCE[0]}" )/buildserver.post.sh"

# The vim on the new build servers is new enough. Getting the NFS vim to work was going poorly.
alias vim='/usr/bin/vim -X'
alias vi='/usr/bin/vim -X'
EDITOR='/usr/bin/vim -X'
