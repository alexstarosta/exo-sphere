require ("math")
local gio = require("gameio")
local gi = require("gameData.gameInfo")
local sh = require("sceneHandler")
local pdata = require("gameData.playerData")
local tm = require("transitionMaker")
local pup = require("playerUpgrades")
local al = require("audioLoader")

local guiBuilder = {}

local dir = "assets/gui/"
local titleFont = "assets/fonts/DungeonFont.ttf"
local mainFont = "assets/fonts/EquipmentPro.ttf"

function guiBuilder.newMenuBox(x, y, width, height, imgdir)
  
  local menuBox = {}
  local borderSize = math.min(width, height)/3
  
  local sheetOptions = {
    width = 320,
    height = 320,
    numFrames = 9
  }
  
  local sheet = graphics.newImageSheet(dir..imgdir, sheetOptions)
  
  menuBox.center = display.newImageRect(sheet, 5, width - borderSize*2, height - borderSize*2)
  menuBox.center.x = x
  menuBox.center.y = y
  
  menuBox.right = display.newImageRect(sheet, 6, borderSize, height - borderSize*2)
  menuBox.right.x = x + width/2 - borderSize/2
  menuBox.right.y = y
  
  menuBox.left = display.newImageRect(sheet, 4, borderSize, height - borderSize*2)
  menuBox.left.x = x - width/2 + borderSize/2
  menuBox.left.y = y
  
  menuBox.top = display.newImageRect(sheet, 8, width - borderSize*2, borderSize)
  menuBox.top.x = x
  menuBox.top.y = y + height/2 - borderSize/2
  
  menuBox.bottom = display.newImageRect(sheet, 2, width - borderSize*2, borderSize)
  menuBox.bottom.x = x
  menuBox.bottom.y = y - height/2 + borderSize/2
  
  menuBox.topLeft = display.newImageRect(sheet, 7, borderSize, borderSize)
  menuBox.topLeft.x = x - width/2 + borderSize/2
  menuBox.topLeft.y = y + height/2 - borderSize/2
  
  menuBox.topRight = display.newImageRect(sheet, 9, borderSize, borderSize)
  menuBox.topRight.x = x + width/2 - borderSize/2
  menuBox.topRight.y = y + height/2 - borderSize/2
  
  menuBox.bottomLeft = display.newImageRect(sheet, 1, borderSize, borderSize)
  menuBox.bottomLeft.x = x - width/2 + borderSize/2
  menuBox.bottomLeft.y = y - height/2 + borderSize/2
  
  menuBox.bottomRight = display.newImageRect(sheet, 3, borderSize, borderSize)
  menuBox.bottomRight.x = x + width/2 - borderSize/2
  menuBox.bottomRight.y = y - height/2 + borderSize/2
  
  local menuGrp = display.newGroup()
  for i,v in pairs(menuBox) do
    menuGrp:insert(v)
  end
  
  return menuBox, menuGrp
  
end

