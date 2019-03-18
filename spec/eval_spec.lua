-- Basic eval test
describe("#eval loads", function()
	local eval = require("src.eval")

	it("and instanciates", function()
		local inst = eval:new()
		assert.same("table", type(inst))
	end)
	
	it("and can reference variables", function()
		local inst = eval:new()
		inst.vals["test"] = "Hello World!"

		assert.same("(test)", inst:translate("test"))
		assert.same(inst.vals["test"], inst:run("test"))
	end)

	it("and does basic calls", function()
		local inst = eval:new()	
		inst.vals.add = function(a, b)
			return a + b
		end
		inst.vals.a = 1
		inst.vals.b = 1
		local code_call = "(add a b)"

		assert.same(2, inst:run(code_call))
	end)
end)
