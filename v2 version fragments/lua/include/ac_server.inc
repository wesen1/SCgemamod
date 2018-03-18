--
-- removes the last digit of an ip and replaces it by 'x'
--
function getGeoIp (ip)

	local parts = split(ip, ".")

	-- replace last digit of ip by "x"
	return parts[1] .. "." .. parts[2] .. "." .. parts[3] .. ".x"

end

--
-- check whether a given string can be interpreted as an ip
--
function isip(ip) 					
	-- split string every time a dot appears in it
	local splitted_ip = split(ip,".")

	-- if the string has not 4 parts abort
	if #splitted_ip ~= 4 then
		return false
	end

	for k = 1, 4 do
		local n = tonumber(splitted_ip[k])

		-- if number is not between 0 and 255 abort
		if n == nil or n < 0 or n > 255 then
			return false
		end
    	end
    	
    	return true
end





-- Colors

--
-- Converts single character to \f*
--
function color(id)
	local textcolor = nil
	if id ~= nil then
		if tonumber(id) ~= nil then
			if tonumber(id) < 10 and tonumber(id) >= 0 then 
				textcolor = "\f" .. tonumber(id)
			end

		elseif id >= "A" and id <="Z" then
			textcolor = "\f" .. id

		elseif id >= "a" and id <="z" then
			textcolor = "\f" .. string.upper(id)
		end
	end
	return textcolor
end


--
-- check whether a color string is in this format \f*
--
function iscolor(id)
	if string.sub(id,1,2) == "\f" and color(string.sub(id,3,3)) ~= nil then return true
	else return false
	end
end



-- Other functions


--
-- Convert the weapon numbers from user input (!cmds) to the server numbers for weapons
--
function getWeaponId(user_input)	

	local result = db:query("SELECT id FROM weapon WHERE number=".. user_input ..";")

	if result == nil then
		return nil
	else
		return tonumber(result[1].id)
	end

end


function getWeaponNumber(weapon_id)

	local result = db:query("SELECT number FROM weapon WHERE id=".. weapon_id ..";")
	
	if result == nil then
		return nil
	else
		return tonumber(result[1].number)
	end
end


--
-- Convert a server number for a weapon to the weapons name
--
function getWeaponName(weapon_id)

	local result = db:query("SELECT name FROM weapon WHERE id=".. weapon_id ..";")

	if result == nil then
		return nil
	else
		return result[1].name
	end

end


--
-- Get the points a weapon is worth
function getWeaponPoints (weapon_id)

	local result = db:query ("SELECT points FROM weapon WHERE id=".. weapon_id ..";")
	
	if result == nil then
		return nil
	else
		return tonumber(result[1].points)
	end

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


--
-- Get the map id from a mapname
--
function getMapId (mapname)

	local result = db:query("SELECT id FROM map WHERE name='".. mapname .."';")

	if result == nil then
		return nil
	else
		return result[1].id
	end
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


-- set tabs until you are one tab stop behind the longest string
-- input: cur_string (Integer): length of current string
--	  longest_string (Integer): length of the longest string in displayed set of strings
-- only works with default font
function getTabs (cur_string, longest_string)

	local tabs = ""
	local tab_width = 8 * 38
	
	print(longest_string.. " - ".. cur_string .." = ".. (longest_string - cur_string))
	
	local next_tab = math.ceil(longest_string / tab_width) -- get first tab position after longest string	
	local amount_tabs = next_tab - math.floor(cur_string / tab_width) -- get amount of tabs for curre
	

	for i = 1, amount_tabs do
		tabs = tabs .."\t"
	end
	
	
	return tabs

	
	
	--[[
	if cur_string % tab_width == 0 then

		if cur_string == longest_string then
			tabs = "\t"
			
			cur_string = cur_string + 1
		end
	end
--]]	
	
end


--
-- get pixel width of default font
--
function getStringWidth (string)

	string = string:gsub("\f.", "")		-- extract colors from cur_string

	local string_width = 0
	
	for i = 1, #string do
	
		local character = string.sub(string,i,i)
		
		if character == " " then
			character = "space"
		end

		local character_width = tonumber(cfg.getvalue("font_default", character))

		string_width = string_width + character_width
	
	end
	
	return string_width

end



--
-- load font width from config file and save it in a lua config file
--
function getFontConfig ()

	local file = "config/font_default.cfg"

	local f = io.open(file, "rb")
	
	for line in io.lines(file) do
	
		if string.match(line, "fontchar") then

			local line = line:gsub("fontchar ", "")

			local data = split(line, "//")	
			local dimensions = split(data[1], " ")


			local width = dimensions[3]
			local character = string.gsub(data[2], " ", "")
			
			cfg.setvalue("font_default", character, width)
		end
		
	end
	
	cfg.setvalue("font_default", "space", 32)

	f:close()

end
