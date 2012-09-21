Time-Track notifier
-------------------

This is a standalone tool to remind you to check-in to "time-track":https://github.com/fs/time-track-reborn

Installation
------------

To setup it first you need to get your auth token from http://tt.flatsoft.com/users/edit
and paste it to config file.

Files searched for config data (in the order specified):
* timetrack.conf.default
* /etc/timetrack.conf
* ~/.timetrack

You'll want to place your auth token to the third one and/or revoke world read permissions from it.

After that you should add the crontab line like the following:

    * * * * * /home/timurb/git/time-track-notifier/timetrack.sh

This will make the popup appear once a minute until you check in.

Requires
--------

* curl is required to retrieve checkin status
* notify-send is required to send notifies in Linux
* growl and growlnotify is required to send notifies in Mac

Copyright notices
-----------------

Icon borrowed from http://www.judithlabaila.com/blog/set-of-animals/
