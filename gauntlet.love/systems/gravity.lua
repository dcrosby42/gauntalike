
return defineUpdateSystem(
  {'pos'}, 
  function(e, estore,input,res)
    e.pos.y = e.pos.y + 1
  end
)
