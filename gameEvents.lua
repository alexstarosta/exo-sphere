local gameEvents = {}
local gb = require("gameGeneration.guiBuilder")
local pdata = require("gameData.playerData")
local gdata = require("gameData.gameData")
local gio = require("gameio")

function gameEvents.closeLevelInfo()
  gio.completeRemove(gdata.overlays.levelBox)
  gio.completeRemove(gdata.overlays.levelTxt)
  
  for y = 0,#pdata.currentMap.tiles do
    for x = 0,#pdata.currentMap.tiles[y] do
      if pdata.currentMap.tiles[y][x].highlightTile ~= nil then
        pdata.currentMap.tiles[y][x].highlightTile.alpha = 0
      end
    end
  end
  
  gdata.overlays.levelBox = nil
  gdata.overlays.levelTxt = nil
end

function gameEvents.startMap(map)
  
  local function homeUnsaturate(map)
    map.tiles[map.radius][map.radius].img.fill.effect = "filter.desaturate"
    map.tiles[map.radius][map.radius].img.fill.effect.intensity = 0
    map.tiles[map.radius][map.radius].img.alpha = 1
    
  end
  
  local function enableDrag(map)
    
    local group = map.tileGroup
    
    local startX, startY = 0, 0
    local lastX, lastY = 0, 0
    group.isDragging = false
    local deltaX 
    local deltaY
    
    local function onTouch(event)
      if (event.phase == "began") then
        startX, startY = event.x, event.y
        lastX, lastY = group.x, group.y
        group.isDragging = true
      elseif (event.phase == "moved" and group.isDragging) then
        
        deltaX = event.x - startX
        deltaY = event.y - startY
        local newX = lastX + deltaX
        local newY = lastY + deltaY
        local maxDragX = group.width * 0.5
        local maxDragY = group.height * 0.5
        
        if (newX < display.contentCenterX - maxDragX) then
          newX = display.contentCenterX - maxDragX
        elseif (newX > display.contentCenterX + maxDragX) then
          newX = display.contentCenterX + maxDragX
        end
        
        if (newY < display.contentCenterY - maxDragY) then
          newY = display.contentCenterY - maxDragY
        elseif (newY > display.contentCenterY + maxDragY) then
          newY = display.contentCenterY + maxDragY
        end
        
        group.x = newX
        group.y = newY
        
        if math.abs(deltaX) > 5 or math.abs(deltaY) > 5 then
          gameEvents.closeLevelInfo()
        end
        
      elseif (event.phase == "ended" or event.phase == "cancelled") then
        local overlay
        if #gdata.overlays ~= 0 then
          overlay = gdata.overlays.levelTxt.playBtn
          if event.x > overlay.x - overlay.width/2 and  event.x < overlay.x + overlay.width/2 and event.y > overlay.y - overlay.height/2 and  event.y < overlay.y + overlay.height/2 then
            gameEvents.closeLevelInfo()
          end
        end
        group.isDragging = false
      end
      return true
    end
    
  map.tapRect:addEventListener("touch", onTouch)
end

  homeUnsaturate(map)
  enableDrag(map)
  
end

function gameEvents.startGame(map)
  
  gameEvents.startMap(map)
  
end

function gameEvents.showLevelInfo(self, event)
  
  if pdata.currentWorldInfo.transitioning then
    return
  end
    
  gameEvents.closeLevelInfo()
  
  if pdata.currentMap.tiles[self.yPos][self.xPos].info.mastered then
    gdata.overlays.levelBox = gb.newMenuBox(centerX, centerY - screenHeight/7.5, screenWidth*0.8, 400, "masteredGui.png")
  else
    gdata.overlays.levelBox = gb.newMenuBox(centerX, centerY - screenHeight/7.5, screenWidth*0.8, 400, pdata.currentMap.planet.."Gui.png")
  end
  
  gdata.overlays.levelTxt = gb.newLevelText(centerX, centerY - screenHeight/7.5, screenWidth*0.8, 400, pdata.currentMap, self.xPos, self.yPos)
  
  if pdata.currentMap.tiles[self.yPos][self.xPos].info.cleared or pdata.currentMap.tiles[self.yPos][self.xPos].info.nearbyCleared then
    pdata.currentMap.tiles[self.yPos][self.xPos].highlightTile.alpha = 0.75
  else
    pdata.currentMap.tiles[self.yPos][self.xPos].highlightTile.alpha = 0.25
  end
  
  transition.to(pdata.currentMap.tileGroup, {time = 250, x = screenWidth - event.target.x, y = screenHeight - event.target.y})
  
  return true
end

return gameEvents