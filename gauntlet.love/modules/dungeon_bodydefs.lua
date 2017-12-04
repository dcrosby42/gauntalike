local Module = {}

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
  else
    error("Dunno how to generate physics opts for body.kind="..tostring(body.kind).." -- "..tdebug(body))
  end
  if body.group then
    if not opts.shape.filter then
      opts.shape.filter={}
    end
    opts.shape.filter.group = body.group
  end
  return opts
end

return Module
