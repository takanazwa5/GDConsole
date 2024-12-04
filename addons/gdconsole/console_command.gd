extends RefCounted


var command : StringName
var description : String
var args : Array[Dictionary]
var default_args : Array

var _callable : Callable


func _init(p_callable: Callable, p_command: StringName, p_description: String) -> void:
	_callable = p_callable
	command = p_callable.get_method().trim_prefix("_") if p_command.is_empty() else p_command
	description = p_description
	_init_args(p_callable.get_object())


func _init_args(p_object: Object) -> void:
	var method_list : Array[Dictionary] = p_object.get_script().get_script_method_list()
	for method : Dictionary in method_list:
		if method.name == _callable.get_method():
			for arg : Dictionary in method.args:
				args.append({"name": arg.name, "type": arg.type})
			default_args = method.default_args
			return


func execute(p_args: PackedStringArray) -> Dictionary:
	var required_args_count : int = args.size() - default_args.size()

	if p_args.size() < required_args_count:

		if default_args.is_empty():
			var s : String = "Expected %s arguments, received %s" % \
			[required_args_count, p_args.size()]
			return {"error" : FAILED, "string" : s}

		else:
			var s : String = "Expected at least %s of %s arguments, received %s" % \
			[required_args_count, args.size(), p_args.size()]
			return {"error" : FAILED, "string" : s}

	elif p_args.size() > args.size():

		var s : String = "Too many arguments for \"%s\" call. Expected at most %s but received %s." % \
		[_callable.get_method(), args.size(), p_args.size()]
		return {"error" : FAILED, "string" : s}

	var result : Variant

	if args.size() == 0:
		result = _callable.call()

	else:
		var converted_args : Array
		for i : int in p_args.size():

			match args[i].type:

				TYPE_INT when p_args[i].is_valid_int():
					converted_args.append(p_args[i].to_int())

				TYPE_INT:
					if not p_args[i].is_empty():
						return {"error" : FAILED, "string" : "Argument %s is not a valid int." % [i + 1]}
					break

				TYPE_FLOAT when p_args[i].is_valid_float():
					converted_args.append(p_args[i].to_float())

				TYPE_FLOAT:
					if not p_args[i].is_empty():
						return {"error" : FAILED, "string" : "Argument %s is not a valid float." % [i + 1]}
					break

				_:
					converted_args.append(type_convert(p_args[i], args[i].type))
					if converted_args[i] == null:
						var s : String = "Cannot convert argument %s from String to %s" % \
						[i + 1, type_string(args[i].type)]
						return {"error" : FAILED, "string" : s}

		result = _callable.callv(converted_args)

	if not result == null:
		return {"error" : OK, "string" : str(result)}

	return {"error" : OK, "string" : ""}
