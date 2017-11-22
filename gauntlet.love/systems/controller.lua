

return defineUpdateSystem(hasComps('controller'),
  function(e, estore, input,res)
    forEachMatching(input.events.controller, 'id', e.controller.id, function(evt)
      print(evt.action)
      e.controller[evt.input] = evt.action
    end)
  end
)
