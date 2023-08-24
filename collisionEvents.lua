local lvle = require("levelEvents")
local pdata = require("gameData.playerData")
local lvlb = require("gameGeneration.levelBuilder")
local lvlr = require("levelRenderer")
local gio = require("gameio")
local py = require("physics")
local sh = require("sceneHandler")
local tm = require("transitionMaker")
local pup = require("playerUpgrades")
local al = require("audioLoader")

local collisionEvents = {}

function collisionEvents.ballDeathWall(ball, other)
  
  ball.isAwake = false
  
  timer.performWithDelay(1, function()
    audio.play(al.sfx["broke"], {channel = 2})
    lvle.resetGameBall()
    ball.bodyType = "static"
  end)
  
end

function collisionEvents.ballWall(ball, other)
  
  ball.firstCollision = true
  audio.play(al.sfx["peghit"], {channel = 2})
  
end

function collisionEvents.ballFireWall(ball, other)
  
  ball.isAwake = false
  
  timer.performWithDelay(1, function()
    lvle.resetGameBall()
    ball.bodyType = "static"
    audio.play(al.sfx["burnt"], {channel = 2})
  end)
  
end

function collisionEvents.ballPeg(ball, other)

  if not other.hit then
    other.hit = true
    other.alpha = 0.5
    ball.totalHits = ball.totalHits + 1
  end

  if other.pegType == "fire" then
    ball.isAwake = false
    
    timer.performWithDelay(1, function()
      lvle.resetGameBall()
      ball.bodyType = "static"
      audio.play(al.sfx["burnt"], {channel = 2})
    end)
  else
    ball.firstCollision = true
    audio.play(al.sfx["peghit"], {channel = 2})
  end
  
end

function collisionEvents.ballFinish(ball, other)
  
  ball.isAwake = false
  
  local function checkComplete()
    for i = 1, #pdata.currentGameInfo.endings do
      if pdata.currentGameInfo.endings[i].hitsRequired ~= 0 then
        return false
      end
    end
    return true
  end
  
  if ball.totalHits == pdata.currentGameInfo.pegs.required then
    other.hitsRequired = other.hitsRequired - 1
    audio.play(al.sfx["shiphit"..math.random(1,2)], {channel = 2})
    lvlr.hitEnemy(other.zone)
    if other.hitsRequired == 0 then
      other.alpha = 0
      timer.performWithDelay(1, function()
        py.removeBody(other)
      lvlr.launchEnemy(other.zone)
      end)
    else
      timer.performWithDelay(1, function()
          
        local amount = pdata.currentGameInfo.pegsGrp.numChildren
        pdata.currentGameInfo.pegsGrp:removeSelf()
        pdata.currentGameInfo.pegs = nil
        
        local rand = math.random(1, pdata.currentGameInfo.pegZones.count)
        pdata.currentGameInfo.pegZones[rand].rect:removeSelf()
        table.remove(pdata.currentGameInfo.pegZones, rand)
        pdata.currentGameInfo.pegZones.count = pdata.currentGameInfo.pegZones.count - 1
        
        local pegs, pegGroup = lvlb.generatePegs(amount + 1, pdata.currentGameInfo.pegZones, 40)
        lvle.addPegEvents(pegs, pdata.currentGameInfo.pegZones)
      end)
    end
  end
  
  if other.hitsRequired == 0 then
    if checkComplete() then
      ball.firstCollision = false
      timer.performWithDelay(1, function()
        local mastered
        mastered = ball.lives == ball.startLives
        local potential
        
        if math.random(1,100) <= pup.upgrades.mastery then
          mastered = true
        end
        
        if mastered then
          potential = ball.coinPotential*2
          pdata.gold = pdata.gold + potential
          potential = ball.coinPotential.." * 2"
        else
          potential = ball.coinPotential
          pdata.gold = pdata.gold + potential
        end
        
        pdata.currentWorldInfo.transitioning = true
        transition.to(ball, {alpha = 0, delay = 500, time = 2500})
        timer.performWithDelay(500, function()
          if mastered then
            audio.play(al.sfx["mastered"], {channel = 2})
          else
            audio.play(al.sfx["levelwin"], {channel = 2})
          end
          local transitionDuration = 3000
          tm.levelToMenu(potential, true, mastered, transitionDuration)
          timer.performWithDelay(transitionDuration, function()
            sh.moveToMenu(pdata.currentGameInfo.currentLevelX, pdata.currentGameInfo.currentLevelY, mastered, true)
          end)
        end)
        
        py.stop()
      end)
    else
      timer.performWithDelay(1, function()
        lvle.resetGameBall()
        ball.bodyType = "static"
      end)
    end
  else
    timer.performWithDelay(1, function()
      lvle.resetGameBall()
      ball.bodyType = "static"
    end)
  end
  
end

function collisionEvents.ballCoin(ball, coin)
  if not coin.hit then
    audio.play(al.sfx["coin"], {channel = 2})
    coin.hit = true
    if coin.omega then
      ball.coinPotential = ball.coinPotential + 5
      if math.random(1,100) <= pup.upgrades.coins then
        ball.coinPotential = ball.coinPotential + 5
      end
    else
      ball.coinPotential = ball.coinPotential + 1
      if math.random(1,100) <= pup.upgrades.coins then
        ball.coinPotential = ball.coinPotential + 1
      end
    end
    coin.alpha = 0
  end
end
  

function collisionEvents.handleCollision(self, event)
  local other = event.other.objt
  local phase = event.phase
  
  if other == "deathwall" and phase == "ended" then
    collisionEvents.ballDeathWall(self, event.other)
  end
  
  if other == "coin" and phase == "began" then
    collisionEvents.ballCoin(self, event.other)
  end
  
  if other == "wall" then
    if phase == "began" then
      local collisionTorque = 5
      local angle = math.atan2(event.other.y - self.y, event.other.x - self.x)
      local degrees = math.deg(angle)
      if self.x < event.other.x then
        degrees = -degrees
      end
      self.angularVelocity = collisionTorque * degrees
    elseif phase == "ended" then
    collisionEvents.ballWall(self, event.other)
    end
  end
  
  if other == "firewall" and phase == "ended" then
    collisionEvents.ballFireWall(self, event.other)
  end
  
  if other == "peg" then
    if phase == "began" then
      local collisionTorque = 5
      if event.other.pegType == "bouncy" then
        collisionTorque = collisionTorque*2
      end
      local angle = math.atan2(event.other.y - self.y, event.other.x - self.x)
      local degrees = math.deg(angle)
      if self.x < event.other.x then
        degrees = -degrees
      end
      self.angularVelocity = collisionTorque * degrees
    elseif phase == "ended" then
      collisionEvents.ballPeg(self, event.other, event)
    end
  end
  
  if other == "ending" and phase == "ended" then
    collisionEvents.ballFinish(self, event.other)
  end
  
end

return collisionEvents