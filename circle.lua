-- circle.
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
inspect = include('lib/inspect')

local Cirle = include('lib/3d/circle')

local draw_mode = include('lib/3d/enums/draw_mode')


-- ------------------------------------------------------------------------
-- conf

local fps = 30

local selected_draw_mode = draw_mode.WIREFRAME
-- local selected_draw_mode = draw_mode.FACES
-- local selected_draw_mode = draw_mode.POINTS


-- ------------------------------------------------------------------------
-- init

function init()
  screen.aa(1)
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

model = Cirle.new(1)

-- print(inspect(model.faces))

-- init
cam = {0,0,-10} -- Initilise the camera position
mult = 128 -- View multiplier
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

function draw_v_as_circle(x, y, col)
  if l then
    screen.level(l)
  end
  local radius = 2
  screen.move(x + radius, y)
  screen.circle(x, y, radius)
  screen.fill()
end


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
  model:draw(15, selected_draw_mode, mult, cam)

  screen.update()
end
