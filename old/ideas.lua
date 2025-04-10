
-- function moveToward(x, y, t)
-- 	return function(_ENV)
-- 		mv = vec2(x, y)
-- 		wait_internal(t)
-- 	end
-- end

-- function set_(key, fnOrV)
-- 	if type(fnOrV) == 'function' then
-- 		return function(self)
-- 			self[key] = fnOrV(self)
-- 		end
-- 	end

-- 	return function(self)
-- 		self[key] = fnOrV
-- 	end
-- end

-- function add_mv(fn)
-- 	return function(_ENV)
-- 		mv += fn(_ENV)
-- 	end
-- end

-- function untilMapCollision_(_ENV)
-- 	repeat
-- 		yield()
-- 	until colided
-- end

-- function pipe_(f_list)
-- 	local outArgs = {}

-- 	return function(self)
-- 		for fn in all(f_list)
-- 		do
-- 			outArgs = pack(fn(self, unpack(outArgs)))
-- 		end
-- 	end
-- end
--
function round(v)
  local z = v & 0x0.ffff
  if z < 0.5 then
    return flr(v)
  else
    return ceil(v)
  end
end

-- 2 layer map display
-- idea... work by using the lower part of the map
--

mapper = class:new {

  speed = 12,
  campos = vector:create(0, 0),

  update = function(self)
    local animframe = framectr / self.speed

    if (animframe << 16 == 0) then
      eachtile(
        self.campos,
        function(t, f, set)
          local m = (f >> 4) & 0b11
          local s = (f >> 7) & 0b1
          if m != 0 and animframe & s == 0
          then
            set(addmask(t, m))
          end
        end
      )
    end

    local x, y = player.sprite()

    self.campos.x = (x - 64) < 0 and 0 or x - 64
    self.campos.y = (y - 64) < 0 and 0 or y - 64
  end,

  draw = function(_ENV, second_l)
    local x, y = campos()
    second_l = second_l or false
    local map_y = second_l and y + 256 or y
    camera(x, map_y)
    map()

    camera(x, y)
  end
}

-- tentative animation code
if mv.x > 0.2 then
  spr_ix = (spr_ix + 0.2) % #spr_t
elseif mv.x < -0.2 then
  spr_ix = (spr_ix - 0.2) % #spr_t
end
-- tentative animation code for player

seq = class {
  NAME = 'seq', create = function(self, s, name)
  return class.new(self,
    s,
    {
      __tostring = function(own)
        return seq_tostr(own, name or self.NAME)
      end
    }
  )
end
}

data=split('54, 8,0,false,false,54, 8,-2,false,false, 55, 4,-4,false,false, 56, 4,-4,false,false, 57, 0,-8,false,false, 57, 0,-8,false,false, 56, -4,-4,true,false, 55, -4,-4,true,false, 54, -8,-2,true,false,54, -8,0,true,false')

function subsplit(s, n)
	local rv={}
	for i=1,(#s\n)-1 do
		local subs={}
		for j=1,n do
			add(subs, s[i*n+j])
		end
		add(rv, subs)
	end
	return rv
end
