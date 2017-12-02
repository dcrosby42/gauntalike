local debug = print
local debug = function() end
local logError = print

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
      sh.x = sh.x or 0
      sh.y = sh.y or 0
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
    fixture:setUserData(opts.userData)
    if sh.sensor == true then
      fixture:setSensor(true)
    end
    if sh.filter then
      local f = sh.filter
      if f.cats then
        fixture:setCategory(unpack(f.cats))
      end
      if f.mask then
        fixture:setMask(unpack(f.mask))
      end
      if f.group then
        fixture:setGroupIndex(f.group)
      end
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
  debug("Creating new physics world")
  local w = love.physics.newWorld(comp.gx, comp.gy, comp.allowSleep)
  return w
end

local function getBodyOpts(body, e, res)
  local opts = {
    kind=body.kind,
    userData=body.cid,
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
      filter={
        -- cats={1},
      },
    }
  elseif body.kind == 'archer' then
    opts.body.angularDamping = 3
    opts.body.linearDamping = 6
    opts.shape={
      type='rectangle',
      x=5,
      y=5,
      width=35,
      height=20,
      filter={
        -- cats={1},
        -- mask={2},
      },
    }
  elseif body.kind == 'arrow' then
    -- opts.body.angularDamping = 3
    -- opts.body.linearDamping = 6
    opts.shape={
      type='rectangle',
      -- x=-5,
      -- y=5,
      width=35,
      height=2,
      filter={
        -- cats={1},
        -- mask={1},
      },
    }

  elseif body.kind == 'item' then
    opts.body.angularDamping = 1
    opts.body.linearDamping = 1
    opts.shape={
      type='circle',
      radius=15,
      sensor=true,
      -- height=15,
      filter={
        -- cats={1},
      },
    }
  end
  opts.shape.filter.group = body.group
  return opts
end

local function getCollisionFuncs(collState)
  local beginContact = function(a,b,coll)
    table.insert(collState.begins, {a,b,coll})
  end
  local endContact = function(a,b,coll)
    table.insert(collState.ends, {a,b,coll})
  end
  return beginContact, endContact
end

local function handleCollisions(physWorld, collState, estore, input, res)
  for _,c in ipairs(collState.begins) do
    local a,b,con = unpack(c)
    local aComp, aEnt = estore:getCompAndEntityForCid(a:getUserData())
    local bComp, bEnt = estore:getCompAndEntityForCid(b:getUserData())

    if aEnt and bEnt then
      aEnt:newComp('collision',{myCid=aComp.cid, theirCid=bComp.cid, theirEid=bEnt.eid})
      bEnt:newComp('collision',{myCid=bComp.cid, theirCid=aComp.cid, theirEid=aEnt.eid})
    else
      logError("!! Unable to register collision between '".. a:getUserData() .."' and '".. b:getUserData() .."'")
    end
  end

  collState.begins = {}
  collState.ends = {}
end

local Module = {}

Module.update = defineUpdateSystem({'physicsWorld'},function(physEnt,estore,input,res)
  local world = physEnt.physicsWorld.world
  if world == 0 then
    world = newPhysicsWorld(physEnt.physicsWorld)
    local collState = {begins={}, ends={}}
    local bc,ec = getCollisionFuncs(collState)
    world:setCallbacks(bc,ec)
    physEnt.physicsWorld.world = world
    physEnt.physicsWorld.collisions = collState
  end

  --
  -- SYNC: Components->to->Physics Objects
  --
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
      debug("New physics body for cid="..e.body.cid.." kind="..e.body.kind)
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
    debug("Removing phys obj cid="..id)
    local obj = oc[id]
    if obj then
      obj.body:destroy()
      oc[id] = nil
    end
  end

  --
  -- Update the physics world
  --
  world:update(input.dt)

  --
  -- Process Collisions
  --
  handleCollisions(world, physEnt.physicsWorld.collisions, estore, input, res)

  --
  -- SYNC: Physics Objects->to->Components
  --
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
    if e.body.debugDraw then
      local obj = res.caches.physicsObjects[e.body.cid]
      for _,shape in ipairs(obj.shapes) do
        if shape:type() == "CircleShape" then
          local x,y = obj.body:getWorldPoints(shape:getPoint())
          local r = shape:getRadius()
          love.graphics.circle("line", x,y,r)
        else
          love.graphics.polygon("line", obj.body:getWorldPoints(shape:getPoints()))
        end
      end
    end
  end)
end

return Module
