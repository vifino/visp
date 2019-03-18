-- The basic builtins.
-- These will hopefully suffice for our stdlib.

-- Generators
local function genlist(ev, gen, arg, names)
	for i=1, #arg do
		local name = (names and names[i]) or arg[i]
		ev.cgfns[name] = gen(ev, arg[i])
	end
end

local function genop1(_, op)
	return function(ev, arg)
		return {
			["type"] = "expr",
			op, ev:parse(arg)
		}
	end
end

local function genop2(_, op)
	return function(ev, first, ...)
		local opers = {...}
		local nopers = #opers
		if nopers == 0 then
			error("need more args in op: "..op..", need 2+, got "..tostring(nopers+1))
		end
		local t = {
			["type"] = "expr",
			"(", ev:parse(first), op
		}
		for i=1, nopers do
			t[#t+1] = ev:parse(opers[i])
			if i ~= nopers then t[#t+1] = op end
		end
		t[#t+1] = ")"
		return t
	end
end

local function isexpr(node)
	if type(node) == "table" then
		return (cc.type == "expr")
	end
	return true
end

-- Conditional.
-- (cond (
--        (check branch)))
-- This is a bit more involved.
-- Since we're a JIT, we don't have access to the actual
-- code graph in the running code.
-- The problem is "solved" by generating functions.
-- Unfortunately, this results in the creation of
-- at least 2 functions. One for the conditional, one for the branch.

local function gencond(ev)
	return function(ev, conds)
		if conds.type ~= "expr" then
			error("conditional needs expr ast, got "..conds.type, 1)
		end
		local nconds = #conds
		local t = {
			["type"] = "closure"
		}
		for i=1, nconds do
			local cond = conds[i]
			-- first is the check, second is the branch or value
			-- check should be an expression, if it's not, it needs to be wrapped
			-- branch is probably either a value (no brackets) or expr/branch
			-- we need to make sure in both cases that expressions return values
			-- get forwarded.
			t[#t+1] = "if "
			local cc = ev:parse(cond[1])
			local check = {}
			if isexpr(cc) then
				check.type = "expr"
				check[1] = cc
			else
				-- TODO: wrap in function definition for caching?
				check.type = "anonf"
				check[1] = "(function()"
				check[2] = cc
				check[3] = "end)()"
			end
			t[#t+1] = check
			t[#t+1] = " then"

			local cb = ev:parse(cond[2])
			local branch = {}
			if isexpr(cb) then
				branch = {"return", cb}
			else
				-- TODO: wrap in function definition for caching?
				branch.type = "anonf"
				branch[1] = "return (function()"
				branch[2] = cc
				branch[3] = "end)()"
			end
			t[#t+1] = branch
			t[#t+1] = "end"
		end
	end
end

return function(inst)
	-- Forward vals
	inst.vals["true"] = true
	inst.vals["false"] = false
	inst.vals["type"] = type

	inst.vals["math"] = math

	-- Conditionals
	inst.cgfns["cond"] = gencond(inst)

	-- Generate operators
	local single_ops = {"#", "!", "-"}
	local single_ops_names = {"length", "not", "neg"}
	genlist(inst, genop1, single_ops, single_ops_names)

	-- Arithmetic operators
	local arith_ops = {"+", "-", "*", "/", "%", "^"}
	local arith_ops_names = {"+", "-", "*", "/", "%", "exp"}
	genlist(inst, genop2, arith_ops, arith_ops_names)

	-- TODO: bind math library functions

	-- Logical operators
	local logic_ops = {"and", "or"}
	genlist(inst, genop2, logic_ops)

	-- Comparisons
	local comp_ops = {"==", "~=", ">", "<", ">=", "<="}
	local comp_ops_names = {"==", "!=", ">", "<", ">=", "<="}
	genlist(inst, genop2, comp_ops, comp_ops_names)
end
