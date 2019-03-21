describe("#parser loads and", function()
	local p = require("src.parser")

	local test = "(first (second arg) arg)"
	it("parses basic string", function()
		local expr = p.readexpr(test)
		assert.is_truthy(p.isexpr(expr))
		assert.same("id", expr[1].type)
		assert.same("first", expr[1][1])
	end)

	it("dump equals input", function()
		local expr = p.readexpr(test)
		assert.same(test, p.dumpexpr(expr))
	end)

	it("parses/dumps complex exprs", function()
		local complex = "(cond (((and true true) true)))"
		local expr = p.readexpr(complex)
		assert.same(complex, p.dumpexpr(expr))
	end)

	it("parses/dumps strings", function()
		local src = '(test "Hello World!")'
		local expr = p.readexpr(src)
		assert.same(src, p.dumpexpr(expr))
	end)

	it("ignores comments", function()
		assert.same(nil, p.readexpr(";; hello world!"))
	end)

	-- invalid uses
	it("errors if reading invalid data", function()
		assert.has.errors(function()
			p.readexpr(false)
		end)
	end)
	it("fails with too few parenthesis", function()
		assert.has.errors(function()
			p.readexpr("(hello")
		end)
	end)

	it("fails with too many parenthesis", function()
		assert.has.errors(function()
			p.readexpr(")")
		end)
	end)

	it("fails dumping with invalid input", function()
		assert.has.errors(function()
			p.dumpsexpr(false)
		end)
	end)
end)