function guiBuilder.newLevelText(x, y, width, height, map, levelx, levely)
  
  local infoObjects = {}
  
  local info = map.tiles[levely][levelx].info
  
  local largeTextSize = 80
  local mediumTextSize = 60
  local smallTextSize = 50
  
  local shadowOffset = 5
  local miniOffset = 30
  
  local function gotoLevelScene()
    audio.play(al.sfx["buttonclick"], {channel = 2})
    if not info.nearbyCleared or map.tiles[levely][levelx].info.cleared then
      return true
    end
    if not pdata.currentWorldInfo.transitioning then
      pdata.currentWorldInfo.transitioning = true
      local lives = map.tiles[levely][levelx].info.levelSettings.lives + pup.upgrades.lives
      map.tiles[levely][levelx].info.levelSettings.lives = lives
      local transitionDuration = 1000
      tm.menuToLevel(map.planet, levelx.." - "..levely, lives, transitionDuration)
      timer.performWithDelay(transitionDuration, function()
        sh.moveToLevel(map.tiles[levely][levelx].info.levelSettings)
      end)
    end
    return true
  end
  
  local function replaceText(st)
    local result = ""
    for i = 1, #st do
      local char = st:sub(i, i)
      if char == " " then
        result = result .. " "
      else
        result = result .. "?"
      end
    end
    return result
  end
  
  infoObjects.titleShadow = display.newText(info.levelName, x + shadowOffset, y - height/3 + shadowOffset, titleFont, largeTextSize)
  infoObjects.titleShadow.anchorY = 0
  infoObjects.titleShadow.fill = {0}
  
  infoObjects.title = display.newText(info.levelName, x, y - height/3, titleFont, largeTextSize)
  infoObjects.title.anchorY = 0
  infoObjects.title.fill = {1}
  
  infoObjects.difficultyShadow = display.newText("Difficulty : "..info.difficulty, x + shadowOffset, y + shadowOffset - height*0.1, mainFont, mediumTextSize)
  infoObjects.difficultyShadow.fill = {0}
  infoObjects.difficultyShadow.alpha = 1
  
  infoObjects.difficulty = display.newText("               "..info.difficulty, x, y - height*0.1, mainFont, mediumTextSize)
  infoObjects.difficulty.fill = info.difficultyColor
  
  infoObjects.planetName = display.newText(string.upper(info.planetName), x - width/2 + miniOffset, y - height/2 + miniOffset/2, mainFont, smallTextSize)
  infoObjects.planetName.anchorX = 0
  infoObjects.planetName.anchorY = 0
  infoObjects.planetName.fill = {0}
  
  infoObjects.levelNumber = display.newText(info.levelNumber, x + width/2 - miniOffset, y - height/2 + miniOffset/2, mainFont, smallTextSize)
  infoObjects.levelNumber.anchorX = 1
  infoObjects.levelNumber.anchorY = 0
  infoObjects.levelNumber.fill = {0}
  
  infoObjects.playBtn = display.newRect(x, y + height/4.5, width/2, height/4)
  
  if map.tiles[levely][levelx].info.mastered then
    infoObjects.playBtn.fill = gi.worldColors["mastered"]
  else
    infoObjects.playBtn.fill = gi.worldColors[map.planet]
  end

  infoObjects.playBtn.tap = gotoLevelScene
  
  if map.tiles[levely][levelx].info.mastered and map.tiles[levely][levelx].info.difficulty ~= "Shop" then
    infoObjects.playTxt = display.newText("Mastered", x, y + height/4.5, titleFont, mediumTextSize)
  else
    infoObjects.playTxt = display.newText("Enter", x, y + height/4.5, mainFont, mediumTextSize)
  end
  
  infoObjects.playTxt.alpha = 1
  
  if map.tiles[levely][levelx].info.cleared then
    infoObjects.playTxt.text = "Compeleted"
  end
  
  if map.tiles[levely][levelx].info.mastered then
    infoObjects.playTxt.text = "Mastered"
  end
  
  if map.tiles[levely][levelx].info.difficulty == "Shop" then
    
    local upgradeName, cost, level
    
    if map.planet == "earth" then
      upgradeName = "Get +1 life for each upgrade"
      cost = gio.formatNum(10 * 2^pup.upgrades.lives) 
      level = pup.upgrades.lives
    elseif map.planet == "watalu" then
      upgradeName = "Get 1% chance for double coins"
      cost = gio.formatNum(math.floor(2 * 1.5^pup.upgrades.coins)) 
      level = pup.upgrades.coins
    elseif map.planet == "epsillion" then
      upgradeName = "Get 1% chance for certain mastery"
      cost = gio.formatNum(50 + 50*pup.upgrades.mastery)
      level = pup.upgrades.mastery
    elseif map.planet == "xenova" then
      upgradeName = "Get 1% chance to not lose a life"
      cost = gio.formatNum(math.floor(100 + 1.4^pup.upgrades.revival))
      level = pup.upgrades.revival
    end
    
    local function buyUpgrade()
      if tonumber(pdata.gold) >= tonumber(cost) then
        audio.play(al.sfx["buy"], {channel = 2})
        pdata.gold = pdata.gold - cost
        if map.planet == "earth" then
          pup.upgrades.lives = pup.upgrades.lives + 1
          cost = gio.formatNum(10 * 2^pup.upgrades.lives) 
          level = pup.upgrades.lives
        elseif map.planet == "watalu" then
          pup.upgrades.coins = pup.upgrades.coins + 1
          cost = gio.formatNum(math.floor(2 * 1.5^pup.upgrades.coins)) 
          level = pup.upgrades.coins
        elseif map.planet == "epsillion" then
          pup.upgrades.mastery = pup.upgrades.mastery + 1
          cost = gio.formatNum(50 + 50*pup.upgrades.mastery)
          level = pup.upgrades.mastery
        elseif map.planet == "xenova" then
          pup.upgrades.revival = pup.upgrades.revival + 1
          cost = gio.formatNum(math.floor(100 + 1.4^pup.upgrades.revival))
          level = pup.upgrades.revival
        end
        infoObjects.playTxt.text = "Buy Upgrade - $"..cost
        infoObjects.levelNumber.text = "Lvl. "..level
        pdata.currentWorldInfo.coinGui.coinTxt.text = gio.formatNum(pdata.gold)
      else
        audio.play(al.sfx["broke"], {channel = 2})
        infoObjects.playTxt.fill = {1,0,0}
        timer.performWithDelay(500, function() infoObjects.playTxt.fill = {1} end)
      end
      return true
    end
    
    infoObjects.playBtn.width = screenWidth*0.5
    
    infoObjects.playTxt.text = "Buy Upgrade - $"..cost
    infoObjects.playBtn.tap = buyUpgrade
    
    infoObjects.levelNumber.text = "Lvl. "..level
    
    infoObjects.difficultyShadow.text = upgradeName
    infoObjects.difficulty.text = upgradeName
  end
  
  if not info.nearbyCleared then
    infoObjects.titleShadow.text = replaceText(info.levelName)
    infoObjects.title.text = replaceText(info.levelName)
    infoObjects.difficultyShadow.text = "Difficulty : "..replaceText(info.difficulty)
    infoObjects.difficulty.text = "               "..replaceText(info.difficulty)
    infoObjects.playTxt.text = "Undiscovered"
  end  
  
  infoObjects.playBtn:addEventListener("tap", infoObjects.playBtn)
  
  infoObjects.playBtn:toFront()
  infoObjects.playTxt:toFront()
  
  return infoObjects
  
