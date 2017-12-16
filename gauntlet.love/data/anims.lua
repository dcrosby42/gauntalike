local DataLoader = require "dataloader"

local Module = {}

-- pic structure:
--   filename string
--   image Image
--   quad   Quad
--   rect   {x,y,w,h}
local function loadImageAsPic(loadImgFunc, filename, rect)
  local img = loadImgFunc(filename)

  local x,y,w,h = unpack(rect or {})
  if x == nil then
    x = 0
    y = 0
  end
  if w == nil then
    w = img:getWidth()
    h = img:getHeight()
  end

  local quad = love.graphics.newQuad(x,y,w,h, img:getDimensions())
  local pic = {
    filename=filename,
    image=img,
    quad=quad,
    rect={x=x, y=y, w=w, h=h},
  }
  return pic
end

-- <character>.feet.<feet_action>
-- <character>.<weapon_mode>.<body_action>

-- Find all image files in a dir with nums in their names like "blahblah_10.png"
-- Load the images as pics, then return sorted array based on the filename numbering
local function loadSortedPics(dir)
  local fnames = DataLoader.listAssetFiles(dir)
  local byNum = {}
  local nums = {}
  for _,fname in ipairs(fnames) do
    local nameNum = tonumber(fname:match("_(%d+)%..+$")) -- will blow up if name doesn't match pattern properly
    table.insert(nums, nameNum)
    byNum[nameNum] = fname
  end
  table.sort(nums)
  local pics = {}
  for _,num in ipairs(nums) do
    local filename = byNum[num]
    local pic = loadImageAsPic(DataLoader.loadFile, filename)
    table.insert(pics,pic)
  end
  return pics
end

function loadAnim(anims, keyPath)
  local path = "images"
  for _,step in ipairs(keyPath) do
    path = path .. "/" .. step
  end
  local pics = loadSortedPics(path)
  tsetdeep(anims,keyPath, {pics=pics})
end
--   local t = anims
--   for _,step in ipairs(pathSpec) do
--     if type(step) == "string" then
--       local next = t[step]
--       if not next then
--         next = {}
--         t[step] = t
--
--     end
--   end
-- end

Module.load = function()

  local keyPaths = {
    {"survivor","feet","idle"},
    {"survivor","feet","run"},
    {"survivor","feet","walk"},
    {"survivor","feet","strafe_left"},
    {"survivor","feet","strafe_right"},

    {"survivor","rifle","idle"},
    {"survivor","rifle","move"},
    {"survivor","rifle","meleeattack"},
    {"survivor","rifle","reload"},
    {"survivor","rifle","shoot"},

    {"survivor","shotgun","idle"},
    {"survivor","shotgun","move"},
    {"survivor","shotgun","meleeattack"},
    {"survivor","shotgun","reload"},
    {"survivor","shotgun","shoot"},

    {"survivor","handgun","idle"},
    {"survivor","handgun","move"},
    {"survivor","handgun","meleeattack"},
    {"survivor","handgun","reload"},
    {"survivor","handgun","shoot"},

    {"survivor","knife","idle"},
    {"survivor","knife","move"},
    {"survivor","knife","meleeattack"},

    {"survivor","flashlight","idle"},
    {"survivor","flashlight","move"},
    {"survivor","flashlight","meleeattack"},
  }

  local anims = {}
  for _,keyPath in ipairs(keyPaths) do
    loadAnim(anims, keyPath)
  end

  return anims
end

return Module
