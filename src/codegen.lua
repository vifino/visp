-- Code gen for JITs and the likes.
-- Very simplistic, but handy.
--
-- Abstracts away the boundry of code vs graph vs obj.
-- Does JIT and AoT compilation.
-- Hopes to result in big functions being loaded,
-- which'll improve performance.
-- Note: No DCE/etc, 1:1 translation.

local cg = {}

local assert = assert
local tconc = table.concat
local loadstr = loadstring or load
local sfe = setfenv
local sme = setmetatable
local strsub, strrep = string.sub, string.rep

cg.new = function(aot_fh)
	local inst = {
		C = {},
		G = {},
		fns = {},
		aot=aot_fh and true or false,
		fh = aot_fh,
	}
	inst.G["_G"] = inst.G
	setmetatable(inst, {["__index"] = cg})
	return inst
end

-- Lua code loading
local cg_loadstr
if load then
	cg_loadstr = function(self, code)
		return assert(loadstr(code, nil, 't', self.G))
	end
else
	cg_loadstr = function(self, code)
		local f = assert(loadstring(code))
		sfe(f, self.G)
		return f
	end
end
cg.loadstr = cg_loadstr

-- Chain processing
local gethash = function(val)
	if type(val) == "function" then
		return strsub(tostring(val), 13) -- dirty hack
	end
	error(1, "can't find hash of non-function")
end
cg.gethash = gethash

local caller = function(self, fn)
	return "(" .. hash .. ")"	
end

local cg_parse
cg_parse = function(self, chain, depth) -- recursive solution
	local depth = depth or 0
	local pad = strrep("\t", depth)
	if type(chain) == "string" then return pad .. snippet end

	local out = {}
	for i=1, #chain do
		local elem = chain[i]
		local elt = type(elem)
		if elt == "table" then
			out[i] = cg_parse(self, elem, depth + 1)
		elseif elt == "function" then
			if self.aot then
				error(1, "can't run compiled function in AOT mode")
			end
			local hash = "fcn_" .. gethash(elem)
			self.G[hash] = elem
			out[i] = pad .. "("..hash..")" -- not the best, but it'll do
		elseif elt == "string" then
			out[i] = pad .. elem .. "\n"
		else
			out[i] = tostring(elem)
		end
	end
	return tconc(out)
end
cg.parse = cg_parse

-- Loading helpers
local cg_load = function(self, chain)
	return cg_loadstr(self, cg_parse(self, parse))
end
cg.load = cg_load

local cg_def = function(self, name, chain)
	local v = self.fns[name]
	if not v then 
		v = cg_parse(self, chain, 1)
		local fnbody = name.." = function(...)\n" .. v .. "\nend\n"
	
		if self.aot then
			self.fh:write("local " .. fnbody)
		else
			cg_loadstr(self, fnbody)()
		end
		self.fns[name] = v
	end
	return "(" .. name .. ")"
end
cg.def = cg_def

local cg_run = function(self, snippet, ...)
	-- cheesy caching
	if self.aot then
		error(1, "can't run with AOT enabled")
	end
	local v = self.G[snippet]
	if v then return v(...) end
	v = cg_load(self, snippet)
	self.G[snippet] = v
	return v(...)
end
cg.run = cg_run

return cg
