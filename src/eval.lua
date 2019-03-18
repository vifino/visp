-- Evaluator.
-- Lets go.

local eval = {}

local cg = require("src.codegen")
local p = require("src.parser")

-- New evaluator.
eval.new = function()
	local n = {
		special = {}, -- syntax handling functions
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
	if ast.type == "id" then
		return "("..ast[1]..")"
	elseif ast.type == "expr" then
		local fn = ast[1]
		local J = self.jit
		if (type(fn) ~= "table") or (not fn.type) then error("expr[1] not ast??", 1) end
		if fn.type == "id" then -- call, the "normal"
			local name = fn[1]
			if name:sub(1,1) == "$" then -- special form!
				-- since we're JITting, only the special form gets evaluated
				-- unlike the rest, which just gets emitted.
				local sfn = name:sub(2)
				if not self.special[sfn] then
					error("tried to call special "..sfn.." which does not exist.", 1)
				end
				return self.special[sfn](self, unpack(ast, 2))
			else
				local g = {
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
	else
		return "("..ast[1]..")" -- strings, numbers, etc..
	end
end
eval.parse = parse_ast

eval.translate = function(self, code)
	return parse_ast(self, p.readsexpr(code))
end

eval.run = function(self, code)
	local code = parse_ast(self, p.readsexpr(code))
	return (self.jit):run(code)
end

return eval
