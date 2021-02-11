#!/bin/bash

# Setup loopback camera
sudo systemctl start video-loopback.service

# create sink specifically for obs
pacmd load-module module-null-sink sink_name="obs-input" sink_properties=device.description="OBSInput" channels=2

# create a combination sink for OBS Input so this continues to export to the dafault audio too
default_sink="$(pacmd list-sinks | grep -A 1 "\*\ index:" | tail -n 1 | sed -e 's/.*<\(.*\)>.*/\1/g')"
pacmd load-module module-combine-sink sink_name="obs-and-default" sink_properties=device.description="OBSAndDefault" slaves="obs-input,$default_sink"

# setup OBS output
pacmd load-module module-null-sink sink_name="obs-output-sink" sink_properties=device.description="OBSOutputSink" channels=2
pacmd load-module module-remap-source source_name="obs-output-source" source_properties=device.description="OBSOutputSource" master="obs-output-sink.monitor"

echo 'Set application outputs to OBS_Input to just send to OBS. Set application outputs to OBS_Input_and_default if you want to hear it too'
echo 'Note: you might need to do this in pauvcontrol'
echo ''
echo 'Make sure OBS is sourcing OBS_Input. Desktop Audio Properties => Device => OBS_Input'
echo ''
echo 'In OBS Output, make sure the audio monitor is set to "Monitor of OBS_Output"'
echo 'In Meet/Zoom set up some cool things'
