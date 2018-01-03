
-- helpers.lua

-- Messy grab-bag of any useful helper funcs and extensions I want globally
-- available.


-- numberlua = require 'vendor/numberlua' -- intentionally global
-- bit32 = numberlua.bit32 -- intentionally global

function flattenTable(t)
  s = ""
  for k,v in pairs(t) do
    if #s > 0 then s = s .. " " end
    s = s .. tostring(k) .. "=" .. tostring(v)
  end
  return s
end

tflatten = flattenTable

function tcount(t)
  local ct = 0
  for _,_ in pairs(t) do ct = ct + 1 end
  return ct
end

function tcountby(t,key)
  local total = 0
  local counts = {}
  for _,item in pairs(t) do
    total = total + 1
    local k = item[key]
    if not counts[k] then counts[k] = 0 end
    counts[k] = counts[k] + 1
  end
  return counts,total
end

function tcopy(orig, defaults)
  if orig == nil then orig = {} end
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = orig_value
    end
    if defaults then
      for def_key, def_value in pairs(defaults) do
        if copy[def_key] == nil then
          copy[def_key] = def_value
        end
      end
    end
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function shallowclone(src)
  if src == nil then return {} end
  local dest={}
  for k,v in pairs(src) do
    dest[k]=v
  end
  return dest
end

