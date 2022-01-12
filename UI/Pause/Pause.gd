extends CanvasLayer

var dead = false
var keybindChange = false
var keybindKey
enum actions {up,left,down,right}

signal dead


func _ready() -> void:
	# Get a global callback for the pause node.
	Global.PauseNode = self
	# Hide the pause screen,
	$Pause.visible = false
	# dev settings,
	$"Pause/Dev Mode Settings".visible = false
	# credits,
	$"Pause/Credits".visible = false
	# and reset the settings position.
	$SettingsPos.position = Vector2()


func _input(_event) -> void:
# When the player presses the ESC key and the player has now started playing the game:
	if  Input.is_action_just_pressed("ui_cancel")\
	and Global.Playing:
		$Pause/PauseAudio.play()
	# If the player is not dead, trigger a pause function.
		if dead == false:
			pauseGame()
	# Otherwise, do the same thing that happens as you pressed the Retry button when the 
	# player dies.
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$Pause.visible = false
			$Death.visible = false
			$Pause/DeathScreen.visible = false
			dead = false

# DEATH SCREEN ----------------------------------------------------------------------------

# When the player presses Retry:
func _on_Restart_pressed() -> void:
	$Pause/SelectAudio.play()
	$Death.visible = false
	# Lock the player's mouse.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Hide the pause screen.
	$Pause.visible = false
	$Pause/DeathScreen.visible = false
	# Making sure that we are not killing the player,meaning we don't get a death screen even if it
	# fundemtally works the same.
	dead = false

# When the player dies:
func kill():
# Death animation screen is now visible.
	$Death.visible = true
	dead = true
# If Death Screen is on.
	if Global.player.DeathScreen == true:
	# Play a death sfx.
		$Pause/DeathAudio.play(0.29)
	# Play an animaton that fades to black.
		$Death/AnimationPlayer.play("death screen")
	# Allow the player to move the mouse.
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$Pause.visible = true
		$Pause/DeathScreen.visible = true
# Otherwise, play an animation that fades to transparent.
	else:
		$Death/AnimationPlayer.play("death")

# PAUSE MENU ------------------------------------------------------------------------------------

# The function that handles the pause menu.
func pauseGame():
# Pause the entire game.
	get_tree().paused = !get_tree().paused
# If the mouse mode is currently not captured:
	if Input.get_mouse_mode() == 0:
	# Set it back to captured.
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Hide all the windows that can show in the pause screen.
		$Pause.visible = false
		$Pause/Pause.visible = false
		$Pause/Credits.visible = false
		$SettingsPos/Settings.visible = false
		$"Pause/Dev Mode Settings".visible = false
# Otherwise,
	else:
	# Make the mouse moveable.
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Show the pause menu.
		$Pause.visible = true
		$Pause/Pause.visible = true

# When the continue button is pressed, trigger the pause function.
func _on_Continue_pressed() -> void:
	$Pause/SelectAudio.play()
	pauseGame()

# When the retry button is pressed, trigger the death function for the player and hide the pause screen.
func _on_Retry_pressed() -> void:
	Global.player.kill()
	emit_signal("dead")
	pauseGame()

# When the settings is pressed:
func _on_Settings_pressed() -> void:
	$Pause/SelectAudio.play()
	$Pause/Pause.visible = false
# If dev mode is on in the player, move the settings to the side.
	if Global.player.DevMode:
		$"Pause/Dev Mode Settings".visible = true
		$SettingsPos/Settings.visible = true
		$SettingsPos.position = Vector2(-250,0)
# Otherwise, keep the settings in the middle.
	else:
		$SettingsPos/Settings.visible = true
		$SettingsPos.position = Vector2()

# When credits is pressed, show the credits node.
func _on_Credits_pressed() -> void:
	$Pause/SelectAudio.play()
	$Pause/Pause.visible = false
	$Pause/Credits.visible = true

# When the quit button is pressed, you quit the game.
func _on_Quit_pressed() -> void:
	get_tree().quit()

# DEV MODE  ------------------------------------------------------------------------------------

