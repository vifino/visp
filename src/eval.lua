-- Evaluator.
-- Lets go.

local eval = {}

local cg = require("src.codegen")
local p = require("src.parser")

local unpack = table.unpack or unpack
local isexpr = p.isexpr
eval.isexpr = isexpr -- re export

-- New evaluator.
eval.new = function()
	local n = {
		cgfns = {}, -- code generating functions, mostly syntax and builtins
		jit = cg.new()
	}
	n.vals = n.jit.G
	setmetatable(n, {["__index"] = eval})
	return n
end

-- Parse ast.
-- Returns a codegen chain.
-- Recursive, like everything else.
local parse_ast
parse_ast = function(self, ast)
	if (type(ast) ~= "table") or (ast.type == nil) then error("ast not ast??", 1) end

	if ast.type == "body" then -- multiple expressions
		local g = {
			["type"] = "expr",
			"{",
		}
		local nexprs = #ast
		for i=1, #ast do
			local cg = parse_ast(ast[i])
			if isexpr(cg) then
				g[#g+1] = {cg, ","}
			else
				g[#g+1] = {
					["type"] = "expr",
					"(function()",
					cg,
					"end)(),",
				}
			end
		end
		g[#g+1] = "}"
		return g
	elseif ast.type == "id" then
		return "("..ast[1]..")"
	elseif ast.type == "expr" then
		local fn = ast[1]
		if (type(fn) ~= "table") or (not fn.type) then error("expr[1] not ast??", 1) end
		if fn.type == "id" then -- call, the "normal"
			local name = fn[1]
			if self.cgfns[name] then -- special form!
				-- since we're JITting, only the special form gets evaluated
				-- unlike the rest, which just gets emitted.
				-- the cgfns return a call graph.
				-- it gets the sub ast nodes as arguments
				return self.cgfns[name](self, unpack(ast, 2))
			else
				-- we don't know this function, just emit a call.
				local g = {
					["type"] = "expr",
					"("..name.."("
				}
				local last = #ast
				for i=2, last do -- evaluate remaining arguments in expr
					g[i] = { parse_ast(self, ast[i]), (i ~= last) and "," or nil}
				end
				g[#g+1] = "))"
				return g
			end
		else
			-- TODO: fix this
			error("other cases not implemented yet")
		end
	elseif ast.type == "string" then
		-- TODO: replace with proper string escaping
		return '"' .. ast[1] .. '"'
	else
		-- bools, numbers, etc..
		return tostring(ast[1]) -- close enough
	end
end
eval.parse = parse_ast

eval.translate = function(self, code)
	return parse_ast(self, p.readall(code))
end

eval.run = function(self, code)
	code = parse_ast(self, p.readall(code))
	return (self.jit):run(code)
end

return eval
