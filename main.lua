--[[
//                         //
//  Alex Starosta 2023     //
//  exoSphere alpha        //
//  April 2023 - May 2023  //
//                         //
]]


local composer = require( "composer" )
local dm = require("dataManager")

math.randomseed = (os.time())

-- helpful screen constants

display.setStatusBar( display.HiddenStatusBar )
centerX = display.contentCenterX
centerY = display.contentCenterY
screenLeft = display.screenOriginX
screenWidth = display.contentWidth - screenLeft * 2
screenRight = screenLeft + screenWidth
screenTop = display.screenOriginY
screenHeight = display.contentHeight - screenTop * 2
screenBottom = screenTop + screenHeight
display.contentWidth = screenWidth
display.contentHeight = screenHeight

local wrongDisplay

if screenWidth ~= 1125 or screenHeight ~= 2436 then
  local alertBg = display.newRect(centerX, centerY, screenWidth, screenHeight)
  alertBg.fill = {0}
  local alertText1 = display.newText("This screen resolution is not currently supported.", centerX, centerY - 22.5*(screenWidth/1080), native.systemFontBold, 40*(screenWidth/1080))
  local alertText2 = display.newText("Please switch to iphone X resolution.", centerX, centerY + 22.5*(screenWidth/1080), native.systemFontBold, 40*(screenWidth/1080))
  wrongDisplay = true
end

if not wrongDisplay then
  dm.checkSystemEvents()
  timer.performWithDelay(1, function()
    composer.gotoScene("home")
  end)
end