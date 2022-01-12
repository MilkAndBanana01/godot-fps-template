extends Panel
var keybindKey
var keybindChange = false

# When the game starts, add a global callback to the settings,
func _ready() -> void:
	Global.Settings = self

# This detects if I am pressing a keyboard key to apply for key binding.
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		newKeyBind(event)

# The keybind buttons set the input map string name and trigger a key change function.
func up() -> void:
	keybindKey = "up"
	keyChange()
func left() -> void:
	keybindKey = "left"
	keyChange()
func down() -> void:
	keybindKey = "down"
	keyChange()
func right() -> void:
	keybindKey = "right"
	keyChange()
func jump() -> void:
	keybindKey = "jump"
	keyChange()
func crouch() -> void:
	keybindKey = "crouch"
	keyChange()
func sprint() -> void:
	keybindKey = "run"
	keyChange()
func interact() -> void:
	keybindKey = "interact"
	keyChange()

# This shows the keybind message and the next key pressed will bind it to the selected key bind.
func keyChange():
	keybindChange = true
	$keybindMessage.visible = true

# If the key bind message is visible and we are allowed to bind a key:
func newKeyBind(event):
	$keybindMessage.visible = false
	if keybindChange == true:
	# and if the pressed key was not the ESC key,
		if event is InputEventKey and not event.scancode == 16777217:
	# grab the pressed key's scan code string
			var newKey = OS.get_scancode_string(event.scancode)
	# find if the key bind already has an assigned key, and if there is, delete that key.
			if !InputMap.get_action_list(keybindKey).empty():
				InputMap.action_erase_event(keybindKey, InputMap.get_action_list(keybindKey)[0])
	# add the pressed key to the keybind keys.
			InputMap.action_add_event(keybindKey, event)
	# set the text of the button we pressed to the button's text.
			get_node("VBoxContainer/" + keybindKey + "/Button").set_text(str(newKey))
			keybindChange = false

# The sound settings work all work similarly from each other:
func mastervol(value: float) -> void:
	# We set the audio bus volume from the new value of the Hslider.
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value * 5)
	# We also play a tick sound showcasing the change of volume through that audio bus.
	$VBoxContainer/master/tick.play()
func sfxvol(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),value * 5)
	$VBoxContainer/sfx/tick.play()
func musicvol(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),value * 5)
	$VBoxContainer/music/tick.play()

# These toggle buttons work like in the dev mode settings, where the attribute being altered
# is toggled on and off by the pressed state of that button (pressed = true, vice versa).
func fovToggle() -> void:
	$SelectAudio.play()
	Global.player.SprintFOVToggle = $VBoxContainer/fov/fovToggle.pressed
func bobbingToggle() -> void:
	$SelectAudio.play()
	Global.player.Bobbing = $VBoxContainer/bobbing/bobbingToggle.pressed

# Here's how to toggle fullscreen.
func fullscreen() -> void:
	$SelectAudio.play()
	OS.window_fullscreen = $VBoxContainer/fullscreen/fullscreen.pressed