function tcopydeep(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[tcopydeep(orig_key)] = tcopydeep(orig_value)
    end
    setmetatable(copy, tcopydeep(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function tkeys(t)
  local keyset={}
  local n=0
  for k,v in pairs(t) do
    n=n+1
    keyset[n]=k
  end
  return keyset
end

function numkeys(t)
  return #tkeys(t)
end

function tsetdeep(t, path, value)
  local key = table.remove(path,1)
  if #path == 0 then
    t[key] = value
  else
    local next = t[key]
    if not next then
      next = {}
      t[key] = next
    end
    tsetdeep(next,path,value)
  end
end

function tgetdeep(t,path)
  local key = table.remove(path,1)
  local v = t[key]
  if v == nil then return nil end
  if #path == 0 then return v end
  if type(v) == "table" then
    return tgetdeep(v,path)
  else
    return nil
  end
end

function lcopy(src)
  local c = {}
  for i=1,#src do
    c[i] = src[i]
  end
  return c
end

function removeObject(list,obj)
  local ridx = 0
  for i=1,#list do
    if list[i] == obj then
      ridx = i
      break
    end
  end
  if ridx > 0 then
    table.remove(list,ridx)
    return ridx
  end
  return nil
end

function tmerge(left,right)
  for k,v in pairs(right) do
    left[k] = v
  end
end

function tappend(t,x)
  t[#t+1] = x
end

function tindexOf(t,v)
  for i,x in ipairs(t) do
    if x == v then return i end
  end
  return nil
end

function tconcat(t1,t2)
  if not t2 then return t1 end
  for i=1,#t2 do
    t1[#t1+1] = t2[i]
  end
  return t1
end

function tdebug(t,ind)
  if not ind then ind = "" end

  if type(t) == "table" then
    local lines = {}
    if ind ~= "" then lines[1] = "" end  -- inner tables need to bump down a line
    local count = 0
    for k,v in pairs(t) do
      local s = ind .. k .. ": " .. tdebug(v,ind.."  ")
      tappend(lines, s)
      count = count +1
    end
    if count > 0 then
      return table.concat(lines,"\n")
    else
      return "{}"
    end
  else
    return tostring(t)
  end
end

function tdebug1(t,ind)
  if type(t) == 'table' then
    local s = ''
    if not ind then
      ind = '  '
    end
    for k,v in pairs(t) do
      s = s .. ind ..tostring(k)..": "..tostring(v).."\n"
    end
    return s
  else
    return ind..tostring(t)
  end
end

function keyvalsearch(t,matchFn,callbackFn)
  for _,v in pairs(t) do
    if fn(k,v) then callbackFn(k,v) end
  end
end

function valsearch(t,matchFn,callbackFn)
  for _,v in pairs(t) do
    if fn(v) then callbackFn(v) end
  end
end

function valsearchfirst(t,matchFn,callbackFn)
  for _,v in pairs(t) do
    if fn(v) then return callbackFn(v) end
  end
end


function tfind(t, fn)
  for k,v in pairs(t) do
    if fn(v,k) == true then
      return v
    end
  end
end
function tfindby(t,key,val)
  for _,v in pairs(t) do
    if v[key] == val then
      return v
    end
  end
end
function tfindall(t,fn)
  local res = {}
  for k,v in pairs(t) do
    if fn(v,k) == true then
      table.insert(res, v)
    end
  end
  return res
end
function tfindallby(t,key,val)
  local res = {}
  for _,v in pairs(t) do
    if v[key] == val then
      table.insert(res, v)
    end
  end
  return res
end

function lcontains(list, item)
  for i=1,#list do
    if list[i] == item then return true end
  end
  return false
end
function lfind(list, fn)
  for i=1,#list do
    if fn(list[i],i) == true then
      return v
    end
  end
end
function lfindby(list,key,val)
  for i=1,#list do
    if list[i][key] == val then
      return list[i]
    end
  end
end
function lfindall(list,fn)
  local res = {}
  for i=1,#list do
    if fn(list[i],i) == true then
      table.insert(res, list[i])
    end
  end
  return res
end
function lfindallby(t,key,val)
  local res = {}
  for i=1,#list do
    if list[i][key] == val then
      table.insert(res, list[i])
    end
  end
  return res
end

function iterateFuncs(funcs)
  return function(a,b,c)
    for _,fn in ipairs(funcs) do
      fn(a,b,c)
    end
  end
end

function math.dist(x1,y1, x2,y2)
  return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function math.pointinrect(x1,y1, rx,ry,rw,rh)
  return x1 >= rx and x1 < rx+rw and y1 >= ry and y1 < ry + rh
end

function math.pointinbounds(x1,y1, b)
  return x1 >= b.x and x1 < b.x+b.w and y1 >= b.y and y1 < b.y + b.h
end

function math.clamp(val, min, max)
  if val < min then
    return min, true
  elseif val > max then
    return max, true
  else
    return val, false
  end
end

function math.round0(num)
  return math.floor(num + 0.5)
end

function math.round1(num)
  return math.floor(num * 10 + 0.5) / 10
end

function math.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


function forEach(list,fn)
  if list then
    for i,x in ipairs(list) do
      fn(i,x)
    end
  end
end

function forEachMatching(list, key, val, fn)
  if list then
    for _,element in ipairs(list) do
      if element[key] == val then
        fn(element)
      end
    end
  end
end

function offsetBounds(t, w,h, wr, hr)
  t.w = w
  t.h = h
  t.offx = wr * w
  t.offy = hr * h
  return t
end

function lazy(fn)
  local called = false
  local value
  return function()
    if not called then
      value = fn()
      called = true
    end
    return value
  end
end

function lazytable(list, mapper)
  local m = {}
  for _,item in ipairs(list) do
    local k = item
    m[k] = lazy(function() return mapper(k) end)
  end
  return m
end

function makeTimeLookupFunc(data,opts)
  opts = tcopy(opts,{loop=true})
  return function(t)
    local newVal = nil
    if opts.loop then
      t = t % data[#data-1]
    end
    for i=1, #data, 2 do
      if t >= data[i] then
        newVal = data[i+1]
      else
        return newVal
      end
    end
    return newVal
  end
end

function dirname(fname)
  return string.gsub(fname:match("(.*/)[^%/]+$"), "/$", "")
end

function split(str,char)
  local res = {}
  for i in string.gmatch(str, "[^"..char.."]+") do
    table.insert(res,i)
  end
  return res
end

function floatstr(x, places)
  places = places or 3
  return ""..math.round(x,places)
end

-- split a string
-- function string:split(delimiter)
--   local result = { }
--   local from  = 1
--   local delim_from, delim_to = string.find( self, delimiter, from  )
--   while delim_from do
--     table.insert( result, string.sub( self, from , delim_from-1 ) )
--     from  = delim_to + 1
--     delim_from, delim_to = string.find( self, delimiter, from  )
--   end
--   table.insert( result, string.sub( self, from  ) )
--   return result
-- end
