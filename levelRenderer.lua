local pdata = require("gameData.playerData")
local py = require("physics")
local gi = require("gameData.gameInfo")

local levelRenderer = {}

local titleFont = "assets/fonts/DungeonFont.ttf"
local mainFont = "assets/fonts/EquipmentPro.ttf"

local frameSize = 64

function levelRenderer.launchEnemy(zone)
  local function launchObject(object, force, angle)
    py.start()
    py.addBody(object, "dynamic")
    
    local impulseX = force * math.cos(math.rad(angle))
    local impulseY = -force * math.sin(math.rad(angle))

    object:applyLinearImpulse(impulseX, impulseY, object.x, object.y)
    
    transition.to(object, {rotation = 360, time = 1000})
    
    local function removeObject()
      display.remove(object)
    end
    
    transition.to(object, {alpha = 0, time = 4000, onComplete = removeObject})
  end

  timer.performWithDelay(1, function()

    for i,v in pairs(pdata.currentGameInfo.enemies[zone].hit) do
      if v.x ~= nil then
        v.physics = true
        launchObject(v, math.random(250,750), math.random(-360,360))
      end
    end
    
    for i,v in pairs(pdata.currentGameInfo.enemies[zone].normal) do
      if v.x ~= nil then
        v.physics = true
        launchObject(v, math.random(250,750), math.random(-360,360))
      end
    end
  
  end)

end

function levelRenderer.hitEnemy(zone)
  for i,v in pairs(pdata.currentGameInfo.enemies[zone].hit) do
    if v.x ~= nil then
      local obj = v
      obj.alpha = 1
      transition.to(obj, {alpha = 0, time = 750})
    end
  end
end

function levelRenderer.moveObjectInOrbital(ship, cX, cY, stype, fullship)
  local angle = math.random(360)
  local radius = math.random(5,15)
  local speed = math.random(-10, 10)
  
  if stype == "boss" then
    speed = math.floor(speed/2)
  end
  
  local orbitX, orbitY = 0, 0
  local count = 0

  local function updateOrbitalPosition()
      local radians = math.rad(angle)
      orbitX = cX + math.cos(radians) * radius
      orbitY = cY + math.sin(radians) * radius
      
      for i,v in pairs(ship) do
        if v.x ~= nil then
          v.x, v.y = orbitX , orbitY
        end
      end
      
      for i,v in pairs(fullship.hit) do
        if v.x ~= nil then
          v.x, v.y = orbitX , orbitY
        end
      end
    
      if stype == "wide" then
        fullship.hit.left:translate(-frameSize,0)
        fullship.hit.right:translate(frameSize,0)
        ship.left:translate(-frameSize,0)
        ship.right:translate(frameSize,0)
      end
      
      if stype == "boss" then
        local moveDiff = frameSize*0.75*2
        fullship.hit.topRight:translate(moveDiff,0)
        fullship.hit.bottomLeft:translate(0,moveDiff)
        fullship.hit.bottomRight:translate(moveDiff,moveDiff)
        ship.topRight:translate(moveDiff,0)
        ship.bottomLeft:translate(0,moveDiff)
        ship.bottomRight:translate(moveDiff,moveDiff)
      end

      angle = angle + speed
  end

  local function changeOrbitalPath()
      radius = radius + math.random(-1,1)
      speed = speed + math.random(-1,1)
      if radius <= 0 then
        radius = 2
      end
      if speed <= 0 then
        speed = 2
      end
      if radius >= 20 then
        radius = 19
      end
      if speed >= 20 then
        speed = 19
      end
  end

  local function physicsCheck()
    for i,v in pairs(ship) do
      if v.physics then
        return false
      end
    end
    return true
  end

  local function onEnterFrame()
    if physicsCheck() then
      updateOrbitalPosition()
      count = count + 1
      if count % 100 == 0 then
        changeOrbitalPath()
      end
    end
  end

  Runtime:addEventListener("enterFrame", onEnterFrame)
end

function levelRenderer.animateEnemies(ships)
  
  for i = 1,ships.amount do
    for i,fullShip in pairs(ships) do
      if type(fullShip) ~= "number" then
        local ship = fullShip.normal
        levelRenderer.moveObjectInOrbital(ship, ship.center.x, ship.center.y, ship.type, fullShip)
      end
    end
  end
  
end

