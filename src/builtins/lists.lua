-- List builtins in visp.
-- Unlike many other Lisps, a conslist is not our primary list.
-- We have tables: Dynamic arrays, hashtables and they are pretty good.

local appls = {}

-- (list "hi" "second element" 3 4 5)
-- Quite simple.
local function genlist(inst)
	local experize = inst.experize
	inst.cgfns.list = function(ev, ...)
		local nodes = {...}
		local g = {
			["type"] = "expr",
			"{"
		}
		for i=1, #nodes do
			g[i+1] = experize(ev:parse(nodes[i]), true)
		end
		g[#g+1] = "}"
		return g
	end
end

local function genat(inst)
	local experize = inst.experize
	inst.cgfns["@"] = function(ev, index, list)
		return {
			["type"] = "expr",
			"((", experize(ev:parse(list)), ")[", experize(ev:parse(index)), "])"
		}
	end
end

return function(inst)
	genlist(inst)
	genat(inst)
end
