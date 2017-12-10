local Comp = require 'ecs/component'

Comp.define("bounds", {'offx',0,'offy',0,'w',0,'h',0})
Comp.define("pos", {'x',0,'y',0, 'sx',1,'sy',1,'r',0,'ox',0,'oy',0})
Comp.define("vel", {'dx',0,'dy',0})

Comp.define("tag", {})

Comp.define('script',{'scriptName','','on','call'})

Comp.define("timer", {'t',0, 'reset',0, 'countDown',true, 'loop',false, 'alarm',false})

Comp.define("controller", {'id','','leftx',0,'lefty',0,'rightx',0,'righty',0,'r1',0,'r2',0,'r3',0,'l1',0,'l2',0,'l3',0,'face1',0,'face2',0,'face3',0,'face4',0, 'select',0,'start',0})


Comp.define("img", {'imgId','','offx',0,'offy',0,'sx',1,'sy',1,'r',0,'color',{255,255,255}})

Comp.define("label", {'text','Label', 'color', {0,0,0},'font',nil, 'width', nil, 'align',nilj, 'height',nil,'valign',nil})

Comp.define("circle", {'offx',0,'offy',0,'radius',0, 'color',{0,0,0}})
Comp.define("rect", {'offx',0,'offy',0,'w',0, 'h',0, 'color',{0,0,0}, 'style','fill'})

Comp.define("event", {'data',''})

Comp.define("output", {'kind',''})

Comp.define("debug", {'value',''})

Comp.define("hero", {'id','','bow','rest', 'bowtimer',0, 'speed',200,'hiSpeed',200,'loSpeed',100,'numKeys',0})
Comp.define("arrow", {})
Comp.define("door", {'x',0,'y',0,'w',0,'h',0})
Comp.define("wall", {'x',0,'y',0,'w',0,'h',0})
Comp.define("roomWalls", {})
Comp.define("item", {'kind',''})

Comp.define('physicsWorld', {'world',0, 'gx',0,'gy',0,'allowSleep',true})
Comp.define('body', {'kind','', 'group',0,'debugDraw',false})
Comp.define("force", {'fx',0,'fy',0})

Comp.define("collision", {'myCid','','theirCid','','theirEid',''})
Comp.define("scoreboard", {})
