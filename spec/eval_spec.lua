-- Basic eval test
describe("#eval loads", function()
	local eval = require("src.eval")

	local inst
	setup(function()
		inst = eval:new()
	end)

	it("and instanciates", function()
		assert.same("table", type(inst))
	end)
	
	it("and can reference variables", function()
		inst.vals["test"] = "Hello World!"

		assert.same("(test)", inst:translate("test"))
		assert.same(inst.vals["test"], inst:run("test"))
	end)

	it("and does basic calls", function()
		inst.cgfns.add = nil
		inst.vals.add = function(a, b)
			return a + b
		end
		inst.vals.a = 1
		inst.vals.b = 1
		local code_call = "(add a b)"

		assert.same(2, inst:run(code_call))
	end)

	it("and does cgfns handling in calls", function()
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
	it("and fails if parsing with no arguments", function()
		assert.has.errors(function()
			inst:parse()
		end)
	end)

	it("and fails if parsing with invalid ast", function()
		assert.has.errors(function()
			inst:parse({})
		end)
		assert.has.errors(function()
			inst:parse({"hi"})
		end)
	end)
end)
