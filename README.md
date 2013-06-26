# Oncotrunk

PubSub based file syncing daemon.

Caveats:

- Requires unison to do the actual work.
- Requires a jabber account on a server with a pubsub server.
- "daemon" is not really a daemon.
- Linux and OS X only until somebody implements Oncotrunk::Watchers::... for further platforms.
- Requires a server to sync to (say, public reachable ssh server).

## Installation

Install globally:

    $ gem install oncotrunk

## Usage

Start once to create a configfile:

    $ oncotrunk
    A new config file has been created for you in /home/ch/.config/Oncotrunk/settings.yml. Please edit and restart.

Edit the mentioned file.

Start again, preferably in a screen or nohup:

    $ screen oncotrunk

(In the future, this should detach from your terminal.)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
