-- Operator builtins.

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

return function(inst)
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
