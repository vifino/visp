-- Basic visp builtin operators spec.

describe("#builtins #operators", function()
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

		describe("basic arithmetic", function()
			it("addition", function()
				assert.same(3, inst:run("(+ 1 2)"))
			end)

			it("substraction", function()
				assert.same(1, inst:run("(- 3 2)"))
			end)

			it("multiplication", function()
				assert.same(4, inst:run("(* 2 2)"))
			end)

			it("division", function()
				assert.same(2, inst:run("(/ 6 3)"))
			end)

			it("negation", function()
				assert.same(-123, inst:run("(neg 123)"))
			end)
		end)

		describe("basic multival arithmetic", function()
			it("addition", function()
				assert.same(6, inst:run("(+ 1 2 3)"))
			end)

			it("substraction", function()
				assert.same(0, inst:run("(- 3 2 1)"))
			end)

			it("multiplication", function()
				assert.same(16, inst:run("(* 2 2 4)"))
			end)

			it("division", function()
				assert.same(1, inst:run("(/ 6 3 2)"))
			end)
		end)

		describe("basic conditional", function()
			it("equals", function()
				assert.is_truthy(inst:run("(== 1 1)"))
				assert.is_falsy(inst:run("(== 3 2)"))
			end)

			it("not equals", function()
				assert.is_truthy(inst:run("(!= 1 2)"))
				assert.is_falsy(inst:run("(!= 4 4)"))
			end)

			it("greater than", function()
				assert.is_truthy(inst:run("(> 2 1)"))
				assert.is_falsy(inst:run("(> 2 3)"))
			end)

			it("less than", function()
				assert.is_truthy(inst:run("(< 1 2)"))
				assert.is_falsy(inst:run("(< 3 2)"))
			end)

			it("greater than or equals", function()
				assert.is_truthy(inst:run("(>= 2 1)"))
				assert.is_truthy(inst:run("(>= 2 2)"))
				assert.is_falsy(inst:run("(>= 2 3)"))
			end)

			it("less than or equals", function()
				assert.is_truthy(inst:run("(<= 1 2)"))
				assert.is_truthy(inst:run("(<= 1 1)"))
				assert.is_falsy(inst:run("(<= 3 2)"))
			end)
		end)

		describe("logical", function()
			it("and", function()
				assert.is_truthy(inst:run("(and true true)"))
				assert.is_falsy(inst:run("(and true false)"))
				assert.is_falsy(inst:run("(and false true)"))
			end)
			it("or", function()
				assert.is_truthy(inst:run("(or true true)"))
				assert.is_truthy(inst:run("(or true false)"))
				assert.is_truthy(inst:run("(or false true)"))
				assert.is_falsy(inst:run("(or false false)"))
			end)
		end)

		describe("logical multivalue", function()
			it("and", function()
				assert.is_truthy(inst:run("(and true true true)"))
				assert.is_falsy(inst:run("(and true true false)"))
				assert.is_falsy(inst:run("(and trie false true)"))
			end)
			it("or", function()
				assert.is_truthy(inst:run("(or true true true)"))
				assert.is_truthy(inst:run("(or true true false)"))
				assert.is_truthy(inst:run("(or false true true)"))
				assert.is_falsy(inst:run("(or false false false)"))
			end)
		end)
	end)
end)
