-- Lua visp JIT for bootstrapping.

local cg = require("src.codegen")
local parser = require("src.parser")
local eval = require("src.eval")
local builtins = require("src.builtins")

local visp = {}

-- Entry
local visp_init = function(self)
	if not self then
		self = {}
		setmetatable(self, {["__index"]=visp})
	end
	if not self.eval then
		local e = eval.new()
		builtins(e)
		self.eval = e
	end
	return self
end

visp.new = function()
	return visp_init()
end

-- A debugging aid.
visp.translate = function(self, code)
	return self.eval.jit:parse(self.eval:translate(code))
end

local visp_run = function(self, code)
	return self.eval:run(code)
end
visp.run = visp_run

-- Return module.
return visp
