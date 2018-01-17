local Module = {}

local MIN_ZOOM=0.2
local MAX_ZOOM=8

Module.newWorld = function(opts)
  opts = opts or {}
  local model={
    loc= opts.loc or {0,0},
    zoom=opts.zoom or 1,
    defaultzoom=opts.defaultzoom or 1,
    pixw=love.graphics.getWidth(),
    pixh=love.graphics.getHeight(),
    gridsize=opts.gridsize or 64,
    mouse={},
    flags={},
  }
  model.defaultloc = {model.loc[1],model.loc[2]}
  return model
end


local function handleKeyboard(model,action)
  -- g - toggle grid
  if action.key == "g" and action.state == "pressed" then
    model.flags.drawGrid = not model.flags.drawGrid
  end
  -- Cmd-0 - reset loc and zoom
  if action.key == "0" and action.state == "pressed" and action.gui then
    model.loc[1] = model.defaultloc[1]
    model.loc[2] = model.defaultloc[2]
    model.zoom = model.defaultzoom
  end
end

local function updateMouseScale(model,action)
  local cx = model.pixw/2
  local cy = model.pixh/2
  local d0 = math.dist(cx,cy,model.mouse.scale_pt[1], model.mouse.scale_pt[2])
  if d0 == 0 then d0 = 0.0001 end
  local d1 = math.dist(cx,cy,action.x,action.y)
  if d1 == 0 then d1 = 0.0001 end
  local z = d1/d0 * model.mouse.scale_zoom
  -- model.zoom = z
  model.zoom = math.clamp(z, MIN_ZOOM, MAX_ZOOM)

  model.loc[1] = model.mouse.scale_center[1] - (model.pixw/2/model.zoom)
  model.loc[2] = model.mouse.scale_center[2] - (model.pixh/2/model.zoom)

  model.mouse.scale_pt_now={action.x,action.y}
  model.mouse.scale_d0 = d0
  model.mouse.scale_d1 = d1
end

local function handleMouse(model,action)
  local out = nil
  if action.state == "pressed" and action.button == 1 then

    if action.shift then
      model.mouse.trans=true
      out=true

    elseif action.ctrl then
      model.mouse.scale=true
      model.mouse.scale_zoom=model.zoom -- zoom level at beginning of scale event
      model.mouse.scale_pt={action.x,action.y} -- start mouse loc
      model.mouse.scale_pt_now={action.x,action.y} -- current mouse loc
      model.mouse.scale_center={
        model.loc[1] + (model.pixw/2/model.zoom),
        model.loc[2] + (model.pixh/2/model.zoom),
      }
      updateMouseScale(model,action)
      out=true

    end
  elseif action.state == "released" and action.button == 1 then
    -- if model.flags.autoUpdatePicture and (model.mouse.trans or model.mouse.scale) then
    --   redrawPicture(model)
    -- end
    model.mouse.trans=nil
    model.mouse.scale=nil
    model.mouse.scale_zoom=nil
    model.mouse.scale_pt=nil
    model.mouse.scale_pt_now=nil
    model.mouse.scale_center=nil
    model.mouse.scale_d0=nil
    model.mouse.scale_d1=nil

  elseif action.state == "moved" then

    if model.mouse.trans then
      model.loc[1] = model.loc[1] - action.dx / model.zoom
      model.loc[2] = model.loc[2] - action.dy / model.zoom
      out=true

    elseif model.mouse.scale then
      updateMouseScale(model,action)
      out=true
    end
  end
  return out
end


Module.updateWorld = function(model,action)
  if action.type == "tick" then
    model.pixw = love.graphics.getWidth()
    model.pixh = love.graphics.getHeight()
  end
  local out = nil
  if action.type == "mouse" then
    out = handleMouse(model,action)
  end
  if action.type == "keyboard" then
    out = handleKeyboard(model,action)
  end

  return model, out
end

local function uiTrans(ui,pt)
  return {(pt[1]-ui.loc[1])*ui.zoom, (pt[2]-ui.loc[2])*ui.zoom}
end
local function uiTransXY(ui,x,y)
  return (x-ui.loc[1])*ui.zoom, (y-ui.loc[2])*ui.zoom
end

local function uiToScreen(ui,x,y)
  local sx = ui.zoom * (x - ui.loc[1])
  local sy = ui.zoom * (y - ui.loc[2])
  -- print("uiToScreen("..x..","..y..") -> ",sx,sy)
  return sx,sy
end

local function screenToUI(ui,x,y)
  local ux = x / ui.zoom + ui.loc[1]
  local uy = y / ui.zoom + ui.loc[2]
  return ux,uy
end

Module.trans = uiTrans
Module.transxy = uiTransXY
Module.uiToScreen = uiToScreen
Module.screenToUI = screenToUI

local function drawGridLines(ui)
  if not ui.flags.drawGrid then return end

  love.graphics.setLineWidth(0.01)

  local left = ui.loc[1]
  local right = left + ui.pixw/ui.zoom
  local top = ui.loc[2]
  local bottom = top + ui.pixh/ui.zoom

  local gf = ui.gridsize
  -- draw vertical lines
  local sx = gf*math.ceil(left/gf,0)
  local ex = gf*math.floor(right/gf,0)
  for i=sx,ex,gf do
    local a = uiTrans(ui, {i, top})
    local b = uiTrans(ui, {i, bottom})
    love.graphics.setColor(255,255,255,255)
    love.graphics.print(""..i,a[1],0)
    love.graphics.setColor(255,255,255,120)
    love.graphics.line(a[1],a[2],b[1],b[2])
  end

  -- draw h lines
  local sy = gf*math.ceil(top/gf,0)
  local ey = gf*math.floor(bottom/gf,0)
  for j=sy,ey,gf do
    local a = uiTrans(ui, {left,j})
    local b = uiTrans(ui, {right, j})
    love.graphics.setColor(255,255,255,255)
    love.graphics.print(""..j,0,a[2])
    love.graphics.setColor(255,255,255,120)
    love.graphics.line(a[1],a[2],b[1],b[2])
  end

  -- Draw a dot at 0,0:
  love.graphics.setPointSize(6)
  love.graphics.points(unpack(uiTrans(ui, {0,0})))
  love.graphics.setPointSize(1)
end

local function drawZoomState(model)
  if not model.mouse.scale then return end

  -- screen center
  local cx = model.pixw/2
  local cy = model.pixh/2

  -- Draw start circle size
  -- local d0 = math.dist(cx,cy,model.mouse.scale_pt[1],model.mouse.scale_pt[2])
  love.graphics.setColor(0,255,0,120)
  love.graphics.circle("line", cx, cy, model.mouse.scale_d0)
  love.graphics.print(floatstr(model.mouse.scale_zoom), cx+model.mouse.scale_d0, cy)

  -- Draw current circle size
  local d = math.dist(cx,cy,model.mouse.scale_pt_now[1],model.mouse.scale_pt_now[2])
  love.graphics.setColor(0,255,0,255)
  love.graphics.circle("line", cx, cy, model.mouse.scale_d1)
  love.graphics.print(floatstr(model.zoom), cx+model.mouse.scale_d1, cy+15)

  -- Draw a green dot at screen center
  love.graphics.setPointSize(6)
  love.graphics.points(cx,cy)
  love.graphics.setPointSize(1)
end

Module.drawWorld = function(model)
    drawGridLines(model)
    drawZoomState(model)
end

return Module
