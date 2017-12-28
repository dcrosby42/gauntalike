local Module = {}

local PI_2 = math.pi / 2
local arcTan = math.atan2
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

local function hypot(x,y)
  return sqrt(x*x + y*y)
end

local function rotatePts(pts, angle)
  local rpts = {}
  for i=1,#pts-1,2 do
    local x = pts[i]
    local y = pts[i+1]
    local r = arcTan(x,y)
    local d = hypot(x,y)
    rpts[i] = d*cos(r+angle)
    rpts[i+1] = d*sin(r+angle)
  end
  return rpts
end

local function movePts(pts, dx,dy)
  local rpts = {}
  for i=1,#pts-1,2 do
    rpts[i] = pts[i]+dx
    rpts[i+1] = pts[i+1]+dy
  end
  return rpts
end


Module.getBodyOpts = function(body, e, res)
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
      x=2,
      y=0,
      width=26,
      height=5,
      filter={
        -- cats={1},
        -- mask={1},
      },
    }
  elseif body.kind == 'survivor' then
    opts.body.angularDamping = 3
    opts.body.linearDamping = 6
    opts.shape={
      type='rectangle',
      x=-15,
      y=2,
      width=40,
      height=30,
      filter={
        -- cats={1},
        -- mask={2},
      },
    }

  elseif body.kind == 'gauntletHero' then
    opts.body.angularDamping = 3
    opts.body.linearDamping = 6
    opts.body.fixedRotation = true
    opts.shape={
      type='rectangle',
      x=0,
      y=0,
      width=32,
      height=32,
      filter={
        -- cats={1},
        -- mask={2},
      },
    }

  elseif body.kind == 'item' then
    opts.body.angularDamping = 1
    opts.body.linearDamping = 1
    opts.shape={
      type='circle',
      radius=10,
      sensor=true,
      -- height=15,
      filter={
        -- cats={1},
      },
    }

  elseif body.kind == 'mob' then
    opts.body.angularDamping = 4
    opts.body.linearDamping = 4
    opts.body.mass = 2
    opts.shape={
      type='circle',
      radius=15,
      -- height=15,
      filter={
        -- cats={1},
      },
    }

  elseif body.kind == 'door' then
    if e.door then
      opts.body.type = 'static'
      opts.shape={type='rectangle'}
      opts.shape.x = e.door.x or 0
      opts.shape.y = e.door.y or 0
      opts.shape.width = e.door.w or 10
      opts.shape.height = e.door.h or 10
    else
      error("body.kind=='door' requires the entity has also got a 'door' component")
    end
  elseif body.kind == 'wall' then
    if e.wall then
      opts.body.type = 'static'
      opts.shape={type='rectangle'}
      opts.shape.x = e.wall.x or 0
      opts.shape.y = e.wall.y or 0
      opts.shape.width = e.wall.w or 10
      opts.shape.height = e.wall.h or 10
    else
      error("body.kind=='door' requires the entity has also got a 'door' component")
    end

  elseif body.kind == 'roomWalls' then
    if e.roomWalls then
      -- -- Simple rect border:
      -- local roomw=1024
      -- local roomw_2=roomw/2
      -- local roomh=768
      -- local roomh_2=roomh/2
      -- local pts = {roomw_2,roomh_2, -roomw_2,roomh_2, -roomw_2,-roomh_2, roomw_2,-roomh_2}
      -- opts.body.type = 'static'
      -- opts.shapes={
      --   {
      --     type='chain',
      --     loop=true,
      --     pts=pts,
      --   },
      -- }

      -- -- Special corner shapes:
      opts.body.type = 'static'
      local hth = 20
      local vth = hth
      local w = 320
      local h = 320
      local w_2 = w/2
      local h_2 = h/2
      local cw = 35
      local pts = {-w_2,h_2, -w_2,-h_2, w_2,-h_2, w_2,-h_2+vth, 0-cw,-h_2+vth, -w_2+hth,0-cw, -w_2+hth,h_2}
      local ehd=1024/2-w_2
      local evd=768/2-h_2
      local pts1 = movePts(pts, -ehd,-evd)
      local pts2 = movePts(rotatePts(pts,math.pi/2), ehd,-evd)
      local pts3 = movePts(rotatePts(pts,math.pi), ehd,evd)
      local pts4 = movePts(rotatePts(pts,-math.pi/2), -ehd,evd)
      -- local pts2 = movePts(rotatePts(pts,0), 1024/2-w_2,0)
      opts.shapes={
        {
          type='chain',
          loop=true,
          pts=pts1,
        },
        {
          type='chain',
          loop=true,
          pts=pts2,
        },
        {
          type='chain',
          loop=true,
          pts=pts3,
        },
        {
          type='chain',
          loop=true,
          pts=pts4,
        },
      }
    end

  else
    error("Dunno how to generate physics opts for body.kind="..tostring(body.kind).." -- "..tdebug(body))

  end
  if body.group and opts.shape then
    if not opts.shape.filter then
      opts.shape.filter={}
    end
    opts.shape.filter.group = body.group
  end
  return opts
end

return Module
