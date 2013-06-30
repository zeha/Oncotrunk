# Oncotrunk

PubSub based file syncing daemon. (Really: directory watcher.)

Caveats:

- Linux and OS X only until somebody implements Oncotrunk::Watchers::... for further platforms. (see issue #1)
- OS X: the system supplied Ruby is too old (see issue #4)

## What you need

* Jabber Server with pubsub (events only)
* Server for file storage (SSH with keys, must install unison there)
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

## How this works

Oncotrunk watches the set directory for changes, and calls unison when needed.
It also publishes the change over Jabber so that other running Oncotrunk
instances can download the changed files (by calling unison).

Because Oncotrunk starts unison in the background, unison must be able to
login to your storage server without password prompts (SSH key in agent
works fine.)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
