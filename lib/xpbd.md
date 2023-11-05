# [#xpbd-0#]
# Library

This is a library to simulate physics using the eXtended Position Based Dynamics (XPBD) methodology.


## xpbd.p8
* page 0, library - 1368 tokens
* page 1, demo    -  698 tokens

# Demo

It contains the following demos you can access with the left and right keys:

* a single bead on a ring;
* multiple beads on a ring;
* a squishy square;
* and an about page with particles.

The bead examples are ports of Matthias Muller's [ten minute physics][10min] examples.

# Usage

Include the first page for the library contents without any demo code.

```
#include xpbd.p8:0

function _init()
  local a = particle:new { pos = vec(64, 64) } }
  local b = particle:new { pos = vec(74, 64) } }
  sim = xpbd:new { 
    particles = { a, b },
    constraints = { distance_constraint:new { rest_length = 10, a, b } }
  }
end

function _update()
  sim:update()
end

function _draw()
  sim:draw()
end
```

See demos for how to setup.

# Bugs 

* I have not optimized the token count yet.
* Collision resolution is not well worked out yet.

## Questions

I'm curious if you could use XPBD to make a platformer that _felt_ right. Maybe if it was stiff and used just a one step solver. I have serious doubts but would be fun to see.

# License

Copyright (c) 2023 [Shane Celis][1]
Released under the [MIT license][2]

# Acknowlegments

Many thanks to Matthias Muller and his collaborators for XPBD papers, code, examples, and videos that illucidate a refreshingly simple way to simulate physics.

[1]: https://mastodon.gamedev.place/%40shanecelis
[2]: https://opensource.org/licenses/MIT
[10min]: https://matthias-research.github.io/pages/tenMinutePhysics/index.html

