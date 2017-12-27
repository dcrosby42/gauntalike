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

local function drawArcher(e,res)
  local key = e.archer.bow
  drawAscii(BowArts[key], e.pos, {255,255,255})
end

local function drawHero(e,res)
  local t = e.timers.spriteAnim.t
  local x = e.pos.x
  local y = e.pos.y
  local s = e.pos.sx
  local anim = res.anims[e.sprite.anim]
  local pic = anim.func(t)
  love.graphics.draw(pic.image, pic.quad, x,y, e.pos.r, s,s, ox,oy)
end

local fps=36
local function drawSurvivor(e,res)
  local t = e.timers.moveAnim.t
  local x = e.pos.x
  local y = e.pos.y
  local s = e.pos.sx

  local fanim = res.anims.survivor.feet[e.survivor.feet]
  local fnum = math.floor(1 + (t * fps) % #fanim.pics)
  local fpic = fanim.pics[fnum]
  local ox = fpic.rect.w / 2
  local oy = fpic.rect.h / 2
  love.graphics.draw(fpic.image, fpic.quad, x,y, e.pos.r, s,s, ox,oy)

  if e.survivor.action == 'idle' or e.survivor.action == 'move' then
  else
    t = e.timers.weaponAnim.t
  end
  local anim = res.anims.survivor[e.survivor.weapon][e.survivor.action]
  fnum = math.floor(1 + (t * fps) % #anim.pics)
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
  if e.archer then drawArcher(e) end
  if e.survivor then drawSurvivor(e,res) end
  if e.arrow then drawArrow(e) end
  if e.mob then drawMob(e) end
  if e.item then drawItem(e) end
  if e.physicsObjects then
    for _,obj in ipairs(e.physicsObjects) do
      print("x")
      drawPhysicsObject(e,obj)
    end
  end
end)

return drawDungeon
