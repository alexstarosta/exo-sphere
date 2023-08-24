local gi = require("gameData.gameInfo")
local gdata = require("gameData.gameData")

local transitionMaker = {}

transitionMaker.currentGrp = nil

local titleFont = "assets/fonts/DungeonFont.ttf"
local mainFont = "assets/fonts/EquipmentPro.ttf"

function transitionMaker.menuToLevel(planet, level, lives, duration)
  
  audio.fadeOut( { channel=1, time=700 } )
  
  local firstDur = duration*0.2
  local secondDur = duration*0.4
  
  local function deleteObj()
    gdata.overlays.returnGrp:removeSelf()
    gdata.overlays.returnGrp = nil
  end
  
  transition.to(gdata.overlays.returnGrp, {alpha = 0, time = firstDur, onComplete = deleteObj})
  
  local transitionGrp = display.newGroup()
  planet = string.upper(planet)
  
  local veil = display.newRect(transitionGrp, centerX, centerY, screenWidth, screenHeight*1.5)
  veil.fill = {0}
  
  local planetName = display.newText(transitionGrp, planet, centerX, centerY, titleFont, 200)
  local levelName = display.newText(transitionGrp, level, centerX, centerY + 130, mainFont, 100)
  
  local heartDisplay = display.newGroup()
  heartDisplay.anchorChildren = true
  
  local heartImg = display.newImageRect(heartDisplay, "assets/sprites/heart.png", 120, 120)
  heartImg.x = centerX - 90
  heartImg.y = centerY + 300
  local livesText = display.newText(heartDisplay, "X "..tostring(lives), centerX + 10, centerY + 300, mainFont, 75)
  livesText.anchorX = 0
  
  heartDisplay.x = centerX
  heartDisplay.y = centerY
  heartDisplay:translate(0,300)
  
  transitionGrp:insert(heartDisplay)
  
  transitionGrp:translate(0,-130)
  transitionGrp:toFront()
  
  transitionGrp.alpha = 0
  veil.alpha = 0
  
  transition.to(veil, {alpha = 1, time = firstDur})
  transition.to(transitionGrp, {alpha = 1, time = secondDur})
  
  transitionMaker.currentGrp = transitionGrp
  
end

function transitionMaker.removeTransition()
  transitionMaker.currentGrp:removeSelf()
  transitionMaker.currentGrp = nil
end

function transitionMaker.levelToMenu(coinsGained, cleared, mastered, duration)
  local transitionGrp = display.newGroup()
  
  audio.fadeOut( { channel=1, time=2000 } )
  
  local veil = display.newRect(transitionGrp, centerX, centerY, screenWidth, screenHeight*1.5)
  veil.fill = {0}
  
  local imgDir
  if cleared then
    if mastered then
      imgDir = "assets/sprites/outcomes/mastered.png"
    else
      imgDir = "assets/sprites/outcomes/passed.png"
    end
  else
    imgDir = "assets/sprites/outcomes/failed.png"
  end
  
  local condition = display.newImageRect(transitionGrp, imgDir, screenWidth*0.8, screenWidth*0.8)
  condition.x = centerX
  condition.y = centerY
  
  local coinDisplay = display.newGroup()
  coinDisplay.anchorChildren = true
  
  local coinImg = display.newImageRect(coinDisplay, "assets/sprites/coins/singlegoldcoin.png", 120, 120)
  coinImg.x = centerX - 90
  coinImg.y = centerY + 150
  local coinsText = display.newText(coinDisplay, "+ "..tostring(coinsGained), centerX + 10, centerY + 150, mainFont, 75)
  coinsText.anchorX = 0
  
  coinDisplay.x = centerX
  coinDisplay.y = centerY
  coinDisplay:translate(0,150)
  
  transitionGrp:insert(coinDisplay)
  
  transitionGrp:translate(0,-130)
  transitionGrp:toFront()
  
  transitionGrp.alpha = 0
  veil.alpha = 0
  
  local firstDur = duration*0.2
  local secondDur = duration*0.4
  
  transition.to(veil, {alpha = 1, time = firstDur})
  transition.to(transitionGrp, {alpha = 1, time = secondDur})
  
  transitionMaker.currentGrp = transitionGrp
end

function transitionMaker.homeToMenu(name, x, y, xScale, yScale, duration)
  local transitionGrp = display.newGroup()
  
  audio.fadeOut( { channel=1, time=2000 } )
  
  local veil = display.newRect(transitionGrp, centerX, centerY, screenWidth, screenHeight*1.5)
  veil.fill = {0}
  
  local planetName = display.newText(transitionGrp, string.upper(name), centerX, centerY - 325, titleFont, 200)
  planetName.fill = gi.worldColors[name]
  
  local sheetOptions = {
    width = 200,
    height = 200,
    numFrames = 50
  }
    
  local planetSheet = graphics.newImageSheet("assets/sprites/planets/"..name.."Spritesheet.png", sheetOptions)
  
  local spinSequence = {
    { 
    name = "spin",
    start = 1,
    count = 50,
    time = math.random(4000,4000),
    loopCount = 0,
    loopDirection = "forward"
    }
  }
    
  local planet = display.newSprite(transitionGrp, planetSheet, spinSequence)
  
  planet.x = centerX
  planet.y = y
  planet.xScale = xScale
  planet.yScale = yScale
  planet.setSequence = "spin"
  planet:play()
  
  transitionGrp.alpha = 0
  transitionGrp:translate(0, 100)
  veil.alpha = 0
  
  local firstDur = duration*0.2
  local secondDur = duration*0.8
  
  transition.to(veil, {alpha = 1, time = firstDur})
  transition.to(transitionGrp, {alpha = 1, y = transitionGrp.y - 100, time = secondDur})
  
  transitionMaker.currentGrp = transitionGrp
end

function transitionMaker.menuToHome(duration)
  local transitionGrp = display.newGroup()
  
  audio.fadeOut( { channel=1, time=2000 } )
  
  local veil = display.newRect(transitionGrp, centerX, centerY, screenWidth, screenHeight*1.5)
  veil.fill = {0}
  
  local planetName = display.newText(transitionGrp, "Hyperion Cluster", centerX, centerY - 325, titleFont, 120)
  
  local sheetOptions = {
    width = 200,
    height = 200,
    numFrames = 50
  }
    
  local planetSheet = graphics.newImageSheet("assets/sprites/hyperionSpritesheet.png", sheetOptions)
  
  local spinSequence = {
    { 
    name = "spin",
    start = 1,
    count = 50,
    time = math.random(4000,4000),
    loopCount = 0,
    loopDirection = "forward"
    }
  }
    
  local planet = display.newSprite(transitionGrp, planetSheet, spinSequence)
  
  planet.x = centerX
  planet.y = centerY
  planet.xScale = 3
  planet.yScale = 3
  planet.setSequence = "spin"
  planet:play()
  
  transitionGrp.alpha = 0
  transitionGrp:translate(0, 100)
  veil.alpha = 0
  
  local firstDur = duration*0.2
  local secondDur = duration*0.8
  
  transition.to(veil, {alpha = 1, time = firstDur})
  transition.to(transitionGrp, {alpha = 1, y = transitionGrp.y - 100, time = secondDur})
  
  transitionMaker.currentGrp = transitionGrp
end

return transitionMaker