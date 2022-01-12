tool
extends StaticBody

# This determines the default position of the lever.
export var LeverState = 0 setget UpdateLeverPosition

signal leverActivated(node)

var hold = false
var mouseMovement = Vector2()
var crankVec = Vector2()
var currentRotX

# The lever state can only switch from -1 up to 1.
func UpdateLeverPosition(b):
	if b > -2 and b < 2:
		LeverState = b
	# Which allows us to use math to calculate how the levers should be rotated or moved.
		if is_in_group("rotation"):
			$"rotation lever/lever".rotation_degrees.z = (43 * b)
		elif is_in_group("translation"):
			$"translation lever/lever".translation.y = (.9 * b)

# Disabling visibility also disables the collision shapes.
func _ready() -> void:
	if not visible:
		if is_in_group("rotation"):
			$CollisionShape.disabled = true
			$"rotation lever/lever/StaticBody/CollisionShape2".disabled = true
			$"rotation lever/lever/Area/CollisionShape2".disabled = true
		elif is_in_group("translation"):
			$CollisionShape.disabled = true
			$"translation lever/lever/StaticBody/CollisionShape2".disabled = true
			$"translation lever/lever/Area/CollisionShape2".disabled = true
# When it's not playing in the editor, connect the player interact and let go signal.
	if not Engine.is_editor_hint():
		Global.player.connect("interact",self,"_on_Player_interact")
		Global.player.connect("letGo",self,"_on_Player_letGo")

# This keeps track of the mouse movement of the player.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouseMovement = event.relative

# When the player interacts with something that is the part of a lever, we tell it that the lever
# is now currently being held.
func _on_Player_interact(node):
	if is_in_group("rotation")\
	and node == $"rotation lever/lever/Area":
		hold = true
	if is_in_group("translation")\
	and node == $"translation lever/lever/Area":
		hold = true
	if is_in_group("crank")\
	and node == $"crank wheel/crank/Area":
		hold = true
	# This is to make the crank remember the past rotation before rotating it.
		currentRotX = $"crank wheel/crank".rotation_degrees.x

# This plays a sound when the lever is activated at any point.
func _on_rotation_lever_leverActivated(_node) -> void:
	$"lever kachunk".play()
func _on_translation_lever_leverActivated(_node) -> void:
	$"lever kachunk".play()

func _on_Player_letGo(_node):
	hold = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.player.lockCamera = false

func _physics_process(_delta: float) -> void:

# If the lever is a rotation lever:
	if is_in_group("rotation"):
	# The lever caps it's rotation to 44/-44 and makes the player let go of the lever.
		if $"rotation lever/lever".rotation_degrees.z > 44:
			$"rotation lever/lever".rotation_degrees.z = 43
			hold = false
	# If the lever was not yet rotated upwards (lever state = 1), it emits a signal
	# that it was activated.
			if not LeverState == 1:
				emit_signal("leverActivated",self)
				LeverState = 1
		elif $"rotation lever/lever".rotation_degrees.z < -44:
			$"rotation lever/lever".rotation_degrees.z = -43
			hold = false
	# This is the other lever state, which means the lever will only emit a signal if the lever
	# was from a rotated upward state to a rotated lower state.
			if not LeverState == -1:
				emit_signal("leverActivated",self)
				LeverState = -1
	
# This is the same concept as the rotation lever, only this time it's applied through translation.
	if is_in_group("translation"):
		if $"translation lever/lever".translation.y > .95:
			$"translation lever/lever".translation.y = .9
			hold = false
			if not LeverState == 1:
				emit_signal("leverActivated",self)
				LeverState = 1
		elif $"translation lever/lever".translation.y < -.95:
			$"translation lever/lever".translation.y = -.9
			hold = false
			if not LeverState == -1:
				emit_signal("leverActivated",self)
				LeverState = -1

# If the player is currently holding the lever:
	if hold:
	# If the lever is a rotation lever:
		if is_in_group("rotation"):
		# It rotates the lever part with the upward or downward movement of the mouse.
			$"rotation lever/lever".rotate_z(deg2rad(-mouseMovement.y))
		# We also clamp the rotation to make sure that it doesn't rotate too much.
			$"rotation lever/lever".rotation.z = clamp($"rotation lever/lever".rotation.z, deg2rad(-45), deg2rad(45))
		
	# Same concept with the translation lever, but instead of rotation, we're moving it up or down with
	# our mouse movement. We also clammp it just like the rotation lever for the same reason.
		if is_in_group("translation"):
			$"translation lever/lever".translate(Vector3(0,-mouseMovement.y/20,0))
			$"translation lever/lever".translation.y = clamp($"translation lever/lever".translation.y,-.975,.975)

	# The crank wheel works a little differently:
		if is_in_group("crank"):
		# First we lock the camera,
			Global.player.lockCamera = true
		# Then we set the mouse mode to confined, which locks the mouse cursor inside the window
		# but allows the cursor to move around.
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		# We take the mouse position,
			var mousePos = get_viewport().get_mouse_position()
		# get the middle of our screen,
			mousePos.x -= get_viewport().size.x / 2
			mousePos.y -= get_viewport().size.y / 2
		# and take the angle of the middle of our screen to the current mouse position.
			var angleToMouse = mousePos.angle_to(Vector2(get_viewport().size.x / 2,get_viewport().size.y / 2))
		# We then take that angle and turn it into the X rotation of the crank part of the wheel +
		# the past rotation of the crank.
			$"crank wheel/crank".rotation_degrees.x = currentRotX + rad2deg(angleToMouse)


