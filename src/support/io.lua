io = class {
  NAME = 'io',
  vec = nil,
  norm = nil,
  x = false,
  o = false,

  nodir = false,

  initialize = function(_ENV)
    vec = vec2(0, 0)
    norm = vec2(0, 0)
  end,

  update = function(_ENV)
    local i = 0
    local j = 0
    nodir = true

    if (btn(⬅️)) then
      i = -1
      nodir = false
    end
    if (btn(➡️)) then
      i = 1
      nodir = false
    end
    if (btn(⬆️)) then
      j = -1
      nodir = false
    end
    if (btn(⬇️)) then
      j = 1
      nodir = false
    end

    x = btn(❎)
    o = btn(🅾️)

    vec.x = i
    vec.y = j

    local factor = 1
    if (abs(i) == 1 and abs(j) == 1) then
      factor = 0.707
    end

    norm = vec * factor
  end,
}
