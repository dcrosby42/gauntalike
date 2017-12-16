local Module = {}

local function level1()
  return {
    name="Level 1",
    players={
      one={
        loc={100,100},
        r=0,
      },
      two={
        -- type="hero",
        name="Jack",
        loc={700,150},
        r=math.pi,
      },
    },
    items={
      -- [1]={ kind='key', loc={200,100}, },
      -- [1]={ kind='key', loc={300,200}, },
    },
    mobs={
      [1]={ kind='slime', loc={300,300}, },
      [2]={ kind='slime', loc={250,350}, },
      [3]={ kind='slime', loc={300,400}, },
    },
  }
end

local function level2()
  return {
    name="Level 1",
    players={
      two={
        name="Jack",
        loc={600,450},
        r=math.pi/2,
      },
    },
    items={
      -- [2]={ kind='key', loc={950,150}, },
    },
    mobs={
      [1]={ kind='slime', loc={300,300}, },
      [2]={ kind='slime', loc={300,350}, },
      [3]={ kind='slime', loc={300,400}, },
    },
  }
end

Module.getFactories = function()
  return {
    level1,
    level2,
  }
end

return Module
