--// vim:ts=4:sw=4:noet
--// showlatest.lua -- Send lastadd when receive PM "/latest"
--[[
-- Version du Script 1.3a
-- Merci a MirageNet pour les tests
-- Contact me loops34atgmaildotcom
--
--   pm                 = normal pm message
--                        f( hub, user, "message" )
--                        DISCARDABLE
--   hubPm              = pm message with a different prefix than the nick in the From field
--                        f( hub, user, "message which may include a <nickname>" )
--                        DISCARDABLE
--   adcPm              = normal pm message
--                        f( hub, user, "message", me_msg )
--                        DISCARDABLE
--   groupPm    = pm message with a different reply-sid than the one who talks (probably chatroom or bot)
--                        f( hub, user, "message", reply_sid, me_msg )
--                        DISCARDABLE
--
--
-- Ecouter le mot "latest" en debut de ligne sur un private message
-- Recuperer la liste des derniers fichiers ajoutés sur les n derniers jours depuis le fichier HashIndex.xml
-- Renvoyer la liste de magnetlink en private message à l'utilisateure et les dossiers sur les bulks
<File Name="/Volumes/Partages/Rpi/eiskaltdcpp_2.10_725.tar.gz" TimeStamp="1606656603" Root="6HHIE3P7AXVTPXGVQNUQIGR476IOG57YEIG7KBI"/>
magnet:?xt=urn:tree:tiger:AWJFB3JFL2CQRQCBUBK4THVJWLQCGWOJCMLPWWQ&xl=65895850&dn=eiskaltdcpp_2.4_03122020.tgz
--]]

--[[
Ne pas toucher la valeur de day
86400 = 1j
--]]
day=86400

--[[ Remplacer le chiffre
exemple: backto= day * 3
--]]
backto= day * 3
filepath="/home/pi/.config/eiskaltdc++/HashIndex.xml"
TKeepExt={"avi", "mkv", "mpeg2", "mp3", "flac", "wav", "ogg", "iso", "img", "mp4", "epub", "pdf", "cbr", "cbz"}
TMultiples={"mp3", "flac", "wav", "ogg", "cbr", "cbz", "pdf", "epub"}

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

function xml_convert(str)
  local xmlstring = str
  xmlstring = xmlstring:gsub('&apos;', "'")
  xmlstring = xmlstring:gsub('&amp;', "&")
  xmlstring = xmlstring:gsub('&lt;', "<")
  xmlstring = xmlstring:gsub('&gt;', ">")
  xmlstring = xmlstring:gsub('&quot;', "\"")
  return xmlstring
end

function magnet_filename_encode(str)
  local magnetfilename = str
  magnetfilename = string.gsub(magnetfilename,'%&','%%26')
  magnetfilename = string.gsub(magnetfilename,',','%%2C')
  magnetfilename = string.gsub(magnetfilename,';','%%3B')
  magnetfilename = string.gsub(magnetfilename,'=','%%3D')
  magnetfilename = string.gsub(magnetfilename,'?','%%3F')
  magnetfilename = string.gsub(magnetfilename,'+','%%2B')
  magnetfilename = string.gsub(magnetfilename,'@','%%40')
  magnetfilename = string.gsub(magnetfilename,'#','%%23')
  magnetfilename = string.gsub(magnetfilename,'%[','%%5B')
  magnetfilename = string.gsub(magnetfilename,'%]','%%5D')
  magnetfilename = magnetfilename:gsub('%s','+')
  return magnetfilename
end

function Reduceifmultiple(str1, str2, int)
 local ext = str1
 local FilePath = str2
 idx = int
 local state = false

 for k2,v2 in pairs(TMultiples) do
    if v2 == ext then
      -- Extraction du dossier
      TFolderName = split_path(FilePath,'/')
      local idlast=table.getn(TFolderName) - 1
      FullPath = table.concat(TFolderName,"\/",2,idlast)
      idx=idx+1
      table.insert(TPath, idx, FullPath)
      state = true
    end
  end
return state
end

function buildfromtab()
  table.sort(TPath)
  local Tresult = {}
  local outfromtable = "\r\nFolders\r\n"
  for k, v in ipairs (TPath) do
    if v ~=TPath[k+1] then
     table.insert(Tresult,v)
    end
  end

  for k, v in ipairs(Tresult) do
    -- print (k,v)
    outfromtable = outfromtable .. v .. "\r\n"
  end
return outfromtable
end


TPath = {}

function searchlatest()
  idx = 0
  local out="\r\nFiles"
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
        --print(Nameglb)

        --[[ Traitement carateres speciaux
             conversion format UNIX
             Validation de l'existance du fichier format "UNIX"
        --]]

        UnixFormat = xml_convert(Nameglb)
        --print(UnixFormat)
        isreal=os.execute("stat -c %n " .. "\"".. UnixFormat .."\"" .. " > /tmp/luaexecute")
        if isreal == 0 then
          -- Debug Nameglb --
          --print(Nameglb)

          --[[ Extraction du nom de fichier ]]

          Tfilename = split_path(UnixFormat,'/')
          local idfilename=table.getn(Tfilename)
          local filename=Tfilename[idfilename]
          filename = magnet_filename_encode(filename)
          --filename = filename:gsub('%s','+')
          -- Debug FileName --
          --print(filename)

          --[[Extraction de l'extension ]]

          Textension = split(filename,'[.]+')
          local idext=table.getn(Textension)
          local ext=Textension[idext]
          -- Debug extension --
          --print(ext)

          for k1,v1 in ipairs(TKeepExt) do
            if v1 == ext then
              ismultiple = Reduceifmultiple(ext, UnixFormat, idx)
              if ismultiple == false then
                local cmd_size = "stat -c %s \"" .. UnixFormat .. "\" > /tmp/luaexecute"
                filesize = Get_cmd_result(cmd_size)
                -- Debug filesize --
                --print(filesize)

                --[[ Recuperation du Hash ]] --
                --print(line)
                result = string.sub(line,-43,-5)
                --print(result)

                --[[ Creation du Magnet ]] --
                out = out .. "\r\n" .. "magnet:?xt=urn:tree:tiger:".. result .."&xl=" .. filesize .. "&dn=" .. filename
                --print(out)
              end
            end
          end
        end
      end
    end
  end
  outtab = buildfromtab()
  out = out .. outtab
  return out
end


dcpp:setListener( "pm", "latest",
        function( hub, user, text )
                local s = string.lower( text )
                --if string.find( s, "^[\/]latest" )  then
                if string.find( s, "^latest" )  then
                  liste=searchlatest()
                  user:sendPrivMsgFmt( liste )
                end
        end
)

dcpp:setListener( "adcPm", "latest",
        function( hub, user, text, me_msg )
                local s = string.lower( text )
                --if string.find( s, "^[\/]latest" )  then
                if string.find( s, "^latest" )  then
                   liste=searchlatest()
                   user:sendPrivMsgFmt( liste )
                end
        end
)

DC():PrintDebug( "  ** Loaded latest.lua **" )
