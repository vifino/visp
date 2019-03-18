-- Small test for codegen
describe("#codegen", function()
	local cg = require("src.codegen")

	describe("initializes", function()
		local inst
		setup(function()
			inst = cg.new()
			inst.G.assert = assert

			-- Fake print function.
			inst.G["print"] = function(str)
				assert.same("hello world!", str)
			end
		end)

		describe("and does basic", function()
			local hello_tree = {
				"print('hello world!')"
			}

			it("code loading", function()
				local hello_f = inst:loadstr(hello_tree[1])
				assert.same(type(hello_f), "function")
			end)

			it("code execution", function()
				local hello_f = inst:loadstr(hello_tree[1])
				hello_f()
			end)
		end)

		describe("and does simple", function()
			local adder_fun_tree = {
				"local args = {...}",
				"return args[1] + args[2]"
			}

			it("loading", function()
				assert.same("function", type(inst:load(adder_fun_tree)))
			end)

			it("execution", function()
				local fn = inst:load(adder_fun_tree)
				assert.same(fn(1, 2), 1 + 2)
			end)
		end)

		describe("and does multilayer", function()
			local multilayer_tree = {
				"local args = {...}",
				"if args[1] then",
				{
					"print('hello world!')"
				},
				"else",
				{
					"return 'nope'"
				},
				"end"
			}

			it("parsing", function()
				assert(inst:parse(multilayer_tree))
			end)

			it("loading", function()
				assert.same("function", type(inst:loadstr(inst:parse(multilayer_tree))))
			end)

			describe("execution with", function()
				local multilayer 
				setup(function()
					multilayer = inst:loadstr(inst:parse(multilayer_tree))
				end)

				it("true", function()
					multilayer(true)
				end)
				it("false", function()
					assert.same(multilayer(false), "nope")
				end)
			end)
		end)

		describe("and does function", function()
			local hello_fn = {
				"local args = {...}",
				"print('hello ' .. args[1]..'!')"
			}

			it("definition", function()
				 inst:def("hello", hello_fn)
			end)

			describe("execution", function()
				inst:def("hello", hello_fn)
				inst.G.hello("world")
			end)
		end)
	end)
end)
