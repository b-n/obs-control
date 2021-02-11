# OBS-Control

A Ruby utility to help run OBS using a Novation Launchpad on Linux

And a little helper to setup pulseaudio and v4l2loopback

## Pre-reqs

This has been tested with the following:

- Ubuntu 20.04.1
- Ruby 3.0.0
- OBS 26.1.1
- Novation Launchpad Mini Mk3
- Pulseaudio

## Setup AV

I wanted to be able to specify which sounds were played to where. The script
`bin/setup-av.sh` has some pulse audio goodness. Don't trust a stranger and the
code they put into a shell script. Read it so you know what's going on

## Running

    bundle install
    ./bin/start

### Getting the Launchpad to Developer mode

I find this mode just easier to play with. Do what you want.

- Hold the Session key for 5 seconds until you are in the menu
- Press the bottom right key (should start scrolling Programmer)
- Press Session key to exit out of the menu

This mode is handy because bottom left is not 11 to 19, second row is 21 to 29.

## Config

This repo currently includes some stores that I'm using for my own purposes.
They are as follows:

- stores/scene.rb - A two way store and listener for the scenes. If you change
  the scene manually in OBS, it should also update on the launchpad for you
- stores/sound.rb - Technically just a shell command executor, but hey, you can
  use it to run `paplay` how you want. Each button press spans another "thread"
  so it will stack and not block the active thread
- stores/command.rb - Useful for just controlling OBS in general. I'm using
  this to swap out scene text specifically. Designed to be momentary buttons

All configs are retrieved from config/config.yml. They really should be split up

## TODO

- Support momentary buttons for audio. i.e. only play whilst holding the key
- Maybe make the config storing a bit more generic in the stores?
- Tests? hah
- Expand the commands that OBS can actually support with websockets
