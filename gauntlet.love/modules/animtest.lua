local Anims = require 'data/anims'

local function buildComps()
  local comps = {}

  local chars = {"elf"}
  local dirs={"d","dl","l","ul","u","ur","r","dr"}
  local acts={"walk","shoot","throw"}
  for _,chname in ipairs(chars) do
    for _,dir in ipairs(dirs) do
      for _,act in ipairs(acts) do
        local comp = {}
        comp.anim = chname .. "/" .. dir .. "/" .. act
        comp.t = 0
        table.insert(comps,comp)
      end
    end
  end

  return comps
end

local function newWorld()
  local model = {
    comps=buildComps(),
    res={
      anims=Anims.load(),
    },
  }
  return model
end

local function updateWorld(model,action)
  if action.type == 'tick' then
    for _,comp in ipairs(model.comps) do
      comp.t = comp.t + action.dt
    end
  end

  return model, nil
end

local function drawWorld(model)
  love.graphics.setBackgroundColor(90,90,90)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("AnimTest")
  local x = 0
  local y = 32
  local s = 2
  for i,comp in ipairs(model.comps) do
    local anim = model.res.anims[comp.anim]
    local pic = anim.func(comp.t)
    love.graphics.draw(pic.image, pic.quad, x,y, 0, s,s, 0,0)
    y = y + (s*32)
    if i % 3 == 0 then
      y = 32
      x = x + (s*32)
    end
  end
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
