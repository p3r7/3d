

local axis = include('lib/3d/enums/axis')
include('lib/3d/utils/core')


-- ------------------------------------------------------------------------

local vertex_motion = {}


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
