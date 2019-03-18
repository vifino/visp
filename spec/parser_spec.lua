describe("#parser loads", function()
	local p = require("src.parser")

	local test = "(first (second arg))"
	it("and parses basic string", function()
		local expr = p.readsexpr(test)
		assert.same("id", expr[1].type)
		assert.same("first", expr[1][1])
	end)

	it("and dump equals input", function()
		local expr = p.readsexpr(test)
		assert.same(test, p.dumpexpr(expr))
	end)
end)
