-- hypercube.
--
-- @eigen
--
--
-- K1 held is SHIFT
--
-- E1: zoom in/out
-- E2: camera x axis
-- E3: camera y axis
--
-- SHIFT+K2: toggle multi-axis
-- SHIFT+E1: rotate x axis
-- SHIFT+E2: rotate y axis
-- SHIFT+E3: rotate z axis
-- K2: toggle auto-rotate
-- K3: emmergency stop


-- ------------------------------------------------------------------------
-- requires

include('lib/3d/utils/core')

local Wireframe = include('lib/3d/wireframe')
local Sphere = include('lib/3d/sphere')

local draw_mode = include('lib/3d/enums/draw_mode')


-- ------------------------------------------------------------------------
-- conf

local fps = 30


-- ------------------------------------------------------------------------
-- init

function init()
  screen.aa(1)
  -- screen.aa(0)
  screen.line_width(1)
end

redraw_clock = clock.run(
  function()
    local step_s = 1 / fps
    while true do
      clock.sleep(step_s)
      redraw()
    end
end)

function cleanup()
  clock.cancel(redraw_clock)
end

-- ------------------------------------------------------------------------
-- state

model_s = Sphere.new(10)

model = Wireframe.new(
  {{-1,-1,-1}, -- points
    {-1,-1,1},
    {1,-1,1},
    {1,-1,-1},
    {-1,1,-1},
    {-1,1,1},
    {1,1,1},
    {1,1,-1},
    {-0.5,-0.5,-0.5}, -- inside
    {-0.5,-0.5,0.5},
    {0.5,-0.5,0.5},
    {0.5,-0.5,-0.5},
    {-0.5,0.5,-0.5},
    {-0.5,0.5,0.5},
    {0.5,0.5,0.5},
    {0.5,0.5,-0.5}},
    {{1,2}, -- lines
      {2,3},
      {3,4},
      {4,1},
      {5,6},
      {6,7},
      {7,8},
      {8,5},
      {1,5},
      {2,6},
      {3,7},
      {4,8},
      {8+1,8+2}, -- inside
      {8+2,8+3},
      {8+3,8+4},
      {8+4,8+1},
      {8+5,8+6},
      {8+6,8+7},
      {8+7,8+8},
      {8+8,8+5},
      {8+1,8+5},
      {8+2,8+6},
      {8+3,8+7},
      {8+4,8+8},
      {1,9},--
      {2,10},
      {3,11},
      {4,12},
      {5,13},
      {6,14},
      {7,15},
      {8,16}})

-- init
cam = {0,0,-4} -- Initilise the camera position
mult = 64 -- View multiplier
a = flr(rnd(3))+1 -- Angle for random rotation
t = flr(rnd(50))+25 -- Time until next angle change
rot_speed = 0
rot_speed_a = {0,0,0} -- Independant angle rotation

independant_rot_a = False
prev_a = nil

random_angle = false

is_shift = false


-- ------------------------------------------------------------------------
-- USER INPUT

function key(id,state)
  if id == 1 then
    if state == 0 then
      is_shift = false
    else
      is_shift = true
    end
  elseif id == 2 then
    if state == 0 then
      if is_shift then
        independant_rot_a = not independant_rot_a
        if not independant_rot_a then
          print("independant angle rotation off")
          rot_speed = rot_speed_a[1] + rot_speed_a[2] + rot_speed_a[3]
        else
          print("independant angle rotation on")
          rot_speed_a = {0,0,0}
          rot_speed_a[a] = rot_speed
        end
      else
        random_angle = not random_angle
        if not random_angle then
          print("random rotation off")
          rot_speed = 0
        else
          print("random rotation on")
          independant_rot_a = false
          rot_speed = 0.01
        end
      end
    end
  elseif id == 3 then
    if state == 0 then
      print("emergency stop!")
      random_angle = False
      rot_speed = 0
      rot_speed_a = {0,0,0}
    end
  end
end


function enc(id,delta)
  if id == 1 then
    if is_shift then
      a = 3
    else
      cam[3] = cam[3] + delta / 5
    end
  elseif id == 2 then
    if is_shift then
      a = 2
    else
      cam[1] = cam[1] - delta / 10
    end
  elseif id == 3 then
    if is_shift then
      a = 1
    else
      cam[2] = cam[2] - delta / 10
    end
  end

  if is_shift then
    local sign = 1
    if delta < 0 then
      sign = -1
    end
    if id == 2 then
      sign = -sign
    end

    if not independant_rot_a then
      if prev_a == a then
        rot_speed = util.clamp(rot_speed + 0.01 * sign, -0.05, 0.05)
      else
        rot_speed = 0.01 * sign
      end
      prev_a = a
    else
      rot_speed_a[a] = util.clamp(rot_speed_a[a] + 0.005 * sign, -0.03, 0.03)
    end
  end
end


-- ------------------------------------------------------------------------
-- MAIN LOOP

function redraw()
  if random_angle then
    t = t - 1 -- Decrease time until next angle change
    if t <= 0 then -- If t is 0 then change the random angle and restart the timer
      t = flr(rnd(50))+25 -- Restart timer
      a = flr(rnd(3))+1 -- Update angle
    end
  end

  local nClock = os.clock()
  if not independant_rot_a then
    model:rotate(a, rot_speed)
  else
    model:rotate(1, rot_speed_a[1])
    model:rotate(2, rot_speed_a[2])
    model:rotate(3, rot_speed_a[3])
  end
  -- print("rotation took "..os.clock()-nClock)


  screen.clear()
  nClock = os.clock()
  model:draw(5, draw_mode.WIREFRAME, mult, cam)
  -- print("drawing took "..os.clock()-nClock)

  -- model_s:draw(10, nil, mult, cam)

  screen.update()
end
