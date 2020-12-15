

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
  p.edges = edges

  return p
end

function Wireframe.new_from_obj(file_path)
  local parsed = model_parse.obj(file_path)
  local vertices = parsed[1]
  local edges = model_convert.faces_2_edges(parsed[2])
  return Wireframe.new(vertices, edges)
end


-- ------------------------------------------------------------------------
-- MOTION

function Wireframe:translate(translation_vector)
  for _i, v in ipairs(self.vertices) do
    vertex_motion.translate(v, translation_vector)
  end
end

function Wireframe:rotate(axis, speed)
  for _i, v in ipairs(self.vertices) do
    vertex_motion.rotate(v, axis, speed)
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
