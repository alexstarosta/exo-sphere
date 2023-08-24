local composer = require("composer")
local py = require("physics")
local lvlb = require("gameGeneration.levelBuilder")
local lvle = require("levelEvents")
local lvlr = require("levelRenderer")
local ce = require("collisionEvents")
local pdata = require("gameData.playerData")
local tm = require("transitionMaker")
local al = require("audioLoader")

local scene = composer.newScene()

local ball, emitter
local pegZones, pegZonesGrp 
local wallZones, wallZonesGrp 
local dropZones, dropZonesGrp 
local endZones, endZonesGrp
local pegs, pegGroup
local endings, endingsGrp
local coins, coinsGrp

function scene:create( event )

  local sceneGroup = self.view
  
  audio.stop()
  audio.setVolume( 0.25, { channel=1 } )
  audio.play(al.bgm[pdata.currentMap.planet.."Level"], {channel = 1, loops = -1, fadein = 5000} )
  
  py.start()
  py.setTimeScale( 1.5 )
  local params = event.params
  
  -- switch to show lives
  
  pdata.currentWorldInfo.scoreGui.switchToLives(tostring(params.lives))
  
  -- generate ball
  
  ball = lvlb.generateBall(centerX, centerY, 60, 0.5, params.lives)
  
  -- zones
  
  pegZones, pegZonesGrp = lvlb.createPegZones(params.pegZones)
  wallZones, wallZonesGrp = lvlb.createWallZones(params.wallZones, params.wallZonesPos)
  dropZones, dropZonesGrp = lvlb.createDropZones(screenTop + screenHeight*0.05, params.dropZones)
  endZones, endZonesGrp = lvlb.createEndZones(screenBottom - screenHeight*0.05, params.endZones)
  
  pdata.currentGameInfo.currentLevelX = params.levelX
  pdata.currentGameInfo.currentLevelY = params.levelY
  pdata.currentGameInfo.ball = ball
  pdata.currentGameInfo.dropZones = dropZones
  pdata.currentGameInfo.pegZones = pegZones
  pdata.currentGameInfo.endZones = endZones
  pdata.currentGameInfo.wallZones = wallZones
  
  ball.dropZones = dropZones

  lvlb.createWalls(params.walls)
  
  -- creating pegs
  
  pegs, pegGroup = lvlb.generatePegs(params.pegAmount, pegZones, 40, params.forcedPegZones, params.forcedPegTypes)
  
  -- creating ending zones
  
  endings, endingsGrp = lvlb.generateEnd(params.difficulties, params.hitsRequired, endZones)
  pdata.currentGameInfo.endings = endings
  
  local enemies = lvlr.renderEnemies(endings, params.enemyTypes)
  pdata.currentGameInfo.enemies = enemies
  
  -- creating coins
  
  coins, coinsGrp = lvlb.createCoinZones(params.coinZones, params.coinZoneTypes, pegZones)
  
  pdata.currentGameInfo.coins = coins
  
  -- loading events
  
  lvle.addBallEvents(ball, dropZones)
  lvle.moveGameBall(ball, dropZones)
  lvle.addPegEvents(pegs, pegZones)
  
  -- inserting into scene
  
  sceneGroup:insert(endingsGrp)
  sceneGroup:insert(dropZonesGrp)
  sceneGroup:insert(pegZonesGrp)
  sceneGroup:insert(endZonesGrp)
  sceneGroup:insert(coinsGrp)
  
  if wallZonesGrp ~= nil then
    sceneGroup:insert(wallZonesGrp)
  end
  
  tm.currentGrp:toFront()

end

function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
  
    transition.to (tm.currentGrp, {alpha = 0, time = 1000, onComplete = function()
      tm.removeTransition()
    end})
    pdata.currentWorldInfo.transitioning = false
  
  elseif ( phase == "did" ) then
    -- Code here runs when the scene is entirely on screen
    
  ball.collision = ce.handleCollision
  ball:addEventListener("collision", ball)
  emitter = lvlr.renderParticles(ball)
  
  local function checkBallVel()
    if ball.firstCollision then
      lvle.checkBallMovement(ball)
    end
  end
  
  Runtime:addEventListener("enterFrame", checkBallVel)

  end
end

function scene:hide( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is on screen (but is about to go off screen)

  elseif ( phase == "did" ) then
    -- Code here runs immediately after the scene goes entirely off screen

  end
end

function scene:destroy( event )

  local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
  
  lvle.removePegImg(pegs)
  
  sceneGroup:insert(emitter)
  sceneGroup:insert(pdata.currentGameInfo.pegsGrp)
  sceneGroup:insert(ball)

end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene