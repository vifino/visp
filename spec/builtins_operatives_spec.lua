-- Basic visp builtin operatives spec.

describe("#builtins #operatives", function()
	local inst
	setup(function()
		local visp = require("src.visp")
		inst = visp.new()
	end)

	describe("oper", function()
		it("simple arg-val pair", function()
			local oper = inst:run("(oper (a) a)")
			assert.same("function", type(oper))
		end)

		it("simple arg-expr pair", function()
			local oper = inst:run("(oper (a) (a))")
			assert.same("function", type(oper))
		end)

		it("with invalid arguments", function()
			assert.has.errors(function()
				inst:run("(oper hi)")
			end)
		end)
	end)

	--[[
	-- testing wrapoper standalone is hard.
	describe("wrapoper", function()
		it("converts simple passthrough oper", function()
			--inst.vals.val = "testval"
			--insts.vals.dummy = function()
			print(inst:translate("(wrapoper (oper (dummy) val))"))
			local appl = inst:run("(wrapoper (oper (a) a))")
			assert.same("function", type(appl))
		end)

		it("converts simple expr oper", function()
			local appl = inst:run("(wrapoper (oper (a) (a)))")
			assert.same("function", type(appl))
		end)
	end)
	--]]

	describe("def-oper", function()
		it("registers simple operatives", function()
			local success = false
			local oper = function()
				success = true
				return {}
			end
			inst.eval.vals["vsucc"] = oper
			inst:run('(defoper "opersucc" vsucc)')
			inst:run("(opersucc)")
			assert.is_truthy(success)
		end)

		it("registers compound operatives", function()
			local success = false
			local appl = function(state)
				success = state
				return {} -- empty CG
			end
			inst.eval.vals["applsucc"] = appl
			inst:run('(defoper "succ" (oper (state) (applsucc state)))')
			inst:run("(succ true)")
			assert.is_truthy(success)
		end)

		it("registers compound operatives lambda implementation", function()
			local success = false
			local appl = function(state)
				success = state
			end
			inst.eval.vals["applsucc"] = appl
			-- Uncomment this if you want your opinion of this project to go negative.
			--print(inst:translate('(defoper "lambda" (oper (args body) (wrapoper (oper args body))))'))
			inst:run('(defoper "lambda" (oper (args body) (wrapoper (oper args body))))')

			--print(inst:translate('(lambda (state) (applsucc state))'))
			local fn = inst:run('(lambda (state) (applsucc state))')
			fn(true)
			assert.is_truthy(success)
		end)

	end)
end)
