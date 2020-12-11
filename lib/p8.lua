-- p8.
--
-- Simplified p8 lib.
-- Provides simplified PICO-8 like syntax for screen operations.
--
-- For a full-fledged implementation (w/ handling of color palette, logic and
-- trionometric operations, collection helpers ...) see:
-- https://github.com/p3r7/p8


local p8 = {}


-- -------------------------------------------------------------------------
-- STATE

local curr_line_endpoint_x = nil
local curr_line_endpoint_y = nil

local function set_current_line_endpoints(x, y)
  curr_line_endpoint_x = x
  curr_line_endpoint_y = y
end

local function invalidate_current_line_endpoints()
  curr_line_endpoint_x = nil
  curr_line_endpoint_y = nil
end


-- -------------------------------------------------------------------------
-- MATH: BASICS

function p8.sgn(x)
  if x < 0 then
    return -1
  else
    return 1
  end
end

function p8.flr(x)
  return math.floor(x)
end


-- -------------------------------------------------------------------------
-- MATH: RANDOMNESS

function p8.rnd(x)
  if x == 0 then
    return 0
  end
  if (not x) then
    x = 1
  end
  x = x * 100000
  x = math.random(x) / 100000
  return x
end

function p8.srand(x)
  if not x then
    x = 0
  end
  math.randomseed(x)
end


-- -------------------------------------------------------------------------
-- MATH: TRIGONOMETRY

function p8.cos(x)
  return math.cos(math.rad(x * 360))
end

function p8.sin(x)
  return -math.sin(math.rad(x * 360))
end

-- this seems to do the work
-- mostly stolen from https://www.lexaloffle.com/bbs/?pid=10287#p
function p8.atan2(dx, dy)
  local q = 0.125
  local a = 0
  local ay = abs(dy)
  if ay == 0 and dx ==0 then
    ay = 0.001
  end
  if dx >= 0 then
    local r = (dx - ay) / (dx + ay)
    a = q - r*q
  else
    local r = (dx + ay) / (ay - dx)
    a = q*3 - r*q
  end
  if dy > 0 then
    a = -a
  end
  return a
end


-- -------------------------------------------------------------------------
-- SCREEN: BASICS

function p8.cls(col)
  col = col or 0
  p8.rectfill(0, 0, 128, 64, col)
end

function p8.flip()
  screen.update()
end


-- -------------------------------------------------------------------------
-- SCREEN: COLORS

function p8.color(col)
  col = p8.flr(col % 16)
  screen.level(col)
end

local function color_maybe(col)
  if col then
    p8.color(col)
  end
end


-- -------------------------------------------------------------------------
-- SCREEN: SHAPES

function p8.pget(x, y)
  local s = screen.peek(x, y, x+1, y+1)
  return string.byte(s, 1)
end

function p8.pset(x, y, col)
  color_maybe(col)
  screen.pixel(x, y)
  screen.fill()
end

local function line_w_start(x0, y0, x1, y1, col)
  color_maybe(col)
  screen.move(x0, y0)
  screen.line(x1, y1)
  screen.stroke()
  set_current_line_endpoints(x1, y1)
end

local function line_w_no_start(x1, y1, col)
  color_maybe(col)
  if curr_line_endpoint_x and curr_line_endpoint_y then
    screen.move(curr_line_endpoint_x, curr_line_endpoint_y)
    screen.line(x1, y1)
    screen.stroke()
  end
  set_current_line_endpoints(x1, y1)
end

function p8.line(a1, a2, a3, a4, a5)
  if not a1 then
    invalidate_current_line_endpoints()
  elseif not a2 then
    color_maybe(a1)
    invalidate_current_line_endpoints()
  elseif not a4 then
    line_w_no_start(a1, a2, a3)
  else
    line_w_start(a1, a2, a3, a4, a5)
  end
end

function p8.circ(x, y, r, col)
  color_maybe(col)
  screen.move(x + r, y)
  screen.circle(x, y, r)
  screen.stroke()
end

function p8.circfill(x, y, r, col)
  color_maybe(col)
  screen.move(x + r, y)
  screen.circle(x, y, r)
  screen.fill()
end

function p8.rect(x0, y0, x1, y1, col)
  color_maybe(col)
  screen.rect(x0, y0, (x1 - x0), (y1 - y0))
  screen.stroke()
end

function p8.rectfill(x0, y0, x1, y1, col)
  color_maybe(col)
  screen.rect(x0, y0, (x1 - x0), (y1 - y0))
  screen.fill()
end


-- -------------------------------------------------------------------------

return p8
