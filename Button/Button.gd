tool
extends StaticBody

# The color of the button when it's not pressed.
export var ButtonColor:Color = Color() setget UpdateButton
# The color of the button when it's pressed.
export var EmissionColor:Color = Color() setget UpdateEmission
# If true, the button returns to being not pressed right after.
export var Instant = true
# If true, you can trigger the button with a rigid body collision.
export var Rigid = false
export var ButtonSensitivity = 5
var interactNode


signal buttonPress(node)

# This updates the color of the button.
func UpdateButton(b):
	ButtonColor = b
	if not is_inside_tree():
		yield(self,"ready")
	$ButtonHull/ButtonMesh.get_active_material(0).set_albedo(b)
func UpdateEmission(b):
	EmissionColor = b
	if not is_inside_tree():
		yield(self,"ready")
	$ButtonHull/ButtonMesh.get_active_material(0).set_emission(b)
func _ready() -> void:
	$ButtonHull/ButtonMesh.get_active_material(0).set_emission_energy(0)
	$ButtonHull/ButtonMesh.get_active_material(0).set_emission(EmissionColor)
	$ButtonHull/ButtonMesh.get_active_material(0).set_albedo(ButtonColor)
# If the node is not visible, it will not collide with anything.
	if not visible:
		$CollisionShape.disabled = true
		$ButtonHull/ButtonMesh/Area/CollisionShape.disabled = true
# If we are not in the editor,
	if not Engine.is_editor_hint():
		# conect the signal if the player clicks on something,
		Global.player.connect("interact",self,"_on_Player_interact")
		# and when the player releases the mouse button.
		Global.player.connect("letGo",self,"_on_Player_letGo")


func _on_Player_interact(node):
# Set the specific node we are currently interacting.
	interactNode = node
	
	# If the node is the button area and the button is not currently being pressed,
	if node == $ButtonHull/ButtonMesh/Area\
	and not $AnimationPlayer.is_playing():
		# if Instant is true, an animation will play to which the button will be pressed once.
		if Instant:
			$AnimationPlayer.play("press")
		# otherwise, an animation will be played the button will be held.
		else:
			$AnimationPlayer.play("regular press")
		# We then send a signal in case it is connected to a door.
		emit_signal("buttonPress",self)
		$PressSound.play()

# If the player releases the button and Instant is not turned on,
# the button plays an animation that reverts it back to normal.
func _on_Player_letGo(_node):
	if interactNode != null\
	and interactNode == $ButtonHull/ButtonMesh/Area:
		if not Instant:
			interactNode.owner.get_node("AnimationPlayer").queue("regular release")
			interactNode = null
			emit_signal("buttonPress",self)

# If Rigid is on, and the button is touching a rigid body or the player,
func _on_Area_body_entered(body: Node) -> void:
	if not body is StaticBody\
	and Rigid:
		$PressSound.play()
		# it takes the velocity of the body,
		var push_amount
		if body is RigidBody:
			push_amount = min(body.linear_velocity.length() / ButtonSensitivity, 1)
		else:
			push_amount = min(body.movement.length() / Global.player.Speed, 1)
		# sets the animation to the pressing animation,
		$AnimationPlayer.set_current_animation("regular press")
		# and skips the animation to the ammount of velocity you pushed the button.
		$AnimationPlayer.seek(push_amount, true)
		emit_signal("buttonPress",self)

# If Rigid is on, and the button is no longer touching the player or a rigid body, 
# it returns back to normal.
func _on_Area_body_exited(_body: Node) -> void:
	if Rigid:
		$AnimationPlayer.play_backwards("regular press")
		emit_signal("buttonPress",self)
