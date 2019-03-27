-- Code gen for JITs and the likes.
-- Very simplistic, but handy.
--
-- Abstracts away the boundry of code vs graph vs obj.
-- Does JIT compilation.
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

cg.new = function()
	local inst = {
		C = {},
		G = {},
		fns = {},
	}
	inst.G["_G"] = inst.G
	sme(inst, {["__index"] = cg})
	return inst
end

-- Lua code loading
local cg_loadstr
if not sfe then
	cg_loadstr = function(self, code)
		local f, e = loadstr("return ".. code, nil, "t", self.G)
		if e then return assert(loadstr(code, nil, "t", self.G)) end
		return f
	end
else
	cg_loadstr = function(self, code)
		local f, e = loadstring("return ".. code)
		if e then f = assert(loadstring(code)) end
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
	error("can't find hash of non-function", 1)
end
cg.gethash = gethash

local cg_parse
cg_parse = function(self, chain, depth) -- recursive solution
	depth = depth or 0
	local pad = strrep("\t", depth)
	if type(chain) == "string" then return pad .. chain
	elseif type(chain) ~= "table" then error("chain not string or table", 1) end

	local out = {
		["type"] = "expr"
	}
	for i=1, #chain do
		local elem = chain[i]
		local elt = type(elem)
		if elt == "table" then
			local graph = cg_parse(self, elem, depth + 1)
			if type(graph) == "table" then -- graph
				if not graph.type then graph.type = "expr" end
				if graph.type == "expr" and out.type == "expr" then
					-- we are an expression still and so is the graph to be embedded
					out[i] = graph
				else
					-- we or the graph is a closure
					out.type = (graph.type ~= "expr" and graph.type) or "closure"
					out[i] = graph
				end
			else -- edge
				out[i] = graph
			end
		elseif elt == "function" then
			local hash = "fcn_" .. gethash(elem)
			self.G[hash] = elem
			out[i] = pad .. "("..hash..")" -- not the best, but it'll do
		elseif elt == "string" then
			out[i] = pad .. elem
		else
			out[i] = tostring(elem)
		end
	end
	return tconc(out, "\n")
end
cg.parse = cg_parse

-- Loading helpers
local cg_load = function(self, chain)
	return cg_loadstr(self, cg_parse(self, chain))
end
cg.load = cg_load

local cg_def = function(self, name, chain)
	local v = self.fns[name]
	if not v then
		v = cg_parse(self, chain, 1)
		local fnbody = name.." = function(...)\n" .. v .. "\nend\n"

		cg_loadstr(self, fnbody)()
		self.fns[name] = v
	end
	return "(" .. name .. ")"
end
cg.def = cg_def

local cg_run = function(self, snippet, ...)
	-- cheesy caching
	local v = self.C[snippet]
	if v then return v(...) end
	v = cg_load(self, snippet)
	self.C[snippet] = v
	return v(...)
end
cg.run = cg_run

return cg
