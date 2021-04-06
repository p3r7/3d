
include('lib/3d/utils/core')
local model_parse = include('lib/3d/utils/model_parse')
local model_convert = include('lib/3d/utils/model_convert')
local vertex_motion = include('lib/3d/utils/vertex_motion')
local draw_3d = include('lib/3d/utils/draw_3d')
local draw_mode = include('lib/3d/enums/draw_mode')
local draw_fx = include('lib/3d/utils/draw_fx')


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

  p.vertices_draw_mode = {}
  for i = 1, p.vertices_count do
    table.insert(p.vertices_draw_mode, draw_mode.POINTS)
  end

  p.edges_draw_mode = {}
  for i = 1, p.edges_count do
    table.insert(p.edges_draw_mode, draw_mode.WIREFRAME)
  end

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
    self:translate_axis(a, t)
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
    self:rotate_axis(a, s)
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

function Wireframe:randomize_draw_props(draw_style, draw_pct)
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
    for i = 1, self.edges_count do
      if rnd_draw_pred() then
        self.edges_draw_mode[i] = draw_mode.WIREFRAME
      else
        self.edges_draw_mode[i] = draw_mode.DISABLED
      end
    end
  end
end

function Wireframe:draw_glitch_edges(l, chance_pct, amount_pct, mult, cam, props)
  local amount = amount_pct
    and amount_pct * self.vertices_count / 100
    or self.vertices_count / 2

  local i = 0
  while i < amount do
    if rnd(100) < chance_pct then
      draw_3d.line(self.vertices[flr(rnd(self.vertices_count)) + 1], self.vertices[flr(rnd(self.vertices_count)) + 1], props['line_level'] or l, mult, cam, props['lines_draw_fn'])
    end
    i = i + 1
  end
end

function Wireframe:draw(l, draw_style, mult, cam, props)
  l = l or 15
  draw_style = draw_style or draw_mode.WIREFRAME
  mult = mult or 64
  cam = cam or {0, 0, 0}
  props = props or {}

  if props['draw_pct'] then
    self:randomize_draw_props(draw_style, props['draw_pct'])
  end

  if draw_style & draw_mode.POINTS ~= 0 then
    for i, v in ipairs(self.vertices) do
      if sef.vertices_draw_mode[i] & draw_mode.POINTS ~= 0 then
        draw_3d.point(v, props['point_level'] or l, mult, cam, props['point_draw_fn'])
      end
    end
  end
  if draw_style & draw_mode.WIREFRAME ~= 0 then
    for i, line in ipairs(self.edges) do
      if self.faces_draw_mode[i] & draw_mode.WIREFRAME ~= 0 then
        draw_3d.line(self.vertices[line[1]], self.vertices[line[2]], props['line_level'] or l, mult, cam, props['lines_draw_fn'])
      end
    end

    if props['glitch_edge_pct'] then
      self:draw_glitch_edges(l, props['glitch_edge_pct'], props['glitch_edge_amount_pct'], mult, cam, props)
    end
  end
end


-- ------------------------------------------------------------------------

return Wireframe
