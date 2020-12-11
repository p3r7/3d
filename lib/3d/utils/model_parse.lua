

include('lib/3d/utils/core')


-- ------------------------------------------------------------------------

local model_parse = {}


-- ------------------------------------------------------------------------
-- .OBJ

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
        table.insert(faces,  {tonumber(cells[2]), tonumber(cells[3]), tonumber(cells[4])})
      end
    end
  end
  f:close()

  return {vertices, faces}
end


-- ------------------------------------------------------------------------

return model_parse
