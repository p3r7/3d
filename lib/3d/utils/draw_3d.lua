

include('lib/3d/utils/core')
local vertex_motion = include('lib/3d/utils/vertex_motion')
local vector_motion = include('lib/3d/utils/vector_motion')
local model_convert = include('lib/3d/utils/model_convert')
local draw_2d = include('lib/3d/utils/draw_2d')
local axis = include('lib/3d/enums/axis')

local inspect = include('lib/inspect')


-- ------------------------------------------------------------------------

local draw_3d = {}


-- ------------------------------------------------------------------------
-- VERTEX / POINT

function draw_3d.point(v, l, mult, cam, draw_fn)
  l = l or 15
  mult = mult or 64
  cam = cam or {0, 0, 0}
  draw_fn = draw_fn or draw_2d.point
  local x, y = vertex_motion.project(v, mult, cam)
  draw_fn(x, y, l)
end


-- ------------------------------------------------------------------------
-- SPHERE

function draw_3d.sphere(v, r, l, mult, cam, draw_fn)
  l = l or 15
  mult = mult or 64
  cam = cam or {0, 0, 0}
  draw_fn = draw_fn or draw_2d.circle
  local x, y = vertex_motion.project(v, mult, cam)
  local r = util.clamp(r - v[3] + cam[3], 1, 50)
  draw_fn(x, y, r, l)
end


-- ------------------------------------------------------------------------
-- CIRCLE

-- NB: we're drawing a cirle by doing a 3D rotation of a point
function draw_3d.circle(center_v, r, tilt_v, r_v, l, mult, cam, draw_fn)
  l = l or 15
  mult = mult or 64
  cam = cam or {0, 0, 0}

  local s = 0.01
  local circle_v = table.copy(r_v)

  -- debug: radius vector
  -- draw_3d.line({0,0,0}, r_v, l, mult, cam, draw_fn)


  local cc_v = {}
  for i = 0, 100 do
    cc_v[1] = center_v[1] + circle_v[1]
    cc_v[2] = center_v[2] + circle_v[2]
    cc_v[3] = center_v[3] + circle_v[3]
    draw_3d.point(cc_v, l, mult, cam, draw_fn)
    vertex_motion.rotate(circle_v, axis.X, s * tilt_v[axis.X])
    vertex_motion.rotate(circle_v, axis.Y, s * tilt_v[axis.Y])
    vertex_motion.rotate(circle_v, axis.Z, s * tilt_v[axis.Z])
  end

  -- local tilt_v2 = table.copy(tilt_v)
  -- for i = 0, 500 do
  --   draw_3d.point(tilt_v2, l, mult, cam, draw_fn)
  --   vertex_motion.rotate(tilt_v2, axis.X, s * circle_v[axis.X])
  --   vertex_motion.rotate(tilt_v2, axis.Y, s * circle_v[axis.Y])
  --   vertex_motion.rotate(tilt_v2, axis.Z, s * circle_v[axis.Z])
  -- end
end


-- ------------------------------------------------------------------------
-- LINE

function draw_3d.line(v1, v2, l, mult, cam, draw_fn)
  l = l or 15
  mult = mult or 64
  cam = cam or {0, 0, 0}
  draw_fn = draw_fn or draw_2d.line
  local x0, y0 = vertex_motion.project(v1, mult, cam)
  local x1, y1 = vertex_motion.project(v2, mult, cam)
  draw_fn(x0, y0, x1, y1, l)
end


-- ------------------------------------------------------------------------
-- FACE

function draw_3d.face(f, l, filled, mult, cam, draw_fn)
  l = l or 15
  mult = mult or 64
  cam = cam or {0, 0, 0}
  draw_fn = draw_fn or draw_2d.polygon
  local edges = model_convert.face_2_edges(f)
  for _i, l in ipairs(edges) do
    local v1, v2 = l[1], l[2]
    local x0, y0 = vertex_motion.project(v1, mult, cam)
    local x1, y1 = vertex_motion.project(v2, mult, cam)
    l[1] = {x0, y0}
    l[2] = {x1, y1}
  end
  draw_fn(edges, l, filled)
end


-- ------------------------------------------------------------------------

return draw_3d
