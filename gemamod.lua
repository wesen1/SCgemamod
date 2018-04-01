PLUGIN_NAME = "wesen's gemamod"
PLUGIN_AUTHOR = "wesen"
PLUGIN_VERSION = "1.0"

function geoip (ip)		-- replace last digit of an ip by "x"
	local parts = split(ip,".")
	return parts[1] .. "." .. parts[2] .. "." .. parts[3] .. ".x"
end

function getcountry(ip)	-- find country where given ip is located
	local parts = split(ip, ".")
	local tmp_first_byte = tonumber(parts[1])
	local tmp_second_byte = tonumber(parts[2])
	local tmp_third_byte = tonumber(parts[3])
	local tmp_ipnum = 65536 * tmp_first_byte + 256 * tmp_second_byte + tmp_third_byte
	local tmp_abbr = 0
	local countries = {}
	local country = ""

	if tmp_ipnum >= 655360 and tmp_ipnum <= 720895 or tmp_ipnum >= 11276288 and tmp_ipnum <= 11280383 or tmp_ipnum >= 12625920 and tmp_ipnum <= 12626175 then return "private" end

	local lines = split(cfg.getvalue("geoip/ipnum", tostring(tmp_first_byte)), "\t")

	for i = 1, #lines, 1 do
		local geoip_data = split (lines[i]," ")
		if tonumber(geoip_data[1]) <= tmp_ipnum then tmp_abbr = geoip_data[2] end
	end

	tmp_abbr = {splitabbr (tmp_abbr)}
	for i = 1, #tmp_abbr, 1 do
		table.insert(countries, cfg.getvalue ("geoip/countrylist",tmp_abbr[i]))
	end

	if #countries == 0 then country = "nowhere"	
	else
		country = countries[1]
		if #countries > 1 then
			for i = 2, #countries, 1 do
				country = country .. " or " .. countries[i]
			end
        end
	end

	return country
end

function whois(cn)		-- returns geoip, getcountry of cn
	ip = getip(cn)
	return geoip(ip), getcountry(ip)
end

