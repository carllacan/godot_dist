extends Node

var is_demo:bool = false
var commit:String = ""

func _ready()-> void:
	is_demo = OS.has_feature("demo")
	
	var file = FileAccess.open("res://dist/version_info.json", FileAccess.READ)
	var content = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data_received = json.data
		commit = json.data["commit"]
	else:
		print("Error: could not read file 'version info.json'")
