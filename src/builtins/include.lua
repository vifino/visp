-- visp include statements.
-- Rudimentary form of multi-file source code.

local pcall = pcall
local ioo = io.open
local error = error
local sm = string.match

local function find_file(path, name)
	local fname = path .. "/" .. name
	local success, fh = pcall(ioo, fname, "r")
	if success and fh then
		return fh, fname
	end
	return nil, fname
end

local function dirname(name)
	return sm(name, "^(.+)/") or "."
end


return function(inst)
	local isexpr = inst.isexpr

	inst.incpath = "."

	inst.cgfns.include = function(ev, str)
		-- TODO: fix the god damn strings.
		local name = ev:parse(str)
		name = name:sub(2, #name-1)

		local fh, fname = find_file(ev.incpath, name)

		if not fh then
			error("file '"..fname.."' not found", 1)
		end

		local fc = fh:read("*all")
		if not fc then
			error("file '"..fname.."' failed to read", 1)
		end

		-- Temporarily switch incpaths to be relative to the file.
		local oldinc = ev.incpath
		ev.incpath = dirname(fname)
		local g = ev:translate(fc)
		ev.incpath = oldinc
		if isexpr(g) then
			return g
		end
		return {
			["type"] = "expr",
			"(function()",
			g,
			"end)()"
		}
	end
end
