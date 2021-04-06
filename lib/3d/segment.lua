

local vertex_motion = include('lib/3d/utils/vertex_motion')
local draw_3d = include('lib/3d/utils/draw_3d')


-- ------------------------------------------------------------------------

local Segment = {}
Segment.__index = Segment


-- ------------------------------------------------------------------------
-- CONSTRUCTORS

function Segment.new(coord1, coord2)
  local p = setmetatable({}, Segment)

  p.v1 = coord1
  p.v2 = coord2 or {0,0,0}

  p.translation = {0,0,0}
  p.rotation = {0,0,0}

  return p
end


-- ------------------------------------------------------------------------
-- TRANSLATION

function Segment:translate_axis(axis, translation)
  self.translation[axis] = self.translation[axis] + translation
  vertex_motion.translate(self.v1, axis, translation)
  vertex_motion.translate(self.v2, axis, translation)
end

function Segment:translate_by_vector(trans_vec)
  for a, t in ipairs(trans_vec) do
    self:translate_axis(a, t)
  end
end

function Segment:translate(a1, a2)
  if a2 == nil and type(a1) == "table" then
    self:translate_by_vector(a1)
  else
    self:translate_axis(a1, a2)
  end
end

-- ------------------------------------------------------------------------
-- ROTATION

function Segment:rotate_axis(axis, speed)
  self.rotation[axis] = self.rotation[axis] + speed
  vertex_motion.rotate(self.v1, axis, speed)
  vertex_motion.rotate(self.v2, axis, speed)
end

function Segment:rotate_by_vector(rot_vec)
  for a, s in ipairs(rot_vec) do
    self:rotate_axis(a, s)
  end
end

function Segment:rotate(a1, a2)
  if a2 == nil and type(a1) == "table" then
    self:rotate_by_vector(a1)
  else
    self:rotate_axis(a1, a2)
  end
end


-- ------------------------------------------------------------------------
-- DRAW

function Segment:draw(l, draw_style, mult, cam, draw_fn)
  l = l or 15
  mult = mult or 64
  cam = cam or {0, 0, 0}
  draw_3d.line(self.v1, self.v2, l, mult, cam, draw_fn)
end


-- ------------------------------------------------------------------------

return Segment
