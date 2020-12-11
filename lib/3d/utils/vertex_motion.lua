

local axis = include('lib/3d/enums/axis')
local p8 = include('lib/p8')


-- ------------------------------------------------------------------------

local vertex_motion = {}


-- ------------------------------------------------------------------------
-- TRANSLATION

function vertex_motion.translate(v, t)
  v = {v[1]+t[1], v[2]+t[2], v[3]+t[3]}
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

  local new_x = p8.cos(s) * v[x] - p8.sin(s) * v[y]
  local new_y = p8.sin(s) * v[x] + p8.cos(s) * v[y]

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
