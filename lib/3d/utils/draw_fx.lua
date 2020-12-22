
include('lib/3d/utils/core')


-- ------------------------------------------------------------------------

local draw_fx = {}


-- ------------------------------------------------------------------------
-- DRAW PREDICATES

function draw_fx.make_always_true_pred()
  return function()
    return true
  end
end

function draw_fx.make_vertex_axis_pos_pred(axis, min, max)
  return function(v)
    local in_low = true
    local in_high = true
    if min then
      in_low = v[axis] >= min
    end
    if max then
      in_high = v[axis] < max
    end
    return in_low and in_high
  end
end

function draw_fx.face_axis_pos_pred(vertex_axis_pred, face)
  for _i, v in ipairs(face) do
    if not vertex_axis_pred(v) then
      return false
    end
  end
  return true
end

function draw_fx.make_rnd_pred(pct_chance)
  return function()
    return rnd(100) < pct_chance
  end
end



-- ------------------------------------------------------------------------

return draw_fx
