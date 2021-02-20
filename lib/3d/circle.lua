

local vertex_motion = include('lib/3d/utils/vertex_motion')
local draw_3d = include('lib/3d/utils/draw_3d')


-- ------------------------------------------------------------------------

local Circle = {}
Circle.__index = Circle


-- ------------------------------------------------------------------------
-- CONSTRUCTORS

function Circle.new(r, center_coord, tilt)
  local p = setmetatable({}, Circle)

  p.r = r
  p.center = center_coord or {0,0,0}
  p.tilt = tilt or {0,0,1}

  p.translation = {0,0,0}
  p.rotation = {0,0,0}

  return p
end


-- ------------------------------------------------------------------------
-- TRANSLATION

function Circle:translate_axis(axis, translation)
  self.translation[axis] = self.translation[axis] + translation
  vertex_motion.translate(self.center, axis, translation)
end

function Circle:translate_by_vector(trans_vec)
  for a, t in ipairs(trans_vec) do
    self:translate_axis(a, t)
  end
end

function Circle:translate(a1, a2)
  if a2 == nil and type(a1) == "table" then
    self:translate_by_vector(a1)
  else
    self:translate_axis(a1, a2)
  end
end


-- ------------------------------------------------------------------------
-- ROTATION

function Circle:rotate_axis(axis, speed)
  self.rotation[axis] = self.rotation[axis] + speed
  vertex_motion.rotate(self.tilt, axis, speed)
end

function Circle:rotate_by_vector(rot_vec)
  for a, s in ipairs(rot_vec) do
    self:rotate_axis(a, s)
  end
end

function Circle:rotate(a1, a2)
  if a2 == nil and type(a1) == "table" then
    self:rotate_by_vector(a1)
  else
    self:rotate_axis(a1, a2)
  end
end


-- ------------------------------------------------------------------------
-- DRAW

function Circle:draw(l, draw_style, mult, cam, draw_fn)
  l = l or 15
  mult = mult or 64
  cam = cam or {0, 0, 0}
  draw_3d.circle(self.center, self.r, self.tilt, l, mult, cam, draw_fn)
end


-- ------------------------------------------------------------------------

return Circle
