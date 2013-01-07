so buildserver.pre.sh

# The libperl.so that vim depends on is in a different place on madison than the old dev servers.
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64/perl5/CORE/
