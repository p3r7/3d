

local model_parse = include('lib/3d/utils/model_parse')
local model_convert = include('lib/3d/utils/model_convert')
local vertex_motion = include('lib/3d/utils/vertex_motion')
local draw_3d = include('lib/3d/utils/draw_3d')
local draw_mode = include('lib/3d/enums/draw_mode')


-- ------------------------------------------------------------------------

local Wireframe = {}
Wireframe.__index = Wireframe


-- ------------------------------------------------------------------------
-- CONSTRUCTORS

function Wireframe.new(vertices, edges)
  local p = setmetatable({}, Wireframe)

  p.vertices = vertices
  p.vertices_count = len(vertices)
  p.edges = edges
  p.edges_count = len(edges)

  p.translation = {0,0,0}
  p.rotation = {0,0,0}

  return p
end

function Wireframe.new_from_obj(file_path)
  local parsed = model_parse.obj(file_path)
  local vertices = parsed[1]
  local edges = model_convert.faces_2_edges(parsed[2])
  return Wireframe.new(vertices, edges)
end


-- ------------------------------------------------------------------------
-- TRANSLATION

function Wireframe:translate_axis(axis, translation)
  self.translation[axis] = self.translation[axis] + translation
  for _i, v in ipairs(self.vertices) do
    vertex_motion.translate(v, axis, translation)
  end
end

function Wireframe:translate_by_vector(trans_vec)
  for a, t in ipairs(trans_vec) do
    self:translate(a, t)
  end
end

function Wireframe:translate(a1, a2)
  if a2 == nil and type(a1) == "table" then
    self:translate_by_vector(a1)
  else
    self:translate_axis(a1, a2)
  end
end


-- ------------------------------------------------------------------------
-- ROTATION

function Wireframe:rotate_axis(axis, speed)
  self.rotation[axis] = self.rotation[axis] + speed
  for _i, v in ipairs(self.vertices) do
    vertex_motion.rotate(v, axis, speed)
  end
end

function Wireframe:rotate_by_vector(rot_vec)
  for a, s in ipairs(rot_vec) do
    self:rotate(a, s)
  end
end

function Wireframe:rotate(a1, a2)
  if a2 == nil and type(a1) == "table" then
    self:rotate_by_vector(a1)
  else
    self:rotate_axis(a1, a2)
  end
end


-- ------------------------------------------------------------------------
-- DRAW

function Wireframe:draw(l, draw_style, mult, cam, draw_fn)
  l = l or 15
  draw_style = draw_style or draw_mode.WIRE_FRAME
  mult = mult or 64
  cam = cam or {0, 0, 0}
  if draw_style == draw_mode.POINTS then
    for _i, v in ipairs(self.vertices) do
      draw_3d.point(v, l, mult, cam, draw_fn)
    end
  elseif draw_style == draw_mode.WIREFRAME then
    for _i, line in ipairs(self.edges) do
      draw_3d.line(self.vertices[line[1]], self.vertices[line[2]], l, mult, cam, draw_fn)
    end
  end
end


-- ------------------------------------------------------------------------

return Wireframe
