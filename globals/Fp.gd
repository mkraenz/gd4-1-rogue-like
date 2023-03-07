class_name Fp
extends Node
# Utility script that implements functional programming routines. 
# Use via Fp.my_static_function without importing in the client script.
# 'Fp' stands for 'functional programming'

static func find_by(property_name: String, array: Array, search_value):
	for element in array:
		if element[property_name] == search_value:
			return element

static func dict_to_array(dict: Dictionary) -> Array:
	var arr := []
	for key in dict:
		arr.append(dict[key])
	return arr

static func pick(property_name: String, obj):
	return obj[property_name]

static func foreach(input: Array, function: Callable) -> void:
	for element in input:
		function.call(element)

static func map(input: Array, function: Callable) -> Array:
	var result := []
	result.resize(len(input))
	for i in range(len(input)):
		result[i] = function.call(input[i])
	return result

static func filter(input: Array, function: Callable) -> Array:
	var result := []
	for element in input:
		if function.call(element):
			result.append(element)
	return result

static func filter_existent(input: Array) -> Array:
	var result := []
	for element in input:
		if object_exists(element):
			result.append(element)
	return result

static func reduce(input: Array, function: Callable, initial_value = null):
	var accumulator = initial_value
	var index := 0
	if not initial_value and input.size() > 0:
		accumulator = input[0]
		index = 1
	while index < input.size():
		accumulator = function.call(accumulator, input[index])
		index += 1
	return accumulator

static func object_exists(x):
	return is_instance_valid(x)
