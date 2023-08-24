local gio = require("gameio")
local settings = require("gameSettings")
local ge = require("gameEvents")
local gdata = require("gameData.gameData")
local gb = require("gameGeneration.guiBuilder")
local tm = require("transitionMaker")
local sh = require("sceneHandler")
local pdata = require("gameData.playerData")

local worldBuilder = {}

local titleFont = "assets/fonts/DungeonFont.ttf"
local transitioning = false

function worldBuilder.createMap(radius, planet)
  
  local diameter = 2 * radius
  local map = {}
  map.radius = radius
  map.planet = planet
  map.tiles = {}
  map.tileAmount = 0
  
  local function calculateDistance(x,y)
    local dx = x - radius
    local dy = y - radius
    return math.sqrt(dx*dx + dy*dy)
  end
  
  local function getDifficulty(distance)
    
    local adjustmentFactor = math.random()/100
    local easyProb = 1/math.abs(distance - 1 + adjustmentFactor)
    local mediumProb = 1/math.abs(distance - ((1+radius)/2) + adjustmentFactor)
    local hardProb = 1/math.abs(distance - radius + adjustmentFactor)
    
    local totalProb = easyProb + mediumProb + hardProb
    easyProb = easyProb / totalProb
    mediumProb = mediumProb / totalProb
    hardProb = hardProb / totalProb
    
    local rand = math.random()
    if rand < easyProb then
      return 1
    elseif rand < easyProb + mediumProb then
      return 2
    else
      if math.floor(rand * 1000) % 10 == 0 and distance > radius then
        return 4
      end
      return 3
    end
    
  end
  
  local function setTileValue(x,y)
    
    if x == y and x == radius then
      return "H"
    end
    
    if math.random(1,radius*5) == radius and calculateDistance(x,y) > 2 then
      return 5
    end
    
    return getDifficulty(calculateDistance(x,y))
    
  end
  
  for y = 0, diameter do
    map.tiles[y] = {}
    for x = 0, diameter do
      local distance = math.sqrt((x - radius) ^ 2 + (y - radius) ^ 2)
      if distance <= radius + 0.5 then
        map.tiles[y][x] = {tileValue = setTileValue(x,y)}
        map.tileAmount = map.tileAmount + 1
      else
        map.tiles[y][x] = {tileValue = " "}
      end
    end
  end
  
  return map
end

function worldBuilder.showMap(map)
  local rad = map.radius
  for y = 0, rad*2 do
    local line = ""
    for x = 0, rad*2 do
      line = line..map.tiles[y][x].tileValue
    end
  end
end

function worldBuilder.addMapEvents(map)
  for y = 0,#map.tiles do
    for x = 0,#map.tiles[y] do
      if map.tiles[y][x].tileValue ~= " " then
        
        local hitarea = map.tiles[y][x].img
        
        hitarea.tap = ge.showLevelInfo
        hitarea.xPos = x
        hitarea.yPos = y
        hitarea:addEventListener("tap", hitarea)
        
      end
    end
  end
end

