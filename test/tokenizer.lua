local tokenizer = require("src.tokenizer")

local test = "(first (second arg))"

print("parse:")
local expr = tokenizer.readsexpr(test)


print("dump:")
tokenizer.dumpexpr(expr)
