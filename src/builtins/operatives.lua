-- visp operatives and AST manipulation functions.
--
-- operatives are first-class combiners whose operands
-- are never evaluated.
-- applicatives are operatives that evaluate the operands.
--
-- Defines oper, wrapoper and defoper.
-- Lambda could be defined as:
-- (def-oper "lambda"
--           (oper (args body)
--                 (wrapoper (oper args body))))
--
-- For it to be any use, ast manipulation and related functions are added:
-- ast-parse ast-unpack
--
-- Inspired by $vau from Kernel Lisp.
local opers = {}

local type = type
local unpack = table.unpack or unpack
local tconc = table.concat
local gethash

local function isexpr(node)
	if type(node) == "table" then
		return (node.type == "expr")
	end
	return true
end

-- (oper (args body)) -> operative anonf
-- Generates an anonymous function,
-- not explicitly evaluating the arguments.
opers.oper = function(ev, args, body)
	if args.type ~= "expr" then
		error("oper needs args as expr ast of ids, got "..tostring(args.type).." instead of expr", 1)
	end

	-- Generate function prelude.
	local argnames = {}
	for i=1, #args do
		local argn = args[i]
		if argn.type ~= "id" then
			error("oper needs args as expr ast of ids, got "..argn.type.." instead of id", 1)
		end
		argnames[i] = argn[1]
	end

	local t = {
		["type"] = "expr", -- very important: it's been wrapped
		"(function(_eval_inst, " .. tconc(argnames, ", ") .. ")"
	}

	-- Generate function body.
	local tbody = ev:parse(body)
	local closure = {
		["type"] = "closure",
		"return",
	}
	if isexpr(tbody) then
		closure[2] = tbody
	else
		closure[1] = tbody
	end
	t[#t+1] = closure

	t[#t+1] = "end)"
	return t
end

-- (wrapoper (oper args..)) -> applicative anonf
-- Wraps an operative converting it into
-- an applicative.
-- It itself is somewhat of an operative,
-- but essentially emulating an applicative.
opers["wrapoper"] = function(ev, oper)
	if oper.type ~= "expr" then
		error("wrapoper: can't wrap non-oper", 1)
	end
	if oper[1].type ~= "id" then
		error("wrapoper: can't wrap expr with non-id oper reference (only static)", 1)
	end

	local oper_name = oper[1][1]
	if not ev.cgfns[oper_name] then
		error("wrapoper: cannot find oper named '"..oper_name.."'", 1)
	end

	local args = {}
	local nargs = #oper - 1
	for i=1, nargs do
		local t = {
			ev:parse(oper[1+i])
		}
		if i ~= nargs then t[2] = ',' end
		args[i] = t
	end

	-- This is bad. Bad to write, bad to read.
	-- Rather inefficient, too.
	-- This all stems from the cgfns only returning code graphs.
	-- We're a JIT. We generate code. We don't know what's going on.
	-- I'm not sure we can do better without much effort,
	-- but this code is not pretty.
	return {
		['type'] = 'closure',
		'local _wrapper_oper = _eval_inst.jit:run(_eval_inst.cgfns["'..oper_name..'"](_eval_inst, ',
		args, '))',
		'local _wrapperfn = function(...)',
		{
			'return _wrapper_oper(_eval_inst, ...)',
		},
		'end',
		'local _wrapper_hash = "oper_" .. _cg_gethash(_wrapperfn)',
		'_G[_wrapper_hash] = _wrapperfn',
		'return _wrapper_hash'
	}
end

-- (defoper name oper)
-- Registers an oper.
-- Applicative.
local function gendefoper(inst)
	inst.vals["defoper"] = function(name, oper)
		if type(name) ~= "string" then
			error("def-oper needs string name: got "..type(name), 1)
		end
		if type(oper) ~= "function" then
			error("def-oper needs operative function: got "..type(name), 1)
		end
		inst.cgfns[name] = oper
		return name
	end
end

return function(inst)
	-- Set up locals
	gethash = inst.jit.gethash

	-- Bind essentials.
	inst.vals["_eval_inst"] = inst
	inst.vals["_cg_gethash"] = gethash
	inst.vals["ast-pack"] = table.pack or pack
	inst.vals["ast-unpack"] = unpack

	inst.vals["ast-parse"] = function(ast)
		return inst:parse(ast)
	end

	-- Register all operatives.
	for name, operative in pairs(opers) do
		inst.cgfns[name] = operative
	end

	-- Generate applicatives.
	gendefoper(inst)
end
