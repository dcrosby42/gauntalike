local Comps = require 'comps'

-- local debug = print
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
    else
      error("Cannot build a phyics shape for sh.type="..tostring(sh.type).." -- "..tdebug(opts))
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
  if b.fixedRotation then
    obj.body:setFixedRotation(true)
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


local function getCollisionFuncs(collState)
  local beginContact = function(a,b,contact)
    local af,bf = contact:getFixtures()
    adx,ady = af:getBody():getLinearVelocity()
    bdx,bdy = bf:getBody():getLinearVelocity()
    local contactInfo = {
      a={
        vel={adx,ady},
      },
      b={
        vel={bdx,bdy},
      },
    }
    debug("beginContact a="..a:getUserData().." b="..b:getUserData())
    debug("  a={"..adx..","..ady.."} b={"..bdx..","..bdy.."}")
    table.insert(collState.begins, {a,b,contactInfo})
  end

  local endContact = function(a,b,_contact)
    debug("endContact a="..a:getUserData().." b="..b:getUserData())
    table.insert(collState.ends, {a,b})
    _contact = nil
    collectgarbage()
  end

  local preSolve = function(a,b,coll)
    -- local af,bf = coll:getFixtures()
    -- adx,ady = af:getBody():getLinearVelocity()
    -- bdx,bdy = bf:getBody():getLinearVelocity()
    -- debug("preSolve  a={"..adx..","..ady.."} b={"..bdx..","..bdy.."}")
  end

  local postSolve = function(a,b,coll,normalImpulse, tangentImpulse)
    -- print("postSolve",normalImpulse, tangentImpulse)
  end


  return beginContact, endContact, preSolve, postSolve
end

local function addCollision(hitEnt, hitComp, otherEnt, otherComp, contactInfo)
  local comp = hitEnt:newComp('collision',{
    myCid=hitComp.cid,
    theirCid=otherComp.cid,
    theirEid=otherComp.eid,
    contactInfo=contactInfo,
  })
  debug("  adding collision comp: hitEnt="..hitEnt.eid.." hitComp="..hitComp.cid.." otherEnt="..otherEnt.eid.." otherComp="..otherComp.cid.." --> "..Comp.debugString(comp))
end

local function dispatchCapturedCollisions(physWorld, collState, estore, input, res)
  if #collState.begins > 0 then
    debug("handleCollisions: num begins:"..#collState.begins)
    for _,c in ipairs(collState.begins) do
      local a,b,contactInfo = unpack(c)
      local aComp, aEnt = estore:getCompAndEntityForCid(a:getUserData())
      local bComp, bEnt = estore:getCompAndEntityForCid(b:getUserData())
      -- debug("  aComp[eid="..aComp.eid.." cid="..aComp.cid.."] aEnt.eid="..aEnt.eid)
      -- debug("  bComp[eid="..bComp.eid.." cid="..bComp.cid.."] bEnt.eid="..bEnt.eid)
      if aEnt and bEnt then
        addCollision(aEnt, aComp, bEnt, bComp, contactInfo)
        addCollision(bEnt, bComp, aEnt, aComp, contactInfo)
        -- aEnt:newComp('collision',{myCid=aComp.cid, theirCid=bComp.cid, theirEid=bEnt.eid})
        -- bEnt:newComp('collision',{myCid=bComp.cid, theirCid=aComp.cid, theirEid=aEnt.eid})
      else
        logError("!! Unable to register collision between '".. a:getUserData() .."' and '".. b:getUserData() .."'")
      end
    end

    collState.begins = {}
  end

  if #collState.ends > 0 then
    collState.ends = {}
  end
end


return defineUpdateSystem({'physicsWorld'},function(physEnt,estore,input,res)
  local world = physEnt.physicsWorld.world
  if world == 0 then
    world = newPhysicsWorld(physEnt.physicsWorld)
    local collState = {begins={}, ends={}}
    local beginCol,endCol, preSolve,postSolve = getCollisionFuncs(collState)
    world:setCallbacks(beginCol,endCol,preSolve,postSolve)
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
      obj = newPhysicsObject(world, res.bodyDefs.getBodyOpts(e.body, e, res))
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
  -- Iterate the physics world
  --
  world:update(input.dt)

  --
  -- Process Collisions
  --
  dispatchCapturedCollisions(world, physEnt.physicsWorld.collisions, estore, input, res)

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
