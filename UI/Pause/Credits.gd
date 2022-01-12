extends VBoxContainer

# When the game loads up:
func _on_Credits_tree_entered() -> void:
	# take all the children and if it's a button, connect the signal with the corresponding node 
	# name.
	for i in get_children():
		if i is Button:
			i.connect("pressed",self,"_on_" + i.name + "_pressed")

# CREDITS  ------------------------------------------------------------------------------------

# Most of these function by opening a link on the browser.
# Again big thanks to these awesome people who make Godot more and more easir to learn <3
func _on_KENNEY_pressed() -> void:
	$SelectAudio.play()
# warning-ignore:return_value_discarded
	OS.shell_open("https://kenney.nl")
func _on_KEVIN_pressed() -> void:
	$SelectAudio.play()
# warning-ignore:return_value_discarded
	OS.shell_open("https://www.youtube.com/channel/UCSZXFhRIx6b0dFX3xS8L1yQ")
func _on_GARBAJ_pressed() -> void:
	$SelectAudio.play()
# warning-ignore:return_value_discarded
	OS.shell_open("https://www.youtube.com/c/Garbaj/featured")
func _on_ARCANE_pressed() -> void:
	$SelectAudio.play()
# warning-ignore:return_value_discarded
	OS.shell_open("https://www.youtube.com/c/ArcaneEnergy/featured")
func _on_GDQUEST_pressed() -> void:
	$SelectAudio.play()
# warning-ignore:return_value_discarded
	OS.shell_open("https://www.youtube.com/c/Gdquest/featured")
func _on_GODOT_DISCORD_pressed() -> void:
	$SelectAudio.play()
# warning-ignore:return_value_discarded
	OS.shell_open("https://discord.gg/jEgDZfTcQg")
func _on_GODOT_REDDIT_pressed() -> void:
	$SelectAudio.play()
# warning-ignore:return_value_discarded
	OS.shell_open("https://www.reddit.com/r/godot/")
func _on_YT_pressed() -> void:
	$SelectAudio.play()
# warning-ignore:return_value_discarded
	OS.shell_open("https://www.youtube.com/channel/UCb3_VvpG7l5YsYXnsKQxrPA")
func _on_INSTA_pressed() -> void:
	$SelectAudio.play()
# warning-ignore:return_value_discarded
	OS.shell_open("https://www.instagram.com/milkandbanana1/")
func _on_TWITTER_pressed() -> void:
	$SelectAudio.play()
# warning-ignore:return_value_discarded
	OS.shell_open("https://twitter.com/milking_banana")
