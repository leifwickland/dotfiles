xset r rate 200 35 & # Wait 200 ms before repeating. Repeat at 35/second.
$HOME/.capsIsEscape &
if [ $(pgrep syndaemon | wc -l) -eq 0 ] ; then
  syndaemon -i 1 -K -d ;  # -i = Wait for 1 second after done typing.  -K = Allow mouse movement with mod keys and chords
fi
synclient PalmDetect=1 MaxTapTime=0 & # Please ignore my chubby palms. Don't tap to click.
