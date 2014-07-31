PLUGIN_NAME = "SilverCloudGemaMod OpenSource version"
PLUGIN_AUTHOR = "Jg99" -- Jg99
PLUGIN_VERSION = "4.2.0" -- SilverCloud Gema mod

dofile("lua/scripts/functions/functions.lua")
-- common

include("ac_server")

config = 
{
  gema_mode_autodetecting = true;
  gema_mode_is_turned_on = true
}

  cached_gtop = nil
  new_record_added = true
fines = {}
start_times = {}
autogemakick = false
dup = false
colortext = true
  function find_place(records, name)
    local result = nil
    for i,record in ipairs(records) do
      if record[1] == name then
        result = i
        break
      end
    end
    return result
  end



function gload()
  if new_record_added == false then return cached_gtop end
  local grecords = {}
  local grecords_m = {}
  local count = 0
  for line in io.lines("lua/config/SvearkMod_maps.cfg") do
      local cnt = string.find(line, "=")
      if cnt ~= nil then
        local map_name = string.sub(line,1,cnt - 1)
        local gdata = sorted_records(load_records(map_name))
        local n = grecords_m[gdata[1][1]]
        if n == nil then
          count = count + 1
          table.insert(grecords, { gdata[1][1], 1})
          grecords_m[gdata[1][1]] = count
        else
          grecords[grecords_m[gdata[1][1]]][2] = grecords[grecords_m[gdata[1][1]]][2] + 1
        end
      else
        print("Error on gload: lua/config/SvearkMod_maps.cfg non-existant")
      end
  end
  table.sort(grecords, function (L, R) return L[2] > R[2] end)
  cached_gtop = grecords
  new_record_added = false
  return grecords
end


function say(text, cn)
  if cn == nil then cn = -1 end -- to all
  clientprint(cn, text)
end

function slice(array, S, E)
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

function is_gema(mapname)
  local implicit = { "jigsaw", "deadmeat-10" }
  local code =
  {
    "g",
    "3e",
    "m",
    "a@4"
  }
  mapname = mapname:lower()
  for k,v in ipairs(implicit) do
    if mapname:find(v) then
      return true
    end
  end
  for i = 1, #mapname - #code + 1 do
    local match = 0
    for j = 1, #code do
      for k = 1, #code[j] do
        if mapname:sub(i+j-1, i+j-1) == code[j]:sub(k, k) then
          match = match + 1
        end
      end
    end
    if match == #code then
      return true
    end
  end
  return false
end

-- interface to the records

function sorted_records(records)
  local sorted_records = {}
  for player, delta in pairs(records) do
    table.insert(sorted_records, { player, delta })
  end
  table.sort(sorted_records, function (L, R) return L[2] < R[2] end)
  return sorted_records
end


function reverse_sorted_records(records)
  if records == nil then return nil end
  local sorted_records = {}
  for player, delta in pairs(records) do
    table.insert(sorted_records, { player, delta })
  end
  table.sort(sorted_records, function (L, R) return L[2] > R[2] end)
  return sorted_records
end

function add_record(map, player, delta)
  local records = load_records(map)
  if records[player] == nil or delta < records[player] then
    records[player] = delta
    save_records(map, records)
  new_record_added = true
  end
end

function save_records(map, records)
  local sorted_records = sorted_records(records)
  local lines = {}
  for i,record in ipairs(sorted_records) do
    table.insert(lines, record[1] .. " " .. tostring(record[2]))
  end
  cfg.setvalue("SvearkMod_maps", map:lower():gsub("=", ""), table.concat(lines, "\t"))
end

function load_records(map)
  local records = {}
  local data = cfg.getvalue("SvearkMod_maps", map:lower():gsub("=", ""))
  if data ~= nil then
    local lines = split(data, "\t")
    for i,line in ipairs(lines) do
      record = split(line, " ")
      records[record[1]] = tonumber(record[2])
    end
  end
  return records
end

function get_best_record(map)
  local sorted_records = sorted_records(load_records(map))
  local i, best_record = next(sorted_records)
if  best_record == nil then
return PLUGIN_BLOCK
end  
if best_record[1] or best_record[2] ~= nil then
  return best_record[1], best_record[2]
elseif best_record[1] or best_record[2] == nil then
print("Error returning best_record")
end
end

---

