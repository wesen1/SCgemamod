This project will be completely converted into a new version, then this repository will be deleted.

Note:
* The V2 version had a failed git commit.
* The source files are all gone (hard disk was reformatted multiple times before recognizing the mistake).
* I am confident to be able to recreate my gema mod from scratch and to do better than the source files that I lost.

# wesen's gema mod

The Lua Mod is using functions / ideas of:

- Sveark : JG99's gema mod is based on Svearks gema mod
- JG99 / Pikachu	: my gema mod is based on JG99's gema mod
- AoX| : !whois, color texts, 
- |FaD|			: !addminute
- Baruch / .45|	: save records in milliseconds, flag reset, moderators, isip()
- grenadier		: geoip

# Lua Mod Documentation

* https://web.archive.org/web/20111102112829/http://sveark.info/ac/Lua/
* Check the lua server source files (not all functions are documented on the website)

# Gema Maps

A list of maps (including a lot of gema maps) can be found here:

* frag.gq/packages/maps/
* http://www.mirari.fr/9n16
* http://ny.aox-ac.net/Contents/packages/maps/servermaps/mapsls.txt
* http://forum.cubers.net/showthread.php?mode=linear&tid=7383&pid=144486


## Ideas:

- save logfile in other place or create own logfile (=> create new logfile every day)
- .45| : 
  * send irc to chat and send ingame chat to irc (of all servers/ server ports)
  * !ignoreirc : players can ignore irc chat to avoid spam
- Gema Central :
  * if people call votes to kick/ban/force someone (votes with target cn) then voteend no if target cn has a higher level than cn who called the vote

## My Ideas : 
- anti spam (chat and sendmap)
- save every record, don't overwrite in case of hackers using same names like existing records, so you can restore the old records when the hacked one is deleted

## current bugs:
- can't vote that often : players can not vote very often
- delrecord not working

## other things:
- server ideas:
  *quality assurance : only moderators/admins can upload new maps to other servers than map upload server
  * different servers:
    * easy maps
    * medium maps
    * hard maps
    * all maps
    * private gema server
    * map upload server  (all maps deleted every day)
- !stats
  * amount of maps uploaded
  * records
* create a web interface for map- and gtops


## Special thanks to:

- +f0r3v3r+ and .45|Todesgurke for trusting me enough to give me an admin password for their servers
- boss and Arisu-chan for playing gemas with me
