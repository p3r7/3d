

local axis = include('lib/3d/enums/axis')

util = require("util")
include('lib/3d/utils/core')


-- ------------------------------------------------------------------------

local vertex_motion = {}


-- ------------------------------------------------------------------------
-- NORMALIZE

function vertex_motion.normalized(v, max)
  max = max or 1
  local length = math.sqrt(v[axis.X]^2 + v[axis.Y]^2 + v[axis.Z]^2)
  if length == 0 then
    return v
  end
  local ratio = length/max
  return {v[axis.X]/ratio, v[axis.Y]/ratio, v[axis.Z]/ratio}
end


-- ------------------------------------------------------------------------
-- MODIFICATION

function vertex_motion.inverted(v)
  local inv =  table.copy(v)
  inv[1] = - inv[1]
  inv[2] = - inv[2]
  inv[3] = - inv[3]
  return inv
end


-- ------------------------------------------------------------------------
-- INTERPOLATION

-- Outputs interpolated vector going from % PERCENT of V2 from V1
function vertex_motion.interpolated(v1, v2, percent)
  local v = {}
  for i=1, 3 do
    v[i] = util.linlin(0, 100, v1[i], v2[i], percent)
  end
  return v
end


-- ------------------------------------------------------------------------
-- TRANSLATION

function vertex_motion.translate(v, a, t)
  v[a] = v[a] + t
end


-- ------------------------------------------------------------------------
-- ROTATION

function vertex_motion.rotate(v, a, s)
  local x,y,z
  if a == axis.X then
    x,y,z = 3,2,1
  elseif a == axis.Y then
    x,y,z = 1,3,2
  elseif a == axis.Z then
    x,y,z = 1,2,3
  end

  local new_x = cos1(s) * v[x] - sin1(s) * v[y]
  local new_y = sin1(s) * v[x] + cos1(s) * v[y]

  v[x] = new_x
  v[y] = new_y
  v[z] = v[z]
end


-- ------------------------------------------------------------------------
-- 2D PROJECTION

function vertex_motion.project(v, mult, cam)
  mult = mult or 64
  cam = cam or {0, 0, 0}

  local x = (v[1] - cam[1]) * mult / (v[3] - cam[3]) + 127/2
  local y = -(v[2] - cam[2]) * mult / (v[3] - cam[3]) + 64/2

  return x, y
end


-- ------------------------------------------------------------------------

return vertex_motion
