-- Tokenizer.
-- The tkn() function is from 20kdc.

local tokenizer = {}

-- For a string, removes whitespace, and splits it
--  into the token, the token type, and the remainder.
local function tkn(s)
	s = s:gsub("^[ \r\n\t]+", "")
	local patterns = {
		{"^['()]", "char"},
		{"^\"[^\"]*\"", "string"}, -- If escapes are needed, this needs special handling.
		{"^[^ \r\n\t'()]*", "id"}
	}
	for _, v in ipairs(patterns) do
		local m = s:match(v[1])
		if m then
			return m, v[2], s:sub(#m + 1)
		end
	end
	return nil, nil, s
end

local readsexpr -- read a single sexpr
readsexpr = function(str)
	local res = {}

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
			res[#res + 1] = tok
		end
		ostr = str
	until (found_tok or #str == 0)
	return nil, str  -- found no expression
end
tokenizer.readsexpr = readsexpr

local dumpexpr
dumpexpr = function(expr, fh)
	fh = fh or io.stdout
	fh:write("(")
	local last = #expr
	for i=1, last do
		local tok = expr[i]
		if type(tok) == "string" then
			fh:write(tok .. ((i == last) and "" or " "))
		elseif type(tok) == "table" then
			dumpexpr(tok, fh)
		end
	end
	fh:write(")")
end
tokenizer.dumpexpr = dumpexpr

return tokenizer
