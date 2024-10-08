- assumes:
	- [ ] templates in ~/Godot/GodotX/Godot_vX.Y.Z/templates
	- [ ] a file named export_info.json in the root of the project
- [ ] a dist folder in ~/Godot/dist
- [ ] build_script.sh: given the path to a project, a target dir, and a commit hash
	- [x] clones the commit to dist/temp/project_name/source
		- is there a way to only copy the last commit tagged a certain way?
		- git clone -b TAG_NAME only moves the head
	- [ ] writes to export_info.json
		- [ ] the commit hash
		- [ ] the version (the commit tag, if any) 
		- [ ] the daytime
	- [x] exports the game
- [ ] get_last_commit.sh: script that, given a path to a repo
	- [ ] gets the hash of the last commit in the repo
- [ ] publish_to_steam.sh: given the path to a project and, optionally, a commit hash or a tag
	- [ ] runs get_last_commit.sh to get the last commit in the repo, if neither commit or hash are provided
	- [ ] runs the build_script.sh with the provided project path and commit/tag and exports it to a temporary folder
	- [ ] takes what is in the dist subfolders and uploads it to steam
	- [ ] deletes everything in temp/project_name
	- [ ] logs the upload in the root of the project directory
	- [ ] TODO: uses SteamGuard to log in