function fine_player(cn, fine)
  if fine > 0 then
    if fines[cn] == nil then
      fines[cn] = fine
    else
      fines[cn] = fines[cn] + fine
    end
  end
end

function sendMOTD(cn)
  if not config.gema_mode_is_turned_on then return end
  if cn == nil then cn = -1 end
  commands["!mapbest"][2](cn, {})
  say("\f4TYPE \fR!cmds \f4TO SEE AVAILABLE SERVER COMMANDS", cn)
say("\fR[SERVER NEWS] \f9Insert News Here! Default News message.", cn)

end


-- commands
--- params: { admin required, show message in chat, gema mode required }

commands =
{
  ["!serverdesc"] = 
  {
    { true, false, false };
  function (cn, args)
  a = tostring(args[1])
  b = tostring(args[2])
  c = tostring(args[3])
  d = tostring(args[4])
  e = tostring(args[5])
  f = tostring(args[6])
  g = tostring(args[7])
  h = tostring(args[8])
  i = tostring(args[9])
  j = tostring(args[10])
if b == nil then
b = "\f9"
elseif c == nil then
c = "\f9 "
elseif d == nil then
d = "\f9 "
elseif e == nil then
e = "\f9 "
elseif f == nil then
f = "\f9 "
elseif g == nil then
g = "\f9 "
elseif h == nil then
h = "\f9 "
elseif i == nil then
i = "\f9 "
elseif j == nil then
j = "\f9 "
 
end
setservname(string.format("%s %s %s %s %s %s %s %s %s %s", a, b, c, d, e, f, g, h, i, j))
  say("\f9 The server name was changed to " ..string.format("%s %s %s %s %s %s %s %s %s %s.", a, b, c, d, e, f, g, h, i, j))  
end
};

  ["!cmds"] = 
  {
    { false, false, false };
    function (cn, args)
      say("\fP-------------------------------------------------------------------------------------------------------------------------------------------------------", cn)
      say("\f4AVAILABLE COMMANDS: \fP| \fR!mapbest \fP| \fR!grank \fP| \fR!mybest \fP| \fR!maptop \fP| \fR!pm \f4<CN> <TEXT>\fP| \fR !whois \f4 <CN> \fP| \fR !rules \fP| \fR !gemarules \fP|\fR !gtop \fP| \fR !inf \fP| \fR!addtime \fP|", cn)
      say("\fP-------------------------------------------------------------------------------------------------------------------------------------------------------", cn)
     
 

     if isadmin(cn) then
        say("\f3ADMIN COMMANDS: \fP| \fR!auto \fP| \fR!gema \fP| \fR!say \f4<TEXT> \fP| \fR!ext \f4<MINUTES> \fP| \fR !setadmin PASS \fP| \fR !ipbl <CN> \fP| \fR !b or !k <CN> \fP| \fR !~mute \f4 <CN>\fP|", cn)
	say("\f3ADMIN CMDS CONTINUED: \f9 !serverdesc NAME | !setmaxclients # |", cn) 
        say("\fP-------------------------------------------------------------------------------", cn)

      end

say("\fR [SERVER INFO] \f4" .. getname(cn) .. "\fR is watching server commands.")
    end
  };

      ["!mute"] = {
       { true, false, false };
        function(cn, tcn, reason)
        server.mute(cn, tcn, reason)
    end
  };
  
  
      ["!colortext"] =
  {
    { true, false, false };
     function (cn,args)
colortext  = not colortext
say("\f4You have " ..(colortext and "enabled" or "disabled").. " colorful text", cn) 
end
};
  
  ["!inf"] = {
    { false, false, false };
    function(cn)
      say("\f9SilverCloud\f4 Gema Mod \fR v. 4.1 OpenSource , Copyleft 2011-2014 SilverCloudTech (Jg99), No Rights Reserved.", cn)
say("\fR Lua AC Executables made by Sveark. \f9Our website is \f4www.sctechusa.com.", cn)

    end
  };

 ["!addtime"] =
  {
    { false, false, false };
    function (cn, args)
      if tonumber(args[1]) < 16 and tonumber(args[1]) > 2 then
        -- elseif args > 2 then
      settimeleft(tonumber(args[1]))
        say(string.format("\fR [SERVER INFO] \f4 Time remaining changed to %d", args[1]))
        else
        say(string.format("\f3 ERROR: Time has to be between 3 and 15 minutes, %s!", getname(cn)))$
end
    end
  };

--]]
  ["!ext"] = 
  {
    { true, false, true };
    function (cn, args)
      if #args == 1 then
        settimeleft(tonumber(args[1]))
        say("\fR [SERVER INFO] \f4 Time remaining changed!")
      end
    end
  };
 			
    ["lol"] = 
   {
     {false, false, false};
     function (cn, args)
       say("\fR [SERVER INFO] \f4" .. getname(cn) .. " \fRLOL'D")
     end
   };


   
       ["!deadmin"] =
  {
    {true, false, false};
    function (cn, tcn)
      
        setrole(tcn, 0, false)
      
    end
  };

   ["lmao"] = 
   {
     {false, true, false};
     function (cn, args)
       say("\fR [SERVER INFO] \f4" .. getname(cn) .. " \fR\fb Laughed his ass off!!!!")
     end
   };
   ["!rules"] = 
   {
     {false, false, false};
     function (cn, args)
     local sender = cn
       say("\fR [SERVER INFO] \f4" .. getname(cn) .. ", \fR Here are the server's \fR\fbRULES:", cn)
       say("\fR [SERVER INFO] \f4 SERVER RULES: 1: NO KILLING IN GEMA = \f3Ban or Blacklist", cn)
       say("\fR [SERVER INFO] \f4 2: NO cheating/abusive behavior = \f3Ban/blaclklist", cn)
       say("\fP ----------------------------------------------------------------------------------------------------", cn)
     end
   };
   ["!gemarules"] = 
   {
     {false, false, false};
     function (cn, args)
     local sender = cn
       say("\fR [SERVER INFO] \f4" .. getname(cn) .. ", \fR Here are the gema \fR\fbRULES:", cn)
       say("\fR [SERVER INFO] \f4 1. No killing in gema, Gema is an obstacle course that ", cn)
       say("\fR [SERVER INFO] \f4 2: you use the AssaultRifle to perform higher jumps, or with a grenade to", cn)
       say("\fR [SERVER INFO] \f4 perform very high jumps. Enjoy!", cn)
     end
   };
  ["!pm"] = 
  {
    { false, false, false };
    function (cn, args)
      if #args < 2 then return end
      local to, text = tonumber(args[1]), table.concat(args, " ", 2)
      say(string.format("\fR [SERVER INFO] \f4PM FROM \fR%s (%d)\f4: \fM%s", getname(cn), cn, text), to)
      say(string.format("\fR [SERVER INFO] \f4PM FOR \fR%s \f4HAS BEEN SENT", getname(to)), cn)
    end
  };

  ["!shuffleteams"] =
  { 
	{true, false, false};
	function (cn)
	shuffleteams()
	end
	};
  ["!auto"] =
  {
    { true, true, false };
    function (cn, args)
      config.gema_mode_autodetecting = not config.gema_mode_autodetecting
      say("\fR [SERVER INFO] \f4AUTODETECTING OF GEMA MODE IS TURNED " .. (config.gema_mode_autodetecting and "ON" or "OFF"), cn)
    end
  };


  ["!ipbl"] = 
   {
     {true, false, false};
         function (cn, args)
	    local name = getname(cn)
	    if not isadmin(cn) then return end
	      local ip = ""
	      local mask = ""	     
 if #args > 1 then
		local y = split(table.concat(args, " ", 1), " ")
		mask = y[2]
		if mask == "/16" or mask == "/32" or mask == "/24" then
		  if string.len(y[1]) < 3 then 
		    local cnx = tonumber(y[1])
		    if cnx == nil then say("\f4Wrong cn",cn) return end
		if isadmin(cnx) then return end		   
 	local tempip = getip(cnx)
		    if mask == "/24" then ip = tempip
		    else
		      ip = temp_ip_split(tempip) .. ".0.0"
		    end
		    say(string.format("\fR%s \f4is banned",getname(cnx)))
		    ban(cnx)
		  else
		    ip = y[1]
		  end
		else
		   say("\f4IP blacklist failed. Wrong mask",cn) 
		   return
		end
	      else
		if string.len(args[1]) < 7 then
		    local cnx = tonumber(args[1])
		if isadmin(cnx) then return end    
		ip = getip(cnx)
		    say(string.format("\fR%s \f4is banned",getname(cnx)))
		    ban(cnx)
		else
		  ip = args[1]
		end
	      end
	      if ip:match("%d+.%d+.%d+.%d+") == nil then say("\f4Not ip",cn) return end
	      os.execute("del /var/www/serverblacklist.cfg.bkp")
	      os.execute("cp /var/www/serverblacklist.cfg /var/www/serverblacklist.cfg.bkp")	
	      local f = assert(io.open("/var/www/serverblacklist.cfg", "a+"))  
	      f:write("\n",ip .. mask .. "\n")
	      f:close() 
	      
	      say(string.format("\fR%s \f4blacklisted by \fR%s",ip .. mask,name))
	 end
   };
   
   ["!unipbl"] = 
   {
     {true, false, false};
         function (cn, args)
	    if not isadmin(cn) then return end
	    os.execute("rm /var/www/serverblacklist.cfg")
	    os.execute("cp /var/www/serverblacklist.cfg.bkp /var/www/serverblacklist.cfg")
	    say("\f9SilverCloud Blacklist has been undone successfully.")
	 end
   };

  ["!gema"] =
  {
    { true, true, false };
    function (cn, args)
      config.gema_mode_is_turned_on = not config.gema_mode_is_turned_on
      say("\fR [SERVER INFO] \f4GEMA MODE IS TURNED " .. (config.gema_mode_is_turned_on and "ON" or "OFF"), cn)
    end
  };

  ["!say"] =
  {
    { true, false, false };
     function (cn,args)
	 local text = table.concat(args, " ", 1)
	 text = string.gsub(text,"\\f","\f")
      local parts = split(text, " ")
	    say(text)
    end
  };

    ["!duplicate"] =
  {
    { true, false, false };
     function (cn,args)
dup  = not dup
say("\f4You have " ..(dup and "enabled" or "disabled").. " duplicating text", cn) 
end
	
  };
  
      ["!colortext"] =
  {
    { true, false, false };
     function (cn,args)
colortext  = not colortext
say("\f4You have " ..(colortext and "enabled" or "disabled").. " colorful text", cn) 
end
	
  };
  
    ["!b"] =
  {
    { true, false, false };
         function (cn, args)
		 local name = getname(cn)
		
		    local cnx = tonumber(args[1])
		    if cn == nil then say("\f4Wrong cn",cn) return end
	say(string.format("\fR[SERVER INFO] \f3" .. getname(cnx) .. "\f4 was banned by \fR" .. getname(cn) .. "\f4. IP: \f4" .. getip(cnx) ))
		    ban(cnx)
		  end
  };
  
    ["!duplicate"] =
  {
    { true, false, false };
    function (cn)
      dup  = not dup
      say("\f4You have " ..(dup and "enabled" or "disabled").. " duplicating text", cn)
    end
  };
  
    ["!k"] =
  {
    { true, false, false };
         function (cn, args)
		 local name = getname(cn)
		
		    local cnx = tonumber(args[1])
		    if cn == nil then say("\f4Wrong cn",cn) return end
		    say(string.format("\fR[SERVER INFO] \f3" .. getname(cnx) .. "\f4 is kicked by \fR" .. getname(cn) .. "\f4!"))
		      disconnect(cnx, DISC_MKICK)
			say("\fR[SERVER INFO]\f4  " ..getname(acn).. "\f4 was kicked. IP:" ..getip(acn).. ".")
		  end
  };

  ["!mapbest"] =
  {
    { false, false, true };
    function (cn, args)
      local player, delta = get_best_record(getmapname())
      if player ~= nil then
        say(string.format("\f4THE BEST TIME FOR THIS MAP IS \fR%02d:%02d \f4(RECORDED BY \fR%s\f4)", delta / 60, delta % 60, player), cn)
      else
        say("\f4NO BEST TIME FOUND FOR THIS MAP", cn)
      end
    end
  };

  ["!mybest"] =
  {
    { false, false, true };
    function (cn, args)
      local records = load_records(getmapname())
      local delta = records[getname(cn)]
      if delta == nil then
        say("\f4NO PRIVATE RECORD FOUND FOR THIS MAP", cn)
      else
        say(string.format("\f4YOUR BEST TIME FOR THIS MAP IS \fR%02d:%02d", delta / 60, delta % 60), cn)
      end
    end
  };


