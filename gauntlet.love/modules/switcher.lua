-- local Dungeon = require 'modules/dungeon'
-- local Physbox = require 'modules/physbox'
local LevelEdit = require 'modules.leveledit'
local TryLevel = require 'modules.trylevel'
local GameRoot = require 'modules.gameroot'
local AnimTest = require 'modules.animtest'
local CarSim = require 'modules.carsim'

local function newModuleSub(module,key)
  local state = module.newWorld()
  return {key=key, module=module, state=state}
end

local function newWorld(opts)
  opts = opts or {}
  local model ={
    subs={
      gameroot=newModuleSub(GameRoot,"f1"),
      trylevel=newModuleSub(TryLevel,"f2"),
      leveledit=newModuleSub(LevelEdit,"f3"),
      animtest=newModuleSub(AnimTest,"f4"),
      carsim=newModuleSub(CarSim,"f5"),
      -- physbox=newModuleSub(Physbox,"f2"),
    },
  }
  model.current = opts.current or "carsim"
  return model
end

local function updateWorld(model,action)
  if action.type == 'keyboard' then
    if action.state == 'pressed' then
      for k,sub in pairs(model.subs) do
        if sub.key == action.key then
          model.current = k
          print("Switcher: '"..k.."'")
          if action.gui then
            print("Switcher: resetting world state")
            local sub = model.subs[model.current]
            sub.state = sub.module.newWorld()
          end
          return model, nil
        end
      end
      -- if action.key == 'escape' and action.shift then
      if action.key == 'escape' then
        return model, {{type="crozeng.reloadRootModule", opts={current=model.current}}}
      end
    end
  end
  local sub = model.subs[model.current]
  newstate, fx = sub.module.updateWorld(sub.state, action)
  sub.state = newstate
  return model, fx
end

local function drawWorld(model)
  local sub = model.subs[model.current]
  sub.module.drawWorld(sub.state)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
