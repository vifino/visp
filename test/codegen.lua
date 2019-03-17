-- Small test for codegen
local cg = require("src.codegen")

-- Instance management
local inst = cg.new()
inst.G["print"] = print

-- Basic functions
print("basics:")
local hello_tree = {
	"print('hello world!')"
}
local hello_f = inst:loadstr(hello_tree[1])
print(hello_f)
hello_f()
print(cg.gethash(hello_f))

-- Codegen
print("codegen:")
local adder_fun_tree = {
	"local args = {...}",
	"return args[1] + args[2]"
}

-- Complex chain
print("multilayer")
local multilayer_tree = {
	"local args = {...}",
	"if args[1] then",
	hello_tree,
	"else",
	{
		"return 'nope'"
	},
	"end"
}
multilayer_src = inst:parse(multilayer_tree)
print(multilayer_src)
local multilayer = inst:loadstr(multilayer_src)
print(multilayer(true))
print(multilayer(false))

-- Functions
print("functions:")
inst:def("hello", {
	"local args = {...}",
	"print('Hello' .. (args[1] and ' '..args[1] or '')..'!')"
})

inst.G.hello("CG")

-- Expressions
print("expressions:")
inst.G.select = select
local function arg(n)
	return "(select("..tonumber(n)..", ...))"
end
local function op(op, a, b)
	return "("..tostring(a).." " .. op .. " " .. tostring(b)..")"
end

local expr_tree = {
	op("+", op("-", 100, 50), 25),
	"+ ("..arg(1).." or 10)"
}
local expr_code = inst:parse(expr_tree)
print(expr_code)
local expr_fn = inst:loadstr(expr_code)
print(expr_fn())
