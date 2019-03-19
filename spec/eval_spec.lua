-- Basic eval test
describe("#eval loads and", function()
	local eval = require("src.eval")

	local inst
	setup(function()
		inst = eval:new()
	end)

	it("instanciates", function()
		assert.same("table", type(inst))
	end)

	it("can handle booleans", function()
		assert.same(true, inst:run("true"))
		assert.same(false, inst:run("false"))
	end)

	it("can handle numbers", function()
		assert.same(1, inst:run("1"))
		assert.same(123, inst:run("123"))
		assert.same(1.23, inst:run("1.23"))
		assert.same(-100, inst:run("-100"))
	end)

	it("can handle strings", function()
		assert.same("Hello World!", inst:run('"Hello World!"'))
	end) 
	pending("can handle strings with escapes", function()
		assert.same("Hello\tWorld!\n", inst:run('"Hello\tWorld!\n"'))
	end) 
	
	it("can reference variables", function()
		inst.vals["test"] = "Hello World!"

		assert.same("(test)", inst:translate("test"))
		assert.same(inst.vals["test"], inst:run("test"))
	end)

	it("does basic calls", function()
		inst.cgfns.add = nil
		inst.vals.add = function(a, b)
			return a + b
		end
		inst.vals.a = 1
		inst.vals.b = 1
		local code_call = "(add a b)"

		assert.same(2, inst:run(code_call))
	end)

	it("does cgfns handling in calls", function()
		inst.vals.add = nil
		inst.cgfns.add = function(ev, a, b)
			return {
				ev:parse(a),
				" + ",
				ev:parse(b),
			}
		end
		inst.vals.a = 1
		inst.vals.b = 2
		local code_call = "(add a b)"
		assert.same(3, inst:run(code_call))
	end)

	-- invalid uses/failures
	it("fails if parsing with no arguments", function()
		assert.has.errors(function()
			inst:parse()
		end)
	end)

	it("fails if parsing with invalid ast", function()
		assert.has.errors(function()
			inst:parse({})
		end)
		assert.has.errors(function()
			inst:parse({"hi"})
		end)
	end)
end)
