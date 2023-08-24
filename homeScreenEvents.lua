local hsr = require("homeScreenRenderer")
local dm = require("dataManager")
local pdata = require("gameData.playerData")

local homeScreenEvents = {}

local transitionAllowed = true

local titleFont = "assets/fonts/DungeonFont.ttf"
local mainFont = "assets/fonts/EquipmentPro.ttf"

local currentGrp = nil
local newGame
homeScreenEvents.titleGrp = display.newGroup()

function homeScreenEvents.startNewGame(planets, menuGrp, newGameStart)
  
  for i = 1,#planets do
    planets[i].fill.effect = "filter.desaturate"
    planets[i].fill.effect.intensity = 0
    transition.to(planets[i], {alpha = 1, time = 1000})
    planets[i]:toFront()
  end
  
  local titleTxt = display.newText(homeScreenEvents.titleGrp, "Hyperion Cluster", centerX, screenTop + 400, titleFont, 120)
  local chooseTxt = display.newText(homeScreenEvents.titleGrp, "Select a destination", centerX, titleTxt.y + 80, mainFont, 60)
  
  homeScreenEvents.titleGrp.alpha = 0
  transition.to(homeScreenEvents.titleGrp, {alpha = 1, time = 3000, transition = easing.outCubic})
  
  newGame = newGameStart
  
  local function deleteGrp()
    display.remove(menuGrp)
  end

  transition.to(menuGrp, {alpha = 0, time = 3000, transition = easing.outCubic, onComplete = deleteGrp})
end

function homeScreenEvents.removeCurrentGrp()
  if currentGrp ~= nil then
    currentGrp:removeSelf()
  end
end

function homeScreenEvents.addPlanetEvents(planets, bubbles)
  
  local function focusPlanet(self, event)
    
    if not transitionAllowed then
      return
    end
    
    transitionAllowed = false
    
    timer.performWithDelay(1000, function() 
        transitionAllowed = true 
        timer.resume("float")
      end)
    transition.cancel("float")
    timer.pause("float")
    self:toFront()
    
    if currentGrp ~= nil then
      display.remove(currentGrp)
      currentGrp = nil
    end

    for i = 1,#planets do
      if self.x == centerX - 1 or self.x == centerX + 1 then
        transition.to(planets[i], {x = planets[i].originx, y = planets[i].originy, time = 750, transition = easing.outCubic})
        for x = 1,#bubbles[i] do
          transition.to(bubbles[i][x], {x = planets[i].originx, y = planets[i].originy - 100, time = 750, transition = easing.outCubic})
        end
      else
        if currentGrp == nil then
          currentGrp = hsr.renderPlanetTitle(self)
        end
        if planets[i] ~= self then
          if planets[i].x ~= 0 or planets[i].x ~= screenWidth then
            if planets[i].x > centerX then
              transition.to(planets[i], {x = screenWidth, y = planets[i].originy, time = 750, transition = easing.outCubic})
              for x = 1,#bubbles[i] do
                transition.to(bubbles[i][x], {x = screenWidth, y = planets[i].originy - 100, time = 750, transition = easing.outCubic})
              end
            else
              transition.to(planets[i], {x = 0, y = planets[i].originy, time = 750, transition = easing.outCubic})
              for x = 1,#bubbles[i] do
                transition.to(bubbles[i][x], {x = 0, y = planets[i].originy - 100, time = 750, transition = easing.outCubic})
              end
            end
          end
        else
          if self.x > centerX then
            transition.to(self, {x = centerX + 1, y = centerY, time = 1000, transition = easing.outCubic})
            for x = 1,#bubbles[i] do
              transition.to(bubbles[i][x], {x = centerX + 1, y = centerY - 100, time = 1000, transition = easing.outCubic})
            end
          else
            transition.to(self, {x = centerX - 1, y = centerY, time = 1000, transition = easing.outCubic})
            for x = 1,#bubbles[i] do
              transition.to(bubbles[i][x], {x = centerX - 1, y = centerY - 100, time = 1000, transition = easing.outCubic})
            end
          end
        end
      end
    end
    
  end
  
  for i = 1,#planets do
    planets[i].tap = focusPlanet
    planets[i].originx = planets[i].x
    planets[i].originy = planets[i].y
    planets[i]:addEventListener("tap", planets[i])
  end
  
end

return homeScreenEvents