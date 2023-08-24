local lfs = require ("lfs")

local gameio = {}

function gameio.rgb(hex)
  hex = hex:gsub("#","")
  return {
    tonumber("0x"..hex:sub(1,2))/255,
    tonumber("0x"..hex:sub(3,4))/255,
    tonumber("0x"..hex:sub(5,6))/255
  }
end

function gameio.irgb(rgb)
  local inverseRgb = {}
  for i = 1, #rgb do
    inverseRgb[i] = 1 - rgb[i]
  end
  return inverseRgb
end

function gameio.getDir(dir_path)
  local dir_contents = {}
  for item in lfs.dir(dir_path) do
    if item ~= "." and item ~= ".." and item ~= ".DS_Store" then
      local item_path = dir_path .. "/" .. item
      local mode = lfs.attributes(item_path, "mode")
      if mode == "file" or mode == "directory" then
        table.insert(dir_contents, item_path)
      end
    end
  end
  table.sort(dir_contents)
  return dir_contents
end

function gameio.pathToName(path)
  local filename = string.match(path, "[^/]*$")
  local name_without_extension = string.gsub(filename, "%.png$", "")
  return name_without_extension
end

function gameio.completeRemove(object)
  if type(object) == "table" then
    for i,v in pairs(object) do
      v:removeSelf()
      v = nil
    end
  end
end

function gameio.formatNum(number)
  local str = tostring(number)
  local length = #str
  if length >= 10 then
    return string.format("%.1fB", number / 1e9)
  elseif length >= 7 then
    return string.format("%.1fM", number / 1e6)
  elseif length >= 5 then
    return string.format("%.1fK", number / 1e3)
  else
    return str
  end
end

return gameio