
return function(estore, input,res)
  estore:search(
    hasComps('controller', 'pos'),
    function(e)
      e.pos.x = e.pos.x + (600 * e.controller.leftx * input.dt)
    end
  )
end
