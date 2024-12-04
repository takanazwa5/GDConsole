@tool
extends EditorPlugin


const _SETTINGS : Dictionary = {
	"general" : {
		"max_history_size" : {
			"type" : TYPE_INT,
			"default_value" : 100,
			"hint" : PROPERTY_HINT_NONE,
			"hint_string" : "test",
		},
	},
	"colors" : {
		"output_background_color" : {
			"type" : TYPE_COLOR,
			"default_value" : Color(0, 0, 0, 0.784),
			"hint" : PROPERTY_HINT_NONE,
			"hint_string" : "test",
		},
		"input_background_color" : {
			"type" : TYPE_COLOR,
			"default_value" : Color(0.098, 0.098, 0.098, 0.784),
			"hint" : PROPERTY_HINT_NONE,
			"hint_string" : "test",
		},
		"font_color" : {
			"type" : TYPE_COLOR,
			"default_value" : Color(1, 1, 1, 1),
			"hint" : PROPERTY_HINT_NONE,
			"hint_string" : "test",
		},
	},
}


func _enable_plugin() -> void:
	add_autoload_singleton("GDConsole", "res://addons/gdconsole/gdconsole.gd")
	_add_project_settings()


func _disable_plugin() -> void:
	remove_autoload_singleton("GDConsole")
	_remove_project_settings()


func _add_project_settings() -> void:
	for section : String in _SETTINGS:
		for setting : String in _SETTINGS[section]:
			var setting_name : String = "gdconsole/%s/%s" % [section, setting]
			if not ProjectSettings.has_setting(setting_name):
				ProjectSettings.set_setting(setting_name, \
				_SETTINGS[section][setting]["default_value"])

			ProjectSettings.set_initial_value(setting_name, _SETTINGS[section][setting]["default_value"])
			ProjectSettings.set_as_basic(setting_name, true)

			var error : int = ProjectSettings.save()
			if not error == OK:
				push_error("GDConsole - error %s while saving project settings." % error_string(error))


func _remove_project_settings() -> void:
	for section : String in _SETTINGS:
		for setting : String in _SETTINGS[section]:
			var setting_name : String = "gdconsole/%s/%s" % [section, setting]
			if ProjectSettings.has_setting(setting_name):
				ProjectSettings.set_setting(setting_name, null)

			var error : int = ProjectSettings.save()
			if not error == OK:
				push_error("GDConsole - error %s while saving project settings." % error_string(error))
