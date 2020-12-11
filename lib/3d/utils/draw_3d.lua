

local vertex_motion = include('lib/3d/utils/vertex_motion')
local model_convert = include('lib/3d/utils/model_convert')
local p8 = include('lib/p8')


-- ------------------------------------------------------------------------

local draw_3d = {}


-- ------------------------------------------------------------------------
-- VERTEX / POINT

function draw_3d.point(v, col, mult, cam, draw_fn)
  col = col or 15
  mult = mult or 64
  cam = cam or {0, 0, 0}
  draw_fn = draw_fn or p8.pset
  local x, y = vertex_motion.project(v, mult, cam)
  draw_fn(x, y, col)
end


-- ------------------------------------------------------------------------
-- LINE

function draw_3d.line(v1, v2, col, mult, cam, draw_fn)
  col = col or 15
  mult = mult or 64
  cam = cam or {0, 0, 0}
  draw_fn = draw_fn or p8.line
  local x0, y0 = vertex_motion.project(v1, mult, cam)
  local x1, y1 = vertex_motion.project(v2, mult, cam)
  draw_fn(x0, y0, x1, y1, col)
end


-- ------------------------------------------------------------------------
-- FACE

-- TODO: allow overrding draw_fn
function draw_3d.face(f, col, mult, cam, _draw_fn)
  col = col or 15
  mult = mult or 64
  cam = cam or {0, 0, 0}
  local edges = model_convert.face_2_edges(f)
  for _i, l in ipairs(edges) do
    draw_3d.line(l[1], l[2], col, mult, cam)
  end
end


-- ------------------------------------------------------------------------

return draw_3d
