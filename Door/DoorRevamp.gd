tool
extends Spatial

# Controls how fast the door opens from input.
export var DoorOpenSpeed = 10
# If true, the door will not lock into place.
export var LooseDoor = false
# If true, the door after SpringTimeLength seconds will close automatically.
export var SpringDoor = true
# How fast it will automatically close.
export var SpringDoorSpeed = 10
export var SpringDoorStrength = .1
# How long will it wait until it starts to automatically close.
export var SpringTimeLength = 1
# If true, the door cannot be opened.
export var Locked = false setget UpdateDoorLock
# How many unlock conditions (pressing a connected button/lever/etc. or inserting a key) it needs
# to unlock the door.
export var UnlocksNeeded = 1
# If true, once the door is unlocked, it will no longer lock.
export var KeepUnlocked = false


signal doorStatus(status)


var unlocks = []
var open = false
var hold = false
var spring = false
var springAction = false
var side = 1
var mouseMovement = Vector2()


onready var door = $Door/Door
onready var timer = door.get_node("Timer")

# We call this function every time we need to either lock or unlock the door. This is also triggered by
# the Locked variable if the value changes.
func UpdateDoorLock(b):
	Locked = b
	emit_signal("doorStatus",Locked)

# If the node is not loaded yet, it calls the ready function instead. This is to prevent the door setting
# a mode when the node isn't even loaded yet.
	if not is_inside_tree():
		yield(self,"ready")

# If the door is locked, the door becomes Static (it doesn't move).
	if Locked:
		door.set_mode(RigidBody.MODE_STATIC)
	else:
		door.set_mode(RigidBody.MODE_RIGID)

func _ready() -> void:

# If we are not in the editor anymore,
	if not Engine.is_editor_hint():
		timer.wait_time = SpringTimeLength

# Connect the signals where the player clicks on something or releases the mouse button.
		Global.player.connect("interact",self,"_on_Player_interact")
		Global.player.connect("letGo",self,"_on_Player_letGo")
		UpdateDoorLock(Locked)
		if Locked:
			door.set_mode(RigidBody.MODE_STATIC)
		else:
			door.set_mode(RigidBody.MODE_RIGID)

func _on_Player_interact(node):

# If the node that was clicked by the player is in the group door,
	if node.is_in_group("door"):
# it stores the specific door node to make sure that we are only opening the specific door.
		door = node.get_parent()

# If the door is locked and you are holding a key, it sends it to the interactWithLock function and 
# deletes the key.
		if Locked and Global.player.Item:
			if Global.player.Item.is_in_group("key"):
				var key = load("res://items/Key.tscn").instance()
				interactWithLock(key)
				Global.player.Item = null
				Global.player.get_node("Head/ItemPosition").get_child(0).queue_free()
		else:
# This checks which side of the door you are, which will influence where the door rotates.
			if node.name == "DoorA":
				side = 1
			else:
				side = -1
			hold = true
		
		if not open:
			$Open.play()

# If the mouse button is released, you are no longer holding the door.
func _on_Player_letGo(_node):
	hold = false

# If the spring timer is up, the door will start to close automatically if SpringDoor is enabled.
func _on_Timer_timeout() -> void:
	springAction = true

# If any elements are spawned with the door, those elements are connected through signal, to which
# if they are activated, they will be sent to interactWithLock to see if they can fulfill an unlock
# condition.
func _on_Button_buttonPress(node) -> void:
	interactWithLock(node)
func _on_plate_platePress(node) -> void:
	interactWithLock(node)
func _on_rotation_lever_leverActivated(node) -> void:
	interactWithLock(node)
func _on_translation_lever_leverActivated(node) -> void:
	interactWithLock(node)

# This grabs the player's mouse movement.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouseMovement = event.relative


func _physics_process(delta) -> void:

	if not Engine.is_editor_hint():

		if (not Locked) or (Locked and open):

# If you are holding the door,
			if hold:
				# the spring timer will stop,
				timer.stop()
				springAction = false
				spring = true
