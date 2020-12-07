--// vim:ts=4:sw=4:noet
--// showlatest.lua -- Send lastadd when receive PM "/latest"
--
--   pm			= normal pm message
--   			  f( hub, user, "message" )
--   			  DISCARDABLE
--   hubPm		= pm message with a different prefix than the nick in the From field
--   			  f( hub, user, "message which may include a <nickname>" )
--   			  DISCARDABLE
--   adcPm		= normal pm message
--   			  f( hub, user, "message", me_msg )
--   			  DISCARDABLE
--   groupPm	= pm message with a different reply-sid than the one who talks (probably chatroom or bot)
--   			  f( hub, user, "message", reply_sid, me_msg )
--   			  DISCARDABLE
--
--
-- Ecouter le mot "/latest" sur un private message
-- Recuperer la liste des dernieres fichiers ajouts sur les 10 derniers jours
-- regarder dans le "HashIndex.xml" 
-- Renvoyer les TTH et al liste en private message à l'utilisateuren private message

ts = os.time()
os.execute("stat -c %Y ~/.config/eiskaltdc++/HashIndex.xml > /tmp/luaexecute")
filepath="/home/pi/.config/eiskaltdc++/HashIndex.xml"
--[[
86400 = 1j
--]]
day=86400
backto= day * 7

file = io.open("/tmp/luaexecute", "r")
io.input(file)
filetime=io.read()
io.close(file)
searchdate = filetime - backto

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t, cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function split_path(str)
   return split(str,'[\\/]+')
end


out=""



dcpp:setListener( "pm", "latest",
	function( hub, user, text )
		local s = string.lower( text )
		if string.find( s, "/latest" )  then
		   for line in io.lines(filepath) do
  		      local i = string.find(line, 'TimeStamp=')
                      if i ~= nil then
                         local key = string.sub(line, -61, -52)
                         local key = key:gsub('"', "0")
                         if tonumber(key) > searchdate then
                            local BeginName = string.find(line, "Name")
                            local EndName = string.find(line, "TimeStamp")
                            local Nameglb = string.sub(line, BeginName +6, EndName -3)
                            cmd = "stat -c %s \"" .. Nameglb .. "\" > /tmp/luaexecute"
                            os.execute( cmd )
                            file = io.open("/tmp/luaexecute", "r")
                            io.input(file)
                            filesize=io.read()
			    io.close(file)
                            pathtab = split_path(Nameglb,'/')
                            local index=table.getn(pathtab)
                            local filename=pathtab[index]
                            filename = filename:gsub('%s','+')
                            result = string.sub(line,-43,-5)
                            out = out .. "\r\n" .. "magnet:?xt=urn:tree:tiger:".. result .."&dn=" .. filename
                         end    
                      end
		   end
	          user:sendPrivMsgFmt( out )
                end
	end
)

dcpp:setListener( "adcPm", "latest",
	function( hub, user, text, me_msg )
		local s = string.lower( text )
		if string.find( s, "/latest" )  then
		   for line in io.lines(filepath) do
  		      local i = string.find(line, 'TimeStamp=')
                      if i ~= nil then
                         local key = string.sub(line, -61, -52)
                         local key = key:gsub('"', "0")
                         if tonumber(key) > searchdate then
                            local BeginName = string.find(line, "Name")
                            local EndName = string.find(line, "TimeStamp")
                            local Nameglb = string.sub(line, BeginName +6, EndName -3)
                            cmd = "stat -c %s \"" .. Nameglb .. "\" > /tmp/luaexecute"
                            os.execute( cmd )
                            file = io.open("/tmp/luaexecute", "r")
                            io.input(file)
                            filesize=io.read()
			    io.close(file)
                            pathtab = split_path(Nameglb,'/')
                            local index=table.getn(pathtab)
                            local filename=pathtab[index]
                            filename = filename:gsub('%s','+')
                            result = string.sub(line,-43,-5)
                            out = out .. "\r\n" .. "magnet:?xt=urn:tree:tiger:".. result .."&dn=" .. filename
                         end    
                      end
                   end
                  user:sendPrivMsgFmt( line )
		end
	end
)

DC():PrintDebug( "  ** Loaded latest.lua **" )