function worldBuilder.renderMap(map, planet, size)

  local dirPath = "assets/tiles/"..planet.."Tiles"
  local contents = gio.getDir(dirPath)
  local spacing = 25
  
  map.planet = planet
  
  local function calculateX(x)
    local distance = x - map.radius
    local position = distance * (spacing + size)
    return centerX + position
  end
  
  local function calculateY(y)
    local distance = y - map.radius
    local position = distance * (spacing + size)*0.75
    return centerY + position
  end
  
  map.tileGroup = display.newGroup()
  map.tileGroup.anchorChildren = true
  map.tileGroup.x = centerX
  map.tileGroup.y = centerY
  
  for y = 0,#map.tiles do
    for x = 0,#map.tiles[y] do
      if map.tiles[y][x].tileValue ~= " " then
        
        local tileValue = map.tiles[y][x].tileValue
        
        map.tiles[y][x].completedTile = display.newImageRect(map.tileGroup, "assets/tiles/completedTiles/completed"..map.planet.."Tile.png", size, size)
        map.tiles[y][x].completedTile.x = calculateX(x)
        map.tiles[y][x].completedTile.y = calculateY(y)
        map.tiles[y][x].completedTile.alpha = 0
        
        map.tiles[y][x].masteredTile = display.newImageRect(map.tileGroup, "assets/tiles/completedTiles/masteredTile.png", size, size)
        map.tiles[y][x].masteredTile.x = calculateX(x)
        map.tiles[y][x].masteredTile.y = calculateY(y)
        map.tiles[y][x].masteredTile.alpha = 0
        
        map.tiles[y][x].highlightTile = display.newImageRect(map.tileGroup, "assets/tiles/blankTile.png", size+10, size+10)
        map.tiles[y][x].highlightTile.x = calculateX(x)
        map.tiles[y][x].highlightTile.y = calculateY(y)
        map.tiles[y][x].highlightTile.alpha = 0
            
      end
    end
  end
  
  map.tapRect = display.newRect(centerX, centerY, screenWidth, screenHeight)
  map.tapRect.alpha = 0.01
  
  for y = 0,#map.tiles do
    for x = 0,#map.tiles[y] do
      if map.tiles[y][x].tileValue ~= " " then
        
        local tileValue = map.tiles[y][x].tileValue
        
        if map.tiles[y][x].tileValue == "H" then
          tileValue = 1
        end
        
        map.tiles[y][x].img = display.newImageRect( map.tileGroup, contents[tileValue].."/var"..math.random(1, #gio.getDir(contents[tileValue]))..".png", size, size)
        
        map.tiles[y][x].img.fill.effect = "filter.desaturate"
        map.tiles[y][x].img.fill.effect.intensity = 1
        
        map.tiles[y][x].img.alpha = 0.2
        
        map.tiles[y][x].img.x = calculateX(x)
        map.tiles[y][x].img.y = calculateY(y)
      end
      
    end
  end
  
  return map.tileGroup
  
end

function worldBuilder.renderBackground(map)
  
  local dir = "assets/backgrounds/"..map.planet
  
  local backgroundTable = {}
  local bgGroup = display.newGroup()
  --bgGroup.anchorChildren = true
  bgGroup.x = 0
  bgGroup.y = centerY
  
  local function align(object)
    object.x = screenWidth
    object.y = centerY
    object.anchorX = 1
  end
  
  local function secondaryAlign(object)
    object.x = screenWidth - object.width
    object.y = centerY
    object.anchorX = 1
  end
  
  local function createLayers()
    
    local returnedDir = gio.getDir(dir)
    
    for i = 1, #returnedDir do
      local name = gio.pathToName(returnedDir[i])
      backgroundTable[name] = {}
      
      backgroundTable[name][1] = display.newImageRect(bgGroup, gio.getDir(dir)[i], screenHeight*2, screenHeight)
      backgroundTable[name][2] = display.newImageRect(bgGroup, gio.getDir(dir)[i], screenHeight*2, screenHeight)
      align(backgroundTable[name][1])
      secondaryAlign(backgroundTable[name][2])
    end
    
    if backgroundTable.planets ~= nil then
      backgroundTable.planets[1]:toFront()
      backgroundTable.planets[2]:toFront()
    end
    
  end
  
  createLayers()
  
  local overlayRect = display.newRect(bgGroup, centerX, centerY, screenWidth, screenHeight)
  overlayRect.fill = {0}
  overlayRect.alpha = 0.75
  overlayRect:toFront()
  
  bgGroup:translate(0,-screenHeight/2)
  bgGroup:toBack()
  
  return backgroundTable, bgGroup
  
end

function worldBuilder.generateReturn(x, y, w, h, map)
  
  local grp = display.newGroup()
  
  local function returnHome()
    if pdata.currentWorldInfo.transitioning then 
      return
    end
    
    local function delete()
      grp:removeSelf()
    end
    
    transition.to(grp, {alpha = 0, time = 1100, onComplete = delete})
    transition.to(pdata.currentWorldInfo.coinGuiGrp, {alpha = 0, time = 1000})
    transition.to(pdata.currentWorldInfo.scoreGuiGrp, {alpha = 0, time = 1000})
    pdata.currentWorldInfo.bgCreated = false
    pdata.currentWorldInfo.transitioning = true
    ge.closeLevelInfo()
    local transitionDuration = 3000
    tm.menuToHome(transitionDuration)
    timer.performWithDelay(transitionDuration, function()
      sh.moveToHome()
      pdata.currentWorldInfo.bgGrp:removeSelf()
    end)
  end
  
  local box, boxGrp = gb.newMenuBox(x, y, w, h, map.planet.."Gui.png")
  grp:insert(boxGrp)
  local icon = display.newImageRect(grp, "assets/sprites/rearrow.png", 100, 100)
  icon.x = x
  icon.y = y
  gdata.overlays.returnGrp = grp
  
  grp.tap = returnHome
  grp:addEventListener("tap", grp)
  
  return grp
end

function worldBuilder.followImg(obj, img, grp)
  obj.x = img.x
  obj.y = img.y
  if grp.isDragging then
    obj:stop()
  elseif obj.state == "stopped" and not grp.isDragging then
    obj:start()
  end
end

function worldBuilder.masteredParticles(x, y, img, map)
  
  local emitterParams = {
      startColorAlpha = 1,
      finishColorRed = 255/255,
      finishColorGreen = 233/255,
      finishColorBlue = 0/255,
      startColorRed = 255/255,
      startColorGreen = 249/255,
      startColorBlue = 170/255,
      emitterType = 1,
      duration = -1,
      maxRadius = 60,
      minRadius	= 50,
      minRadiusVariance = 10,
      rotatePerSecond = 30,
      rotatePerSecondVariance = 10,
      particleLifespan = 1,
      particleLifespanVariance = 1,
      startParticleSize = 25,
      startParticleSizeVariance = 10,
      finishParticleSize = 25,
      finishParticleSizeVariance = 10,
      rotationStart = 10,
      rotationStartVariance = 10,
      rotationEnd = 10,
      rotationEndVariance = 10,
      angle	= 0,
      angleVariance = 360,
      textureFileName = "assets/sprites/sparkle.png",
      maxParticles = 20,
      blendFuncSource = 770,
      blendFuncDestination = 1,
    }
   
    local emitter = display.newEmitter( emitterParams )
    emitter.x = x
    emitter.y = y
    map.tileGroup:insert(emitter)
    emitter:toBack()
    
    Runtime:addEventListener( "enterFrame", function() worldBuilder.followImg(emitter, img, map.tileGroup) end)
    
    return emitter
    
end

function worldBuilder.showCompleted(map)
  local completed = 0
  for y = 0,#map.tiles do
    for x = 0,#map.tiles[y] do
      if map.tiles[y][x].tileValue ~= " " then
        
        if map.tiles[y][x].info.cleared then
          map.tiles[y][x].img.alpha = 1
          map.tiles[y][x].img.fill.effect.intensity = 0
          map.tiles[y][x].completedTile.alpha = 1
          completed = completed + 1
          if map.tiles[y][x].info.mastered then
            map.tiles[y][x].emitter = worldBuilder.masteredParticles(map.tiles[y][x].img.x,map.tiles[y][x].img.y,map.tiles[y][x].img, map)
            map.tiles[y][x].masteredTile.alpha = 1
          end
        else
        
          local completedAround = 0
          
          for xv = -1,1 do
            for yv = -1,1 do
              
              if y + yv >= 0 and x + xv >= 0 and y + yv <= map.radius*2 and x + xv <= map.radius*2 then
                if yv + xv ~= 2 and yv + xv ~= 0 and yv + xv ~= -2 then
                  if map.tiles[y + yv][x + xv].info ~= nil then
                    if map.tiles[y + yv][x + xv].info.cleared then
                      completedAround = completedAround + 1
                    end
                  end
                end
              end
              
            end
          end
          if completedAround > 0 then 
            map.tiles[y][x].info.nearbyCleared = true
            map.tiles[y][x].img.alpha = 1
            map.tiles[y][x].img.fill.effect.intensity = 0.5
          end
          
        end
        
      end
    end
  end
  return completed
end

function worldBuilder.animateBackground(map, layers)
  
  local dir = "assets/backgrounds/"..map.planet
  local returnedDir = gio.getDir(dir)
  local backgroundTable = layers
  
  for i = 1, #returnedDir do
    local name = gio.pathToName(returnedDir[i])
    local timing = 1/settings.backgroundSpeeds[name] * 100000
    
    transition.to(backgroundTable[name][1], {time = timing, x = backgroundTable[name][1].x + backgroundTable[name][1].width, iterations = -1})
    transition.to(backgroundTable[name][2], {time = timing, x = backgroundTable[name][2].x + backgroundTable[name][2].width, iterations = -1})
  end
  
end

function worldBuilder.animateTiles(map)
  
  local function continuousEasing(obj, easing1, easing2, time, ymove)
    transition.to(obj, {time = time/2, y = obj.y + ymove, transition = easing1, onComplete = function() 
        transition.to(obj, {time = time/2, y = obj.y - ymove, transition = easing2})
      end})
    timer.performWithDelay(time, function()
      transition.to(obj, {time = time/2, y = obj.y + ymove, transition = easing1, onComplete = function() 
        transition.to(obj, {time = time/2, y = obj.y - ymove, transition = easing2})
      end})
    end, -1)
  end
  
  for y = 0,#map.tiles do
    for x = 0,#map.tiles[y] do
      if map.tiles[y][x].tileValue ~= " " then
        local randOffset = math.random(1,2000)
        local time = 4000 + randOffset
        local pos = 20
        local upDown = 0
        continuousEasing(map.tiles[y][x].img, easing.inOutQuad, easing.inOutQuad, time, pos)
        continuousEasing(map.tiles[y][x].completedTile, easing.inOutQuad, easing.inOutQuad, time, pos)
        continuousEasing(map.tiles[y][x].masteredTile, easing.inOutQuad, easing.inOutQuad, time, pos)
        continuousEasing(map.tiles[y][x].highlightTile, easing.inOutQuad, easing.inOutQuad, time, pos)
      end
    end
  end

end

return worldBuilder