end

function guiBuilder.createMenuGui(map, completed)
  local xPos = screenRight - 300
  local yPos = 220
  local height = 100
  
  local coinGui = {}
  local coinGuiGrp = display.newGroup()
  
  coinGui.coinBar = display.newRoundedRect(coinGuiGrp, xPos, yPos, screenWidth/2.6, height, 20)
  coinGui.coinBar.fill = gi.worldColors[map.planet]
  coinGui.coinBar.alpha = 0.5
  
  coinGui.coinImg = display.newImageRect(coinGuiGrp, "assets/sprites/coins/singlegoldcoin.png", height*1.25, height*1.25)
  coinGui.coinImg.x = xPos - coinGui.coinBar.width/2 + height*0.55
  coinGui.coinImg.y = yPos
  
  coinGui.coinTxt = display.newText(coinGuiGrp, gio.formatNum(pdata.gold), xPos - 80, yPos, titleFont, 90)
  coinGui.coinTxt.anchorX = 0
  
  xPos = 300
  yPos = 220
  
  local scoreGui = {}
  local scoreGuiGrp = display.newGroup()
  
  scoreGui.scoreBar = display.newRoundedRect(scoreGuiGrp, xPos, yPos, screenWidth/2.6, height, 20)
  scoreGui.scoreBar.fill = gi.worldColors[map.planet]
  scoreGui.scoreBar.alpha = 0.5
  
  scoreGui.scoreImg = display.newImageRect(scoreGuiGrp, "assets/sprites/map.png", height*1.25, height*1.25)
  scoreGui.scoreImg.x = xPos - coinGui.coinBar.width/2 + height*0.55
  scoreGui.scoreImg.y = yPos
  
  scoreGui.scoreTxt = display.newText(scoreGuiGrp, completed.." / "..map.tileAmount, xPos - 80, yPos, titleFont, 90)
  scoreGui.scoreTxt.anchorX = 0
  
  function scoreGui.switchToLives(lives)
    scoreGui.scoreImg:removeSelf()
    scoreGui.scoreImg = nil
    scoreGui.scoreImg = display.newImageRect(scoreGuiGrp, "assets/sprites/heart.png", height*1.25, height*1.25)
    scoreGui.scoreImg.x = xPos - coinGui.coinBar.width/2 + height*0.55
    scoreGui.scoreImg.y = yPos
    scoreGui.scoreTxt.text = lives
  end
  
  function scoreGui.switchToScore()
    scoreGui.scoreImg:removeSelf()
    scoreGui.scoreImg = nil
    scoreGui.scoreImg = display.newImageRect(scoreGuiGrp, "assets/sprites/map.png", height*1.25, height*1.25)
    scoreGui.scoreImg.x = xPos - coinGui.coinBar.width/2 + height*0.55
    scoreGui.scoreImg.y = yPos
    scoreGui.scoreTxt.text = completed.." / "..map.tileAmount
  end
  
  return coinGui, coinGuiGrp, scoreGui, scoreGuiGrp
end

return guiBuilder