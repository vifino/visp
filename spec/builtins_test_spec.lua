-- Test Builtins autotest.
describe("#builtins #autotest", function()
	_G._BUSTED = true
	local visp = require("visp")
	local inst = visp.new()

	local backend = inst.eval.vals["_testmod"]
	if not backend then error("no backend table?") end
	backend.test = function(_, title, checker, expected)
		it(title, function()
			assert.same(expected, checker())
		end)
	end

	describe("testing", function()
		-- Testing itself.
		inst:run('(test "itself" true true)')
	end)
end)
