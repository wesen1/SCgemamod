PLUGIN_NAME = "wesen's gemamod"
PLUGIN_AUTHOR = "wesen"
PLUGIN_VERSION = "1.0"

-------------------

--	other stuff

function isip(ip) 					-- check if a given string can be interpreted as an ip
	local splitted_ip = split(ip,".")
	if #splitted_ip ~= 4 then return false end
	for k = 1, 4 do
		local n = tonumber(splitted_ip[k])
		if n == nil or n <0 or n > 255 then return false end
    end
    return true
end

-- check whether there is a vote pending
function isVotePending ()

	isvote = false

	for i in pairs (players) do
		
		if getvote(i) ~= 0 then
			isvote = true
			break
		end
	end
	
	return isvote
end

--
-- returns with which weapons the map was finished
--
function getWeaponsFinished ()

	-- get weapons with which the map was finished
	local sql = [[ SELECT weapon.name AS weapon_name
		       FROM weapon
         	       WHERE weapon.id IN
         			       ( SELECT weapon
                    		         FROM record
                    		         WHERE map = ]].. map_id ..[[
                 		       )
                 	ORDER BY weapon.number ASC;]]

	return db:query (sql)
	
end


--
-- returns with which weapons the map was not finished yet
--
function getWeaponsMissing ()

	local sql = [[ SELECT weapon.name AS weapon_name
		       FROM weapon
         	       WHERE weapon.id NOT IN
         			           ( SELECT weapon
                    		  	     FROM record
                    		  	     WHERE map = ]].. map_id ..[[
                 		 	   )
                       ORDER BY weapon.number ASC;]]

	return db:query (sql)

end

-- params: level 	-> admin = 2, unarmed = 0
-- build commands like that ["commandname"] = { level;function};
commands = 
{
-- admin commands

["!blacklist"] = 	-- blacklist a player (cn or ip) Usage: !blacklist <cn>/<ip> <reason>
{
	2;
	function (cn, args)
		local ip = ""
		if #args >=1 then
			if isip (args[1]) then ip = args[1]
			else
				local tcn = tonumber(args[1])
				if isconnected(tcn) and ishigher(cn, tcn) then
                     ip = getip(tcn)
				else 
					say("\f3blacklist failed, you can not blacklist players with a higher role and have to use <cn> or <ip>",cn)
					return
				end
			end
			local admin_ip = getip(cn)
			local name = getname(tcn)
			if player_name == nil then player_name = "" end
			local player_name = getname(cn)
			local TimeStr = os.date( "%X - %d/%m/%Y" , os.time() )
			local reason = ""
			if #args >= 2 then reason = table.concat(args,"",2) end
			local text = "\n//reason: " ..reason.. "\n//name: " ..name.. "\n//time: " ..TimeStr.. "\n//map: " ..getmapname().. "\n//blacklisted by: " ..player_name.. "(" ..admin_ip..")\n" ..ip .. "\n"	
			local f = assert(io.open("config/serverblacklist.cfg", "a+"))  
			f:write(text)
			f:close() 
			say("\f3" .. ip .. " has been blacklisted!",cn)
			ban(tcn)
		else say("\f3invalid arguments",cn) 
		end
    end
};
}

function onPlayerCallVote(acn, type, text, number)

	if (type == SA_AUTOTEAM) or (type == SA_CLEARDEMOS) or (type == SA_SHUFFLETEAMS) then 
		voteend(VOTE_NO)
		say ("\f3You are not allowed to vote that!", cn)
	elseif (type == SA_FORCETEAM) and not isadmin(cn) then
		voteend(VOTE_NO)
		say ("\f3You are not allowed to vote that!", cn)
	end

end
