local gi = require("gameData.gameInfo")
local md = require("mapData")
local mp = require("mapPresets")

local metadataBuilder = {}

function metadataBuilder.addLevelData(data)
  local d = data
  if d.difficulty == "H" then
    return
  end
  local specs = md.specs[d.planet][d.difficulty]
  local layouts = mp.layouts[d.planet][d.difficulty]
  
  local function rerand(tab)
    local num = math.random(1,#tab)
    return tab[num], num
  end
  
  local function assignCheck(info)
    if #info == 1 then
      return info
    else
      return rerand(info)
    end
  end
  
  local function enemyAssignment(endZones)
    if #endZones == 1 then
      d.endZones = layouts.endZones
      d.enemyTypes = layouts.enemyTypes
      d.difficulties = layouts.difficulties
      d.hitsRequired = layouts.hitsRequired
    else
      local value
      d.endZones, value = rerand(layouts.endZones)
      d.enemyTypes = layouts.enemyTypes[value]
      d.difficulties = layouts.difficulties[value]
      d.hitsRequired = layouts.hitsRequired[value]
    end
  end
  
  d.walls = specs.walls
  d.pegAmount = rerand(specs.pegAmount)
  d.lives = specs.lives
  
  d.pegZones = assignCheck(layouts.pegZones)
  d.dropZones = assignCheck(layouts.dropZones)
  if d.difficulty == 5 then
    d.coinZones = {1,2,3,4,5,6,7,8,9}
  else
    d.coinZones = assignCheck(layouts.coinZones)
  end
  
  enemyAssignment(layouts.endZones)
  
  return d
  
end

function metadataBuilder.addData(map)
  
  map.meta = true
  
  for y = 0,#map.tiles do
    for x = 0,#map.tiles[y] do
      if map.tiles[y][x].tileValue ~= " " then
        local tile =  map.tiles[y][x]
        
        tile.info = {
          planetName = map.planet,
          levelName = gi.levelNames[map.planet][tile.tileValue],
          levelNumber = x.." - "..y,
          difficulty = gi.difficultyNames[tile.tileValue],
          difficultyColor = gi.difficultyColors[tile.tileValue],
          
          highlighted = false,
          cleared = false,
          nearbyCleared = false,
          mastered = false,
          
          levelSettings = {
            planet = map.planet,
            difficulty = tile.tileValue,
            walls = "normal",
            pegAmount = 0,
            lives = 3,
            
            pegZones = {"a"},
            forcedPegZones = {},
            forcedPegTypes = {},
            
            wallZones = {},
            wallZonesPos = {},
            dropZones = {"a"},
            
            coinZones = {5},
            coinZoneTypes = {math.random(1,5),math.random(1,5),math.random(1,5),math.random(1,5),math.random(1,5),math.random(1,5),math.random(1,5),math.random(1,5),math.random(1,5),math.random(1,5),math.random(1,5)},
            
            endZones = {2},
            enemyTypes = {"medium"},
            difficulties = {1},
            hitsRequired = {1},
            
            levelX = x,
            levelY = y
          }
          
        }
        
        if tile.info.difficulty == "Shop" then
          tile.info.cleared = true
          tile.info.nearbyCleared = true
          tile.completedTile.alpha = 1
        end
        metadataBuilder.addLevelData(tile.info.levelSettings)
      end
    end
  end
  
end

return metadataBuilder