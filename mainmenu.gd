extends CanvasLayer

func _input(_event: InputEvent) -> void:

# If the player presses ESC in the main menu, it hides any current windows showing and 
# shows the main menu options open.
	if Input.is_action_just_pressed("ui_cancel"):
		hide()
		if not $Control.visible\
		and not Global.Playing:
			$Control.visible = true
			$SelectAudio.play()

# When you press play,
func _on_Play_pressed() -> void:
	$SelectAudio.play()
	# it hides all windows opened
	hide()
	Global.Playing = true
	# and grabs the player node's camera to set as the current camera.
	Global.player.get_node("Head/Camera").set_current(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# We then hide the menu and logo,
	$Control.visible = false
	Global.player.get_node("Crosshair").visible = true
	if Global.player.SprintMeter:
		Global.player.get_node("Sprint").visible = true


# When you press quit, it quits the game.
func _on_Quit_pressed() -> void:
	$SelectAudio.play()
	get_tree().quit()
# When you press settings,
func _on_Settings_pressed() -> void:
	$SelectAudio.play()
# it hides all windows opened,
	hide()
# it shows the settings node,
	Global.Settings.visible = true
# and hides the menu options.
	$Control.visible = false

# Same thing with the credits.
func Credits() -> void:
	$SelectAudio.play()
	hide()
	$Credits.visible = true
	$Control.visible = false

# This function hides the Settings and Credits.
func hide():
	Global.Settings.visible = false
	$Credits.visible = false
