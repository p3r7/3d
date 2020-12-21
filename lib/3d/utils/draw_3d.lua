

local vertex_motion = include('lib/3d/utils/vertex_motion')
local model_convert = include('lib/3d/utils/model_convert')
local draw_2d = include('lib/3d/utils/draw_2d')

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
-- LINE

function draw_3d.line(v1, v2, l, mult, cam, draw_fn)
  l = l or 15
  mult = mult or 64
  cam = cam or {0, 0, 0}
  draw_fn = draw_fn or draw_2d.line
  local x0, y0 = vertex_motion.project(v1, mult, cam)
  local x1, y1 = vertex_motion.project(v2, mult, cam)
  draw_fn(x0, y0, x1, y1, col)
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
