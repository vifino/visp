-- Tokenizer and Parser.
-- The tkn() function is from 20kdc.

local parser = {}

local type = type
local ip = ipairs
local sm, ss, sgs = string.match, string.sub, string.gsub
local tconc = table.concat

-- For a string, removes whitespace, and splits it
--  into the token, the token type, and the remainder.
local patterns = {
	{"^;.*[\r\n]*", "comment"},
	{"^['()]", "char"},
	{"^-?[0-9]%.?[0-9]?+", "number"}, -- parses 1, -1, 1.0, -1.0, but no invalid numbers
	{"^true", "boolean"},
	{"^false", "boolean"},
	{"^\"[^\"]*\"", "string"}, -- If escapes are needed, this needs special handling.
	{"^[^ \r\n\t'()]+", "id"}
}

local function tkn(s)
	s = sgs(s, "^[ \r\n\t]+", "")
	for _, v in ip(patterns) do
		local m = sm(s, v[1])
		if m then
			return m, v[2], ss(s, #m + 1)
		end
	end
	return nil, nil, s
end

-- Expression reader.
-- Takes a string and returns an equivalent AST.
local readexpr -- read a single sexpr
readexpr = function(str)
	if type(str) ~= "string" then error("invalid input: not string, is type "..type(str), 1) end
	local res = {
		["type"] = "expr"
	}

	local found_exp = false
	local tok, tkt
	local ostr = str
	local sstr = str
	repeat
		tok, tkt, str = tkn(str)
		if not tok then return nil end
		if tkt ~= "comment" then -- discard those
			if tok == "(" then -- start expression
				if not found_exp then found_exp = true else
					-- a sub expression
					res[#res + 1], str = readexpr(ostr)
				end
			elseif tok == ")" then
				if not found_exp then
					error("unmatched parens (too many): "..sstr, 1)
				end
				return res, str
			else
				local elm = {
					["type"] = tkt
				}

				if tkt == "number" then elm[1] = tonumber(tok)
				elseif tkt == "boolean" then elm[1] = (tok == "true")
				elseif tkt == "string" then
					-- TODO: add proper string parsing.
					-- This only works because none of the escapes are parsed.
					-- In the JITted code, it'll just be embedded.
					-- That will work, as Lua parses the escapes.
					elm[1] = tok:sub(2, #tok - 1)
				else elm[1] = tok end

				if not found_exp then return elm end -- ooc expr
				res[#res + 1] = elm
			end
			ostr = str
		end
	until #str == 0

	if found_exp then
		error("unmatched parens (too few): "..sstr, 1)
	end

	return nil, ""  -- found no expression
end
parser.readexpr = readexpr

-- Expression dumper.
-- Takes an AST and returns an equivalent string.
local dumpexpr
dumpexpr = function(expr)
	local last = #expr
	if expr.type == "body" then
		local t = {}
		for i=1, last do
			t[i] = dumpexpr(last)
		end
		return tconc(t, "\n")
	end
	local str = "("
	for i=1, last do
		local elm = expr[i]
		if (not (type(elm) == "table" and elm.type)) then error("invalid sexpr tree?", 1) end
		local space = (i == last) and "" or " "
		if elm.type == "expr" then
			str = str .. dumpexpr(elm) .. space
		else
			local tok
			if elm.type == "string" then
				-- TODO: replace with proper escaping.
				tok = '"'..elm[1]..'"'
			else
				tok = tostring(elm[1])
			end
			str = str .. tok .. space
		end
	end
	return str .. ")"
end
parser.dumpexpr = dumpexpr

-- Helpers
local function readall(code)
	if type(code) ~= "string" then
		error("parser: readall requires string", 1)
	end
	local node
	local body = {
		["type"] = "body" -- synthetic type. just a bunch of exprs.
	}

	while code and code ~= "" do
		node, code = readexpr(code)
		if node then body[#body+1] = node end
	end

	if #body == 1 then
		return body[1]
	end
	return (node and body) or nil
end
parser.readall = readall

local function isexpr(node)
	if type(node) == "table" then
		return (node.type == "expr")
	end
	return true
end
parser.isexpr = isexpr

return parser
