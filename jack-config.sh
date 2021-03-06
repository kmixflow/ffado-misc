#!/bin/bash

######################################################################
#      REDIRECTING ALSA AUDIO TO PULSEADUIO AND THEN TO JACK         #
#          (or how to make JACK ready for everyday use)              #
######################################################################

#This script:
#1 - Installs pulseaudio-module-jack to load pulseaudio's jack modules
#    automatically via jackdbus

#2 - Configures ALSA to redirect all output to PulseAudio

#3 - (Deprecated) Makes JACK default PulseAudio out

#4 - Creates a script (pulse-jack-post-start.sh) and set qjackctl to load it
#    after JACK startup to redirect active sink-inputs nicely to JACK


#1 - Installing JACK, JACK2, qjackctl and pulseaudio module for JACK2
sudo apt-get -y install jack jackd2 qjackctl pulseaudio-module-jack

#2 - Redirecting ALSA audio to Pulseaudio
echo 'pcm.pulse {
    type pulse
}

ctl.pulse {
    type pulse
}

pcm.!default {
    type pulse
}
ctl.!default {
    type pulse
}' | sudo tee -a /etc/asound.conf > /dev/null

#3 - Redirecting Pulseaudio to JACK is not necessary if using JACK2 with  D-BUS
#If you prefer to not install JACK2 you can uncomment the following lines:
#(This will redirect PulseAudio to JACK forever.. if you prefer to to this only
#when loading jack, save the following lines to a new script and load it
#via qjackctl PostStartupScript. For more info see [1]).

#echo 'load-module module-native-protocol-unix
#load-module module-jack-sink channels=2
#load-module module-jack-source channels=2
#load-module module-null-sink
#load-module module-stream-restore
#load-module module-rescue-streams
#load-module module-always-sink
#load-module module-suspend-on-idle
#set-default-sink jack_out
#set-default-source jack_in' > ~/.pulse/default.pa

#4 - Setting things up nicely when loading jack.

cd ~/.config/rncbc.org/
wget https://raw.github.com/kmixflow/ffado-misc/master/pulse-jack-post-start.sh

chmod +x pulse-jack-post-start.sh

#Configuring qjackctl to load pulse-jack-post-start after JACK startup
cp QjackCtl.conf QjackCtl.conf.back

sed -i 's#^PostStartupScript=false#PostStartupScript=true#' QjackCtl.conf
sed -i 's#^PostStartupScriptShell=.*#PostStartupScriptShell=~/.config/rncbc.org/pulse-jack-post-start.sh#' QjackCtl.conf

#References:
#-----------
#[1]: https://wiki.archlinux.org/index.php/PulseAudio/Examples
#[2]: http://trac.jackaudio.org/wiki/WalkThrough/User/PulseOnJack
