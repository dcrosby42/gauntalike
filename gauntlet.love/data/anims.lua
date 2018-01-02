local DataLoader = require "dataloader"

local Module = {}

-- pic structure:
--   filename string
--   image Image
--   quad   Quad
--   rect   {x,y,w,h}
local function img2pic(img, rect)
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

local function loadImageAsPic(loadImgFunc, filename, rect)
  local img = loadImgFunc(filename)
  return img2pic(img,rect)
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

local function loadAnim(anims, keyPath)
  local path = "images"
  for _,step in ipairs(keyPath) do
    path = path .. "/" .. step
  end
  local pics = loadSortedPics(path)
  tsetdeep(anims,keyPath, {pics=pics})
end

local function asepriteAnimFunc(anim)
  return function(t)
    local ms = math.floor(t * 1000) % anim.total_ms
    local acc = 0
    for _,pic in ipairs(anim.pics) do
      acc = acc + pic.duration_ms
      if ms < acc then
        return pic
      end
    end
  end
end

-- JSON structure (expigated version)
--  frames: (array of:)
--    frame
--      x
--      y
--      w
--      h
--    duration
--  meta:
--    frameTags: (array of:)
--      name  -- eg "ur/walk" for "up-right walk"
--      from
--      to
--      direction
local function loadAsepriteSheet(anims,sheetName,prefix)
  local img = DataLoader.loadFile("assets/images/"..sheetName..".png")
  local layout = DataLoader.loadFile("assets/images/"..sheetName..".json")
  -- frameTag 1-1 with an "anim"
  for _,ftag in ipairs(layout.meta.frameTags) do
    local pics={}
    local total_ms = 0
    for i=(1+ftag.from),(1+ftag.to) do
      local fr = layout.frames[i]
      local f = fr.frame
      local pic = img2pic(img, {f.x, f.y, f.w, f.h})
      pic.duration_ms = fr.duration
      total_ms = total_ms + fr.duration
      table.insert(pics, pic)
    end
    local anim = {
      pics=pics,
      total_ms=total_ms,
    }
    anim.func = asepriteAnimFunc(anim)
    local animName = prefix .. ftag.name
    anims[animName] = anim
  end
end

local function loadSurvivorAnims(anims)
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
  for _,keyPath in ipairs(keyPaths) do
    loadAnim(anims, keyPath)
  end
end

Module.load = function()
  local anims = {}

  --loadSurvivorAnims(anims)
  loadAsepriteSheet(anims, "elf-sheet", "elf/")
  loadAsepriteSheet(anims, "item-sheet", "item/")
  loadAsepriteSheet(anims, "dungeon-tiles", "dungeon/")

  return anims
end

return Module
