## setting up auto-build system (godot_dist)
* download the appropriate godot or godotsteam version
* place it in ~/Godot/GodotX/GodotX.Y.Z
* add to path as godotX.Y.Z
* download export templates
	* if using plain Godot, do it through Godot itself
	* if using Godosteam, download them and place them in ~Godot/GodotsteamX.Y.Z/templates
* download godot_dist and place it wherever
	* give run permissions to all scripts
## setting up auto-publish system (steampipe)
* download the Steamworks SDK
* extract in ~
* got to sdk/tools/ContentBuilder, edit ./run_build.bat so that
	* it uses builder_linux/steamcmd.sh instead of the .exe
	* it has the necessary username and password
* give run permissions to run_build.bat and to the whole builder_linux folder
* add sdk/tools/ContentBuilder/builder_linux/steamcmd.sh to the path as steampipe
	* edit ~/.bashrc
	* add alias steampipe=sdk/tools/ContentBuilder/builder_linux/steamcmd.sh