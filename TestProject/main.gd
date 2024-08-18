extends CenterContainer


func _ready():	
	if Versioning.is_demo:
		%AppLabel.text = "This is a demo"	
	else:
		%AppLabel.text = "This is the main app"	
	
	%VersionLabel.text = "The commit for this version is '%s'" % Versioning.commit
