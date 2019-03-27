-- Builtins loader.

local builtins = {
	"include",
	"operatives",
	"operators",
	"lists",
	"control",
	"test",
}

local loaders = {}
for i=1, #builtins do
	loaders[i] = require("builtins."..builtins[i])
end

return function(inst)
	for i=1, #loaders do
		loaders[i](inst)
	end
end
