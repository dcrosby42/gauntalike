local Module = {}

Module.newWorld = function()
  local model={
    loc={-2,-2},
    zoom=100,
    pixw=love.graphics.getWidth(),
    pixh=love.graphics.getHeight(),
    mouse={},
    flags={},
  }
  return model
end


local function handleKeyboard(model,action)
  -- if action.key == "space" and action.state == "pressed" then
    -- redrawPicture(model)
  -- end
  if action.key == "g" and action.state == "pressed" then
    model.flags.drawGrid = not model.flags.drawGrid
    print("model.flags.drawGrid",model.flags.drawGrid)
  end
  if action.key == "a" and action.state == "pressed" then
    model.flags.autoUpdatePicture = not model.flags.autoUpdatePicture
  end
  if action.key == "p" and action.state == "pressed" then
    model.flags.drawPicture = not model.flags.drawPicture
  end
end

local function handleMouse(model,action)
  if action.state == "pressed" and action.button == 1 then

    if action.shift then
      model.mouse.trans=true

    elseif action.ctrl then
      model.mouse.scale=true
      model.mouse.scale_zoom=model.zoom
      model.mouse.scale_pt={action.x,action.y}
      model.mouse.scale_center={
        model.loc[1] + (model.pixw/2/model.zoom),
        model.loc[2] + (model.pixh/2/model.zoom),
      }

    end
  elseif action.state == "released" and action.button == 1 then
    -- if model.flags.autoUpdatePicture and (model.mouse.trans or model.mouse.scale) then
    --   redrawPicture(model)
    -- end
    model.mouse.trans=nil
    model.mouse.scale=nil
    model.mouse.scale_zoom=nil
    model.mouse.scale_pt=nil
    model.mouse.scale_pt_off=nil

  elseif action.state == "moved" then

    if model.mouse.trans then
      model.loc[1] = model.loc[1] - action.dx / model.zoom
      model.loc[2] = model.loc[2] - action.dy / model.zoom

    elseif model.mouse.scale then
      local ax = action.x - model.mouse.scale_pt[1]
      local ay = action.y - model.mouse.scale_pt[2]
      local dist = math.sqrt(ax*ax, ay*ay)
      if ax < 0 then dist = -dist end
      model.zoom = math.clamp(model.mouse.scale_zoom + dist, 1, 10000)
      -- adjust viewport loc to stay centered
      model.loc[1] = model.mouse.scale_center[1] - (model.pixw/2/model.zoom)
      model.loc[2] = model.mouse.scale_center[2] - (model.pixh/2/model.zoom)
    end
  end
end


Module.updateWorld = function(model,action)
  if action.type == "tick" then
    model.pixw = love.graphics.getWidth()
    model.pixh = love.graphics.getHeight()
  end
  if action.type == "mouse" then handleMouse(model,action) end
  if action.type == "keyboard" then handleKeyboard(model,action) end
  return model, nil
end

local function uiTrans(ui,pt)
  return {(pt[1]-ui.loc[1])*ui.zoom, (pt[2]-ui.loc[2])*ui.zoom}
end

Module.trans = uiTrans

local function drawGridLines(ui)
  local left = ui.loc[1]
  local right = left + ui.pixw/ui.zoom
  local top = ui.loc[2]
  local bottom = top + ui.pixh/ui.zoom
  local sx = math.round(left,0)
  local ex = math.round(right,0)
  -- local pry = 0
  for i=sx,ex,1 do
    local a = uiTrans(ui, {i, top})
    local b = uiTrans(ui, {i, bottom})
    love.graphics.print(""..i,a[1],0)
    -- love.graphics.print(""..a[1].." "..a[2].." "..b[1].." "..b[2],0,pry)
    -- pry = pry + 12
    love.graphics.line(a[1],a[2],b[1],b[2])
  end
  local sy = math.round(top,0)
  local ey = math.round(bottom,0)
  for j=sy,ey,1 do
    local a = uiTrans(ui, {left,j})
    local b = uiTrans(ui, {right, j})
    love.graphics.print(""..j,0,a[2])
    -- love.graphics.print(""..a[1].." "..a[2].." "..b[1].." "..b[2],0,pry)
    -- pry = pry + 12
    love.graphics.line(a[1],a[2],b[1],b[2])
  end
end


Module.drawWorld = function(model)
  if model.flags.drawGrid then
    love.graphics.setColor(255,255,255)
    love.graphics.setLineWidth(0.01)
    drawGridLines(model)
    -- Draw a dot at 0,0:
    love.graphics.setPointSize(6)
    love.graphics.points(unpack(uiTrans(model, {0,0})))
    love.graphics.setPointSize(1)
  end
end

return Module
