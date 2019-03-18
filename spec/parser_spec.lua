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

	-- invalid uses
	it("and errors if reading invalid data", function()
		assert.has.errors(function()
			p.readsexpr(false)
		end)
	end)
	it("and fails with too few parenthesis", function()
		assert.has.errors(function()
			p.readsexpr("(hello")
		end)
	end)

	it("and fails with too many parenthesis", function()
		assert.has.errors(function()
			p.readsexpr(")")
		end)
	end)

	it("and fails dumping with invalid input", function()
		assert.has.errors(function()
			p.dumpsexpr(false)
		end)
	end)
end)