["!autokick"] =
{
{ true, false, false };
function (cn, args)
autogemakick = not autogemakick
say("\f4You have " ..(autogemakick and "enabled" or "disabled").. " auto gema and teamkill kick.", cn) 
end
};

  ["!mapbottom"] =
  {
    { false, false, true };
    function (cn, args)
	logline(2, getname(cn).." viewed mapbottom")
      local sorted_records = reverse_sorted_records(load_records(getmapname()))
     if sorted_records == nil then
        say("\f1MAP BOTTOM IS EMPTY", cn)
      else
	local record = {}
        for i, record in ipairs(sorted_records) do
          if i > 5 then break end
	      if record == nil then
              say("\f1MAP BOTTOM IS EMPTY", cn)
              break
            else
              if i == 1 then say("\f1 SLOWEST PLAYERS OF THIS MAP:", cn) end
              say(string.format("\f1%d. \f2%s \f0%02d:%02d", i, record[1], record[2] / 60, record[2] % 60), cn)
            end
        end
      end
    end
  };
  
  
  ["!maptop"] =
  {
    { false, false, true };
    function (cn, args)
      local sorted_records = sorted_records(load_records(getmapname()))
      if next(sorted_records) == nil then
        say("\f4MAP TOP IS EMPTY", cn)
      else
        say("\f43 FASTEST PLAYERS OF THIS MAP:", cn)
        for i, record in ipairs(sorted_records) do
          if i > 3 then break end
          say(string.format("\f4%d. \fR%s \f9%02d:%02d", i, record[1], record[2] / 60, record[2] % 60), cn)
        end
      end
    end
  };

 