function levelRenderer.renderEnemies(endings, stype)

  if stype == nil then
    stype = {}
  end

  local dir = "assets/sprites/enemies/"

  local sheetOptions = {
    width = 64,
    height = 64,
    numFrames = 100
  }

  local enemySheet = graphics.newImageSheet(dir.."enemies"..math.random(1,2)..".png", sheetOptions)
  local hitSheet = graphics.newImageSheet(dir.."enemiesHit"..".png", sheetOptions)
  local blackShadowSheet = graphics.newImageSheet(dir.."enemiesBlack"..".png", sheetOptions)
  local whiteShadowSheet = graphics.newImageSheet(dir.."enemiesWhite"..".png", sheetOptions)

  local function moveShip(i, ship)
    for k,v in pairs(ship) do
      v.x, v.y  = endings[i]:localToContent( 0, 0 )
    end
  end
  
  local function cleanEdges(ship)
    for k,v in pairs(ship) do
      v.fill.effect = "filter.vignetteMask"
      v.fill.effect.innerRadius = math.random(0.7,0.9)
      v.fill.effect.outerRadius = math.random(0.2,0.1)
    end
  end
  
  local function getRandomShip(stype)
    
    local delta, theta
    
    if stype == "wide" then
      delta = math.random(0,4)*10
    end
    
    if stype == "small" then
      delta = math.random(1,4)*10
      theta = math.random(0,5)
    end
    
    if stype == "medium" then
      delta = math.random(5,6)*10
      theta = math.random(0,5)
    end
    
    if stype == "boss" then
      repeat
        delta = math.random(7,9)*10
      until delta ~= 80
      theta = math.random(0,2)*2
    end
    
    return delta, theta
  end
  
  local ships = {}

  for i = 1,#endings do
    ships[i] = {}
    
    local delta, theta = getRandomShip(stype[i])
    
    for round = 1,2 do
      local currentShip, sheet
      
      if round == 1 then
        ships[i].normal = {}
        currentShip = ships[i].normal
        sheet = enemySheet
      else
        ships[i].hit = {}
        currentShip = ships[i].hit
        sheet = hitSheet
      end
      
      if stype[i] == "wide" then
        currentShip.center = display.newImageRect(sheet, delta + 2, 100, 100)
        currentShip.left = display.newImageRect(sheet, delta + 1, 100, 100)
        currentShip.right = display.newImageRect(sheet, delta + 3, 100, 100)
        
        moveShip(i, currentShip)
        
        currentShip.left:translate(-frameSize,0)
        currentShip.right:translate(frameSize,0)
      end
      
      if stype[i] == "small" then
        currentShip.center = display.newImageRect(sheet, delta - theta, 100, 100)
        moveShip(i, currentShip)
      end
      
      if stype[i] == "medium" then
        currentShip.center = display.newImageRect(sheet, delta - theta, 64, 64)
        moveShip(i, currentShip)
      end
      
      if stype[i] == "boss" then
        currentShip.center = display.newImageRect(sheet, delta - theta - 1, 100, 100)
        currentShip.topRight = display.newImageRect(sheet, delta - theta, 100, 100)
        currentShip.bottomLeft = display.newImageRect(sheet, delta - theta + 9, 100, 100)
        currentShip.bottomRight = display.newImageRect(sheet, delta - theta + 10, 100, 100)
        
        moveShip(i, currentShip)
        
        local moveDiff = frameSize*0.75
        
        currentShip.center:translate(-moveDiff,-moveDiff)
        currentShip.topRight:translate(moveDiff,-moveDiff)
        currentShip.bottomLeft:translate(-moveDiff,moveDiff)
        currentShip.bottomRight:translate(moveDiff,moveDiff)  
      end
      
      cleanEdges(currentShip)
      currentShip.type = stype[i]
      
      if round == 2 then
        for i,v in pairs(currentShip) do
          if v.x ~= nil then
            v.alpha = 0
          end
        end
      end
    
    end
  end
  
  ships.amount = #endings
  levelRenderer.animateEnemies(ships)
  return ships
  
end

function levelRenderer.followBall(obj, ball)
  obj.x = ball.x
  obj.y = ball.y
  ball:toFront()
end

function levelRenderer.renderParticles(ball)
  
  local colors = gi.worldColors[pdata.currentMap.planet]
  
  local emitterParams = {
    startColorAlpha = 1,
    startParticleSizeVariance = 100,
    finishColorRed = 248/255,
    finishColorGreen = 52/255,
    finishColorBlue = 26/255,
    startColorRed = 255/255,
    startColorGreen = 203/255,
    startColorBlue = 1/255,
    yCoordFlipped = math.random(-1,1),
    blendFuncSource = 770,
    rotatePerSecondVariance = 100,
    particleLifespan = 0.75,
    blendFuncDestination = 1,
    startParticleSize = 55,
    textureFileName = "assets/sprites/smoke.png",
    startColorVarianceAlpha = 1,
    maxParticles = 100,
    finishParticleSize = 75,
    duration = -1,
    maxRadiusVariance = 75,
    finishParticleSizeVariance = 64,
    gravityy = -1000,
    speedVariance = 100,
    tangentialAccelVariance = -100,
    angleVariance = 360,
    angle = math.random(-360,360)
  }
 
  local emitter = display.newEmitter( emitterParams )
   
  emitter.x = ball.x
  emitter.y = ball.y
  ball:toFront()
  
  Runtime:addEventListener( "enterFrame", function() levelRenderer.followBall(emitter, ball) end)

  return emitter
  
end

function levelRenderer.generatePegOverlay(peg)
  if peg.pegType == "fire" then
    peg.pegImg = display.newImageRect("assets/sprites/pegDeathOutline.png", peg.radius*2, peg.radius*2)
  else
    peg.pegImg = display.newImageRect("assets/sprites/pegOutline.png", peg.radius*2, peg.radius*2)
  end
  peg.pegImg.x = peg.x
  peg.pegImg.y = peg.y
end

return levelRenderer