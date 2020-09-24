local shadowTableModule = require("./shadowTableModule")
local shadowTable = shadowTableModule.new()
local shadowTableChnagedEvent

shadowTable.example = "Hello, World!" -- Our normal index

shadowTable.example.Removed.Event:Connect(function()
	shadowTableChnagedEvent:Disconnect() -- Once we remove the index, We disconnect the event.
	-- NOTE; The bindable destroys itself once destroyed.
end)

shadowTableChnagedEvent = shadowTable.example.Changed.Event:Connect(function(oldValue, newValue)
	print("oldValue: " .. tostring(oldValue)) -- Before changed

	print("newValue: " .. tostring(newValue)) -- After changed
end)

shadowTable.example = "Bye, World!" -- Fire the changed event
shadowTable.example = nil -- Fire the removed event.