["!mrank"] = --accepts name to check
{
    { false, false, true };
    function (cn, args)
	local data ="(self)"
	if args[1] ~= nil then data = ": "..table.concat(args, " ") end
	logline(2, getname(cn).." viewed mrank"..data)
      local sorted_records = sorted_records(load_records(getmapname()))
      if sorted_records == nil then
        say("\f1NO RECORDS FOR THIS MAP", cn)
	return
      else
        local prn = nil
	local player_name = getname(cn)
	if args[1] ~=nil then player_name = args[1] end --use supplied name instead of self
        for i, record in ipairs(sorted_records) do
          total_records = i
	    if record == nil then
           say("\f1NO RECORDS FOR THIS MAP", cn)
            return
          else -- look for player and get time
            if player_name == record[1] and prn == nil then -- get only first record incase there are duplicated names
              prt = record[2]
              prn = i
            end
          end
        end
        if prn == nil then
	  if args[1] == nil then
            say("\f1YOU DON'T HAVE ANY RECORDS YET. MAKE AT LEAST ONE RECORD", cn)
	  else
	    say("\f1" .. args[1] .. " Does not have a record for this map", cn)
	  end
        else
	  if args[1] == nil then
            sayexept(string.format("\f2%s`s \f1 RANK FOR THIS MAP IS \f0%d \f1of \f0%d \f1TIME: \f2%02d:%02d ",player_name, prn, total_records, prt/60, prt % 60), cn) 
            say(string.format("\f2%s\f1, YOUR MAP RANK IS \f0%d \f1of \f0%d \f1TIME: \f2%02d:%02d ",player_name, prn, total_records, prt/60, prt % 60), cn) 
	  else
	    say(string.format("\f2%s`s \f1 RANK FOR THIS MAP IS \f0%d \f1of \f0%d \f1TIME: \f2%02d:%02d ",player_name, prn, total_records, prt/60, prt % 60), cn)
	  end
        end
      end
    end
};

  ["!mapbest"] =
  {
    { false, false, true };
    function (cn)
      local player, delta = get_best_record(getmapname())
      if player ~= nil then
      if delta ~= nil then

        say(string.format("\f4THE BEST TIME FOR THIS MAP IS \fR%02d:%02d \f4(RECORDED BY \fR%s\f4)", delta / 60, delta % 60, player), cn)
else
print("ERROR")
end      
else
	
        say("\f4NO BEST TIME FOUND FOR THIS MAP", cn)
	end
    end
  };

  ["!mybest"] =
  {
    { false, false, true };
    function (cn)
      local records = load_records(getmapname())
      local delta = records[getname(cn)]
      if delta == nil then
        say("\f4NO PRIVATE RECORD FOUND FOR THIS MAP", cn)
      else
        say(string.format("\f4YOUR BEST TIME FOR THIS MAP IS \fR%02d:%02d", delta / 60, delta % 60), cn)
      end
    end
  };


 ["!maptop"] =
  {
    { false, false, true };
    function (cn)
      local sorted_records = sorted_records(load_records(getmapname()))
      if next(sorted_records) == nil then
        say("\f4MAP TOP IS EMPTY", cn)
      else
        say("\f43 FASTEST PLAYERS OF THIS MAP:", cn)
        for i, record in ipairs(sorted_records) do
          if i > 3 then break end
          say(string.format("\f4%d. \fR%s \f9%02d:%02d", i, record[1], record[2] / 60, record[2] % 60), cn)
        end
      end
    end
  };

   ["!grank"] =
  {
    { false, true, true };
    function (cn, args)
      local name
      if #args > 0 then
        if tonumber(args[1]) == nil then
          name = args[1]
        else
          x = tonumber(args[1])
          if isconnected(x) ~= true then say("\f4Wrong cn",cn) return end
          name = getname(x)
        end
      else
        name = getname(cn)
      end
      top = gload()
      local place = find_place(top,name)
      if place == nil then
        say("\f9[\fPSERVER INFO\f9] \f4DON'T HAVE \fRGRANK\f4. MAKE AT LEAST ONE RECORD", cn)
      else
        say(string.format("\fR%s \f4GRANK IS \f9%d \f4WITH \fR%s \f4BEST RESULTS", name,place,top[place][2]),cn)
      end
    end
  };

  ["!gtop"] =
  {
    { false, false, false };
    function (cn, amount)
      local top = gload()
      if top == nil then
        say("\f4GTOP IS EMPTY!", cn)
      else
        if tonumber(#top) ~= nil then
          if amount ~= nil and tonumber(amount) ~= nil then
            amount = (tonumber(#top) >= tonumber(amount)) and tonumber(amount) or tonumber(#top)

            say("\fR" .. amount .. " \f4BEST PLAYERS ON THIS SERVER:", cn)
            for i, record in ipairs(top) do
              if i > amount and record ~= nil then break end
              say(string.format("\f4%d. \fR%s \f4with \fR%d \f4best records", i, record[1], record[2]), cn)
            end
          else
            say("\fR5 \f4BEST PLAYERS ON THIS SERVER:", cn)
            for i, record in ipairs(top) do
              if i > 5 then break end
              say(string.format("\f4%d. \fR%s \f4with \fR%d \f4best records", i, record[1], record[2]), cn)
            end
          end
        else
          clientprint(cn, "Top players in !gtop are NULL")
        end
      end
    end
  };


  


}


-- handlers

function onPlayerDeathAfter(tcn, acn, gib, gun) 
	if acn ~= tcn  and isTeammode(getgamemode()) then
		if getteam(acn) == getteam(tcn) then
			ban(acn)			
		--	say(string.format("\f4Player \f3%s\f4 has been autobanned for \f9 gema killing. \f4 Ip-address: \f8 %s.", getname(cn), getip(cn)))
	say("\f4 Player has been \f9AUTOBANNED.")
		elseif getfrags(acn) >= 4 and config.gema_mode_is_turned_on then
			ban(acn)
	--		say(string.format("\f4Player \f3%s\f4 has been autobanned for \f9 gema killing. \f4 Ip-address: \f8 %s.", getname(cn), getip(cn)))		
			say("\f4 Player has been \f9AUTOBANNED.")
--	ban(acn)
		end
	end
end


  function onPlayerSayText(cn, text)
text2 = string.format("SCLog: Player %s says: %s. Their IP is: %s",getname(cn), text ,getip(cn))
logline(4, text2)

if colortext then
 
      text = string.gsub(text,"\\f","\f")
      local parts = split(text, " ")
     
      local command, args = parts[1], slice(parts, 2)
      if commands[command] ~= nil then
	  
        local params, callback = commands[command][1], commands[command][2]
        if (isadmin(cn) or not params[1]) and (config.gema_mode_is_turned_on or not params[3]) then
          callback(cn, args)
      
		  
		  if not params[2] then
		 
            return PLUGIN_BLOCK
          end
        else
          return PLUGIN_BLOCK
        end
      end
	  if isadmin(cn) then
	  SayToAllA(text,cn)
  
	  return PLUGIN_BLOCK
	  else
      SayToAll(text,cn)
        return PLUGIN_BLOCK
	  end
 --logtext = string.gsub("player" .. getname(cn) .. "says:" .. text .. ". IP-address "..getip(cn).. " has been logged") --Output text to Log
 --logline(3, logtext)

	   else
   
 local parts = split(text, " ")
     
      local command, args = parts[1], slice(parts, 2)
      if commands[command] ~= nil then
	  
        local params, callback = commands[command][1], commands[command][2]
        if (isadmin(cn) or not params[1]) and (config.gema_mode_is_turned_on or not params[3]) then
          callback(cn, args)
      
		  
		  if not params[2] then
		 
            return PLUGIN_BLOCK
          end
        else
          return PLUGIN_BLOCK
        end
      end
	  if isadmin(cn) then
	  SayToAllA(text,cn)
	  return PLUGIN_BLOCK
	  else
      SayToAll(text,cn)
      return PLUGIN_BLOCK
	  end
    end
  end
 
function SayToAll(text, except)
   for n=0,20,1 do
    -- if isconnected(n) and n ~= except then
	if dup then
      say("\f4|\fX" .. except .. "\f4|\fR#\f5" .. getname(except) .. ":\f9 " .. text,n)
	  elseif isconnected(n) and n ~= except then
	   say("\f4|\fX" .. except .. "\f4|\fR#\f5" .. getname(except) .. ":\f9 " .. text,n)
	 end
	--  end
    
     end
   end
   
function SayToAllA(text, except)
   for n=0,20,1 do
    -- if isconnected(n) and n ~= except then
	if dup then
      say("\f4|\fX" .. except .. "\f4|\f3#\f5" .. getname(except) .. ":\f9 " .. text,n)
	  elseif isconnected(n) and n ~= except then
	  say("\f4|\fX" .. except .. "\f4|\f3#\f5" .. getname(except) .. ":\f9 " .. text,n)
	 end
	--  end
    
     end
   end
   
function SayToAll2(text, except)
   if isconnected(n) and n ~= except then
      say("\fR[SERVER INFO] \f4",text,n)
	  end
   end

function onPlayerNameChange (cn, new_name)
say("\fR [SERVER INFO] \f4" .. getname(cn) .. " \fR changed name to \f4" .. new_name .. "!")
end

function onPlayerSendMap(map_name, cn, upload_error)
if is_gema(map_name) then
say("\fR SERVER INFO] \f4Gema Check: \f9 Map is a gema!, You may vote it now!", cn)
upload_error = UE_NOERROR
else
say("\fR[SERVER INFO]\f4 Gema Check: \f3 Map is NOT a gema. You may not upload non-gema maps.", cn)
upload_error = UE_IGNORE
return upload_error
end

end


if config.gema_mode_autodetecting then
   -- config.gema_mode_is_turned_on = (gamemode == GM_CTF and is_gema(mapname))
  end
  sendMOTD()
     settimeleft(tonumber(25))
setautoteam(false)

     local records = load_records(getmapname())
      local delta = records[getname(cn)]
      if delta == nil then
        say("\f4NO PRIVATE RECORD FOUND FOR THIS MAP", cn)
      else
        say(string.format("\f4YOUR BEST TIME FOR THIS MAP IS \fR%02d:%02d", delta / 60, delta % 60), cn)
      end
    

function onPlayerConnect(cn)
  sendMOTD(cn)
   say("\f4Hello \fR" .. getname(cn) .. "!") 
-- say("\fR [SERVER INFO]" .. getname(cn) .. "\fR connected!!! with ip \f4" .. getip(cn) .. "")
setautoteam(false)
end

function onPlayerCallVote(cn, type, text, number)
    if (type == SA_AUTOTEAM) and (not getautoteam()) then
        voteend(VOTE_NO)
    elseif (type == SA_FORCETEAM) or (type == SA_SHUFFLETEAMS) then
        voteend(VOTE_NO)
end
	if (type == SA_MAP) and not (number == GM_CTF) then voteend(VOTE_NO) end
        if (type == SA_GIVEADMIN) or (type == SA_CLEARDEMOS) then voteend(VOTE_NO) end
 -- if (type == SA_BAN) or (type == SA_KICK) or (type == SA_REMBANS) or (type == --SA_GIVEADMIN) then
  --      voteend(1)
 --   end
--if number ~= 5 then
--voteend

--if (type == SA_BAN) or (type == SA_KICK) then
--voteend(1)
--end


setautoteam(0)

end

function onFlagAction(cn, action, flag)
  if config.gema_mode_is_turned_on and action == FA_SCORE then
    if start_times[cn] == nil then return end
    local delta = math.floor((getsvtick() - start_times[cn]) / 1000)
    start_times[cn] = nil
    if delta == 0 then return end
    if fines[cn] ~= nil then
      delta = delta + fines[cn]
      fines[cn] = nil
    end
    say(string.format("\f4%s SCORED AFTER %02d:%02d or %02d milliseconds", getname(cn), delta / 60, delta % 60, delta *1000))
    add_record(getmapname(), getname(cn), delta)
    local best_player, best_delta = get_best_record(getmapname())
    if best_delta == delta then
      say("\fR*** \f4\fbNEW BEST TIME RECORDED! \fR***")
    end
  end
 end

function onPlayerVote(actor_cn, vote)

say("\fR[SERVER INFO] \f4Player " .. getname(actor_cn) .. "\fR(\f9".. actor_cn .. "\fR)\f9 voted \f4F" .. vote .. "\fP!")
end

function onMapEnd()
say("\f4 GG!  \f9Thanks for playing a game with us!")
end


 
function temp_ip_split(ip)
  local x,y
  local xt = false
  local yt = true
  for i=1,string.len(ip),1 do
    if string.sub(ip,i,i) == "." then
      if yt == false then
	y = i
	break
      end
      
      if xt == false then
	xt = true
	yt = false
	x = i
      end
    end
  end
  return string.sub(ip,1,y-1)
end
function RandomMessages()
local messages = {"\fR [SERVER INFO] \f4 No killing in gema! \f3 Or ban/blacklist!", "\fR [SERVER INFO] \f4Visit =AoW= clan site at http://acaowforum.tk", "\fR \fR[SERVER INFO] \f3Cheating is not allowed. Cheaters will be blacklisted and/or reported.", "\fR [SERVER INFO] \f9 Laggers don't matter in a gema!", "\fR [SERVER INFO] \f3 Abusive behavior/trolling is not allowed, and may result in a \fB ban/blacklist.", "\fR [SERVER INFO] \f4 Have fun playing gemas on SilverCloud Gema server!", "\fR [SERVER INFO] \f4 Look for other \f9SilverCloud\fP\f9=\f4A\fRo\f3W\f9= \f4Servers!", "\fR [SERVER INFO] \f4 Contact Jg99 on IRC or on forum.cubers.net!", "\fR [SERVER INFO] \f4 This gema server has a !whois (CN) cmd so you can view where players connected from (country)!"}
clientprint(-1, messages[math.random(#messages)])
end

function ChangeServerName()
local names = {"\f9 Come Play @ SilverCloud Gemas", "\f9sctechusa.com is the main site!", "\f9No gameplay-modifying commands are used!", "\f9 Hosted by \fPJg99!", "\f9 SilverCloud Gemas has a wide selection of gemas!", "\f9  SilverCloud Gema server has useful stuff, like a gema timer!", "\f9 SAVE GEMAS NOW -  SilverCloud Gemas"}
setservname(names[math.random(#names)])
end

function DisableAutoTeam5Secs()
setautoteam(0)
end

function onInit()
--tmr.create(9,9 * 60 * 1000, "RandomMessages") -- every 5 minutes
--tmr.create(1,7 * 60 * 1000, "ChangeServerName") -- every 5 seconds
tmr.create(2,7 * 1 * 1, "DisableAutoTeam5Secs") -- every 5 ms i think
setautoteam(0)
setnickblist("/var/www/nicknameblacklist.cfg")
setblacklist("/var/www/serverblacklist.cfg")
end

function onDestroy()
tmr.remove(1)
tmr.remove(2)
tmr.remove(9)
end
function onPlayerSpawn(cn)
  start_times[cn] = getsvtick()
  fines[cn] = nil
  setautoteam(0)
end
