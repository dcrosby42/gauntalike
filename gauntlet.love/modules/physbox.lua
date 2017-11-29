local Module = {}

require 'crozeng.helpers'
require 'ecs.ecshelpers'

function beginCallback(fixture1, fixture2, contact)
  local s = tostring(fixture1:getUserData() .. "-" .. fixture2:getUserData())
  print("beginCallback "..s)
end

function endCallback(fixture1, fixture2, contact)
  local s = tostring(fixture1:getUserData() .. "-" .. fixture2:getUserData())
  print("endCallback "..s)
  contact = nil
  collectgarbage()
end


Module.newWorld = function()
  local world = {}

  love.physics.setMeter(64) --the height of a meter our worlds will be 64px
  world.physworld = love.physics.newWorld(0, 0, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
  world.physworld:setCallbacks(beginCallback, endCallback)

	world.sensor = {}
	world.sensor.body = love.physics.newBody(world.physworld, 400, 300, "static")
	world.sensor.shape = love.physics.newRectangleShape(150, 100)
	world.sensor.fixture = love.physics.newFixture(world.sensor.body, world.sensor.shape)
	world.sensor.touching = 0
	world.sensor.fixture:setSensor(true)
	world.sensor.fixture:setUserData("sensor")

	world.box = {}
	world.box.body = love.physics.newBody(world.physworld, 600, 400, "dynamic")
	world.box.body:setAngularDamping(2*math.pi)
	world.box.shape = love.physics.newRectangleShape(40, 10)
	world.box.fixture = love.physics.newFixture(world.box.body, world.box.shape)
	world.box.fixture:setUserData("box")

	world.block = {}
	world.block.body = love.physics.newBody(world.physworld, 500, 400, "dynamic")
	world.block.body:setAngularDamping(2*math.pi)
	world.block.body:setLinearDamping(10)
	world.block.shape = love.physics.newRectangleShape(15, 60)
	world.block.fixture = love.physics.newFixture(world.block.body, world.block.shape)
	world.block.fixture:setUserData("block")
	world.block.body:setMass(4)

  return world
end

Module.updateWorld = function(world,action)
  if action.type == 'tick' then
    world.physworld:update(action.dt)
    -- world.input.dt = action.dt
    -- RunSystems(world.estore, world.input, world.resources)
    -- world.input.events = {}

  elseif action.type == 'joystick' then
    -- Joystick.handleJoystick(action, ControllerIds, function(controllerId, input,action)
    --   addInputEvent(world.input, {type='controller', id=controllerId, input=input, action=action})
    -- end)

  elseif action.type == 'keyboard' then
    if action.key == "left" then
      if action.state == "pressed" then
        local dx,dy = world.box.body:getLinearVelocity()
        world.box.body:setLinearVelocity(-200,dy)
      else
        local dx,dy = world.box.body:getLinearVelocity()
        world.box.body:setLinearVelocity(0,dy)
      end
    elseif action.key == "right" then
      if action.state == "pressed" then
        local dx,dy = world.box.body:getLinearVelocity()
        world.box.body:setLinearVelocity(200,dy)
      else
        local dx,dy = world.box.body:getLinearVelocity()
        world.box.body:setLinearVelocity(0,dy)
      end
    elseif action.key == "up" then
      if action.state == "pressed" then
        local dx,dy = world.box.body:getLinearVelocity()
        world.box.body:setLinearVelocity(dx,-200)
      else
        local dx,dy = world.box.body:getLinearVelocity()
        world.box.body:setLinearVelocity(dx,0)
      end
    elseif action.key == "down" then
      if action.state == "pressed" then
        local dx,dy = world.box.body:getLinearVelocity()
        world.box.body:setLinearVelocity(dx,200)
      else
        local dx,dy = world.box.body:getLinearVelocity()
        world.box.body:setLinearVelocity(dx,0)
      end
    end
    -- KeyboardSimGamepad.handleKeyboard(action, keyboardOpts, function(controllerId, input,action)
    --   addInputEvent(world.input, {type='controller',id=controllerId, input=input, action=action})
    -- end)

  end

  return world
end

Module.drawWorld = function(world)
  love.graphics.setBackgroundColor(0,0,0)

  local s = world.sensor
	love.graphics.polygon("line", s.body:getWorldPoints(s.shape:getPoints()))
  local b = world.box
	love.graphics.polygon("line", b.body:getWorldPoints(b.shape:getPoints()))
  local b = world.block
	love.graphics.polygon("line", b.body:getWorldPoints(b.shape:getPoints()))
end

return Module
