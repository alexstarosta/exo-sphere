local pdata = require("gameData.playerData")
local py = require("physics")
local sh = require("sceneHandler")
local tm = require("transitionMaker")
local pup = require("playerUpgrades")
local al = require("audioLoader")

local levelEvents = {}

function levelEvents.moveGameBall(ball, dropZones)

  local totalX = 0
  
  for i = 1,dropZones.count do
    totalX = dropZones[i].x + totalX
  end
  
  totalX = totalX/dropZones.count
  
  ball.x = totalX
  ball.y = ball.dropY
  
end

function levelEvents.resetGameBall()
  
  local ball = pdata.currentGameInfo.ball
  
  ball.bodyType = "static"
  ball.firstCollision = false
  ball.sleepCounter = 0
  ball.totalHits = 0
  ball.coinPotential = 0
  
  if math.random(1,100) <= pup.upgrades.revival then
    ball.lives = ball.lives + 1
  end
  ball.lives = ball.lives - 1
  
  if ball.lives < 0 then
    pdata.currentWorldInfo.scoreGui.scoreTxt.text = 0
  else
    pdata.currentWorldInfo.scoreGui.scoreTxt.text = ball.lives
  end
  
  for i = 1,#pdata.currentGameInfo.pegs do
    pdata.currentGameInfo.pegs[i].hit = false
    pdata.currentGameInfo.pegs[i].alpha = 1
  end
  
  for i = 1,#pdata.currentGameInfo.coins do
    pdata.currentGameInfo.coins[i].hit = false
    pdata.currentGameInfo.coins[i].alpha = 1
  end
  
  if ball.lives >= 0 then
    ball.x = ball.lastX
    ball.y = ball.lastY
    ball.active = false
  else
    ball.tap = nil
    transition.to(ball, {alpha = 0, delay = 500, time = 2500})
    pdata.currentWorldInfo.transitioning = true
    timer.performWithDelay(500, function()
      audio.play(al.sfx["levellose"], {channel = 2})
      local transitionDuration = 3000
      tm.levelToMenu(0, false, false, transitionDuration)
      timer.performWithDelay(transitionDuration, function()
        sh.moveToMenu(pdata.currentGameInfo.currentLevelX, pdata.currentGameInfo.currentLevelY, false, false)
      end)
    end)
    
    py.stop()
    
    for zone = 1,3 do
      if pdata.currentGameInfo.enemies[zone] ~= nil then
        for i,v in pairs(pdata.currentGameInfo.enemies[zone].hit) do
          if v.x ~= nil then
            local function removeObject()
              display.remove(v)
            end
            v.physics = true
            transition.to(v, {alpha = 0, time = 2000, onComplete = removeObject})
          end
        end
        
        for i,v in pairs(pdata.currentGameInfo.enemies[zone].normal) do
          if v.x ~= nil then
            local function removeObject()
              display.remove(v)
            end
            v.physics = true
            transition.to(v, {alpha = 0, time = 2000, onComplete = removeObject})
          end
        end
      end
    end
  end
  
  ball.firstCollision = false
  
end

function levelEvents.setStartArea(ball, dropZones)
  
  local left = screenWidth
  local right = -screenWidth
  local width = 0
  local yVal = 0

  for i = 1,dropZones.count do
    if dropZones[i].x < left then
      left = dropZones[i].x
    end
    if dropZones[i].x > right then
      right = dropZones[i].x
    end
    width = dropZones[i].width
    yVal = dropZones[i].y
  end
  
  ball.rightStop = right + width/2
  ball.leftStop = left - width/2
  ball.dropAreaWidth = width
  ball.dropY = yVal
  
end

