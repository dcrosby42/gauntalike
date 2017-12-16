require 'crozeng/helpers'
local json = require 'json'
local serialize = require 'serialize'

local fs= love.filesystem

local Extensions = {
  {{"png","jpg","gif","bmp"}, "image"},
  {{"wav","ogg","mp3"}, "sound"},
  {{"lua"}, "lua"},
  {{"json"}, "json"},
  {{"txt"}, "text"},
}

--
-- FILENAME OPERATIONS
--

local function fileExt(path)
  return path:match("^.+%.(.+)$")
end

local function fileDir(path)
  return path:match("^(.+)/[^/]+$") or ""
end

local function gamePath(subpath)
  subpath = subpath or ""
  return subpath
end

local function userPath(subpath)
  subpath = subpath or ""
  return fs.getSaveDirectory() .. "/" .. subpath
end

local function getFileType(name)
  local ext = fileExt(name:lower())
  for i=1,#Extensions do
    local mapping = Extensions[i]
    for j=1,#mapping[1] do
      if ext == mapping[1][j] then
        return mapping[2]
      end
    end
  end
  return nil
end

--
-- FILE OPERATIONS
--

local function mkdirUpToFile(name)
  local parts = {}
  for part in string.gmatch(name,"(.-)/") do
    table.insert(parts,part)
  end
  local rebuild = ""
  for i=1,#parts do
    rebuild = rebuild .. parts[i]
    if fs.isDirectory(rebuild) then
      -- ok
    elseif fs.isFile(rebuild) then
      error("Cannot save file '"..name.."' because '"..rebuild.."' exists and is NOT a dir")
    else
      local ok = love.filesystem.createDirectory(rebuild)
      if not ok then
        error("Failed to create dir '"..rebuild.."' while saving file '"..name.."'")
      end
    end
    rebuild = rebuild .. "/"
  end
end

local function loadTextFile(name)
  return fs.read(name)
end

local function loadJsonFile(name)
  local data,pos,err = json.decode(loadTextFile(name),1,nil)
  if err then
    print("!! loadJsonFile ERR: "..err)
    return nil
  end
  return data
end

local function loadLuaFile(name)
  chunk = assert(loadstring(loadTextFile(name)))
  return chunk()
end

local function saveTextFile(name,text)
  mkdirUpToFile(name)
  fs.write(name,text,#text)
end

local function saveJsonFile(name,data)
  local str = json.encode(data, {indent=true})
  saveTextFile(name,str)
end

local function saveLuaFile(name,data)
  local str = serialize(data)
  saveTextFile(name, str)
end

local Loaders = {
  text=fs.read,
  json=loadJsonFile,
  lua=loadLuaFile,
  image=love.graphics.newImage,
  -- TODO: sound
}

local Savers = {
  text=saveTextFile,
  json=saveJsonFile,
  lua=saveLuaFile,
}

local function loadFile(name)
  if fs.isFile(name) then
    local loader = Loaders[getFileType(name)]
    if loader then return loader(name) end
    error("loadFile("..name..") failed; no loader for "..name)
  end
end

local function saveFile(name,data)
  local saver = Savers[getFileType(name)]
  if saver then return saver(name,data) end
  error("saveFile("..name..") failed; no saver for "..name)
end


local function recursiveFileList(path)
  if fs.isDirectory(path) then
    local list = {}
    for _,item in ipairs(fs.getDirectoryItems(path)) do
      tconcat(list, recursiveFileList(path.."/"..item))
    end
    return list
  elseif fs.isFile(path) and getFileType(path) then
    return {path}
  end
  return {}
end

local function listAssetFiles(subdir)
  local suff = ""
  if subdir ~= "" then
    suff = "/"..subdir
  end
  return recursiveFileList(gamePath("assets"..suff))
end

local function listDataFiles(subdir)
  local suff = ""
  if subdir ~= "" then
    suff = "/"..subdir
  end
  return recursiveFileList(gamePath("data"..suff))
end


-- local function test()
--   local assets = listAssetFiles()
--
--   assets = tconcat(assets, listDataFiles())
--
--   for i=1,#assets do
--     local data = loadFile(assets[i])
--     local str = "?"
--     if type(data) == "table" then
--       str = "\n"..tdebug(data)
--     else
--       str = tostring(data)
--     end
--     print("i="..i.." name="..assets[i].." => "..str)
--   end
--
--   saveFile("testing/data/json/output.json", {welcome={to="my nightmare"}})
--   saveFile("testing/data/lua/serd.lua", {"I","think",{youre="gonna like it"}})
--   saveFile("testing/data/bare/file.txt", "I think you're gonna feel you belong.")
-- end

return {
  listAssetFiles=listAssetFiles,
  listDataFiles=listDataFiles,
  listAllResourceFiles=function() return tconcat(listAssetFiles(), listDataFiles()) end,
  loadFile=loadFile,
  saveFile=saveFile,
  getFileType=getFileType,
  test=function()
  end,
}
