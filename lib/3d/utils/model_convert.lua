
local model_convert = {}


-- ------------------------------------------------------------------------
-- PROPERTY CONVERTIONS

function model_convert.face_2_edges (face)
  local x, y, z = face[1], face[2], face[3]
  return {{x, y}, {y, z}, {z, x}}
end


function model_convert.faces_2_edges (faces)
  local edges = {}
  for _i, f in ipairs(faces) do
    local f_edges = model_convert.face_2_edges(f)
    for _i, e in ipairs(f_edges) do
      table.insert(edges, e)
    end
  end
  return edges
end


-- ------------------------------------------------------------------------

return model_convert
