# Mvtk

This gem install a command `mvtk`, it's not a gem you can use in your software.

The goal is simple: take crappy movie filename from a directory and name them the good way for kodi mediacenter using well known scraper.

2 scraper supported at this Time

* [media-passion](http://scraper.media-passion.fr/index2.php?Page=Home)
* [themoviedb.org](https://www.themoviedb.org/)

## Installation

    $ gem install mvtk

Then first launch will create the configuration file in ~/.config/mvtk.conf

## Configuration

Edit  **~/.config/mvtk.conf**

* *scraper* = "themoviedb" or "mediapassion", which scraper you Usage
* *saga_enable* = enable or not saga subdir
* *saga_prefix* = a string to prefix saga subdir name (.../terminator/... => .../prefix saganame/...)
* *source* = source directory to recursively find movie file
* *target* = directory to copy movie with right name
* *windows_name* = make created file and folder Microsoft Windows compatible (some characters replace witch _ )
* *min_movie_time* = Minimum number of minutes to determine if the video file is a movie or a tvshow



## Usage

just launch `mvtk`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Celedhrim/mvtk.
