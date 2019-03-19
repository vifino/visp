-- Basic visp builtin controls spec.

describe("#builtins #control", function()
	local visp
	setup(function()
		visp = require("src.visp")
	end)
	
	it("initialize", function()
		local inst = visp.new()
		assert.same("table", type(inst))
	end)

	describe("load", function()
		local inst
		setup(function()
			inst = visp.new()
		end)

		describe("cond", function()
			it("single value-value", function()
				assert.is_truthy(inst:run("(cond ((true true)))"))
				assert.is_falsy(inst:run("(cond ((true false)))"))
				assert.is_falsy(inst:run("(cond ((false true)))"))
			end)

			it("multiple value-value", function()
				assert.is_truthy(inst:run("(cond ((false true) (true true)))"))
				assert.is_falsy(inst:run("(cond ((false true) (true false)))"))
				assert.is_falsy(inst:run("(cond ((false true) (false false)))"))
			end)

			it("single expr-value", function()
				--print(inst:translate("(cond ((true true)))"))
				assert.is_truthy(inst:run("(cond (((and true true) true)))"))
				assert.is_falsy(inst:run("(cond (((and true false) true)))"))
			end)

			it("single expr-expr", function()
				assert.same(16, inst:run("(cond (((and true true) (* 4 4))))"))
				assert.is_falsy(inst:run("(cond (((and true false) (* 4 4))))"))
			end)

			it("in cond (expr-closure)", function()
				assert.same(16, inst:run("(cond (((and true true) (cond ((true (* 4 4))))))))"))
				assert.is_falsy(inst:run("(cond (((and false false) (cond ((true (* 4 4))))))))"))
			end)
		end)
	end)
end)
