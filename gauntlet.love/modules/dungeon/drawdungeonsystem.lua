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

local fps=36
local function drawHero(e,res)
  -- local key = e.hero.bow
  -- drawAscii(BowArts[key], e.pos, {255,255,255})

  local t = e.timers.anim.t
  local x = e.pos.x
  local y = e.pos.y
  local s =  0.3

  local fanim = res.anims.survivor.feet.walk
  local fnum = math.floor(1 + (t * fps) % #fanim.pics)
  local fpic = fanim.pics[fnum]
  local ox = fpic.rect.w / 2
  local oy = fpic.rect.h / 2
  love.graphics.draw(fpic.image, fpic.quad, x,y, e.pos.r, s,s, ox,oy)

  local anim = res.anims.survivor.rifle.move
  fnum = math.floor(1 + (t * 24) % #anim.pics)
  local pic = anim.pics[fnum]
  ox = pic.rect.w / 2
  oy = pic.rect.h / 2
  love.graphics.draw(pic.image, pic.quad, x,y, e.pos.r, s,s, ox,oy)
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
  if e.hero then drawHero(e,res) end
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
