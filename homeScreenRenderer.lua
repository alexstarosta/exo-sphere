local gio = require("gameio")
local gi = require("gameData.gameInfo")
local gb = require("gameGeneration.guiBuilder")
local sh = require("sceneHandler")
local tm = require("transitionMaker")
local pdata = require("gameData.playerData")
local dm = require("dataManager")
local pup = require("playerUpgrades")
local al = require("audioLoader")

local homeScreenRenderer = {}

local titleFont = "assets/fonts/DungeonFont.ttf"
local mainFont = "assets/fonts/EquipmentPro.ttf"
local newGame, bubblesGrp

function homeScreenRenderer.renderMenu(planets, bubbles, bubblesGrp)
  local hse = require("homeScreenEvents")
  
  local firstMenuGrp = display.newGroup()
  
  local warningSprite
  local noTap = false
  local warningShown = false
  local warningShowing = false
  
  local newgameButton, button1 = gb.newMenuBox( centerX, centerY + 200, screenWidth*0.5, 125, "menuGui.png")
  firstMenuGrp:insert(button1)
  local newgameTxt = display.newText(firstMenuGrp, "NEW GAME", centerX, centerY + 200, mainFont, 80)
  
  local continueButton, button2 = gb.newMenuBox(centerX, centerY + 375, screenWidth*0.5, 125, "menuGui.png")
  firstMenuGrp:insert(button2)
  local continueTxt = display.newText(firstMenuGrp, "CONTINUE", centerX, centerY + 375, mainFont, 80)
  
  local function showWarning()
    local sheetOptions = {
      width = 2790/5,
      height = 6273/17,
      numFrames = 83
    }
    
    local warnSheet = graphics.newImageSheet("assets/sprites/warningbubble.png", sheetOptions)
    
    local talkSequence = {
      { 
      name = "talk",
      start = 1,
      count = 83,
      time = 4000,
      loopCount = 1,
      loopDirection = "forward"
      }
    }
    
    local warningSprite = display.newSprite(firstMenuGrp, warnSheet, talkSequence)
    warningSprite:scale(0.65,0.65)
    warningSprite.x = centerX + screenWidth*0.3
    warningSprite.y = centerY + screenWidth*0.2
    warningSprite.setSequence = "talk"
    warningSprite:play()
  end
  
  local function newGameTap(self)
    if noTap then
      return
    end
    if warningShowing then
      return
    end
    if not warningShown then
      if dm.playerData.lastUpdated ~= nil then
        warningShowing = true
        showWarning()
        button2.alpha = 0.4
        newgameTxt.alpha = 0.4
        newgameTxt.fill = {1,0,0}
        timer.performWithDelay(5000, function() 
            warningShown = true
            warningShowing = false
            button2.alpha = 1
            newgameTxt.alpha = 1
          end)
        return
      end
    end
    newGame = true
    noTap = true
    audio.play(al.sfx["buttonclick"], {channel = 2})
    hse.startNewGame(planets, firstMenuGrp, true)
    homeScreenRenderer.showBubbles(bubbles, dm.playerData.lastUpdated)
    timer.performWithDelay(500, function()
      hse.addPlanetEvents(planets, bubbles)
    end)
  end
  
  local function continueGameTap()
    if noTap then
      return
    end
    newGame = false
    noTap = true
    hse.startNewGame(planets, firstMenuGrp, false)
    audio.play(al.sfx["buttonclick"], {channel = 2})
    homeScreenRenderer.showBubbles(bubbles, dm.playerData.lastUpdated)
    timer.performWithDelay(500, function()
      hse.addPlanetEvents(planets, bubbles)
    end)
  end
  
  button2.alpha = 0.4
  continueTxt.alpha = 0.4
  
  if dm.playerData.lastUpdated ~= nil then
    button2.alpha = 1
    continueTxt.alpha = 1
    continueTxt.y, newgameTxt.y = newgameTxt.y, continueTxt.y
    continueTxt:toFront()
    newgameTxt:toFront()
    button1.tap = continueGameTap
    button1:addEventListener("tap", button1.tap)
    button2.tap = newGameTap
    button2:addEventListener("tap", button2.tap)
  else
    button1.tap = newGameTap
    button1:addEventListener("tap", button1.tap)
  end
  
  local gameLogoRatio = 3.4
  local width = screenWidth*0.9
  
  local gameLogo = display.newImageRect(firstMenuGrp, "assets/sprites/exoSphereLogo.png", width, width / gameLogoRatio)
  gameLogo.x = centerX
  gameLogo.y = centerY - 400
  
  local splashtext = display.newText(firstMenuGrp, gi.splashTexts[math.random(1,#gi.splashTexts)], centerX + screenWidth/4, centerY - 250, mainFont, 50)
  transition.loop( splashtext, {size = 60, time = 1500, iterations = -1} )
  
  local creditTxt = display.newText(firstMenuGrp, "Alex Starosta 2023 - All Rights Reserved", centerX, screenBottom - 50, mainFont, 50)
  
  return firstMenuGrp
end

function homeScreenRenderer.renderPlanets()
  
  local planetSheets = gio.getDir("assets/sprites/planets")
  local planets = {}
  local planetsGrp = display.newGroup()
  
  for i = 1,#planetSheets do
    local sheetOptions = {
      width = 200,
      height = 200,
      numFrames = 50
    }
      
    local planetSheet = graphics.newImageSheet(planetSheets[i], sheetOptions)
    
    local spinSequence = {
      { 
      name = "spin",
      start = 1,
      count = 50,
      time = math.random(4000,6000),
      loopCount = 0,
      loopDirection = "forward"
      }
    }
    
    planets[i] = display.newSprite(planetsGrp, planetSheet, spinSequence)
    planets[i].x = centerX
    planets[i].y = centerY
    planets[i]:scale(2,2)
    planets[i].setSequence = "spin"
    planets[i]:play()
  end
  
  local separatingDistance = screenHeight/5
  
  planets[1].y = centerY + separatingDistance
  planets[1].x = centerX + screenWidth/4
  planets[1].name = "earth"
  planets[1].difficulty = "Easy Passage"
  planets[1].difficultyColor = 1
  
  planets[3].y = centerY + separatingDistance/3
  planets[3].x = centerX - screenWidth/4
  planets[3].name = "watalu"
  planets[3].difficulty = "Challenging Trials"
  planets[3].difficultyColor = 2
  
  planets[2].y = centerY - separatingDistance/2
  planets[2].x = centerX + screenWidth/4
  planets[2].name = "epsillion"
  planets[2].difficulty = "Depths of Dispair"
  planets[2].difficultyColor = 3
  planets[2]:scale(1.5,1.5)
  
  planets[4].y = centerY - separatingDistance
  planets[4].x = centerX - screenWidth/5
  planets[4].name = "xenova"
  planets[4].difficulty = "For the Undaunted"
  planets[4].difficultyColor = 4
  planets[4]:scale(1.5,1.5)
  
  for i = 1,#planets do
    local object = planets[i]
    object.fill.effect = "filter.blurGaussian"
    
    object.alpha = 0.4
    
    object.fill.effect.horizontal.blurSize = 20
    object.fill.effect.horizontal.sigma = 140
    object.fill.effect.vertical.blurSize = 20
    object.fill.effect.vertical.sigma = 140
  end
  
  planetsGrp:translate(0, 100)
  
  return planets, planetsGrp
  
end

function homeScreenRenderer.renderPlanetTitle(planet)
  local hse = require("homeScreenEvents")
  
  local name = planet.name
  local diff = planet.difficulty
  local color = gi.difficultyColors[planet.difficultyColor]
  
  local function enterWorld()
    if not pdata.currentWorldInfo.transitioning then
      local transitionDuration = 3000
      if not newGame then
        dm.loadMapData(name)
      else
        dm.playerData = {
          gold = 0,
          lastUpdated = nil,
          
          earthMap = nil,
          wataluMap = nil,
          epsillionMap = nil,
          xenovaMap = nil,
          
          upgrades = {
            lives = 0,
            coins = 0,
            mastery = 0,
            revival = 0,
          }
        }
        
        pdata.gold = 0
        pdata.currentMap = nil
        pdata.currentWorldInfo = {}
        pdata.currentGameInfo = {}
        
        pup.upgrades = {
          lives = 0,
          coins = 0,
          mastery = 0,
          revival = 0,
        }
        
      end
      audio.play(al.sfx["buttonclick"], {channel = 2})
      pdata.currentWorldInfo.transitioning = true
      transition.to(hse.titleGrp, {alpha = 0, time = 3000})
      transition.to(planet, {alpha = 0, time = 3000, y = planet.y - 100})
      transition.to(bubblesGrp, {alpha = 0, time = 3000, transition = easing.outCubic})
      tm.homeToMenu(name, planet.x, planet.y, planet.xScale, planet.yScale, transitionDuration)
      timer.performWithDelay(transitionDuration, function()
        sh.moveToGame(name, math.random(3,6))
      end)
    end
  end
  
  local grp = display.newGroup()
  
  local planetName = display.newText(grp, string.upper(name), centerX, centerY, titleFont, 130)
  local difficulty = display.newText(grp, diff, centerX, centerY + 100, mainFont, 70)
  difficulty.fill = color
  local playButton, playButtonGrp = gb.newMenuBox(centerX, screenBottom - 200, screenWidth*0.4, 150, name.."Gui.png")
  grp:insert(playButtonGrp)
  playButtonGrp.tap = enterWorld
  playButtonGrp:addEventListener("tap", playButtonGrp)
  
  local playTxt = display.newText(grp, "ENTER", centerX, screenBottom - 200, mainFont, 100)
  
  grp:translate(0, -425)
  grp.alpha = 0
  transition.to(grp, {alpha = 1, time = 500})
  
  return grp
  
end

function homeScreenRenderer.renderBubbles(planets)
  
  local bubbleTab = {}
  local bubbleGrp = display.newGroup()
  
  -- 1 = continue?
  -- 2 = enter?
  -- 3 = last saved
  -- 4 = start here
  
  for i = 1,#planets do
    bubbleTab[i] = {}
    
    local dir = gio.getDir("assets/sprites/bubbles")
    for x = 1,#dir do
      bubbleTab[i][x] = display.newImage(bubbleGrp, dir[x])
      bubbleTab[i][x].x = planets[i].x + 50
      bubbleTab[i][x].y = planets[i].y - 100
      bubbleTab[i][x].alpha = 0
    end
    
  end
  
  bubblesGrp = bubbleGrp
  
  return bubbleTab, bubbleGrp
  
end

function homeScreenRenderer.showBubbles(bubbles, lastSaved)
  if newGame then
    transition.to(bubbles[1][4], {alpha = 1, time = 1000})
    return
  end
  print(lastSaved)
  if lastSaved == "earth" then
    transition.to(bubbles[1][1], {alpha = 1, time = 1000})
  elseif lastSaved == "epsillion" then
    transition.to(bubbles[2][1], {alpha = 1, time = 1000})
  elseif lastSaved == "watalu" then
    transition.to(bubbles[3][1], {alpha = 1, time = 1000})
  elseif lastSaved == "xenova" then
    transition.to(bubbles[4][1], {alpha = 1, time = 1000})
  else
    transition.to(bubbles[1][4], {alpha = 1, time = 1000})
  end
end

function homeScreenRenderer.animateBubbles(bubbles)
  
  local function continuousEasing(obj, easing1, easing2, time, ymove)
    transition.to(obj, {time = time/2, y = obj.y + ymove, tag = "float" , transition = easing1, onComplete = function() 
        transition.to(obj, {time = time/2, y = obj.y - ymove, transition = easing2, tag = "float"})
      end})
    timer.performWithDelay(time, function()
      transition.to(obj, {time = time/2, y = obj.y + ymove, tag = "float", transition = easing1, onComplete = function() 
        transition.to(obj, {time = time/2, y = obj.y - ymove, transition = easing2, tag = "float"})
      end})
    end, -1, "float")
  end
  
  for i = 1,#bubbles do
    for x = 1,#bubbles[i] do
      local randOffset = math.random(1,2000)
      local time = 4000 + randOffset
      local pos = 20
      local upDown = 0
      continuousEasing(bubbles[i][x], easing.inOutQuad, easing.inOutQuad, time, pos)
    end
  end
  
end

function homeScreenRenderer.animatePlanets(planets)
  
  local function continuousEasing(obj, easing1, easing2, time, ymove)
    transition.to(obj, {time = time/2, y = obj.y + ymove, tag = "float", transition = easing1, onComplete = function() 
        transition.to(obj, {time = time/2, y = obj.y - ymove, transition = easing2, tag = "float"})
      end})
    timer.performWithDelay(time, function()
      transition.to(obj, {time = time/2, y = obj.y + ymove, tag = "float", transition = easing1, onComplete = function() 
        transition.to(obj, {time = time/2, y = obj.y - ymove, transition = easing2, tag = "float"})
      end})
    end, -1, "float")
  end
  
  for i = 1,#planets do
    local randOffset = math.random(1,2000)
    local time = 4000 + randOffset
    local pos = 20
    local upDown = 0
    continuousEasing(planets[i], easing.inOutQuad, easing.inOutQuad, time, pos)
  end
  
end

return homeScreenRenderer