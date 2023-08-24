local py = require("physics")
local pdata = require("gameData.playerData")
local lvle = require("levelEvents")
local lvlr = require("levelRenderer")
local gi = require("gameData.gameInfo")
local gio = require("gameio")
local al = require("audioLoader")

local levelBuilder = {}

local padding = 15
local mainFont = "assets/fonts/EquipmentPro.ttf"

function levelBuilder.generateBall(x, y, radius, bounce, lives)
  
  local ball
  
  local function changeState(self)
    ball.active = true
    self.bodyType = "dynamic"
  end
  
  ball = display.newImageRect("assets/sprites/meteorite.png", radius*2.1, radius*2.1)
  ball.tap = changeState
  ball.radius = radius
  ball.objt = "ball"
  ball.active = false
  py.addBody(ball, "static", {radius = radius, bounce = bounce})
  ball:addEventListener("tap", ball)
  
  ball.firstCollision = false
  ball.sleepCounter = 0
  ball.totalHits = 0
  ball.coinPotential = 0
  
  ball.lives = lives
  ball.startLives = lives
  
  ball.isSleepingAllowed = false
  
  return ball
  
end

function levelBuilder.createPegZones(zones)
  
  if zones[1] == "a" then
    zones = {1,2,3,4,5,6,7,8,9}
  end
  
  local areaTable = {}
  areaTable.count = #zones
  local width = screenWidth/3 - padding
  
  local areaGrp = display.newGroup()
  
  for i = 1,#zones do
    areaTable[i] = {}
    areaTable[i].areaNum = zones[i]
    areaTable[i].pegs = {}
    areaTable[i].rect = display.newRoundedRect(areaGrp, centerX, centerY, width, width, 20)
    areaTable[i].rect.fill = gi.worldColors[pdata.currentMap.planet]
    areaTable[i].rect.alpha = 0.5
    transition.loop( areaTable[i].rect, { alpha = 0, delay = i*200, time = 5000, iterations = -1, transition = easing.inOutQuad } )
    
    local xOffset = (zones[i] - 1) % 3 - 1
    local yOffset = math.ceil(zones[i] / 3) - 2
    
    areaTable[i].rect:translate(xOffset*(width+padding), yOffset*(width+padding))
  end
  
  return areaTable, areaGrp
  
end

