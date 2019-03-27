-- Control statements.

-- Conditionals
-- (cond (
--        (check branch)))
-- This is a bit more involved.
-- Since we're a JIT, we don't have access to the actual
-- code graph in the running code.
-- The problem is "solved" by generating functions.
-- Unfortunately, this results in the creation of
-- at least 2 functions. One for the conditional, one for the branch.

local function gencond(inst)
	local isexpr = inst.isexpr
	local experize = inst.experize

	inst.cgfns["cond"] = function(ev, conds)
		if conds.type ~= "expr" then
			error("conditional needs expr ast, got "..conds.type, 1)
		end
		local nconds = #conds
		local t = {
			["type"] = "closure"
		}
		for i=1, nconds do
			local cond = conds[i]
			-- first is the check, second is the branch or value
			-- check should be an expression, if it's not, it needs to be wrapped
			-- branch is probably either a value (no brackets) or expr/branch
			-- we need to make sure in both cases that expressions return values
			-- get forwarded.
			t[#t+1] = "if "

			local cc = ev:parse(cond[1])
			t[#t+1] = experize(cc)
			t[#t+1] = " then"

			local cb = ev:parse(cond[2])
			local branch = {
				["type"] = "closure",
				"return ",
			}
			if isexpr(cb) then
				branch[2] = cb
			else
				-- TODO: check if function is needed
				-- It doesn't seem to be on first glance.
				-- After all, it'll return.
				--branch[1] = "return (function()"
				branch[1] = cb
				--branch[3] = "end)()"
			end
			t[#t+1] = branch
			t[#t+1] = "end"
		end
		return t
	end
end

return function(inst)
	-- Conditionals
	gencond(inst)
end
