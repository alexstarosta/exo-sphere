local gio = require("gameio")

local audioLoader = {}

audio.reserveChannels( 2 )

audioLoader.sfxDir = gio.getDir("audio/sfx")
audioLoader.sfx = {}

audioLoader.bgmDir = gio.getDir("audio/bgm")
audioLoader.bgm = {}

function audioLoader.loadSfx()

  for i, v in pairs(audioLoader.sfxDir) do
    
    local function convertName(filePath)
      local baseName = filePath:match("^.+/(.+)%..+$")
      return baseName
    end
    
    local baseName = convertName(v)
    
    audioLoader.sfx[baseName] = audio.loadSound(v)
    
  end

end

function audioLoader.loadBgm()

  for i, v in pairs(audioLoader.bgmDir) do
    
    local function convertName(filePath)
      local baseName = filePath:match("^.+/(.+)%..+$")
      return baseName
    end
    
    local baseName = convertName(v)
    
    audioLoader.bgm[baseName] = audio.loadStream(v)
    
  end

end

return audioLoader