local Module = {}

local PI_2 = math.pi / 2
local arcTan = math.atan2
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

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

  elseif body.kind == 'car' then
    opts.body.angularDamping = 3
    opts.body.linearDamping = 6
    opts.body.fixedRotation = true
    opts.shape={
      type='rectangle',
      x=0,
      y=0,
      width=100,
      height=60,
      filter={
        -- cats={1},
        -- mask={2},
      },
    }

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
