local composer = require("composer")
local pdata = require("gameData.playerData")
local dm = require("dataManager")

local sceneHandler = {}

function sceneHandler.moveToLevel(tileSettings)
  
  local ge = require("gameEvents")
  ge.closeLevelInfo()

  composer.removeScene("menu", true)

  pdata.sceneOptions = {
    effect = "fade",
    time = 1000,
    params = tileSettings
  }

  composer.gotoScene("game", pdata.sceneOptions)
  
end

function sceneHandler.moveToMenu(tileX, tileY, mastered, pass)

  composer.removeScene("game", true)
  
  local code
  if pass then
    code = "completed"
  else
    code = "failed"
  end

  pdata.sceneOptions = {
    effect = "zoomInOutFade",
    time = 1000,
    params = {
      tX = tileX, 
      tY = tileY, 
      mastered = mastered,
      levelCode = code
      }
  }

  composer.gotoScene("menu", pdata.sceneOptions)
  
end

function sceneHandler.moveToGame(world, radius)
  
  composer.removeScene("home", true)

  pdata.sceneOptions = {
    effect = "zoomInOutFade",
    time = 1000,
    params = {
      world = world,
      radius = radius
      }
  }

  composer.gotoScene("menu", pdata.sceneOptions)
  
end

function sceneHandler.moveToHome()
  
  dm.saveData()
  
  composer.removeScene("menu", true)

  pdata.sceneOptions = {
    effect = "zoomInOutFade",
    time = 1000,
  }

  composer.gotoScene("home", pdata.sceneOptions)
  
end
  
return sceneHandler