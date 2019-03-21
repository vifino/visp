-- Autotest of stdlib.
describe("#stdlib #autotest", function()
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

	inst:run('(include "src/stdlib/boot.lisp")')
end)
