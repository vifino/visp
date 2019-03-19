-- Builtins loader.

local builtins = {
	"operators",
	"control",
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
