-- opts
--   type | ...
--   body
--     type  | (dynamic) static kinematic
--     x | 0
--     y | 0
--   shapes
--     []
--       type | rectangle circle chain edge (polygon)
--       x (for circle and rectangle only)
--       y (for circle and rectangle only)
--       pts (for edge, chain and polygon)
--       width (for rectangles only)
--       height (for rectangles only)
--       radius (for circles only)
--       loop (for chain only)
--       sensor | true (false)
--       userData | nil
local function newPhysicsObject(physicsWorld,opts)
  print("New physics object")
  local obj = {
    type=opts.type,
    body={},
    shape={},
    fixture={},
    shapes={},
    fixtures={},
  }

  local b = opts.body
  b.x = b.x or 0
  b.y = b.y or 0
  b.type = b.type or "dynamic"
  obj.body = love.physics.newBody(physicsWorld, b.x, b.y, b.type)

  local ss = nil
  local singleShape = false
  if opts.shapes then
    ss = opts.shapes
  elseif opts.shape then
    ss = {opts.shape}
  else
    error("Provide opts.shape or opts.shape")
  end

  for _,sh in ipairs(ss) do
    local shape = nil
    if sh.type == 'rectangle' then
      sh.x = sh.x or 0
      sh.y = sh.y or 0
      sh.width = sh.width or 0
      sh.height = sh.height or 0
      shape = love.physics.newRectangleShape(sh.x,sh.y,sh.width,sh.height,0)
    elseif sh.type == 'circle' then
      sh.radius = sh.radius or 1
      shape = love.physics.newCircleShape(sh.x,sh.y, sh.radius)
    elseif sh.type == 'chain' then
      sh.pts = sh.pts or {}
      shape = love.physics.newChainShape(sh.loop, unpack(sh.pts))
    elseif sh.type == 'edge' then
      sh.pts = sh.pts or {}
      shape = love.physics.newEdgeShape(unpack(sh.pts))
    elseif sh.type == 'polygon' then
      sh.pts = sh.pts or {}
      shape = love.physics.newPolygonShape(sh.pts)
    end
    table.insert(obj.shapes, shape)

    local fixture = love.physics.newFixture(obj.body, shape)
    if sh.sensor == true then
      fixture:setSensor(true)
    end
    if sh.userData ~= nil then
      fixture:setUserData(sh.userData)
    end
    table.insert(obj.fixtures, fixture)
  end

  if #obj.shapes > 0 then
    obj.shape = obj.shapes[1]
    obj.fixture = obj.fixtures[1]
  end

  if b.mass then
    obj.body:setMass(b.mass)
  end
  if b.linearDamping then
    obj.body:setLinearDamping(b.linearDamping)
  end
  if b.angularDamping then
    obj.body:setAngularDamping(b.angularDamping)
  end

  return obj
end

local function updateBodyObject(obj,body,e,estore,input,res)
  obj.body:setPosition(getPos(e))
  obj.body:setAngle(e.pos.r)
  if e.vel then
    obj.body:setLinearVelocity(e.vel.dx, e.vel.dy)
  end
  if e.force then
    obj.body:applyForce(e.force.fx, e.force.fy)
  end
end

local function updateBodyComponent(obj,body,e,estore,input,res)
  local x,y = obj.body:getPosition()
  e.pos.x = x
  e.pos.y = y
  e.pos.r = obj.body:getAngle()
  local dx,dy = obj.body:getLinearVelocity()
  e.vel.dx = dx
  e.vel.dy = dy
end

local function newPhysicsWorld(comp)
    print("Creating new physics world")
  local w = love.physics.newWorld(comp.gx, comp.gy, comp.allowSleep)
  return w
end

local function getBodyOpts(body, e, res)
  local opts = {
    kind=body.kind,
    body={
      type="dynamic",
      x=0,
      y=0,
    },
  }
  if body.kind == 'testbox' then
    opts.body.angularDamping = 1
    opts.body.linearDamping = 1
    opts.shape={
      type='rectangle',
      width=100,
      height=100,
    }
  elseif body.kind == 'archer' then
    opts.body.angularDamping = 3
    opts.body.linearDamping = 3
    opts.shape={
      type='rectangle',
      width=100,
      height=30,
    }
  end
  return opts
end

local Module = {}

Module.update = defineUpdateSystem({'physicsWorld'},function(physEnt,estore,input,res)
  local world = physEnt.physicsWorld.world
  if world == 0 then
    world = newPhysicsWorld(physEnt.physicsWorld)
    physEnt.physicsWorld.world = world
  end

  local oc = res.caches.physicsObjects
  if not oc then
    oc = {}
    res.caches.physicsObjects = oc
  end
  local sawIds = {}
  estore:walkEntity(physEnt, hasComps('body'), function(e)
    local id = e.body.cid
    table.insert(sawIds,id)
    -- See if there's a cached phys obj for this component
    local obj = oc[id]
    if obj == nil then
      -- newly-added physics component -> create new obj in cache
      obj = newPhysicsObject(world, getBodyOpts(e.body, e, res))
      oc[id] = obj
    end
    updateBodyObject(obj,e.body,e,estore,input,res)
  end)

  -- Remove cached objects whose ids weren't seen in the last pass through the physics components
  local remIds = {}
  for id,obj in pairs(oc) do
    if not lcontains(sawIds, id) then
      table.insert(remIds, id)
    end
  end
  for _,id in ipairs(remIds) do
    oc[id] = nil
  end

  world:update(input.dt)

  estore:walkEntity(physEnt, hasComps('body'), function(e)
    local id = e.body.cid
    local obj = oc[id]
    if obj then
      updateBodyComponent(obj,e.body,e,estore,input,res)
    else
      -- ? wtf
    end
  end)

end)

Module.draw = function(physWorldE, estore,input,res)
  love.graphics.setColor(255,255,255)
  estore:walkEntity(physWorldE, hasComps('body'), function(e)
    local obj = res.caches.physicsObjects[e.body.cid]
    -- print(tdebug(obj))
    --
    --
    for _,shape in ipairs(obj.shapes) do
    --   -- print(tdebug(shape:getPoints()))
    --   local pts =
    --   -- print(tflatten(pts))
      love.graphics.polygon("line", obj.body:getWorldPoints(shape:getPoints()))
    end
  end)
end

return Module
