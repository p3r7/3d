

local axis = include('lib/3d/enums/axis')
inspect = include("lib/inspect")


-- ------------------------------------------------------------------------

local vector_motion = {}


-- ------------------------------------------------------------------------
-- VECTOR -> NORMALIZED VERTEX

function vector_motion.to_vertex(vec)
  return {
    vec[axis.X][2] - vec[axis.X][1],
    vec[axis.Y][2] - vec[axis.Y][1],
    vec[axis.Z][2] - vec[axis.Z][1],
  }
end


-- ------------------------------------------------------------------------
-- PROJECTION: DOT PRODUCT

function vector_motion.dot_product_normalized(v1, v2)
  return {
    v1[axis.X] * v2[axis.X],
    v1[axis.Y] * v2[axis.Y],
    v1[axis.Z] * v2[axis.Z],
  }
end

function vector_motion.dot_product(v1, v2)
  local v1 = vector_motion.to_vertex(vec1)
  local v2 = vector_motion.to_vertex(vec2)
  local v3 = vector_motion.dot_product_normalized(v1, v2)
  return v3
end



-- ------------------------------------------------------------------------
-- PROJECTION: CROSS PRODUCT

function vector_motion.cross_product_normalized(v1, v2)
  return {
    v1[axis.Y] * v2[axis.Z] - v1[axis.Z] * v2[axis.Y],
    v1[axis.Z] * v2[axis.X] - v1[axis.X] * v2[axis.Z],
    v1[axis.X] * v2[axis.Y] - v1[axis.Y] * v2[axis.X],
  }
end

function vector_motion.cross_product(vec1, vec2)
  local v1 = vector_motion.to_vertex(vec1)
  local v2 = vector_motion.to_vertex(vec2)
  local v3 = vector_motion.cross_product_normalized(v1, v2)
  return v3
end


-- ------------------------------------------------------------------------
-- PERPENDICULAR

function vector_motion.any_perpendicular(v)
  if v[1] == 0. and v[2] == 0. and v[3] == 1. then
    return {0, -v[3], v[2]}
  else
    return {v[2], -v[1], 0}
  end
end

function vector_motion.any_perpendicular_buggy1(v)
  if v[1] == -0.5 and v[2] == 0.5 and v[3] == 0. then
    return {- v[2] - v[3], v[1], v[1]}
  else
    return {v[3], v[3], - v[1] - v[2]}
  end
end

function vector_motion.any_perpendicular_buggy2(v)
  -- NB: the trick is to make a slightly different copy of the tilt vector and then make the cross product
  -- this should give us a perpendicular vector, i.e. corresponding to the circle
  -- in practice, not working as expected, poentially due to some precision error

  local intersecting_v = table.copy(v)
  intersecting_v[1] = intersecting_v[1] + 0.5

  return vector_motion.cross_product_normalized(tilt_v, intersecting_v)
end


-- ------------------------------------------------------------------------

return vector_motion
