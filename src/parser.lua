-- Tokenizer and Parser.
-- The tkn() function is from 20kdc.

local parser = {}

-- For a string, removes whitespace, and splits it
--  into the token, the token type, and the remainder.
local patterns = {
	{"^['()]", "char"},
	{"^\"[^\"]*\"", "string"}, -- If escapes are needed, this needs special handling.
	{"^[^ \r\n\t'()]*", "id"}
}

local function tkn(s)
	s = s:gsub("^[ \r\n\t]+", "")
	for _, v in ipairs(patterns) do
		local m = s:match(v[1])
		if m then
			return m, v[2], s:sub(#m + 1)
		end
	end
	return nil, nil, s
end

-- Expression reader.
-- Takes a string and returns an equivalent AST.
local readsexpr -- read a single sexpr
readsexpr = function(str)
	local res = {
		["type"] = "expr"
	}

	local found_exp = false
	local tok, tkt
	local ostr = str
	repeat
		tok, tkt, str = tkn(str)
		if not tok then return nil end
		if tok == "(" then -- start expression
			if not found_exp then found_exp = true else
				-- a sub expression
				res[#res + 1], str = readsexpr(ostr)
			end
		elseif tok == ")" then
			if not found_exp then
				error("unmatched parens: "..str, 1)
			end
			return res, str
		else
			local elm = {tok}
			elm.type = tkt
			if not found_exp then return elm end -- ooc expr
			res[#res + 1] = elm
		end
		ostr = str
	until (found_tok or #str == 0)
	return nil, str  -- found no expression
end
parser.readsexpr = readsexpr

-- Expression dumper.
-- Takes an AST and returns an equivalent string.
local dumpexpr
dumpexpr = function(expr)
	local str = "("
	local last = #expr
	for i=1, last do
		local elm = expr[i]
		if type(elm) ~= "table" then error("invalid sexpr tree?", 1) end
		if elm.type == "expr" then
			str = str .. dumpexpr(elm)
		else
			local space = (i == last) and "" or " "
			local tok
			if elm.type == "id" then tok = elm[1]
			elseif elm.type == "string" then tok = '"'..elm[1]..'"' end -- replace this
			str = str .. tok .. space
		end
	end
	return str .. ")"
end
parser.dumpexpr = dumpexpr

return parser
