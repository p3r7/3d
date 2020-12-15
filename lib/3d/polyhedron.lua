
local model_parse = include('lib/3d/utils/model_parse')
local model_convert = include('lib/3d/utils/model_convert')
local vertex_motion = include('lib/3d/utils/vertex_motion')
local draw_3d = include('lib/3d/utils/draw_3d')
local draw_mode = include('lib/3d/enums/draw_mode')



-- ------------------------------------------------------------------------

local Polyhedron = {}
Polyhedron.__index = Polyhedron


-- ------------------------------------------------------------------------
-- CONSTRUCTORS

function Polyhedron.new(vertices, faces)
  local p = setmetatable({}, Polyhedron)

  p.vertices = vertices
  p.faces = faces

  return p
end

function Polyhedron.new_from_obj(file_path)
  local parsed = model_parse.obj(file_path)
  local vertices = parsed[1]
  local faces = parsed[2]
  return Polyhedron.new(vertices, faces)
end


-- ------------------------------------------------------------------------
-- MOTION

function Polyhedron:translate(translation_vector)
  for _i, v in ipairs(self.vertices) do
    vertex_motion.translate(v, translation_vector)
  end
end

function Polyhedron:rotate(axis, speed)
  for _i, v in ipairs(self.vertices) do
    vertex_motion.rotate(v, axis, speed)
  end
end


-- ------------------------------------------------------------------------
-- DRAW

function table.copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end


function Polyhedron:evaled_face(face)
  local evaled_face = {}
  for _i, v in ipairs(face) do
    table.insert(evaled_face, self.vertices[v])
  end
  return evaled_face
end

function Polyhedron:draw(l, draw_style, mult, cam, draw_fn)
  l = l or 15
  draw_style = draw_style or draw_mode.WIRE_FRAME
  mult = mult or 64
  cam = cam or {0, 0, 0}
  if draw_style == draw_mode.POINTS then
    for _i, v in ipairs(self.vertices) do
      draw_3d.point(v, l, mult, cam, draw_fn)
    end
  elseif draw_style == draw_mode.WIREFRAME then
   for _i, f in ipairs(self.faces) do
    local evaled_f = self:evaled_face(f)
    draw_3d.face(evaled_f, l, false, mult, cam, draw_fn)
   end
  elseif draw_style == draw_mode.FACES then
    local sign = -1
    local l = 15
    for i, f in ipairs(self.faces) do
      local evaled_f = self:evaled_face(f)
      l = (16 + sign * i) % 16
      draw_3d.face(evaled_f, l, true, mult, cam, draw_fn)
      sign = -sign
    end
  end
end


-- ------------------------------------------------------------------------

return Polyhedron
