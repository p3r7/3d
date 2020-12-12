

local inspect = include('lib/inspect')


-- ------------------------------------------------------------------------

local draw_2d = {}


-- ------------------------------------------------------------------------
-- POINT

function draw_2d.point(x, y, l)
  if l then
    screen.level(l)
  end
  screen.pixel(x, y)
  screen.fill()
end


-- ------------------------------------------------------------------------
-- LINE

function draw_2d.line(x0, y0, x1, y1, l)
  if l then
    screen.level(l)
  end
  screen.move(x0, y0)
  screen.line(x1, y1)
  screen.stroke()
end


-- ------------------------------------------------------------------------
-- POLYGON

function draw_2d.polygon(lines, l, filled)
  if l then
    screen.level(l)
  end
  commit_fn = (filled and screen.fill) or screen.stroke
  for i, line in ipairs(lines) do
    local p1, p2 = line[1], line[2]
    if i == 1 then
      screen.move(p1[1], p1[2])
    end
    screen.line_rel(p2[1]-p1[1], p2[2]-p1[2])
  end
  commit_fn()
end


-- ------------------------------------------------------------------------

return draw_2d