# For numbered values, it follows a template:
func newValue(value,attribute,default):
	# It first checks if the value is valid, and if it is, we set the corresponding attribute to
	# the new value.
	if value:
		Global.player.set(attribute, int(value))
	# Otherwise, the value will be set to the default value of the attribute.
	else:
		Global.player.set(attribute, default)

# The settings changes the corresponding value directly to the player node by checking the pressed state of it. 
func _on_arcade_pressed() -> void:
# For example, Arcade Style setting will be toggled by the pressed state of the button.
	Global.player.ArcadeStyle = $"Pause/Dev Mode Settings/DevMode/VBoxContainer/ARCADE/arcade".pressed
func _on_sprint_pressed() -> void:
	Global.player.get_node("Sprint").visible = $"Pause/Dev Mode Settings/DevMode/VBoxContainer/SPRINT/sprint".pressed
	Global.player.SprintMeter = $"Pause/Dev Mode Settings/DevMode/VBoxContainer/SPRINT/sprint".pressed
	$"Pause/Dev Mode Settings/DevMode/VBoxContainer/regen".visible = $"Pause/Dev Mode Settings/DevMode/VBoxContainer/SPRINT/sprint".pressed
	$"Pause/Dev Mode Settings/DevMode/VBoxContainer/drain".visible = $"Pause/Dev Mode Settings/DevMode/VBoxContainer/SPRINT/sprint".pressed
func _on_regen_text_changed(new_text: String) -> void:
	newValue(new_text,"StaminaRegen",1.0)
func _on_drain_text_changed(new_text: String) -> void:
	newValue(new_text,"StaminaDrain",1.0)
func _on_death_pressed() -> void:
	Global.player.set("DeathScreen", $"Pause/Dev Mode Settings/DevMode/VBoxContainer/DEATH/death".pressed)
func _on_jump_text_changed(new_text: String) -> void:
	newValue(new_text,"Jump",30)
func _on_maxjumps_text_changed(new_text: String) -> void:
	newValue(new_text,"MaxJumps",1)
func _on_sens_text_changed(new_text: String) -> void:
	newValue(new_text,"MouseSensitivity",1)
func _on_camera_text_changed(new_text: String) -> void:
	newValue(new_text,"CameraSmoothing",20)
func _on_grav_text_changed(new_text: String) -> void:
	newValue(new_text,"Gravity",50)
func _on_grab_text_changed(new_text: String) -> void:
	newValue(new_text,"GrabSmoothing",20)
func _on_throw_text_changed(new_text: String) -> void:
	newValue(new_text,"ThrowForce",30)
func _on_min_text_changed(new_text: String) -> void:
	newValue(new_text,"MinFOV",70)
func _on_max_text_changed(new_text: String) -> void:
	newValue(new_text,"MaxFOV",120)
func _on_fovsmooth_text_changed(new_text: String) -> void:
	newValue(new_text,"SprintFOVSmooth",10)
func _on_scroll_text_changed(new_text: String) -> void:
	newValue(new_text,"ScrollStrength",1)
func _on_scrollsmooth_text_changed(new_text: String) -> void:
	newValue(new_text,"ScrollSmoothing",0.2)
func _on_scrolllimit_text_changed(new_text: String) -> void:
	newValue(new_text,"ScrollLimit",10)
func _on_speed_text_changed(new_text: String) -> void:
	newValue(new_text,"defaultSpeed",10)
func _on_sprint_text_changed(new_text: String) -> void:
	newValue(new_text,"SprintSpeedFactor",10)
func _on_crouch_text_changed(new_text: String) -> void:
	newValue(new_text,"CrouchSpeedFactor",10)
func _on_tilt_text_changed(new_text: String) -> void:
	newValue(new_text,"TiltAmmount",3)
func _on_tiltspeed_text_changed(new_text: String) -> void:
	newValue(new_text,"TiltSpeed",5)
func _on_crouchsmooth_text_changed(new_text: String) -> void:
	newValue(new_text,"CrouchSmoothing",20)
