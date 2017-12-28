local Module = {}

local function level1()
  return {
    name="Level 1",
    players={
      {
        id="two",
        type="elf",
        name="Green Elf",
        loc={700,150},
        r=0,
      },
    },
    items={
      -- [1]={ kind='key', loc={200,100}, },
      -- [1]={ kind='key', loc={300,200}, },
    },
    mobs={
      { kind='slime', loc={300,300}, },
      { kind='slime', loc={250,350}, },
      { kind='slime', loc={300,400}, },
    },
  }
end

local function level2()
  return {
    name="Level 1",
    players={
      {
        id="two",
        type="elf",
        name="Green Elf",
        loc={700,150},
        r=0,
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
