local shadowTable = {}
local tableContent = {}
local tableManipulation = {}

--<<-------------------------------------------------------->>--

tableContent.__metatable = "The metatable is locked."

function tableContent:__index(index)
	local content = rawget(self, "content")
	local events = rawget(self, "events")
	
	if events[index] then return events[index] end
	return content[index]
end

function tableContent:__newindex(index, value)
	local content = rawget(self, "content")

	content[index] = value
end

function tableContent:__tostring(index)
	local content = rawget(self, "content")

	return tostring(content)
end

function tableContent:__call(...)
	local content = rawget(self, "content")
	
	return content(...)
end

function tableContent:__concat(value)
	local content = rawget(self, "content")
	
	return content .. value
end

function tableContent:__unm()
	local content = rawget(self, "content")
	
	return -content
end

function tableContent:__add(value)
	local content = rawget(self, "content")
	
	return content + value
end

function tableContent:__sub(value)
	local content = rawget(self, "content")
	
	return content - value
end

function tableContent:__mul(value)
	local content = rawget(self, "content")
	
	return content * value
end

function tableContent:__div(value)
	local content = rawget(self, "content")
	
	return content / value
end

function tableContent:__mod(value)
	local content = rawget(self, "content")
	
	return content % value
end

function tableContent:__pow(value)
	local content = rawget(self, "content")
	
	return content ^ value
end

function tableContent:__eq(value)
	local content = rawget(self, "content")
	
	return content == value
end

function tableContent:__lt(value)
	local content = rawget(self, "content")
	
	return content < value
end

function tableContent:__le(value)
	local content = rawget(self, "content")
	
	return content <= value
end

function tableContent:__len()
	local content = rawget(self, "content")
	
	return #content
end

--<<-------------------------------------------------------->>--

function shadowTable:__index(index)
	local apiCallback = rawget(self, index)

	if apiCallback then
		return apiCallback
	else
		local content = rawget(self, "content")
		
		return content[index]
	end
end

function shadowTable:__newindex(index, value)
	local content = rawget(self, "content")
	
	if content[index] then
		local previousValue = rawget(content[index], "content")
		local events = rawget(content[index], "events")
		
		rawset(content[index], "content", value)
		
		if value == nil then
			events.Removed:Fire(previousValue, value)

			events.Removed:Destroy()
			events.Changed:Destroy()		

			rawset(content, index, nil)
		else
			events.Changed:Fire(previousValue, value)
		end
	else
		local indexTable = {}
		
		indexTable.events = {Changed = Instance.new("BindableEvent"), Removed = Instance.new("BindableEvent")}
		indexTable.content = value
		
		content[index] = setmetatable(indexTable, tableContent)
	end
end

--<<-------------------------------------------------------->>--

function tableManipulation:replicateElements(table_1, table_2, setvalueCallback, methodClass)
	for index, value in pairs(table_1) do
		if setvalueCallback then
			setvalueCallback(methodClass, table_2, index, value)	
		else
			table_2[index] = value	
		end
	end
end

function tableManipulation:removeElements(table_1)
	local clone = {}
	
	for index, value in pairs(table_1) do
		clone[index] = value
		
		table_1[index] = nil
	end
	
	return clone
end

--<<-------------------------------------------------------->>--

return {
	["new"] = function(previousDataTable)
		local self__content = {}
		local self__raw = previousDataTable or {}
		
		tableManipulation:replicateElements(self__raw, self__content)
		tableManipulation:removeElements(self__raw)
		
		self__raw.content = {}
		
		tableManipulation:replicateElements(self__content, self__raw.content, shadowTable.__index, self__raw)
		tableManipulation:removeElements(self__content)

		function self__raw:GetElementChangedSignal(elementName)
			return self__raw[elementName].Changed.Event
		end
		
		setmetatable(self__content, {mode = "k"})
		return setmetatable(self__raw, shadowTable)
	end
}
