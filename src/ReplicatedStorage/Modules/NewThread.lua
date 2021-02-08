return function(func, ...)
	assert(typeof(func) == "function", "Argument 1 must be a function")

	local args = {...}
	local count = select("#", ...)

	local bindable = Instance.new("BindableEvent")
	bindable.Event:Connect(function()
		func(unpack(args, 1, count))
	end)

	bindable:Fire()
	bindable:Destroy()
end