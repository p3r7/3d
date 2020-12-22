

include('lib/3d/utils/core')


-- ------------------------------------------------------------------------

local model_parse = {}


-- ------------------------------------------------------------------------
-- .OBJ

function normalize_face_vertex_id(vertex_id)
  return tonumber(split(vertex_id, "/")[1])
end

function model_parse.obj (file_path)
  local vertices = {}
  local faces = {}

  local f = io.open(file_path, "r")
  if f then
    for line in f:lines() do
      local cells = split(line, " ")
      local instruction = cells[1]
      if instruction == "v" then
        table.insert(vertices, {tonumber(cells[2]),
                                tonumber(cells[3]),
                                tonumber(cells[4])})
      elseif instruction == "f" then
        table.insert(faces,
                     {normalize_face_vertex_id(cells[2]),
                      normalize_face_vertex_id(cells[3]),
                      normalize_face_vertex_id(cells[4])})
      end
    end
  end
  f:close()

  return {vertices, faces}
end


-- ------------------------------------------------------------------------

return model_parse
