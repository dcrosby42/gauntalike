
local MsgBase = "This is the template module.\nt="
local function newWorld()
  local model ={
    t=0,
    message=MsgBase
  }
  return model
end

local function updateWorld(model,action)
  if action.type == 'tick' then
    model.t = model.t + action.dt
    model.message=MsgBase..tostring(model.t)
  end

  return model, nil
end

local function drawWorld(model)
  love.graphics.setBackgroundColor(255, 255, 255)
  love.graphics.setColor(0,0,0)
  love.graphics.print(model.message,100,100)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