# and the door rotates depending on the mouse's movemement. The door rotation is handled by altering
# the angular rotation (how fast it rotates) of the rigid body door.
				door.angular_velocity.y = deg2rad(
# This rotates it by moving the mouse up and down.
					(((mouseMovement.y * -side) * DoorOpenSpeed * 2) + 
# This rotates it by moving the mouse left and right.
					(mouseMovement.x * DoorOpenSpeed * 2)) + 
# This rotates it by moving forwards and backwards.
					((Input.get_action_strength("up") - Input.get_action_strength("down")) * side)
					* 25 * DoorOpenSpeed)

# If the door is rotated 90/-90 degrees, it makes the player let go of the door and stops the door's
# momentum.
				if door.rotation_degrees.y > 90:
					door.angular_velocity.y = -0.1
					hold = false
				elif door.rotation_degrees.y < -90:
					door.angular_velocity.y = 0.1
					hold = false

# While the door is open,
			if open:
				# If spring is true and the timer hasn't set off yet, we start the timer.
				if spring and timer.get_time_left() == 0:
					timer.start()
				# Spring is only true if we are not holding the door.
				spring = !hold

# Once all these conditions are met, the door then automatically close.
			if SpringDoor\
			and open\
			and springAction:
				# We clamp the rotation speed of the door to make sure it doesn't bug out. 
				door.angular_velocity.y = clamp(door.angular_velocity.y, -3, 3)
				# The door then moves towards the close position by doing this:
				door.angular_velocity.y = move_toward(
					door.angular_velocity.y, 
				# by grabbing the current rotation, reversing it, and dividing it by SpringDoorStrength.
					-door.rotation_degrees.y / SpringDoorStrength * delta, 
					delta * SpringDoorSpeed)

# If the door is now in between 0.99 or -0.99 degrees,
		if door.rotation_degrees.y < 1 and door.rotation_degrees.y > -1:
			
			# If LooseDoor is true, the door would just swing freely and not lock.
			if not LooseDoor:
				# If the door is open,
				if open:
					# we set it to static mode to remove all momentum,
					door.set_mode(RigidBody.MODE_STATIC)
					open = false
					# let go of the door,
					hold = false
					# turn off all springs that are currently working in the door,
					spring = false
					springAction = false
					# and set all the velocity and rotation back to zero.
					door.angular_velocity = Vector3.ZERO
					door.rotation_degrees = Vector3.ZERO
					$Close.play()
					# And if the door is unlocked, it should return back to Rigid mode.
					if not Locked:
						door.set_mode(RigidBody.MODE_RIGID)
# If the door is rotated more/less than 1/-1 degrees, the door is now open.
		else:
			open = true


func interactWithLock(interacted):

# If the node that was sent to the function is not inside the unlocks array, it is added to the array.
	if not unlocks.has(interacted):
		unlocks.push_back(interacted)
# If not, it then gets removed from the array. (Say if you press a button to unlock it, pressing the same
# button again locks the door.)
	else:
		unlocks.erase(interacted)

# If keep unlocked is on,
	if KeepUnlocked:
		if Locked:
			# If the unlocks array is now equal or more than the needed ammount of unlock conditions,
			# the door will remain open even if it doesn't meet the ammount of unlock conditions anymore.
			if unlocks.size() == UnlocksNeeded or unlocks.size() > UnlocksNeeded:
				Locked = false
				door.set_mode(RigidBody.MODE_RIGID)
# If keep unlocked is off,
	else:
		# then if the unlocks array is now equal or more than the needed ammount of unlock conditions,
		# the door will now be unlocked.
		if unlocks.size() == UnlocksNeeded or unlocks.size() > UnlocksNeeded:
			Locked = false
			door.set_mode(RigidBody.MODE_RIGID)
		# but if the unlock conditions are not enough, the door will remain locked.
		else:
			Locked = true
			if not open:
				door.set_mode(RigidBody.MODE_STATIC)
	UpdateDoorLock(Locked)