function levelEvents.addBallEvents(ball, dropZone)
  
  levelEvents.setStartArea(ball, dropZone)
  
  local startX, startY = 0, 0
  ball.lastX = 0
  ball.lastY = 0
  local isDragging = false
  
  local function onTouch(event)
    
    if ball.active or ball.justReset then
      return
    end
    
    if (event.phase == "began") then
      startX, startY = event.x, event.y
      ball.lastX, ball.lastY = ball.x, ball.y
      isDragging = true
      display.getCurrentStage():setFocus(event.target)
    elseif (event.phase == "moved") then
      
      local deltaX = event.x - startX
      local deltaY = event.y - startY
      local newX = ball.lastX + deltaX
      local newY = ball.lastY + deltaY
      
      local height = ball.dropAreaWidth*0.75/2
      
      if newY < ball.dropY - height + ball.radius then
        newY = ball.dropY - height + ball.radius
      elseif newY > ball.dropY + height - ball.radius then
        newY = ball.dropY + height - ball.radius
      end
      
      if newX > ball.rightStop - ball.radius then
        newX = ball.rightStop - ball.radius
      elseif newX < ball.leftStop + ball.radius then
        newX = ball.leftStop + ball.radius
      end
      
      ball.x = newX
      ball.y = newY
      
    elseif (event.phase == "ended" or event.phase == "cancelled") then
      isDragging = false
      display.getCurrentStage():setFocus(nil)
    end
    return true
  end
    
  ball:addEventListener("touch", onTouch)
  
end

function levelEvents.getZoneRestrictions(zone, pegZones)
  
  local id = zone.areaNum
  local rect = zone.rect
  local pzones = pegZones
  
  local function checkNear(num)
    for i = 1,#pzones do
      if num == pzones[i].areaNum then
        return true
      end
    end
    return false
  end

  if id <= 3 or (id >= 4 and not checkNear(id-3)) then
    zone.top = rect.y - rect.width/2
  end
  
  if id >= 7 or (id <= 6 and not checkNear(id+3)) then
    zone.bottom = rect.y + rect.width/2
  end
  
  if (id - 1) % 3 == 0 or ((id - 1) % 3 ~= 0 and not checkNear(id-1)) then
    zone.left = rect.x - rect.width/2
  end
  
  if id % 3 == 0 or (id % 3 ~= 0 and not checkNear(id+1)) then
    zone.right = rect.x + rect.width/2
  end
  
end

