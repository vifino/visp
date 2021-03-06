-- visp testing builtins.
--
-- This is mainly to have testing suites.
-- Primary test suite is the stdlib test suite.
-- This will also be bundled in the visp repo,
-- along with the stdlib itself.
--
-- test
--
-- The functions are only supported in busted,
-- but this is an implementation choice.
-- The self-hosted compiler will probably
-- have choices regarding the implementation.

local is_busted = _BUSTED or false
local is_testing = is_busted

local operatives = {}
local fns = {}

if is_testing then
	-- Generic test interface.
	operatives.test = function(ev, title, check, res)
		local checkg = ev:parse(check)
		if ev.isexpr(checkg) then
			checkg = {"return", checkg}
		end

		return {
			['type'] = 'expr',
			'_testmod:test(', ev:parse(title), ', function()',
			checkg,
			'end, '..(((not res) and "true") or ev:parse(res)) ..')',
		}
	end
else
	-- TODO: fill out
	operatives.test = function()
		return {}
	end
	operatives.tests = function()
		return {}
	end
end


	-- Entry point
return function(inst)
	-- Test backends.
	fns["_testmod"] = {}

	for n, v in pairs(operatives) do
		inst.cgfns[n] = v
	end

	for n, v in pairs(fns) do
		inst.vals[n] = v
	end
end
