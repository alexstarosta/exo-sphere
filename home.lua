local composer = require( "composer" )
local hsr = require("homeScreenRenderer")
local hse = require("homeScreenEvents")
local wb = require("gameGeneration.worldBuilder")
local gb = require("gameGeneration.guiBuilder")
local gi = require("gameData.gameInfo")
local pdata = require("gameData.playerData")
local tm = require("transitionMaker")
local al = require("audioLoader")

local scene = composer.newScene()

local titleFont = "assets/fonts/DungeonFont.ttf"
local mainFont = "assets/fonts/EquipmentPro.ttf"

local planets, planetsGrp
local bubbles, menuGrp, bubblesGrp
local bgTable, bgGrp

function scene:create( event )

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen
  
  al.loadSfx()
  al.loadBgm()
  
  audio.stop()
  audio.setVolume( 0.25, { channel=1 } )
  audio.play(al.bgm["homeBackground"], {channel = 1, loops = -1, fadein = 5000} )
  
  planets, planetsGrp = hsr.renderPlanets()
  bubbles, bubblesGrp = hsr.renderBubbles(planets)
  
  bgTable, bgGrp = wb.renderBackground({planet = "menu"})
  wb.animateBackground({planet = "menu"}, bgTable)
  
  hsr.animateBubbles(bubbles)
  hsr.animatePlanets(planets)
  
  -- menuing
  
  sceneGroup:insert(planetsGrp)
  
  if tm.currentGrp == nil then
    menuGrp = hsr.renderMenu(planets, bubbles)
    sceneGroup:insert(menuGrp)
  end

end

function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
  -- Code here runs when the scene is still off screen (but is about to come on screen)

  if tm.currentGrp ~= nil then
    transition.to (tm.currentGrp, {alpha = 0, time = 1000, onComplete = function()
      tm.removeTransition()
      hse.startNewGame(planets, menuGrp, false)
      hse.addPlanetEvents(planets, bubbles)
      end})
  end
  pdata.currentWorldInfo.transitioning = false

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
  sceneGroup:insert(bgGrp)
  hse.removeCurrentGrp()
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene