local drawDevOverlay = require 'modules.ecsinspector.drawdevoverlay'

local function elistMoveSelection(elist,n)
  if elist.count then
    local idx = elist.selectedIndex + n
    if idx < 1 then idx = elist.count end
    if idx > elist.count then idx = 1 end
    elist.selectedIndex = idx
  end
end

local function handleKeyboard(world,action)
  if action.key == 'f12' and action.state == 'pressed' then
    world.on = not world.on
  end
  if world.focus == 'elist' then
    if action.state == 'pressed' then
      if action.key == "up" then elistMoveSelection(world.parts.elist, -1) end
      if action.key == "down" then elistMoveSelection(world.parts.elist, 1) end
    end
  end
end

local function handleTick(world,action)
end


--
-- MODULE FUNCS:
--
local function newWorld(opts)
  local world = {
    sub={
      module=opts.sub.module,
      state=opts.sub.state,
    },
    drawSub=true,
    on=false,
    parts={
      elist={
        selectedIndex=1,
      }
    },
    focus="elist",
  }
  return world
end

local function updateWorld(world,action)
  if action.type == 'keyboard' then
    handleKeyboard(world,action)
  elseif action.type == 'tick' then
    handleTick(world,action)
  -- elseif action.type == 'mouse' then
  --   handleMouse(world,action)
  -- elseif action.type == 'controller' then
  --   handleController(world,action)
  end
  if not world.on then
    world.sub.state = world.sub.module.updateWorld(world.sub.state, action)
  end
  return world, nil
end

local function drawWorld(world)
  if world.drawSub then
    world.sub.module.drawWorld(world.sub.state)
  end
  if world.on then
    drawDevOverlay(world)
  end
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
