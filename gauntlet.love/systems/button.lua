local Comp = require 'ecs/component'

Comp.define("mouse_sensor", {'on','pressed','eventName','','eventData',''})

return defineUpdateSystem(
  {'mouse_sensor','pos','bounds'},
  function(e, estore,input,res)
    local sensor = e.mouse_sensor
    local x,y = getPos(e)
    for _,evt in ipairs(input.events.mouse or {}) do
      if evt.state == sensor.on then
        local b = e.bounds
        if math.pointinrect(evt.x,evt.y,  x+b.offx, y+b.offy, b.w, b.h) then
          estore:newComp(e, 'event', {name=sensor.eventName, data=sensor.eventData})
        end
      end
    end
  end
)
