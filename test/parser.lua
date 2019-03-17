local p = require("src.parser")

local test = "(first (second arg))"

print("parse:")
local expr = p.readsexpr(test)

print("dump:")
p.dumpexpr(expr)
