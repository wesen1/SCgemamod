wesen's gema mod

This is the lua mod I created some time ago. It is based on JG99's gema mod and includes some ideas of other people.
Including an offline cube script gema mod.

The Lua Mod is using functions / ideas of:

Sveark : JG99's gema mod is based on Svearks gema mod
JG99 / Pikachu	: my gema mod is based on JG99's gema mod
AoX| : !whois, color texts, 
|FaD|			: !addminute
Baruch / .45|	: save records in milliseconds, flag reset, moderators, isip()
grenadier		: geoip

ideas:

save logfile in other place or create own logfile (=> create new logfile every day)

.45| : 
	send irc to chat and send ingame chat to irc (of all servers/ server ports)
	!ignoreirc : players can ignore irc chat to avoid spam

AoX| :
	add sent maps to random maprot
	!randomrot  (de/activate random maprot) for moderator and admins
		
Gema Avenger :
    save timestring with record
    
Gema Central :
if people call votes to kick/ban/force someone (votes with target cn) then voteend no if target cn has a higher level than cn who called the vote

my ideas : 
	unlockall() / reset_locked ()
	anti spam (chat and sendmap)
	save every record, don't overwrite in case of hackers using same names like existing records, so you can restore the old records when the hacked one is deleted
	add "invalid arguments" error message to every command
	make everything working with an empty server too (for example maptop)
	delservermap (mapname)
	delfromrandomrot (mapname)
	!autokick <cn> : in case of !ban not working properly
		
current bugs:
	can't vote that often : players can not vote very often
	load for 2934024109348 minuts : random big number instead of the real time the next map starts with
	delrecord not working
	
	
other things:
		server ideas:
			quality assurance : only moderators/admins can upload new maps to other servers than map upload server
				-> therefore add2randomrot (mapname) onplayersendmap possible
			
			different servers:
				easy maps
				medium maps
				hard maps
				all maps
				private gema server
				map upload server  (all maps deleted every day)
				
			!stats
				maps uploaded : 
				records :
