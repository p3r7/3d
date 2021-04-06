

local vertex_motion = include('lib/3d/utils/vertex_motion')
local draw_3d = include('lib/3d/utils/draw_3d')


-- ------------------------------------------------------------------------

local Point = {}
Point.__index = Point


-- ------------------------------------------------------------------------
-- CONSTRUCTORS

function Point.new(coord)
  local p = setmetatable({}, Point)

  p.center = coord or {0,0,0}

  p.translation = {0,0,0}

  return p
end


-- ------------------------------------------------------------------------
-- TRANSLATION

function Point:translate_axis(axis, translation)
  self.translation[axis] = self.translation[axis] + translation
  vertex_motion.translate(self.center, axis, translation)
end

function Point:translate_by_vector(trans_vec)
  for a, t in ipairs(trans_vec) do
    self:translate_axis(a, t)
  end
end

function Point:translate(a1, a2)
  if a2 == nil and type(a1) == "table" then
    self:translate_by_vector(a1)
  else
    self:translate_axis(a1, a2)
  end
end


-- ------------------------------------------------------------------------
-- DRAW

function Point:draw(l, draw_style, mult, cam, draw_fn)
  l = l or 15
  mult = mult or 64
  cam = cam or {0, 0, 0}
  draw_3d.point(self.center, l, mult, cam, draw_fn)
end


-- ------------------------------------------------------------------------

return Point
