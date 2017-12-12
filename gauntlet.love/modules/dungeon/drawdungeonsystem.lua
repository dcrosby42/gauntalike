require 'ecs.ecshelpers'

local BowArts = {
  rest  ="  -}->",
  drawn ="=--}>",
  fired="     }",
}

local ArrowArts = {
  default="=-->"
}

local function drawAscii(str, p, color)
  love.graphics.setColor(unpack(color))
  love.graphics.print(str, p.x, p.y, p.r, p.sx, p.sy, p.ox, p.oy)
end

local function drawHero(e)
  local key = e.hero.bow
  drawAscii(BowArts[key], e.pos, {255,255,255})
end

local function drawArrow(e)
  drawAscii(ArrowArts.default, e.pos, {150,150,200})
end
local function drawItem(e)
  love.graphics.print(e.item.kind,e.pos.x-5, e.pos.y-5)
end
local function drawMob(e)
  local x = e.pos.x-7
  local y = e.pos.y-6
  local hp = e.mob.hp or "?"
  love.graphics.print(""..hp, x,y)
end

local Module = {}

local drawDungeon = defineDrawSystem({'pos'}, function(e,estore,res)
  if e.hero then drawHero(e) end
  if e.arrow then drawArrow(e) end
  if e.mob then drawMob(e) end
  if e.item then drawItem(e) end
  if e.physicsObjects then
    for _,obj in ipairs(e.physicsObjects) do
      drawPhysicsObject(e,obj)
    end
  end
end)

return drawDungeon
