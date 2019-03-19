describe("#parser loads and", function()
	local p = require("src.parser")

	local test = "(first (second arg) arg)"
	it("parses basic string", function()
		local expr = p.readsexpr(test)
		assert.same("id", expr[1].type)
		assert.same("first", expr[1][1])
	end)

	it("dump equals input", function()
		local expr = p.readsexpr(test)
		assert.same(test, p.dumpexpr(expr))
	end)

	it("parses/dumps complex exprs", function()
		local complex = "(cond (((and true true) true)))"
		local expr = p.readsexpr(complex)
		assert.same(complex, p.dumpexpr(expr))
	end)

	it("parses/dumps strings", function()
		local src = '(test "Hello World!")'
		local expr = p.readsexpr(src)
		assert.same(src, p.dumpexpr(expr))
	end)

	-- invalid uses
	it("errors if reading invalid data", function()
		assert.has.errors(function()
			p.readsexpr(false)
		end)
	end)
	it("fails with too few parenthesis", function()
		assert.has.errors(function()
			p.readsexpr("(hello")
		end)
	end)

	it("fails with too many parenthesis", function()
		assert.has.errors(function()
			p.readsexpr(")")
		end)
	end)

	it("fails dumping with invalid input", function()
		assert.has.errors(function()
			p.dumpsexpr(false)
		end)
	end)
end)
