# Lemonade
This is my config for i3. It uses lemonbar. It's work-in-progress-ish\*, and has a lot of sloppy things that I'm too lazy to fix.

![Screenshot!](http://i.imgur.com/9mX6bIR.png)

<sub>\* Meaning that I don't work much on it. Not that it's almost finished.</sub>

But hey, it has multi-monitor support and it works for me! Your mileage may vary. 

# Dependencies
- [i3-gaps](https://github.com/Airblader/i3)
- xscreensaver
- python3 - for benkaiser's workspace controller script and my subscription_handler
- feh - background manager
- compton - for ocd mode
- conky - for stats
- [lemonbar-xft-git](https://github.com/krypt-n/bar) - lemonbar with xft support
- ttf-droid - font
- ttf-font-awesome - font
- weather - to get celcius
- i3ipc-python-git - for subscription_handler helper script
- gnome-do - Or change it to dmenu or something
- arandr - xrandr gui

# Rainmeter
Set up your `RAIN_LAT` and `RAIN_LON` in your settings file.
When it('s about to) rain(s), you will see 1-3 umbrella's

The first umbrella shows you the rain in the next 40 minutes.
The second umbrella shows you the rain 40 minutes from now, until 80 minutes from now.
The third umbrella shows you the rain 80 minutes from now, until 120 minutes from now.

The umbrella's have colours as specified in by `RAIN_COLOR_*` in settings.
The more it rains, the higher the colour level.

# Credits and Thanks
- [Benkaiser](https://github.com/benkaiser/) for his work on i3-wm-config which was used as a basis for this config.
- [maikelwever](https://github.com/maikelwever) for his edits to benkaiser's config which I originally forked from.
- [eletro7](https://github.com/electro7/) for his idea of using fifo queues for lemonbar
- Author of the perl volume script. I think it originated [here](https://askubuntu.com/questions/456842/check-pulseaudio-sink-volume/456869).
- Also thanks to all the developers who made the tools I am using and anyone I might have forgotten.

# Background:
Once you have feh installed, you can use this to set your background:
`feh --bg-scale /path/to/img`
