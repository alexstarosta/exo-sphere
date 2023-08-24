local composer = require("composer")
local wb = require("gameGeneration.worldBuilder")
local mb = require("gameGeneration.metadataBuilder")
local gb = require("gameGeneration.guiBuilder")
local ge = require("gameEvents")
local pdata = require("gameData.playerData")
local gi = require("gameData.gameInfo")
local gio = require("gameio")
local tm = require("transitionMaker")
local dm = require("dataManager")
local al = require("audioLoader")

local scene = composer.newScene()

local map
local titleFont = "assets/fonts/DungeonFont.ttf"
local menuCreated = false
local coinGui, coinGuiGrp, scoreGui, scoreGuiGrp
local completed
pdata.currentWorldInfo.bgCreated = false
local returnGrp

function scene:create( event )
  
  if pdata.currentWorldInfo.scoreGui ~= nil then
    pdata.currentWorldInfo.scoreGui.switchToScore()
  end
  
  if event.params ~= nil then
    if event.params.levelCode == "completed" then
      pdata.currentMap.tiles[event.params.tY][event.params.tX].info.cleared = true
    end
    if event.params.mastered then
      pdata.currentMap.tiles[event.params.tY][event.params.tX].info.mastered = true
    end
  end

  local sceneGroup = self.view

  local rad = event.params.radius
  
  if pdata.currentMap ~= nil then
    map = pdata.currentMap
  else
    map = wb.createMap(rad, event.params.world)
  end
  
  audio.stop()
  audio.setVolume( 0.25, { channel=1 } )
  audio.play(al.bgm[map.planet.."Menu"], {channel = 1, loops = -1, fadein = 5000} )
  
  local tileGrp = wb.renderMap(map, map.planet, 125)
  wb.showMap(map)
  
  if map.meta == nil then
    mb.addData(map)
  end
  
  wb.addMapEvents(map)
  completed = wb.showCompleted(map)

  if pdata.currentMap == nil or not pdata.currentWorldInfo.bgCreated then
    pdata.currentWorldInfo.bgCreated = true
    local bgTable, bgGrp = wb.renderBackground(map)
    wb.animateBackground(map, bgTable)
    pdata.currentWorldInfo.bgGrp = bgGrp
    pdata.currentWorldInfo.bgTable = bgTable
  end
  
  sceneGroup:insert(tileGrp)
  
  ge.startMap(map)

  wb.animateTiles(map)
  
  pdata.currentMap = map
  
 if pdata.currentWorldInfo.coinGui == nil then
    coinGui, coinGuiGrp, scoreGui, scoreGuiGrp = gb.createMenuGui(map, completed)
    pdata.currentWorldInfo.coinGui = coinGui
    pdata.currentWorldInfo.scoreGui = scoreGui
    pdata.currentWorldInfo.coinGuiGrp = coinGuiGrp
    pdata.currentWorldInfo.scoreGuiGrp = scoreGuiGrp
    scoreGuiGrp.alpha = 0
    coinGuiGrp.alpha = 0
  else
    pdata.currentWorldInfo.coinGui.coinTxt.text = gio.formatNum(pdata.gold)
    pdata.currentWorldInfo.scoreGui.scoreTxt.text = completed.." / "..map.tileAmount
  end
  
  returnGrp = wb.generateReturn(screenRight - 150, screenBottom - 150, 150, 150, map)
  returnGrp.alpha = 0
  
end

function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
  -- Code here runs when the scene is still off screen (but is about to come on screen)
  
  if tm.currentGrp ~= nil then
    transition.to (tm.currentGrp, {alpha = 0, time = 1000, onComplete = function()
      tm.removeTransition()
    end})
    transition.to(scoreGuiGrp, {alpha = 1, time = 1000})
    transition.to(coinGuiGrp, {alpha = 1, time = 1000})
    transition.to(returnGrp, {alpha = 1, time = 1000})
  end
  pdata.currentWorldInfo.transitioning = false
  
  map.tileGroup:toFront()

  elseif ( phase == "did" ) then
  -- Code here runs when the scene is entirely on screen

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

end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene