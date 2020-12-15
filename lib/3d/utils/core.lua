

-- ------------------------------------------------------------------------
-- STRING

function split(str, pat)
  local t = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t, cap)
    end
    last_end = e+1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  return t
end


-- ------------------------------------------------------------------------
-- TABLE

function table.copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

function len(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


-- ------------------------------------------------------------------------
-- TRIGONOMETRY

--- Cos of value
-- Value is expected to be between 0..1 (instead of 0..360)
-- @param x value
function cos1(x)
  return math.cos(math.rad(x * 360))
end

--- Sin of value
-- Value is expected to be between 0..1 (instead of 0..360)
-- Result is sign-inverted, like in PICO-8
-- @param x value
function sin1(x)
  return math.sin(math.rad(x * 360))
end

--- Arctangent of point
-- @param dx point location on the x axis
-- @param dy point location on the y axis
function atan2(dx, dy)
  local q = 0.125
  local a = 0
  local ay = abs(dy)
  if ay == 0 and dx ==0 then
    ay = 0.001
  end
  if dx >= 0 then
    local r = (dx - ay) / (dx + ay)
    a = q - r*q
  else
    local r = (dx + ay) / (ay - dx)
    a = q*3 - r*q
  end
  if dy > 0 then
    a = -a
  end
  return a
end


-- ------------------------------------------------------------------------
-- PICO-8 style fns

function flr(x)
  return math.floor(x)
end


function rnd(x)
  if x == 0 then
    return 0
  end
  if (not x) then
    x = 1
  end
  x = x * 100000
  x = math.random(x) / 100000
  return x
end
