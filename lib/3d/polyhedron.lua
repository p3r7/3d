
include('lib/3d/utils/core')
local model_parse = include('lib/3d/utils/model_parse')
local model_convert = include('lib/3d/utils/model_convert')
local vertex_motion = include('lib/3d/utils/vertex_motion')
local draw_3d = include('lib/3d/utils/draw_3d')
local draw_mode = include('lib/3d/enums/draw_mode')
local draw_fx = include('lib/3d/utils/draw_fx')


-- ------------------------------------------------------------------------

local Polyhedron = {}
Polyhedron.__index = Polyhedron


-- ------------------------------------------------------------------------
-- CONSTRUCTORS

function Polyhedron.new(vertices, faces)
  local p = setmetatable({}, Polyhedron)

  p.vertices = vertices
  p.vertices_count = len(vertices)
  p.faces = faces
  p.faces_count = len(faces)

  p.translation = {0,0,0}
  p.rotation = {0,0,0}

  p.vertices_draw_mode = {}
  for i = 1, p.vertices_count do
    table.insert(p.vertices_draw_mode, draw_mode.POINTS)
  end

  p.faces_draw_mode = {}
  for i = 1, p.faces_count do
    table.insert(p.faces_draw_mode, draw_mode.FACES | draw_mode.WIREFRAME)
  end

  return p
end

function Polyhedron.new_from_obj(file_path)
  local parsed = model_parse.obj(file_path)
  local vertices = parsed[1]
  local faces = parsed[2]
  return Polyhedron.new(vertices, faces)
end


-- ------------------------------------------------------------------------
-- TRANSLATION

function Polyhedron:translate_axis(axis, translation)
  self.translation[axis] = self.translation[axis] + translation
  for _i, v in ipairs(self.vertices) do
    vertex_motion.translate(v, axis, translation)
  end
end

function Polyhedron:translate_by_vector(trans_vec)
  for a, t in ipairs(trans_vec) do
    self:translate_axis(a, t)
  end
end

function Polyhedron:translate(a1, a2)
  if a2 == nil and type(a1) == "table" then
    self:translate_by_vector(a1)
  else
    self:translate_axis(a1, a2)
  end
end


-- ------------------------------------------------------------------------
-- ROTATION

function Polyhedron:rotate_axis(axis, speed)
  self.rotation[axis] = self.rotation[axis] + speed
  for _i, v in ipairs(self.vertices) do
    vertex_motion.rotate(v, axis, speed)
  end
end

function Polyhedron:rotate_by_vector(rot_vec)
  for a, s in ipairs(rot_vec) do
    self:rotate_axis(a, s)
  end
end

function Polyhedron:rotate(a1, a2)
  if a2 == nil and type(a1) == "table" then
    self:rotate_by_vector(a1)
  else
    self:rotate_axis(a1, a2)
  end
end


-- ------------------------------------------------------------------------
-- DRAW

function Polyhedron:randomize_draw_props(draw_style, draw_pct)
  draw_pct = draw_pct or false

  local rnd_draw_pred = draw_pct
    and draw_fx.make_rnd_pred(draw_pct)
    or draw_fx.make_always_true_pred()

  if draw_style & draw_mode.POINTS then
    for i = 1, self.vertices_count do
      if rnd_draw_pred() then
        self.vertices_draw_mode[i] = draw_mode.POINTS
      else
        self.vertices_draw_mode[i] = draw_mode.DISABLED
      end
    end
  end

  if draw_style & draw_mode.WIREFRAME then
    for i = 1, self.faces_count do
      if rnd_draw_pred() then
        self.faces_draw_mode[i] = draw_mode.WIREFRAME
      else
        self.faces_draw_mode[i] = draw_mode.DISABLED
      end
    end
  end

  if draw_style & draw_mode.FACES then
    for i = 1, self.faces_count do
      if rnd_draw_pred() then
        self.faces_draw_mode[i] = self.faces_draw_mode[i] | draw_mode.FACES
      end
    end
  end
end

function Polyhedron:evaled_face(face)
  local evaled_face = {}
  for _i, v in ipairs(face) do
    table.insert(evaled_face, self.vertices[v])
  end
  return evaled_face
end

function Polyhedron:draw(l, draw_style, mult, cam, props)
  l = l or 15
  draw_style = draw_style or draw_mode.WIREFRAME
  mult = mult or 64
  cam = cam or {0, 0, 0}
  props = props or {}

  if props['draw_pct'] then
    self:randomize_draw_props(draw_style, props['draw_pct'])
  end

  local z_draw_pred = (props['min_z'] or props['max_z'])
    and draw_fx.make_vertex_axis_pos_pred(3, props['min_z'], props['max_z'])
    or draw_fx.make_always_true_pred()

  if draw_style & draw_mode.POINTS ~= 0 then
    for i, v in ipairs(self.vertices) do
      if z_draw_pred(v) and self.vertices_draw_mode[i] & draw_mode.POINTS ~= 0 then
        draw_3d.point(v, props['point_level'] or l, mult, cam, props['point_draw_fn'])
      end
    end
  end
  if draw_style & draw_mode.WIREFRAME ~= 0 then
    for i, f in ipairs(self.faces) do
      local evaled_f = self:evaled_face(f)
      if self.faces_draw_mode[i] & draw_mode.WIREFRAME ~= 0
        and draw_fx.face_axis_pos_pred(z_draw_pred, evaled_f) then
        draw_3d.face(evaled_f, props['line_level'] or l, false, mult, cam, props['face_edges_draw_fn'])
      end
    end
  end
  if draw_style & draw_mode.FACES ~= 0 then
    local sign = -1
    local l = 15
    for i, f in ipairs(self.faces) do
      local evaled_f = self:evaled_face(f)
      if self.faces_draw_mode[i] & draw_mode.FACES ~= 0
        and draw_fx.face_axis_pos_pred(z_draw_pred, evaled_f) then
        l = (16 + sign * i) % 16
        draw_3d.face(evaled_f, l, true, mult, cam, props['face_draw_fn'])
        sign = -sign
      end
    end
  end
end


-- ------------------------------------------------------------------------

return Polyhedron