function levelEvents.addPegEvents(pegs, pegZones)
  
  for i = 1,#pegZones do
    levelEvents.getZoneRestrictions(pegZones[i], pegZones)
  end
  
  local width = pegZones[1].rect.width
  local pzones = pegZones
  
  local function findZone(x, y, width)
    local zone = 0
    
    if y > centerY + width/2 then
      zone = zone + 6
    elseif y > centerY - width/2 then
      zone = zone + 3
    end
    
    if x < centerX - width/2 then
      zone = zone + 1
    elseif x > centerX + width/2 then
      zone = zone + 3
    else
      zone = zone + 2
    end
    
    return zone
  end
  
  local startX, startY = 0, 0
  local lastX, lastY = 0, 0
  local isDragging = false
  local oldZone
  
  local function pegTouch(self, event)
    
    if pdata.currentGameInfo.ball.active then
      return
    end
    
    if (event.phase == "began") then
      startX, startY = event.x, event.y
      lastX, lastY = self.x, self.y
      self.isDragging = true
      oldZone = findZone(self.x,self.y,width)
      self:toFront()
      display.getCurrentStage():setFocus(self)
    elseif (event.phase == "moved") and self.isDragging then
      
      local deltaX = event.x - startX
      local deltaY = event.y - startY
      local newX = lastX + deltaX
      local newY = lastY + deltaY
      
      local zone = findZone(self.x,self.y,width)
      if zone ~= nil then
        for i = 1,#pzones do
          if zone == pzones[i].areaNum then
            zone = pzones[i]
          end
        end
      else
        zone = oldZone
      end
      local radius = self.radius
      
      if type(zone) == "number" then
        newX, newY = lastX, lastY
        self.x = newX
        self.y = newY
        self.pegImg.x = newX
        self.pegImg.y = newY
        self.isDragging = false
        return true
      else
      
        if zone.bottom ~= nil then
          if newY > zone.bottom - radius then
            newY = zone.bottom - radius
          end
        end
        
        if zone.top ~= nil then
          if newY < zone.top + radius then
            newY = zone.top + radius
          end
        end
        
        if zone.left ~= nil then
          if newX < zone.left + radius then
            newX = zone.left + radius
          end
        end
        
        if zone.right ~= nil then
          if newX > zone.right - radius then
            newX = zone.right - radius
          end
        end
      end
      
      self.x = newX
      self.y = newY
      self.pegImg.x = newX
      self.pegImg.y = newY
      
    elseif (event.phase == "ended" or event.phase == "cancelled") then
      
      local function isWithinRadius(x, y, objs, pradius, obj)
        if #objs == 0 then
          return false
        end
        
        for i = 1,#objs do
          
          if objs[i].id ~= obj.id then
            local distance = math.sqrt((objs[i].x - x)^2 + (objs[i].y - y)^2)
            if distance < pradius*2 then
              return true, objs[i].x, objs[i].y, distance
            end
          end
        end
        
        return false
      end
      
      local function angleBetweenPoints(x1, y1, x2, y2)
        local dx = x2 - x1
        local dy = y2 - y1
        local angle = math.atan2(dy, dx)
        return math.deg(angle)
      end
      
      local function convertToXAxis(angle)
        local relativeAngle = 90 - angle
        if relativeAngle < 0 then
          relativeAngle = relativeAngle + 360
        end
        return relativeAngle
      end
      
      local function moveObjInAngle(obj, angle, length, targetDistance)
        local angleRadians = math.rad(angle)
        local directionX = math.cos(angleRadians)
        local directionY = math.sin(angleRadians)
        
        directionX = directionX * (targetDistance - length)
        directionY = directionY * (targetDistance - length)
        
        local obj1X, obj1Y = obj.x, obj.y
        local obj2X = obj1X - directionX
        local obj2Y = obj1Y - directionY
        
        obj.x = obj2X
        obj.y = obj2Y
      end
      
      local function wallCheck()
        local zone = findZone(self.x,self.y,width)
        
        if zone ~= nil then
          for i = 1,#pzones do
            if zone == pzones[i].areaNum then
              zone = pzones[i]
            end
          end
          if type(zone) == "number" then
            zone = oldZone
            for i = 1,#pzones do
              if zone == pzones[i].areaNum then
                zone = pzones[i]
              end
            end
          end
        end
        
        local radius = self.radius
        
        if zone ~= nil then
          if zone.bottom ~= nil then
            if self.y > zone.bottom - radius then
              self.y = zone.bottom - radius
            end
          end
          
          if zone.top ~= nil then
            if self.y < zone.top + radius then
              self.y = zone.top + radius
            end
          end
          
          if zone.left ~= nil then
            if self.x < zone.left + radius then
              self.x = zone.left + radius
            end
          end
          
          if zone.right ~= nil then
            if self.x > zone.right - radius then
              self.x = zone.right - radius
            end
          end
          
          self.pegImg.x = self.x
          self.pegImg.y = self.y
          
        end
      end
      
      local finalCheck = true
      local finalCounter = 0
      
      repeat
        local check, ox, oy, diff = isWithinRadius(self.x, self.y, pegs, self.radius, self)
        
        if check then
          local angle = angleBetweenPoints(self.x, self.y, ox, oy)
          moveObjInAngle(self, angle, diff, self.radius*2)
        end
        
        wallCheck()
        
        finalCheck = isWithinRadius(self.x, self.y, pegs, self.radius - 1, self)
        finalCounter = finalCounter + 1
        
        if finalCounter > 25 then
          self.x = lastX
          self.y = lastY
          self.pegImg.x = self.x
          self.pegImg.y = self.y
          finalCheck = false
        end
        
      until not finalCheck 
      
      self.isDragging = false
      display.getCurrentStage():setFocus(nil)
    end
    return true
  end
  
  for i = 1,#pegs do
    if pegs[i].pegType == "normal" or pegs[i].pegType == "bouncy" then
      pegs[i].touch = pegTouch
      pegs[i]:addEventListener("touch", pegs[i])
    end
  end
  
end

function levelEvents.removeBodies(objs)

  if type(objs) == "table" then
    for i = 1,#objs do
      if objs[i].x ~= nil then
        py.removeBody(objs[i])
      end
    end
  else
    py.removeBody(objs)
  end
end

function levelEvents.removePegImg(pegs)
  for i = 1,#pegs do
    pegs[i].pegImg:removeSelf()
  end
end

function levelEvents.checkBallMovement(ball)
  
  local vx, vy = ball:getLinearVelocity()

  ball.angularVelocity = ball.angularVelocity*0.98

  if math.abs(vx) * math.abs(vy) <= 0.000001 and ball.firstCollision then
    ball.sleepCounter = ball.sleepCounter + 1
  end
  
  if ball.sleepCounter == 30 and ball.firstCollision then
    ball.sleepCounter = 0
    ball.firstCollision = false
    ball.angularVelocity = 0
    timer.performWithDelay(1, function()
      levelEvents.resetGameBall()
    end)
  end
  
end

return levelEvents