function readAll(file)	-- read a file and save it in a table (each line = table entry)
	local f = io.open(file, "rb")
	lines = {}
	for line in io.lines(file) do 
		lines[#lines + 1] = line
	end
    f:close()
    return lines
end

function splitabbr(str)	-- split a string into a table of 2 chars each entry
	if #str>0 then return string.sub(str,1,2),splitabbr(string.sub(str,3)) end
end

function ipnums ()		-- use geoip_ipnum.txt and geoip_abbr.txt to create ipnum.cfg	->	[first digit] = ipnum country	ipnum country ... 
	local ipnum = readAll("lua/config/geoip_ipnum.txt")		-- path to your geoip_ipnum.txt
	local abbr = readAll("lua/config/geoip_abbr.txt")		-- path to your geoip_abbr.txt
	local tmp_start = 0
	local tmp_end = 0
	local tmp_lines = {}
	
	for i = 2, #ipnum-1, 1 do
		tmp_lines = {}
		parts = split(ipnum[i]," ")
		if parts[1] == "const" then
			tmp_start = i+1
		elseif parts[1] == "]" then
			tmp_end = i-1
			
			for i = tmp_start, tmp_end, 1 do
				table.insert(tmp_lines, ipnum[i] .. " " .. abbr[i] )
			end
			parts = split(ipnum[tmp_start - 1]," ")
			cfg.setvalue("geoip/ipnum", string.sub(parts[2],17), table.concat(tmp_lines, "\t"))
		end
	end
end

function countrylist ()	-- use geoip_countrylist.txt to create countrylist.cfg	( [abbr] = country )
	local countrylist = readAll("lua/config/geoip_countrylist.txt")
	
	for i = 3, #countrylist - 2, 1 do
		local parts = split (countrylist[i], " ")
		local tmp_abbr = string.gsub(parts[1],'"',"")
		local tmp_countryname = string.gsub(table.concat(parts," ",2),'"',"")
		cfg.setvalue ("geoip/countrylist",tmp_abbr, tmp_countryname)
	end
end

-------------------
cached_gtop = {}		-- cached gtop table, to make loading the gtops much faster

function change_record_gtop (gtop, name, index, mode)	-- modes : "add", "remove" ; add a normal record to gtop
	local exists = false
	for i = 1, #gtop[index], 1 do
		if gtop[index][i][1] == name then
			if mode == "add" then
				gtop[index][i][2] = gtop[index][i][2]+1
				gtop[index][i][4] = gtop[index][i][4]+1
			elseif mode == "remove" then
				gtop[index][i][2] = gtop[index][i][2]-1
				gtop[index][i][4] = gtop[index][i][4]-1
			end			
			exists = true
		end
	end
	if not exists and mode == "add" then table.insert(gtop[index], {name,1,0,1}) end
	table.sort(gtop[index],function (L, R) return L[2] > R[2] end)
	return gtop
end

function change_best_gtop (gtop,name, index, mode)		-- modes : "add", "remove" ; add a best time to gtop
	local exists = false
	for i = 1, #gtop[index], 1 do
		if gtop[index][i][1] == name then
			if mode == "add" then
				gtop[index][i][2] = gtop[index][i][2] + 100001
				gtop[index][i][3] = gtop[index][i][3]+1 
				gtop[index][i][4] = gtop[index][i][4]+1
			elseif mode == "remove" then
				gtop[index][i][2] = gtop[index][i][2] - 100001
				gtop[index][i][3] = gtop[index][i][3]-1 
				gtop[index][i][4] = gtop[index][i][4]-1
			end
			exists = true
		end
	end
	if not exists and mode == "add" then table.insert(gtop[index],{name,100001,1,1}) end
	table.sort(gtop[index],function (L, R) return L[2] > R[2] end)
	return gtop
end

function gload(weapon,grecords1,player_index1,counter1)	-- get gtop from one maptop file
	
	local grecords = grecords1
	if grecords == nil then	grecords = {} end
	local player_index = player_index1
	if player_index == nil then player_index = {} end
	local counter = counter1
	if counter == nil then counter = 0 end
	
	local filepath = "lua/config/maptop/maptop"
	if weapon == nil then filepath = filepath .. ".cfg"
	else filepath = filepath .. "_" .. weapon .. ".cfg"
	end
	
	for line in io.lines(filepath) do
		local cnt = string.find(line, "=")
		if cnt ~= nil then
			local map_name = string.sub(line,1,cnt - 1)
			local tmp_records = sorted_records(load_records(map_name,weapon))
			for i, record in ipairs (tmp_records) do
				if player_index[record[1]] == nil then
					counter = counter + 1
					player_index[record[1]] = counter
					if i == 1 then table.insert (grecords, {record[1], 1, 1})
					else table.insert(grecords, { record[1], 0, 1})
					end
				else
					if i == 1 then grecords[player_index[record[1]]][2] = grecords[player_index[record[1]]][2] + 1 end
					grecords[player_index[record[1]]][3] = grecords[player_index[record[1]]][3] + 1
				end
			end
		end
	end
	return grecords, player_index, counter
end

function load_gtop()									-- load all 6 gtops from maptop files (can take a while..)

	for i = 0, 5, 1 do
	
		local weapon = usergun(i)
		local top = {}
		local tmp_grecords = {}
		local tmp_player_index = {}
		local tmp_counter = 0
		local tmp_filepath = "maptop/maptop"
		if weapon ~= nil then tmp_filepath = tmp_filepath .. "_" .. weapon end
	
		if weapon == nil then	  			-- load rank from all maptops but maptop.cfg
			for i = 1, 5 , 1 do
				if file_exists("lua/config/maptop/maptop_" .. usergun(i) .. ".cfg" ) then 
					tmp_grecords, tmp_player_index, tmp_counter = gload(usergun(i),tmp_grecords,tmp_player_index,tmp_counter)
				else say("file not existent : lua/config/maptop/maptop_" .. usergun(i) .. ".cfg")
				end
			end
		else 
				if file_exists("lua/config/" .. tmp_filepath .. ".cfg") then
					tmp_grecords, tmp_player_index, tmp_counter = gload(weapon)
				else say("file does not exist : lua/config" .. tmp_filepath .. ".cfg")
			end
		end
	
		local tmp_index = 0
		for name, index in pairs (tmp_player_index) do
			local score = tmp_grecords[index][2] * 100000 + tmp_grecords[index][3]
			table.insert(top,{name,score,tmp_grecords[index][2],tmp_grecords[index][3]})
		end
		table.sort(top, function (L, R) return L[2] > R[2] end)
				
		local cache_index = weapon
		if weapon == nil then cache_index = 0 end

		cached_gtop[cache_index] = top
	end
end

function grank(weapon, name, self, cn)					-- load grank from one gtop for a specific player
	
	local cache_index = weapon
	if weapon == nil then cache_index = 0 end
	local top = cached_gtop[cache_index]

	local rank, record, best_times
	
	if #top ~= 0 then 
	
		for i, data in ipairs(top) do
			if name == data[1] then 
				rank = i 
				best_times = data[3]
				record = data[4]
				break
			end
		end

		if rank == nil then 
			if weapon == nil then
				if not self then say("\f3No records found for player " .. name, cn) return
				else say("\f3You have no records yet. Make at least one record to get a rank in gtop.",cn) return 
				end
			else
				weapon = getgun(weapon)
				say("\f1"..weapon.." \fJ: \f3no records found", cn)
			end	
		else
			local title = "Your"
			if not self then title = name .. "'s" end
			
			if weapon == nil then
				say("\fJ" .. title .. " grank is \fH"..rank.. " \fJwith \fH"..best_times.." \fJbest times and " .. record .. " records", cn)
			else
				weapon = getgun(weapon)
				say("\f1"..weapon.." \fJ: \fH"..rank.." \fJwith \fH".. best_times.."\fJ best times and " ..record.." records",cn)
			end
		end
	else
		if weapon == nil then say ("\f3gtop is empty!",cn)
		else say ("\f1" .. getgun(weapon) .. "\fJ: \f3no records found",cn)
		end
	end
end

------------------

function sendMOTD(cn)									-- send MOTD, some information about the map and about !cmds
   if cn == nil then cn = -1 end
   mapbest(getmapname(),nil,cn)
   local count, missing_weapons = get_missing_weapons()
   local total_records = get_totalrecords(getmapname())
   local s = "s"
   if total_records == 1 then s = "" end

   say("\fJThis map was finished by \fH" .. total_records .. " \fJplayer" .. s .. " and with \fH" .. count .. " \fJof \fH5 \fJweapons " .. missing_weapons,cn) 
   say("\fFSay \fH!cmds \fFto see a list of avaiable commands, say \fH!allcmds \fFto see a complete list of avaiable commands!", cn)
end

function get_missing_weapons(name)						-- get with how many and which weapons the map was not finished yet
	local count = 0
	local text_counter = 0
	local text = ""
	local s = ""
   
	for i=1, 5, 1 do
		local records = load_records(getmapname(),usergun(i))
		if not (name == nil and next(records) ~= nil) and not (name ~= nil and records[name] ~= nil) then
			text_counter = text_counter + 1
			if text_counter == 1 then text = getgun(usergun(i))
			else text = text .. ", " .. getgun(usergun(i))
			end
		else count = count + 1
		end
	end
	
	if text_counter > 1 then s = "s" end
	if text_counter ~= 0 then text = "\fJ(\f3missing weapon" .. s .. " : " .. text .. "\fJ)" end
	return count, text	 
end

------------------

function load_records(map,weapon)	-- load all records of a map with weapon	(records[name] = record)
	local records = {}
	local filename = "maptop/maptop"               				-- load from normal maptop
	if weapon ~= nil then filename = filename .. "_" .. weapon end	-- load from specific weapon maptop
  
	local data = cfg.getvalue(filename, map:gsub("=", ""))   
	if data ~= nil then
		local lines = split(data, "\t")
		for i,line in ipairs(lines) do
			record = split(line, " ")
			records[record[1]] = tonumber(record[2])
		end
	end
	return records
end

function sorted_records(records)	-- sort records table by record	(records[i] = {name, record})
	local sorted_records = {}
	for player, delta in pairs (records) do
		table.insert(sorted_records, { player, delta })
	end
	table.sort(sorted_records, function (L, R) return L[2] < R[2] end)
	return sorted_records
end

------------------

function usergun(gun)	-- convert user numbers for weapons to server number for weapons
	if gun == 1 then return 6    -- Assault
	elseif gun == 2 then return 4    -- Submachine
	elseif gun == 3 then return 5    -- Sniper
	elseif gun == 4 then return 3    -- shotgun
	elseif gun == 5 then return 2    -- carbine
	end
end

function getgun(gun)	-- returns weapon names which are displayed ingame, gun has to be server number for weapons
	if gun == 6 then return "Assault Rifle"
	elseif gun == 4 then return "Submachine Gun"
	elseif gun == 5 then return "Sniper Rifle"
	elseif gun == 3 then return "Shotgun"
	elseif gun == 2 then return "Carbine" 
	end
end

function tellmeweapon(record, name)	-- get, with which weapon a map was finished, if you only have the name and the record (and mapname) (if two records are the same the first weapon found will be chosen)
	local gunname = ""
	for i= 1,5,1 do
		local tmp_records = load_records(getmapname(),usergun(i))
		local tmp_delta = tmp_records[name]
		gunname = getgun(usergun(i))
		if tmp_delta == record then break end 
	end
	return gunname
end

------------------

function find_place(records, name)			-- find the place of a player in a maptop, returns rank, totalrecords
	local result = 0
	local total = 0
	for i,record in ipairs(records) do
		if record[1] == name then result = i end
		total = i
	end
	return result, total
end

function get_totalrecords (map)				-- get total amount of records of a map with all weapons, no player name is counted twice
	local amount = 0
	local counted = {}

	for i = 1, 5, 1 do
		local records = sorted_records(load_records(map,usergun(i)))
		for i , record in ipairs(records) do
			if counted[record[1]] ~= true then
				counted[record[1]] = true
				amount = amount + 1
			end
		end
	end
	return amount
end

function get_best_record(mapname,weapon)	-- get best record of a map
	local sorted_records = sorted_records(load_records(mapname,weapon))
	if sorted_records ~= nil then
		local i, best_record = next(sorted_records)
		if best_record == nil then return end
		if best_record[1] ~= nil  and best_record[2] ~= nil then return best_record[1], best_record[2] end
	end
end

function mrank(name, weapon, self,cn)		-- get maprank from one maptop for one player
	local records = load_records(getmapname(),weapon)
	local delta = records[name]
	local rank,total_records = find_place(sorted_records(records), name)
	
	if weapon == nil then
		if rank ~= nil and delta~= nil then 
			local title = "\fH"..name.."\fJ's"
			if self then title = "Your" end
			weapon = tellmeweapon (delta, name)
			say("\fJ"..title.." best time is \fH"..milliToHuman(delta).." \fJ(\f1"..weapon.."\fJ, rank \fF"..rank.." \fJof \fF"..total_records.."\fJ)",cn)
		else
			if self then say("\f3You don't have records on this map",cn)return
			else say("\f3"..name.." doesn't have records on this map",cn)
			end
		end
	else
		weapon = getgun(weapon)
		if rank ~= nil and delta~=nil then say("\f1".. weapon .. "\fJ: \fH"..milliToHuman(delta).." \fJ(rank \fF"..rank.." \fJof \fF"..total_records.."\fJ)", cn)
		else say("\f1"..weapon.."\fJ: \f3No record found", cn)
		end
	end
end

function mapbest (mapname,weapon, cn)		-- get best player of each maptop
	local player, delta = get_best_record(mapname,weapon)
	local record = nil
		
	if delta~= nil and player ~= nil then 
		record = milliToHuman(delta)
		if weapon == nil then 
			weapon = tellmeweapon(delta,player)
			say("\fJThe best time for this map is \fH"..record.." \fJ(recorded by \fH"..player.." \fJwith \f1"..weapon.."\fJ)", cn)
		else
			weapon = getgun(weapon)
			say("\f1"..weapon.."\fJ : \fH"..record.." \fJ(recorded by \fH"..player.."\fJ)", cn)
		end	
	else 
		if weapon == nil then say("\f3No records found for this map", cn)
		else say("\f1"..getgun(weapon).."\f3 No records found for this weapon", cn)
		end
	end
end

------------------

text_color = {}

function get_text_color (cn)	-- get the text color a player has (default color is set on player connect)
	return color(text_color[cn])
end

function color(id)				-- make a single char to \f* to use it later to color the text
	local textcolor = nil
	if id ~= nil then
		if tonumber(id) ~= nil then
			if tonumber(id) < 10 and tonumber(id) >= 0 then textcolor = "\f" .. tonumber(id) end
		elseif id >= "A" and id <="Z" then textcolor = "\f" .. id
		elseif id >= "a" and id <="z" then textcolor = "\f" .. string.upper(id)
		end
	end
	return textcolor
end

function iscolor(id)			-- check if a color string is in this format \f*
	if string.sub(id,1,2) == "\f" and color(string.sub(id,3,3)) ~= nil then return true
	else return false
	end
end

-----------------

modos= {} -- moderators table, if modos[cn] ~= false then player is moderator

function addmod(password)		-- add moderator password
	local passwords = {}
	if file_exists ("lua/config/modos.cfg") then 
		passwords = cfg.getvalue ("modos", "passwords") 
	end
	table.insert(passwords,password)
	cfg.setvalue("modos", "passwords", table.concat(passwords,"\t"))
end

function delmod(cn)				-- delete moderator password used by cn
	local passwords = cfg.getvalue ("modos", "passwords")
	if modos[cn] == "promote" then demote(cn) return
	else
		if passwords~= nil then
			passwd = split(passwords, "\t")
			for i = 1, #passwd, 1 do
				if passwd[i] == modos[cn] then table.remove (passwords, i) end
			end
		end
		cfg.setvalue("modos", "passwords", table.concat(passwords, "\t"))
	end
end

function demote (tcn)			-- set modos[cn] = false
	if not isconnected (tcn) or not ismodo(tcn) then return false end
	modos[tcn] = false
	return true
end

function ismodo(cn)				-- status
	if modos[cn] ~= false then return true
	else return false
	end
end

function logout (cn)			-- set modos[(own cn)] false
	if modos[cn] ~= "promote" then logline (4,"[" .. getip(cn) .. "] player " .. getname(cn) .. " used moderator password (" .. modos[cn] ..")\nSet role of player " .. getname(cn) .. " to normal player") end
	modos[cn] = false
end

function login (cn, password)	-- set modos[(own cn)] = password
	local passwords = cfg.getvalue ("modos", "passwords")
	if passwords ~= nil then
		passwd = split(passwords, "\t")
		for i = 1, #passwd, 1 do
			if passwd[i] == password then 
				modos[cn] = password
				logline (4,"[" .. getip(cn) .. "] player " .. getname(cn) .. " used moderator password (" .. password ..")\nSet role of player " .. getname(cn) .. " to moderator")
				return true
			end
		end
		return false
	end
end 

function promote (tcn)			-- set modos[cn] = "promote"
  if not isconnected (tcn) or ismodo(tcn) or isadmin(tcn) then return false end
  modos[tcn] = "promote"
  return true
end

function getlevel (cn)			-- admin = 2, moderator = 1, unarmed = 0
	if isadmin(cn) then return 2
	elseif ismodo(cn) then return 1
	else return 0
	end
end

function ishigher(cn,tcn)		-- compare player level of cn and tcn
	if getlevel(cn) > getlevel(tcn) then return true
	else return false
	end
end

-----------------

start_times = {}

function add_record(delta,player,weapon,map)	-- save record if it is a better record than last record of player and update gtop

	local records = load_records(map)
	local text = "but has a better record with this weapon"
	
	if records[player] == nil or delta < records[player] then
		records[player]=delta
		save_records(map, records)
	end
	
	records = load_records(map, weapon)

	if records[player] == nil then
		records[player] = delta
		save_records(map, records, weapon)
		local rank, total = find_place (sorted_records(load_records(map,weapon)), player)
		text = "rank " .. rank .. " of " .. total

			if rank == 1 then 
				cached_gtop = change_best_gtop (cached_gtop, player, 0,"add")
				cached_gtop = change_best_gtop (cached_gtop, player, weapon,"add")
			else 
				cached_gtop = change_record_gtop (cached_gtop, player, 0,"add")
				cached_gtop = change_record_gtop (cached_gtop, player, weapon,"add")
			end
	else
		local old_rank
		if delta < records[player] then
		old_rank = find_place(sorted_records(records),player)
		records[player] = delta
		save_records(map, records, weapon)
		local rank, total = find_place (sorted_records(load_records(map,weapon)), player)
		if rank == 1 and old_rank ~= 1 then
			cached_gtop = change_record_gtop (cached_gtop, player, 0,"add")
			cached_gtop = change_record_gtop (cached_gtop, player, weapon,"add")
		end
		text = "rank " .. rank .. " of " .. total
		end
	end
	return text
end

function delete_record(map, weapon, name)  		-- delete the record for a specific weapon and name (currently not working)

   local records = sorted_records(load_records(map))
   
   local rank = find_place(records,name)
   
   table.remove (records,rank)
   save_records(map,records)
   
   records = sorted_records(load_records(map, weapon))		-- load specific weapon maptop and delete record from <name>
   rank = find_place(records,name)
   if rank == 1 then
		cached_gtop = change_best_gtop (cached_gtop, player, 0,"remove")
		cached_gtop = change_best_gtop (cached_gtop, player, weapon,"remove")
	else 
		cached_gtop = change_record_gtop (cached_gtop, player, 0,"remove")
		cached_gtop = change_record_gtop (cached_gtop, player, weapon,"remove")
	end
		
	table.remove(records, rank)
	save_records(map, records,weapon)
		
	local tmp_record 
	for i =1, 5, 1 do
		records = load_records(map, usergun(i))
		if tmp_record == nil or records[name] < tmp_record then tmp_record = records[name] end
	end
		
	if tmp_record ~= nil then 	
		records = sorted_records(load_records(map))
		table.insert (records, {name,tmp_record})
		save_records(map,records)
	end
end

function save_records(map, records, weapon)		-- save records to a specific maptop or general maptop
   local sorted_records = sorted_records(records)
   local lines = {}
   for i,record in ipairs(sorted_records) do
     table.insert(lines, record[1] .. " " .. record[2])
   end

   local filename = "maptop/maptop"
   if weapon ~= nil then filename = filename .. "_" .. weapon end
   cfg.setvalue(filename, map:gsub("=", ""), table.concat(lines, "\t"))
end

-----------------

minute_limit = 0					-- counter for !addminute

function reset_minute_limit ()	-- reset addminute counter
	minute_limit = 0
end

----------------

function savename(name,ip) 	-- names log
	local exists = false
	local data = cfg.getvalue("ipnames",ip)	
	local lines = {}	
	if data ~= nil then
		lines = split(data, "\t")
		for i=1, #lines, 1 do
		   if lines[i] == name then exists = true end
		end
	end
	if not exists then table.insert(lines, name)
		cfg.setvalue("ipnames", ip, table.concat(lines, "\t"))
	end
end

function load_names(ip)		-- load names log
	local data = cfg.getvalue ("ipnames", ip)
	local lines = split(data,"\t")
	return lines
end

---------------

--	other stuff

ignore = {}		-- ignore table, if "cn target_cn" == true then cn ignores target_cn 

function is_gema(mapname)			-- check if mapname contains g3ema@4		
	local implicit = { "jigsaw", "deadmeat-10" }
	local code ={"g","3e","m","a@4"}
	mapname = mapname:lower()
	for k,v in ipairs(implicit) do
		if mapname:find(v) then return true end
	end
	for i = 1, #mapname - #code + 1 do
		local match = 0
		for j = 1, #code do
			for k = 1, #code[j] do
				if mapname:sub(i+j-1, i+j-1) == code[j]:sub(k, k) then match = match + 1 end
			end
		end
		if match == #code then return true end
	end
	return false
end

function isip(ip) 					-- check if a given string can be interpreted as an ip
	local splitted_ip = split(ip,".")
	if #splitted_ip ~= 4 then return false end
	for k = 1, 4 do
		local n = tonumber(splitted_ip[k])
		if n == nil or n <0 or n > 255 then return false end
    end
    return true
end

function say(text, cn)				-- say text to cn
	if cn == nil then cn = -1 end	-- say to all
	clientprint(cn,text)
end

function SayToAll(text, cn, color)	-- say text to all, color = text color
	local name_color = "\f2"
	if isadmin(cn) then name_color = "\f3"
	elseif ismodo(cn) then name_color = "\f9"
	end

	if color == nil then color = "\fP" end
	if not isadmin(cn) and not ismodo(cn) then
		for n=0,20,1 do
			if isconnected(n) and ignore[n..""..cn] ~= true then
				say(name_color .. "".. getname(cn) .. ": " .. color .. "" .. text,n)
			end
		end
	else
		for n=0,16,1 do
			if isconnected (n) and (n ~= cn or ignore[cn..""..n]==false) then say(name_color .. "".. getname(cn) .. ":" .. color .. " " .. text,n) end
		end
	end
end

function milliToHuman(milliseconds)	-- convert records from maptop savefiles to minute:second,milisecond ; found that function on the internet :D
	local totalseconds = math.floor(milliseconds / 1000) 
	milliseconds = math.fmod(milliseconds,1000)
	local seconds = math.fmod(totalseconds,60)
	local minutes = math.floor(totalseconds / 60)

	if (minutes < 10) then minutes = "0" .. minutes end
	if (seconds < 10) then seconds = "0" .. seconds end
	if (milliseconds < 100) then 
		if (milliseconds < 10) then milliseconds = "00" .. milliseconds
		else milliseconds = "0" .. milliseconds
		end
	end
	
	return minutes .. ":" .. seconds .. "," .. milliseconds
end

function split(p,d)					-- split string p everytime d appears in it
  local t, ll
  t={}
  ll=0
  if(#p == 1) then return {p} end
    while true do
      l=string.find(p,d,ll,true)
      if l~=nil then
        table.insert(t, string.sub(p,ll,l-1))
        ll=l+1
      else
        table.insert(t, string.sub(p,ll))
        break
      end
    end
  return t
end

function slice(array, S, E)			-- get part of an array, from arrray[S] to array[E]
  local result = {}
  local length = #array
  S = S or 1
  E = E or length
  if E < 0 then
    E = length + E + 1
  elseif E > length then
    E = length
  end
  if S < 1 or S > length then
    return {}
  end
  local i = 1
  for j = S, E do
    result[i] = array[j]
    i = i + 1
  end
  return result
end

function file_exists(name)			-- check if file "name" exists
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

-- params: level 	-> admin = 2, modo = 1, unarmed = 0
-- build commands like that ["commandname"] = { level;function};

commands = 
{

-- unarmed commands

["!addminute"] =	-- add one minute to the game, 10 times usable per game
{
	0;
	function (cn, args)
		minute_limit = minute_limit + 1
		if minute_limit <= 10 then
			local timeleft = gettimeleft() + 2
			settimeleft (timeleft)
			say("\f9remaining time changed to " .. timeleft .." minutes")
		else
			say("\f3error, you can only add a maximum of 10 extra minutes.", cn) 
		end
	end
};

["!allcmds"] = 			-- show all avaiable commands and parameters
{
	0;
	function (cn, args)
	say("\f2regular commands: ",cn)
	say("\f2 	records:\fN !check  !grank <name>  !gtop <weapon> <startrank>  !mapbest  !maptop <weapon> <startrank>  !mrank <name>")
	say ("\f2	ignore:\fN  !ignore <cn>  !ignoreall  !unignore <cn>  !unignoreall",cn)
	say("\f2	colors:\fN  !setcolor <color>  !colorsay <color> <text>", cn)
	say("\f2	other:\fN   !addminute  !allcmds  !cmds  !pm <cn> <text>  !whois <cn>",cn)

	if not ismodo(cn) and not isadmin(cn) then say("\f2moderator commands: \f9 !login <password>",cn)
	else
    say("\f9moderator commands: \f8!ban <cn> <reason>  !f1  !f2  !kick <cn> <reason>  !logout  !who <cn>",cn)
    end

	if isadmin(cn) then
		say("\f3admin commands: !addmod <password>  !blacklist <cn>/<ip> <reason>  !delmod <cn>  !delrecord <name> <weapon>  !demote <cn>  !promote<cn>",cn)
    end

	say("\fMweapons: 1 = Assault Rifle   2 = Submachine Gun   3 = Sniper Rifle   4 = Shotgun   5 = Carbine",cn)

    end
  };

["!check"] =	-- for players: check with which weapons you finished the map => evtl mit in mrank einbauen
{
	0;
	function (cn, args)
		local count, missing_weapons = get_missing_weapons(getname(cn))
		say("\fJYou have finished this map with \fH" .. count .. " \fJof \fH5 \fJweapons " .. missing_weapons,cn)
	end
};

["!cmds"] = 			-- show important avaiable commands
{
    0;
    function (cn, args)
     say("\fPregular commands: \fN!addminute   !allcmds   !grank   !gtop   !maptop    !mrank   !pm <cn> <text>",cn)
    if not ismodo(cn) and not isadmin(cn) then say("\f2moderator commands: \f9 !login <password>",cn)
	else
    say("\f2moderator commands: \f9!ban <cn> <reason>  !f1  !f2  !kick <cn> <reason>  !logout  !who <cn>", cn)
    end

	if isadmin(cn) then
		say("\f3admin commands: !addmod <password>  !blacklist <cn>/<ip> <reason>  !delmod <cn>  !delrecord <name> <weapon>  !demote <cn>  !promote<cn>",cn)
    end

    end
  };

["!colorsay"] =
{
	0;
	function (cn,args)
		if #args >= 2 then
			if #args[1] == 1 then
				if color(args[1]) ~= nil then SayToAll(table.concat(args," ",2), cn, color(args[1])) 
				else say("\f3invalid color id",cn)
				end
			else say("\f3invalid color id",cn)
			end
		else say("\f3invalid arguments")
		end
	end
};

["!grank"] =		-- shows grank for every gtop
{
	0;
	function (cn, args)
		local name = ""
		local self = false
		if #args == 0 or args[1] == getname(cn) then 
			name = getname(cn)
			self = true
		else name = args[1] end
		
		for i = 0, 5, 1 do
			grank(usergun(i), name, self,cn)
		end
	end
};

["!gtop"] =		-- -- shows 5 best players in gtop of general gtop or specific weapon gtop
{
    0;
    function (cn, args)

		local weapon = nil
		local startrank = 1
  
		if #args >= 1 then
			if tonumber(args[1])<=5 and tonumber(args[1])>=0 then
				weapon = usergun(tonumber(args[1]))
			else say ("\f3Invalid weapon number!",cn) return 
			end
		end

		local cache_index = weapon
		if weapon == nil then cache_index = 0 end
		local top = cached_gtop[cache_index]
		
		if #args >= 2 then
			if tonumber(args[2]) ~= nil and tonumber(args[2]) >= 1 then startrank = tonumber(args[2]) end
			if startrank > #top then say("\f3error, start rank has to be between 1 and " .. #top .. " for this gtop",cn) return end  
		end
		
		if #top == 0 then 
			if cache_index == 0 then say ("\f3gtop is empty",cn) 
			else say ("\f3gtop for " .. getgun(weapon) .. " is empty",cn)
			end
			return
		end
	
		local title = "\fJbest players on this server"
		if weapon ~= nil then title = title .. " with \f1" .. getgun(weapon) .. "\fJ" end
		title = title .. " :"
	
		say (title,cn)

		local endrank = startrank + 4
		
		if endrank > #top then endrank = #top end
		
		if #top < 5 then endrank = #top end
		
		for i=startrank, endrank, 1 do
		
			local name = top[i][1]
			local best = top[i][3]
			local record = top[i][4]
		
			if name == nil or best == nil or record == nil then return
			else
				say ("\f2".. i .. "\fJ) " .. name .. " with " .. best .. " best times and " .. record .. " records",cn)
			end
		end
    end
};

["!ignore"] =
{
	0;
	function (cn,args)
		local acn = tonumber(args[1])
		if ishigher(acn, cn) then 
			if acn == cn then 
			ignore[cn..""..acn] = true 
			say("\f3you successfully ignored " .. getname(cn),cn)
			else say ("\f3you can't igore players with a higher role than you!",cn)
			end
		elseif isconnected(acn) then 
			ignore[cn..""..acn] = true 
			say("\f3you successfully ignored " .. getname(cn),cn)
		end
	end
};

["!ignoreall"] =
{
	0;
	function (cn,args)
		for i = 0, 20, 1 do
			if not ishigher(i, cn) then ignore[cn..""..i] = true end
		end
		say("\f3you successfully ignored all players",cn)
	end
};

["!login"] =
{
	0;
	function (cn,args)
		if #args == 1 then
			if login (cn, args[1]) == true  then
				if not isadmin(cn) then say("\f9" .. getname(cn) .. " is now moderator!")
				else say ("\f3error, you are already at moderator or higher level!",cn)
				end
			else say ("\f3wrong password",cn) 
			end
		end
	end
};

["!mapbest"] =	-- show the best time of every maptop
{
	0;
	function (cn, args)
		for i=0,5,1 do
			mapbest(getmapname(),usergun(i),cn)
		end
	end
};

["!maptop"] =	-- shows startrank+4 best players of general maptop or with a specific weapon
{
	0;
    function (cn, args)
		local weapon = nil
		if #args>=1 and #args<=2 then
			if tonumber(args[1])<6 and tonumber(args[1])>=0 then weapon = usergun(tonumber(args[1]))
			else say("\f3invalid weapon number!",cn) return 
			end
		end

		local records = sorted_records(load_records(getmapname(),weapon))    

		if weapon == nil then 
			if next(records) == nil then say("\f3maptop is empty", cn) return
			else say("\fFfastest players of this map:", cn)  
			end
		else
			if next(records) == nil then say("\f3no one has finished this map yet with \f1" .. getgun(usergun(tonumber(args[1]))), cn) return
			else say ("\fFfastest players with \f1" .. getgun(usergun(tonumber(args[1]))) ..  "\fF:", cn)
			end 
		end

		local startrank = 1
		if tonumber(args[2]) ~= nil and tonumber(args[2]) >= 1 then startrank = tonumber(args[2]) end
		if startrank > #records then say("\f3error, start rank has to be between 1 and " .. #records .. " for this map",cn) return end  

		for i, record in ipairs(records) do
			if i > 4+startrank then break end
			if i >= startrank then 
				if weapon == nil then
					say("\fJ" .. i .. ") \fH" .. record[1] .. " \fL" .. milliToHuman(record[2]) .. " \fJ(\f1" .. tellmeweapon(record[2],record[1]) .. "\fJ)", cn)
				else
					say("\fJ" .. i .. ") \fH" .. record[1] .. " \fL" .. milliToHuman(record[2]), cn) 
				end
			end
		end
	end
  };

["!mrank"] = 	-- show map rank, only !mrank <name>, cn is not allowed because someone could be searching for a player named 1 for example
{
	0;
	function (cn, args)
		local self = false
		local player_name = ""
		if #args == 0 then
			self = true
			player_name = getname(cn)
		else player_name = args[1] 
		end
		
		for i=0,5,1 do
			mrank(player_name, usergun(i), self, cn)
		end
	end
};

["!mybest"] =
{
	0;
	function (cn)
		for i=0,5,1 do
			mrank(getname(cn), usergun(i), true, cn)
		end
	end
};

["!pm"] =
{
	0;
	function (cn,args)
		if #args >= 2 then
			local to, text = tonumber(args[1]), table.concat(args, " ", 2)
			if not isconnected(to) then say("\f3wrong cn",cn)
			elseif ignore [to.. "" .. cn] ~= true then say("\fJ" .. getname(cn) .. "\f2 (PM)\fJ:\f9 " .. text,to)
			elseif ignore [to.. "" .. cn] == true then say("\f3could not send message : " .. getname(to) .. " ignored all of your messages",cn)
			end
		end
	end
};

["!setcolor"] =
{
	0;
	function (cn,args)
		if #args == 1 then
			if #args[1] == 1 then
				if color(args[1]) ~= nil then
					text_color[cn] = args[1]
					say (get_text_color(cn) .. "your chat messages will be displayed in this color now!",cn)
				else say("\f3invalid color id",cn)
				end
			else say ("\f3invalid color id",cn)
			end
		end
	end
};

["!unignore"] =
{
	0;
	function (cn,args)
		local tcn = tonumber(args[1])
		if isconnected(tcn) then 
			ignore[cn..""..tcn] = false 
			say("\f3you successfully unignored " .. getname(tcn),cn)
		end
	end
};
 
["!unignoreall"] =
{
	0;
	function (cn,args)
		for i = 0, 20, 1 do
			if i ~= cn then ignore[cn..""..i] = false end
		end
		say("\f3you successfully unignored all players",cn)
	end
};

["!whois"] =
{
	0;
	function (cn,args)
		if #args == 1 then
			local tcn = tonumber(args[1])
			if isconnected (tcn) then
				local ip, country = whois (tcn)
				say ("\f2" .. getname(tcn) .. " \fJ(\f1" .. tcn .. "\fJ) connected from \f2" .. country .. " \fJ(\f9" .. ip .. "\fJ)", cn)
			else say("\f3error, this client number isn't valid!",cn)
			end
		else say ("\f3error, invalid arguments",cn)
		end
	end
};

-- moderator commands

["!ban"] =
{
	1;
	function (cn,args)
		if #args >= 2 then
			target_cn = tonumber(args[1])
			reason = table.concat(args," ",2)
			if isconnected(target_cn) and target_cn ~= cn and ishigher(cn,target_cn) then
				say ("\f3" .. getname(target_cn) .. "has been banned by " .. getname(cn) .. " , reason : " .. reason)
				ban (target_cn, DISC_MBAN)
			elseif not isconnect(target_cn) then say ("\f3you can't ban this player [cn not connected]",cn)
			elseif target_cn == cn then say ("\f3you can't ban this player [cn is your own cn]",cn)
			elseif not ishigher(cn,target_cn) then say ("\f3you can't ban this player [cn has a higher role than you]",cn)
			end
		else say ("\f3invalid arguments",cn)
		end
	end
};

["!f1"]=	-- same like admin F1
{
	1;
	function ()
		voteend(VOTE_YES)
	end
};

["!f2"]=	-- same like admin F2
{
	1;
	function ()
		voteend(VOTE_NO)
	end
};

["!kick"] =
{
	1;
	function (cn,args)
		if #args >= 2 then
			target_cn = tonumber(args[1])
			reason = table.concat(args," ",2)
			if isconnected(target_cn) and target_cn ~= cn and ishigher(cn,target_cn) then
				say ("\f3" .. getname(target_cn) .. "has been kicked by " .. getname(cn).. " , reason : " .. reason)
				disconnect (target_cn , DISC_MKICK)
			else say("\f3You can't kick yourself, not connected cns or a higher player than your role!")
			end
		else say ("\f3invalid arguments",cn)
		end
	end
};

["!logout"] =
{
	1;
	function (cn)
		if ismodo(cn) then
			logout(cn)
			say ("\f9" .. getname(cn) .. " logged out")
		else
			say("\f3use /setadmin 0 to logout",cn)
		end
	end
};

["!who"] =	-- access names log
{
	1;
	function (cn,args)
      	if #args == 1 then
			if tonumber(args[1]) ~= nil then
				tcn = tonumber(args[1])
				if isconnected(tcn) then
					names = load_names (getip(tcn))
					show_names = ""
					for i = 1, #names, 1 do
						if i == 1 then show_names = names[i]
						else
							show_names = show_names .. " , " .. names[i]
						end
					end
				else say ("\f3error, invalid cn",cn)
				end
				say ("\f3" .. getip(tcn) .. " used these names: " .. show_names,cn)
			else say ("\f3invalid arguments",cn)
			end
		end
    end
};

-- admin commands

["!addmod"] =
{
	2;
	function (cn,args)
		if #args == 1 then
			addmod(args[1])
			say("\f3moderator successfully added",cn)
		else
			say ("\f3invalid arguments")
		end
	end
};

["!blacklist"] = 	-- blacklist a player (cn or ip)
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

["!delmod"] =
{	
	2;
	function (cn,args)
		if #args == 1 then
			local tcn = tonumber(args[1])
			delmod(tcn)
			say("\f3moderator successfully removed",cn)
			demote(tcn)
			say("\f3your moderator password was removed!",tcn)
		end
	end
};

["!delrecord"] =	-- delete a record of a specific player, warning! : you can't undo this
{
	2;
	function (cn,args)
	   if #args == 2 then
		if tonumber (args[2]) > 6 or tonumber(args[2]) < 1 then say("\f3invalid weapon number",cn) return end

		del = delete_record(getmapname(), usergun(tonumber(args[2])),args[1])
		if del == true then say ("\f3record successfully removed")
		else say("\f3error, this player does not have a record on this map with this weapon")
	        end
	   else say("\f3invalid arguments")
	   end
	end
   };

["!demote"] =	-- set role of a unarmed to moderator
{
	2;
	function (cn,args)
		if #args == 1 then
			if demote(tonumber(args[1])) == true then say ("\f3" .. getname(tonumber(args[1])) .. " is not moderator anymore!")
			else say("\f3error, cn is not moderator or is not connected",cn)
			end
		end
	end
};

["!promote"] =	-- set role of a moderator to unarmed
{ 
	2;
	function (cn,args)
		if #args == 1 then
			if promote(tonumber(args[1])) == true then say ("\f9" .. getname(target_cn) .. " is now moderator!")
			else say ("\f3error, cn is moderator or is not connected",cn)
			end
		end
	end
};

}

function onFlagAction(cn, action, flag)

    if action == FA_DROP or action == FA_LOST then flagaction (cn, FA_RESET, flag) end	-- auto flag reset

	if action == FA_SCORE then
		if start_times[cn] == nil then return end
		--local delta = socket.gettime() - start_times[cn]
		local delta = getsvtick() - start_times[cn]
		start_times[cn] = nil
		if delta == 0 then return end

		local text = "(" .. add_record(delta,getname(cn), getprimary(cn), getmapname()) .. ")"
	
		say("\fH"..getname(cn).." \fJscored after \fF"..milliToHuman(delta).." \fJwith \f1"..getgun(getprimary(cn)).." \f9".. text)
		
		local player, record = get_best_record(getmapname())
		if player == getname(cn) and record == delta then say("                 \f9*\f2*\fP*\f9*\f2* \fPn\f9e\f2w \fPb\f9e\f2s\fPt \f9t\f2i\fPm\f9e \f2*\fP*\f9*\f2*\fP*")
		else 
		player, record = get_best_record(getmapname(),getprimary(cn))
		if player == getname(cn) and record == delta then say("\fH*****\fJnew best time for \f1"..getgun(getprimary(cn)).."!\fH*****") end
		end
	end
end

function onInit()
load_gtop()
end

function onMapChange ()
	sendMOTD()
	reset_minute_limit()	-- reset minute limit for !addminute command
end

function onPlayerCallVote(acn, type, text, number)

	if (type == SA_AUTOTEAM) or (type == SA_CLEARDEMOS) or (type == SA_SHUFFLETEAMS) then 
		voteend(VOTE_NO)
		say ("\f3You are not allowed to vote that!", cn)
	elseif (type == SA_FORCETEAM) and not (isadmin(cn) or ismodo(cn)) then
		voteend(VOTE_NO)
		say ("\f3You are not allowed to vote that!", cn)
	elseif (type == SA_MAP) and not ((number == GM_CTF) and is_gema(text)) then 
		voteend(VOTE_NO)
		say ("\f3Only CTF mode is allowed. Make sure that your mapname contains g3/ema/@/4!")
	end
   
   --if type == SA_KICK or type == SA_BAN then
      --if (isadmin(target_cn) or ismodo(target_cn)) then
      --voteend(VOTE_NO)
      --say ("\f3You can't kick or ban moderators / admins !",cn)
      --elseif ismodo(cn) then voteend(VOTE_YES)
      --end
   --end

end

function onPlayerConnect(cn)
	
	local count = 0
	
	for i = 0, 15, 1 do
		if isconnected(i) then
			if getip(i) == getip(cn) then count = count + 1 end
		end
	end
	
	if count >= 3 then
	say ("\f3" .. getname(cn) .. " could not connect [to many connections with same IP]" )
	disconnect(cn, DISC_NONE) 
	end
	
	setautoteam (false)		-- needed when it is the first player who connects to the server
	
	say("\fJWelcome \f2" .. getname(cn) .. "\fJ!")
	local country, geoip = whois(cn)
	say("\f2" .. getname(cn) .. " \fJ(\f1" ..cn.. "\fJ) connected from \f2" ..country.. "\f9 (" ..geoip.. ")")
	sendMOTD(cn)
	
	text_color[cn] =  "Q"	-- default text color
	modos[cn] = false
	savename (getname(cn), getip(cn))

	ignore[cn..""..cn] = true
end

function onPlayerDisconnect(cn, reason)

	if reason == DISC_BANREFUSE then say ("\f3" .. getname(cn) .. " could not connect [banned]") end
	if ismodo(cn) then logout(cn) end

	for i = 0, 20, 1 do
		ignore[cn..""..i] = false
		ignore[i..""..cn] = false
	end
end

function onPlayerNameChange (acn, new_name)
	savename(new_name,getip(acn))
end

function onPlayerSayText(cn, text)

	logline(4,"[" .. getip(cn) .. "] " .. getname(cn) .. " says: '" .. text .. "'")
	
	local parts = split(text, " ")
	local command, args = string.lower(parts[1]), slice(parts, 2)	-- string.lower to ignore capitalized chars in commands 

	if string.sub(command,1,1) == "!" and string.sub(command,2,2) ~= "!" then	-- if first character is "!" and second is not "!"
		if commands[command] ~= nil then
			local level, callback = commands[command][1], commands[command][2]
			if (getlevel(cn) >= level) then callback(cn, args)
			elseif command ~= "!logout" then say("\f3no permission!",cn)
			end
		else	say ("\f3Unknown command, check your spelling and try again",cn)	-- error in case of non existant command
		end
		return PLUGIN_BLOCK
	end
		
	SayToAll(text, cn, get_text_color(cn))
	return PLUGIN_BLOCK
end

function onPlayerSpawn(cn)
	
	--start_times[cn] = socket.gettime()	-- nano seconds
	start_times[cn] = getsvtick()
end
