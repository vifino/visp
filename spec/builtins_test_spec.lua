-- Test Builtins autotest.
describe("#builtins #autotest", function()
	_G._BUSTED = true
	visp = require("visp")
	inst = visp.new()

	local backend = inst.eval.vals["_testmod"]
	if not backend then error("no backend table?") end
	backend.test = function(self, title, checker, res)
		it(title, function()
			assert.same(res, checker())
		end)
	end

	describe("testing", function()
		-- Testing itself.
		inst:run('(test "itself" true true)')
	end)
end)
