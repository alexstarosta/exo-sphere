local json = require("json")
local pdata = require("gameData.playerData")
local pup = require("playerUpgrades")

local filename = "playerData.txt"

local dataManager = {}

dataManager.playerData = {
  gold = 0,
  lastUpdated = nil,
  
  earthMap = nil,
  wataluMap = nil,
  epsillionMap = nil,
  xenovaMap = nil,
  
  upgrades = {
    lives = 0,
    coins = 0,
    mastery = 0,
    revival = 0,
  }
}

function dataManager.fileExists()
  local path = system.pathForFile( filename, system.DocumentsDirectory)
  local f=io.open(path,"r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function dataManager.saveState()
  local path = system.pathForFile( filename, system.DocumentsDirectory)
  local file = io.open( path, "w" )
  local contents = json.encode( dataManager.playerData, {indent = true} )
  file:write( contents )
  io.close( file )
end

function dataManager.convertKeysToNumbers(table)
  local convertedTable = {}
  for key, value in pairs(table) do
    if type(value) == "table" then
      if tonumber(key) ~= nil then
        convertedTable[tonumber(key)] = dataManager.convertKeysToNumbers(value)
      else
        convertedTable[key] = dataManager.convertKeysToNumbers(value)
      end
    elseif tonumber(key) ~= nil then
      convertedTable[tonumber(key)] = value
    else
      convertedTable[key] = value
    end
  end
  return convertedTable
end

function dataManager.loadSavedState()
  local path = system.pathForFile( filename,system.DocumentsDirectory)
  local file = io.open( path, "r" )
  local contents = file:read( "*a" )
  dataManager.playerData = json.decode( contents )
  dataManager.playerData = dataManager.convertKeysToNumbers(dataManager.playerData)
  io.close( file )
end

function dataManager.saveData()
  dataManager.playerData.gold = pdata.gold 
  if pdata.currentMap ~= nil then
    dataManager.playerData[pdata.currentMap.planet.."Map"] = pdata.currentMap
    dataManager.playerData.lastUpdated = pdata.currentMap.planet
    dataManager.playerData.upgrades = pup.upgrades
  end
end

function dataManager.loadData()
  pdata.gold = dataManager.playerData.gold
  pup.upgrades = dataManager.playerData["upgrades"]
end

function dataManager.loadMapData(planet)
  pdata.currentMap = dataManager.playerData[planet.."Map"]
end

local function onSystemEvent( event )
  if event.type == "applicationExit" then
    dataManager.saveData()
    dataManager.saveState()
  elseif event.type == "applicationStart"  then
    if dataManager.fileExists() then
      dataManager.loadSavedState()
      dataManager.loadData()
    end
  end
end

function dataManager.checkSystemEvents()
  Runtime:addEventListener( "system", onSystemEvent )
end

return dataManager 