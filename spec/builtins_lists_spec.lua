describe("#builtins #lists", function()
	local inst
	setup(function()
		local visp = require("visp")
		inst = visp.new()
	end)

	-- (list ...)
	it("can create numeric lists", function()
		assert.same({1, 2, 3}, inst:run("(list 1 2 3)"))
	end)

	it("can create boolean lists", function()
		assert.same({true, false}, inst:run("(list true false)"))
	end)

	it("can create string lists", function()
		assert.same({"hi", "hello", "sup there"}, inst:run('(list "hi" "hello" "sup there")'))
	end)

	-- (@ ...)
	it("can access list elements", function()
		assert.same(2, inst:run('(@ 2 (list 1 2 3))'))
	end)
end)
