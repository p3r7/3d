

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
function draw_3d.circle(center_v, r, tilt_v, l, mult, cam, draw_fn)
  l = l or 15
  mult = mult or 64
  cam = cam or {0, 0, 0}

  local s = 0.01
  -- NB: the trick is to make a slightly different copy of the tilt vector and then make the cross product
  -- this should give us a perpendicular vector, i.e. corresponding to the circle
  local intersecting_v = table.copy(tilt_v)
  intersecting_v[1] = intersecting_v[1] + 0.1

  -- tabutil.print(intersecting_v)

  circle_v = vector_motion.cross_product(
    {
      {center_v[axis.X], tilt_v[axis.X]},
      {center_v[axis.Y], tilt_v[axis.Y]},
      {center_v[axis.Z], tilt_v[axis.Z]},
    },
    {
      {center_v[axis.X], intersecting_v[axis.X]},
      {center_v[axis.Y], intersecting_v[axis.Y]},
      {center_v[axis.Z], intersecting_v[axis.Z]},
    }
  )

  circle_v = vertex_motion.normalized(circle_v)

  for i = 0, 500 do
    draw_3d.point(circle_v, l, mult, cam, draw_fn)
    vertex_motion.rotate(circle_v, axis.X, s * tilt_v[axis.X])
    vertex_motion.rotate(circle_v, axis.Y, s * tilt_v[axis.Y])
    vertex_motion.rotate(circle_v, axis.Z, s * tilt_v[axis.Z])
  end
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
