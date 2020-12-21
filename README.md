# 3d

Pure Lua 3D lib for Norns.

Based on an [example code](https://gist.github.com/Ivoah/477775d13e142b2c89ba) by [@Ivoah](https://github.com/Ivoah) for [PICO-8](https://www.lexaloffle.com/pico-8.php).

## Description

Provides 2 classes for storing & manipulating 3D objects, [Polyhedron](./lib/3d/polyhedron.lua) and [Wireframe](./lib/3d/wireframe.lua), with similar APIs but different internal structures.

`Polyhedron` has a notion of faces composed of vertices. It is more suited for importing 3D models.

`Wireframe`, on the other hand, only has a notion of edges (line between points). It is more suited for representing models with internal edges (such as an hypercube).

Both support importing `.OBJ` models (even though `Polyhedron` is more naturally suited for this use-case).


## Usage

Importing a 3D model and displaying it.

```lua
local Polyhedron = include('lib/3d/polyhedron')
local draw_mode = include('lib/3d/enums/draw_mode')

local model = Polyhedron.new_from_obj("/home/we/dust/code/3d/model/teapot.obj")
local level = 15
model:draw(level, draw_mode.WIREFRAME)
```

Rotating it:

```lua
local axis = include('lib/3d/enums/axis')

model:rotate(axis.Y, 0.02)
```

Drawing can take a multiplication coefficient and a camera position:

```lua
local mult = 64 -- scale up model by 640%
local cam = {0, 0, -4} -- x, y, z
model:draw(level, draw_mode.WIREFRAME, mult, cam)
```

We can choose to only draw vertices:

```lua
model:draw(level, draw_mode.POINTS)
```

Or even pass a custom drawing function:

```lua
function draw_v_as_circle(x, y, l)
  if l then
    screen.level(l)
  end
  local radius = 2
  screen.move(x + radius, y)
  screen.circle(x, y, radius)
  screen.fill()
end

model:draw(level, draw_mode.POINTS, mult, cam,
           {point_draw_fn = draw_v_as_circle})
```