function levelBuilder.createWallZones(zones, types)
  
  if zones[1] == "a" then
    zones = {1,2,3,4,5,6,7,8,9}
  end
  
  if zones[1] == "none" then
    return
  end
  
  local areaTable = {}
  areaTable.count = #zones
  local width = screenWidth/3 - padding
  
  local areaGrp = display.newGroup()
  
  local possibleWalls = gio.getDir("assets/sprites/walls/"..pdata.currentMap.planet)
  
  
  for i = 1,#zones do
    areaTable[i] = {}
    areaTable[i].areaNum = zones[i]
    
    local operationTable = types[i]
    local iterations = 1
    
    if #types[i] == 1 then
      local first = string.sub(types[i], 1, 1)
      operationTable = {first.."tl",first.."tr",first.."bl",first.."br"}
      iterations = 4
    elseif #types[i] == 2 then
      local first = string.sub(types[i], 1, 1)
      local second =  string.sub(types[i], 2, 2)
      if second == "t" or second == "b" then
        operationTable = {first..second.."l",first..second.."r"}
      else
        operationTable = {first..second.."b",first..second.."t"}
      end
      iterations = 2
    end
    
    for it = 1,iterations do
      
      local typeTab, sheetOptions, fireSheet, flickerSequence
      
      local function createFireWall()
        sheetOptions = {
            width = 240,
            height = 240,
            numFrames = 4
          }
          
        fireSheet = graphics.newImageSheet("assets/sprites/firewalls/"..pdata.currentMap.planet..".png", sheetOptions)
        
        flickerSequence = {
          { 
        name = "flicker",
        start = 1,
        count = 4,
        time = math.random(400,500),
        loopCount = 0,
        loopDirection = "forward"
          }
        }
      end
      
      typeTab = types[i]
      
      if type(operationTable) ~= "string" then
        typeTab = operationTable[it]
      end
      
      if string.sub(typeTab, 1, 1) == "n" then
        areaTable[i].rect = display.newImageRect(areaGrp, possibleWalls[math.random(1,#possibleWalls)], width, width)
        areaTable[i].rect.objt = "wall"
      elseif string.sub(types[i], 1, 1) == "f" then
        createFireWall()
        areaTable[i].hitbox = display.newRoundedRect(areaGrp,centerX, centerY, width*0.95, width*0.95, 50)
        areaTable[i].hitbox.alpha = 0
        areaTable[i].rect = display.newSprite(areaGrp, fireSheet, flickerSequence)
        areaTable[i].rect.width = width
        areaTable[i].rect.height = width
        areaTable[i].rect:setSequence( "flicker" )
        areaTable[i].rect:play()
        areaTable[i].rect.objt = "firewall"
        areaTable[i].hitbox.objt = "firewall"
      end
      
      areaTable[i].rect.x = centerX
      areaTable[i].rect.y = centerY
      
      for x = 2,string.len(typeTab) do
        if string.sub(typeTab, x, x) == "t" then
          areaTable[i].rect.height = areaTable[i].rect.height/2
          areaTable[i].rect.anchorY = 1
        elseif string.sub(typeTab, x, x) == "b" then
          areaTable[i].rect.height = areaTable[i].rect.height/2
          areaTable[i].rect.anchorY = 0
        elseif string.sub(typeTab, x, x) == "l" then
          areaTable[i].rect.width = areaTable[i].rect.width/2
          areaTable[i].rect.anchorX = 1
        elseif string.sub(typeTab, x, x) == "r" then
          areaTable[i].rect.width = areaTable[i].rect.width/2
          areaTable[i].rect.anchorX = 0
        end
      end
      
      if string.sub(types[i], 1, 1) == "f" then
        py.addBody(areaTable[i].hitbox, "static")
        areaTable[i].rect:scale(0.7,0.7)
      else
        py.addBody(areaTable[i].rect, "static")
        areaTable[i].rect:scale(1.05,1.05)
      end
      
      local xOffset = (zones[i] - 1) % 3 - 1
      local yOffset = math.ceil(zones[i] / 3) - 2
      
      areaTable[i].rect:translate(xOffset*(width+padding), yOffset*(width+padding))
      if string.sub(types[i], 1, 1) == "f" then
        areaTable[i].hitbox:translate(xOffset*(width+padding), yOffset*(width+padding))
      end
    
    end
    
  end
  
  return areaTable, areaGrp
  
end

function levelBuilder.createDropZones(y, zones)
  
  if zones[1] == "a" then
    zones = {1,2,3}
  end
  
  local areaTable = {}
  areaTable.count = #zones
  local width = screenWidth/3 - padding
  local height = width*0.75
  
  local areaGrp = display.newGroup()
  
  for i = 1,#zones do
    areaTable[i] = display.newRoundedRect(areaGrp, centerX, y, width, height, 20)
    areaTable[i].fill = gi.worldColors[pdata.currentMap.planet]
    areaTable[i].alpha = 0.5
    
    local xOffset = (zones[i] - 1) % 3 - 1
    
    areaTable[i]:translate(xOffset*(width+padding), width)
    transition.loop( areaTable[i], { alpha = 0, delay = i*200, time = 5000, iterations = -1, transition = easing.inOutQuad } )
  end
  
  return areaTable, areaGrp
  
end

function levelBuilder.createEndZones(y, zones)
  
  if zones[1] == "a" then
    zones = {1,2,3}
  end
  
  local areaGrp = display.newGroup()
  
  local areaTable = {}
  areaTable.count = #zones
  local width = screenWidth/3 - padding
  local height = width*0.75
  
  for i = 1,#zones do
    areaTable[i] = {}
    areaTable[i].rect = display.newRoundedRect(areaGrp, centerX, y, width, height, 20)
    areaTable[i].rect.fill = gi.worldColors[pdata.currentMap.planet]
    areaTable[i].rect.alpha = 0.5
    
    local xOffset = (zones[i] - 1) % 3 - 1
    
    areaTable[i].rect:translate(xOffset*(width+padding), -width)
    transition.loop( areaTable[i].rect, { alpha = 0, delay = i*200, time = 5000, iterations = -1, transition = easing.inOutQuad } )
  end
  
  return areaTable, areaGrp
  
end

function levelBuilder.addPegAttributes(peg, iVal)
  
  if iVal % 3 == 0 then
    if math.random(1,4) == 1 then
      peg.pegType = "static"
      return
    end
  end
  
  if math.random(1,10) == 2 then
    peg.pegType = "bouncy"
    peg.fill = {0,1,1}
    py.removeBody(peg)
    print("body")
    py.addBody(peg, "static", {radius = peg.radius, bounce = 0.99})
    return
  end
  
  if math.random(1,10) == 2 then
    peg.pegType = "fire"
    return
  end

end

function levelBuilder.generatePegs(amount, pegZones, radius, forceZone, forceType)
  
  for i = 1,#pegZones do
    for x = 1,#pegZones[i].pegs do
      pegZones[i].pegs[x].pegImg:removeSelf()
      pegZones[i].pegs[x] = nil
    end
  end
  
  local pegs = {}
  pegs.required = 0
  local pegGroup = display.newGroup()
  
  local function isWithinRadius(x, y, objs, pradius)
    
    if #objs == 0 then
      return false
    end
    
    for i = 1,#objs do
      local distance = math.sqrt((objs[i].x - x)^2 + (objs[i].y - y)^2)
      if distance < radius*2 then
        return true
      end
    end
    
    return false
  end
  
  for i = 1,amount do
    
    local area
    
    if forceZone ~= nil then
      if #forceZone ~= 0 then
        area = forceZone[1]
        table.remove(forceZone, 1)
      else
        area = math.random(1,#pegZones)
      end
    else
      area = math.random(1,#pegZones)
    end
    
    pegs[i] = display.newCircle(pegGroup, pegZones[area].rect.x, pegZones[area].rect.y, radius)
    py.addBody(pegs[i], "static", {radius = radius})
    
    pegs[i].radius = radius
    pegs[i].id = i
    pegs[i].objt = "peg"
    
    if forceType ~= nil then
      if #forceType ~= 0 then
        pegs[i].pegType = forceType[1]
        table.remove(forceType, 1)
        
        if pegs[i].pegType == "bouncy" then
          py.removeBody(pegs[i])
          py.addBody(pegs[i], "static", {radius = radius, bounce = 0.99})
        end
      else
        pegs[i].pegType = "normal"
        levelBuilder.addPegAttributes(pegs[i], i)
      end
    else
      pegs[i].pegType = "normal"
      levelBuilder.addPegAttributes(pegs[i], i)
    end
    
    pegs[i].radius = radius
    pegs[i].hit = false
    
    if pegs[i].pegType ~= "fire" then
      pegs.required = pegs.required + 1
    end
    
    local randArea = pegZones[1].rect.width/2 - radius
    
    local randx = math.random(-randArea, randArea)
    local randy = math.random(-randArea, randArea)
    
    local counter = 0
    
    repeat
      randx = math.random(-randArea, randArea)
      randy = math.random(-randArea, randArea)
      counter = counter + 1
      
      if counter % 10 == 0 then
        local area = math.random(1,#pegZones)
      end
      
    until not isWithinRadius(randx + pegZones[area].rect.x, randy + pegZones[area].rect.y, pegZones[area].pegs, radius) or counter > 99
    
    pegs[i]:translate(randx, randy)
    lvlr.generatePegOverlay(pegs[i])
    
    local paint = {
      type = "image",
      filename = "assets/sprites/pegs/"..pegs[i].pegType..".png"
    }

    pegs[i].fill = paint
    
    table.insert(pegZones[area].pegs, pegs[i])
    
  end
  
  pdata.currentGameInfo.pegs = pegs
  pdata.currentGameInfo.pegsGrp = pegGroup 
  
  return pegs, pegGroup
  
end

function levelBuilder.createWalls(wallType)
  
  local walls = {}
  local wallsGrp = display.newGroup()
  
  walls.right = display.newRect(wallsGrp, screenWidth, centerY, 10, screenHeight)
  walls.right.anchorX = 0
  
  walls.left = display.newRect(wallsGrp, 0, centerY, 10, screenHeight)
  walls.left.anchorX = 1
  
  walls.bottom = display.newRect(wallsGrp, centerX, screenHeight, screenWidth, 10)
  walls.bottom.anchorY = 0
  
  local function teleportWall()
    local ball = pdata.currentGameInfo.ball
    if ball.x > screenWidth + ball.radius then
      ball.x = -ball.radius
      ball.y = ball.y - ball.radius/2
      audio.play(al.sfx["portal"], {channel = 2})
    elseif ball.x < -ball.radius then
      ball.x = screenWidth + ball.radius
      ball.y = ball.y - ball.radius/2
      audio.play(al.sfx["portal"], {channel = 2})
    end
  end
  
  for k,v in pairs(walls) do
    if wallType == "fire" then
      v.objt = "deathwall"
    elseif wallType == "portal" then
      v.objt = "telewall"
      walls.right.x = screenWidth + pdata.currentGameInfo.ball.radius*2.5
      walls.left.x = -pdata.currentGameInfo.ball.radius*2.5
      Runtime:addEventListener("enterFrame", teleportWall)
    else
      v.objt = "wall"
    end
    py.addBody(v, "static")
  end
  
  walls.bottom.objt = "deathwall"
  
end

function levelBuilder.generateEnd(diffs, hitsRequired, endZones)
  
  local endings = {}
  local endingGrp = display.newGroup()
  
  for i = 1,#endZones do
    local difficulty = diffs[i]
    
    local randomSelection = math.random(1,2)
    local width = math.random(endZones[1].rect.width/difficulty, endZones[1].rect.width)
    endings.difficulty = difficulty
    
    if difficulty == 1 then
      
      if randomSelection == 1 then
        endings[i] = display.newRect(endingGrp, endZones[i].rect.x, endZones[i].rect.y, width, 10)
      else
        endings[i] = display.newRect(endingGrp, endZones[i].rect.x, endZones[i].rect.y, width*0.75, 10)
      end
      
    elseif difficulty == 2 then
      
      if randomSelection == 1 then
        endings[i] = display.newRect(endingGrp, endZones[i].rect.x, endZones[i].rect.y, width*0.25, width*0.25)
      else
        endings[i] = display.newCircle(endingGrp, endZones[i].rect.x, endZones[i].rect.y, width*0.125)
      end
      
    elseif difficulty == 3 then
      
      if randomSelection == 1 then
        endings[i] = display.newRect(endingGrp, endZones[i].rect.x, endZones[i].rect.y, 10, width*0.25)
      else
        endings[i] = display.newCircle(endingGrp, endZones[i].rect.x, endZones[i].rect.y, width*0.1)
      end
      
    elseif difficulty == 4 then
      
      if randomSelection == 1 then
        endings[i] = display.newRect(endingGrp, endZones[i].rect.x, endZones[i].rect.y, width*0.05, width*0.05)
      else
        endings[i] = display.newCircle(endingGrp, endZones[i].rect.x, endZones[i].rect.y, width*0.05)
      end
      
    elseif difficulty == 5 then
      
      if randomSelection == 1 then
        endings[i] = display.newRect(endingGrp, endZones[i].rect.x, endZones[i].rect.y + width/2, width*2, 10)
      else
        endings[i] = display.newRect(endingGrp, endZones[i].rect.x, endZones[i].rect.y + width/2, width*2, 10)
      end
      
    end
    
    local shiftX = math.random (-1,1)
    local shiftY = math.random (-1,1)
    local padding = 75
    local tileWidth = endZones[1].rect.width

    if math.abs(endings[i].width - tileWidth) > 1 then
      if shiftX == -1 then
        endings[i].anchorX = 0
        endings[i]:translate(-tileWidth/2 + padding, 0)
      elseif shiftX == 1 then
        endings[i].anchorX = 1
        endings[i]:translate(tileWidth/2 - padding, 0)
      end
    end
    
    if shiftY == -1 then
      endings[i].anchorY = 0
      endings[i]:translate(0, -tileWidth/2 + padding)
    elseif shiftY == 1 then
      endings[i].anchorY = 1
      endings[i]:translate(0, tileWidth/2 - padding)
    end
    
    endings[i].alpha = 0
    endings[i].hitsRequired = hitsRequired[i]
    endings[i].hitsStarted = hitsRequired[i]
    
    endings[i].zone = i
    endings[i].objt = "ending"
    py.addBody(endings[i], "static")
    
  end
  
  return endings, endingGrp
  
end

function levelBuilder.createCoinZones(coinZones, types, pegZones)

  local sheetOptions = {
    width = 20,
    height = 20,
    numFrames = 9
  }
    
  local goldSheet = graphics.newImageSheet("assets/sprites/coins/goldcoin.png", sheetOptions)
  
  local omegaSheet = graphics.newImageSheet("assets/sprites/coins/omegacoin.png", sheetOptions)
  
  local spinSequence = {
    { 
  name = "spin",
  start = 1,
  count = 9,
  time = math.random(700,800),
  loopCount = 0,
  loopDirection = "forward"
    }
  }
  
  local coins = {}
  local coinsGrp = display.newGroup()
  
  local width = pegZones[1].rect.width
  
  local function generateGoldCoin(amount, zone)
    for i = 1,amount do
      if pegZones[zone] ~= nil then
        coins[#coins + 1] = display.newSprite(coinsGrp, goldSheet, spinSequence)
        coins[#coins].x = pegZones[zone].rect.x
        coins[#coins].y = pegZones[zone].rect.y
        coins[#coins]:scale(3,3)
        coins[#coins]:setSequence("spin")
        coins[#coins]:play()
      end
    end
  end
  
  local function generateOmegaCoin(amount, zone)
    for i = 1,amount do
      if pegZones[zone] ~= nil then
        coins[#coins + 1] = display.newSprite(coinsGrp, omegaSheet, spinSequence)
        coins[#coins].x = pegZones[zone].rect.x
        coins[#coins].y = pegZones[zone].rect.y
        coins[#coins]:scale(3,3)
        coins[#coins]:setSequence("spin")
        coins[#coins]:play()
      end
    end
  end
  
  for i = 1,#coinZones do
    if pegZones[i] == nil then
      return
    end
    if types[i] == 1 then
      
      generateGoldCoin(3, coinZones[i])
      coins[#coins]:translate(width/4, width/4)
      coins[#coins - 1]:translate(-width/4, -width/4)
      
    elseif types[i] == 2 then
      
      generateGoldCoin(3, coinZones[i])
      coins[#coins]:translate(-width/4, width/4)
      coins[#coins - 1]:translate(width/4, -width/4)
      
    elseif types[i] == 3 then
      
      generateGoldCoin(3, coinZones[i])
      coins[#coins]:translate(0, width/4)
      coins[#coins - 1]:translate(0, -width/4)
      
    elseif types[i] == 4 then
      
      generateGoldCoin(3, coinZones[i])
      coins[#coins]:translate(width/4, 0)
      coins[#coins - 1]:translate(-width/4, 0)
      
    elseif types[i] == 5 then
      
      generateGoldCoin(4, coinZones[i])
      coins[#coins]:translate(width/4, width/4)
      coins[#coins - 1]:translate(-width/4, -width/4)
      if coins[#coins - 2] ~= nil then
        coins[#coins - 2]:translate(-width/4, width/4)
      end
      if coins[#coins - 3] ~= nil then
        coins[#coins - 3]:translate(-width/4, width/4)
      end
      generateOmegaCoin(1, coinZones[i])
      coins[#coins].omega = true
      
    end
  end
  
  for i = 1,#coins do
    coins[i].objt = "coin"
    coins[i].hit = false
    py.addBody(coins[i], "static", {radius = 30, isSensor = true})
  end
  
  return coins, coinsGrp
  
end

return levelBuilder