local utils = {}

utils.addToList = function(arr, obj)
	obj.id = #arr + 1
	table.insert(arr, obj)
end

utils.addToList = function(arr, obj)
	obj.id = #arr + 1
	table.insert(arr, obj)
end

utils.removeFromList = function(arr, id)
	arr[id] = arr[#arr]
	arr[id].id = id
	arr[#arr] = nil
end

return utils
