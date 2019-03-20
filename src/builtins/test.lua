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
	local function isexpr(node)
		if type(node) == "table" then
			return (node.type == "expr")
		end
		return true
	end

	operatives.test = function(ev, title, check, res)
		local checkg = ev:parse(check)
		if isexpr(checkg) then
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
	operatives.test = function(ev)
		return {}
	end
	operatives.tests = function(ev)
		return {}
	end
end


	-- Entry point
return function(inst)
	-- Test backends.
	local backend = {}
	if is_busted then
		inst.testing = function()
			print("Begun testing")
			backend.test = function(self, title, check, res)
				it(title, function()
						 assert.same(res, check)
				end)
			end
		end
	end

	fns["_testmod"] = backend

	for n, v in pairs(operatives) do
		inst.cgfns[n] = v
	end

	for n, v in pairs(fns) do
		inst.vals[n] = v
	end
end
