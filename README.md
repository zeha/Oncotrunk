# Oncotrunk

PubSub based file syncing daemon. (Really: directory watcher.)

Caveats:

- Linux and OS X only until somebody implements Oncotrunk::Watchers::... for further platforms.

## What you need

* Jabber Server with pubsub (events only)
* Server for file storage (SSH, must install unison there)
* Clients (install oncotrunk and unison on them)

## Installation

Install globally:

    $ gem install oncotrunk

Install unison:

Debian/Ubuntu:

    $ apt-get install unison

OS X:

    $ brew install unison

## Usage

Start once to create a configfile:

    $ oncotrunk start
    A new config file has been created for you in /home/ch/.config/Oncotrunk/settings.yml. Please edit and restart.

Edit the mentioned file.

Start again:

    $ screen oncotrunk start

Oncotrunk will now register itself as a PubSub publisher and subscriber, and watch the local directory for changes.
You should now install Oncotrunk on a second machine (say, your laptop or the remote server) as well.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
