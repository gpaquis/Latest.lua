--// vim:ts=4:sw=4:noet
--// showlatest.lua -- Send lastadd when receive PM "/latest"
--[[
-- Version du Script 1.1
-- Merci a MirageNet pour les test
-- Contact me loops34atgmaildotcom
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
-- Recuperer la liste des dernieres fichiers ajouts sur les n derniers jours
-- regarder dans le "HashIndex.xml" 
-- Renvoyer les TTH et al liste en private message à l'utilisateuren private message

<File Name="/Volumes/Partages/Rpi/eiskaltdcpp_2.10_725.tar.gz" TimeStamp="1606656603" Root="6HHIE3P7AXVTPXGVQNUQIGR476IOG57YEIG7KBI"/>
magnet:?xt=urn:tree:tiger:AWJFB3JFL2CQRQCBUBK4THVJWLQCGWOJCMLPWWQ&xl=65895850&dn=eiskaltdcpp_2.4_03122020.tgz
--]]

--[[
Ne pas toucher la valeur de day
86400 = 1j
--]]
day=86400

--[[ Remplacer le chiffre
exemple: backto= day * 7
--]]
backto= day * 1

--[[
<File Name="/Volumes/Partages/Rpi/eiskaltdcpp_2.10_725.tar.gz" TimeStamp="1606656603" Root="6HHIE3P7AXVTPXGVQNUQIGR476IOG57YEIG7KBI"/>
magnet:?xt=urn:tree:tiger:AWJFB3JFL2CQRQCBUBK4THVJWLQCGWOJCMLPWWQ&xl=65895850&dn=eiskaltdcpp_2.4_03122020.tgz
--]]


filepath="/home/pi/.config/eiskaltdc++/HashIndex.xml"
TKeepExt={"avi", "mkv", "mpeg2", "mp3", "flac", "iso", "img", "mp4"}


function Get_cmd_result(str)
   local cmd = str
   local state =  os.execute(cmd)
   file = io.open("/tmp/luaexecute", "r")
   io.input(file)
   local value=io.read()
   io.close(file)
   return value
end


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

function searchlatest()
  local out="Latest"
  local cmd_date = "stat -c %Y " .. filepath .. " > /tmp/luaexecute"
  filetime = Get_cmd_result(cmd_date)
  searchdate = filetime - backto
  for line in io.lines(filepath) do
    local i = string.find(line, 'TimeStamp=')
    if i ~= nil then
      local timekey = string.sub(line, -61, -52)
      timekey = timekey:gsub('"', "0")
      if tonumber(timekey) > searchdate then
        --Debug Path--
        --print(line)

        --[[ Extraction du chemin ]]

        local BeginName = string.find(line, "Name")
        local EndName = string.find(line, "TimeStamp")
        local Nameglb = string.sub(line, BeginName +6, EndName -3)
        isreal=os.execute("stat -c %n " .. "\"".. Nameglb .."\"" .. " > /tmp/luaexecute")
        if isreal == 0 then 
          -- Debug Nameglb --
          --print(Nameglb)
         

          --[[ Extraction du nom de fichier ]]

          Tfilename = split_path(Nameglb,'/')
          local idfilename=table.getn(Tfilename)
          local filename=Tfilename[idfilename]
          filename = filename:gsub('%s','+')
          -- Debug FileName --
          --print(filename)


          --[[Extraction de l'extension ]]

          Textension = split(filename,'[.]+')
          local idext=table.getn(Textension)
          local ext=Textension[idext]
          -- Debug extension --
          --print(ext)
          for k,v in ipairs(TKeepExt) do
            if v == ext then
              --  local out=""
              -- Debug Filename Triee --
              --print(filename)
              local cmd_size = "stat -c %s \"" .. Nameglb .. "\" > /tmp/luaexecute"
              filesize = Get_cmd_result(cmd_size)
              -- Debug filesize --
              --print(filesize)
              
              --[[ Recuperation du Hash ]] --
              --print(line)
              result = string.sub(line,-43,-5)
              --print(result)

              --[[ Creation du Magnet ]] --
              --out = out .. "magnet:?xt=urn:tree:tiger:".. result .."&xl=" .. filesize .. "&dn=" .. filename
              out = out .. "\r\n" .. "magnet:?xt=urn:tree:tiger:".. result .."&xl=" .. filesize .. "&dn=" .. filename
	    end
          end
        end
      end
    end
  end
  return out
end




dcpp:setListener( "pm", "latest",
	function( hub, user, text )
		local s = string.lower( text )
		if string.find( s, "^[\/]latest" )  then
		  liste=searchlatest()
	          user:sendPrivMsgFmt( liste )
                end
	end
)

dcpp:setListener( "adcPm", "latest",
	function( hub, user, text, me_msg )
		local s = string.lower( text )
		if string.find( s, "^[\/]latest" )  then
                   liste=searchlatest() 
                   user:sendPrivMsgFmt( out )
		end
	end
)

DC():PrintDebug( "  ** Loaded latest.lua **" )
