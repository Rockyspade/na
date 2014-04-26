[![Gem Version](https://badge.fury.io/rb/ayadn.svg)](http://badge.fury.io/rb/ayadn) 
[![Build Status](https://travis-ci.org/ericdke/na.svg?branch=master)](https://travis-ci.org/ericdke/na)
[![Flattr this](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=ericdejonckheere&url=https://github.com/ericdke/na&title=Ayadn&language=&tags=github&category=software)

AYADN
=====

[App.net](http://app.net) command-line client.

The purpose of Ayadn is to give you access to all the features of App.net from the console.

View or scroll all streams in your Terminal, view or scroll conversations and posts from specific users or mentioning a user, follow/unfollow users, star/unstar/repost/etc, get information about users and their followers/followings, search for words or hashtags, list and download your files, view all your channels including Broadcasts and Patter rooms, write single-line or multi-line posts, send private messages, view geolocation data, etc.

This CLI has more than 50 features awaiting for your Geekiness to command them.

Ayadn is configurable: colors, timelines, durations, aliases, etc. 

You can also specify many options, like show the raw JSON instead of the formatted response, show only a number of most recents posts, show only new posts, etc.

There's also exclusive features, like the Blacklist: feed this mini database with usernames, client names or hashtags and Ayadn will never show you any post containing any of these elements.

Last but not least: Ayadn supports multiple ADN accounts! Authorize as many accounts as you wish and simply switch between them with a keystroke.  


## INSTALL

Install:

`gem install ayadn`  

Update:

`gem update ayadn`  

Uninstall:

`gem uninstall ayadn`  

### OS X, LINUX, BSD

Please use something like RVM or RBENV to install Ruby if necessary.

You can also use the Ruby shipped with your system but you shouldn't, as it would require root privileges.

### OTHER PLATFORMS

Ayadn 1.0.x isn't compatible with Windows: there's too many issues due to external Gems and POSIX-dependant tools.  

That may change in the future...  

### ALPHA-BETA-PRE

This is only necessary if you installed a pre-1.0 testing version:

Users of alpha, beta or pre-release versions should first uninstall the old versions with `gem uninstall ayadn` then run `ayadn set defaults` after installing version 1.0 (note that this will replace the config file contents).  

# DOCUMENTATION

Read the [manual](https://github.com/ericdke/na/blob/master/MANUAL.md).

# CONTACT

Author: [@ericd](http://app.net/ericd)

App account: [@ayadn](http://app.net/ayadn)

Website: [ayadn-app.net](http://ayadn-app.net)
