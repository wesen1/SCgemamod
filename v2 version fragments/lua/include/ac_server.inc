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
