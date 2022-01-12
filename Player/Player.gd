extends KinematicBody

# EXPORT VARIABLES  ----------------------------------------------------------------------------

# Locks the mouse at the start of the game.
export var LockMouse = true
# Allows you to alter the player feel while in-game.
export var DevMode = false
# Simulates arcade game style movement (no momentum).
export var ArcadeStyle = false
# If true, when the player dies, there will be a death screen.
export var DeathScreen = true
# If true, the player can only run for a certain period of time.
export var SprintMeter = true
# How fast your player regains stamina and looses stamina.
export var StaminaRegen:float = 1.0
export var StaminaDrain:float = 1.0
# If true, the player would play a bobbing animation when moving.
export var Bobbing = true
# If false, the player will not change FOV.
export var SprintFOVToggle = true
# The height of your jump.
export var Jump = 20
# How many jumps the player can do.
export var MaxJumps = 1
# The user's mouse sensitivity.
export var MouseSensitivity = 1
# How much the camera is being smoothened (lower = smoother)
export var CameraSmoothing = 20
# The gravity of the player.
export var Gravity = 50
# The smoothness of the object's movemement to the player's hand.
export var GrabSmoothing = 20
# How hard you can yeet a holding object.
export var ThrowForce = 30
# The minimum and maximum FOV the player gets.
export var MinFOV = 70
export var MaxFOV = 120
# How smooth the transition in changing FOVs. (lower = smoother)
export var SprintFOVSmooth = 10
# How fast the player moves the holding object near or far from itself.
export var ScrollStrength = 1
# How smooth that scrolling is.
export var ScrollSmoothing = .2
# General walking speed, sprinting speed and crouching speed.
export var Speed = 10
export var SprintSpeedFactor = 10
export var CrouchSpeedFactor = 10
# How much tilt your camera does when moving sideways, and how fast it is.
export var TiltAmmount = 3
export var TiltSpeed = 5
# How smoothly your camera transitions from standing to crouching.
export var CrouchSmoothing = 20
# How far you can extend the holding object.
export var ScrollLimit = 10 

# PRESET VARIABLES  ----------------------------------------------------------------------------

# Current acceleration.
var h_acceleration = 6
# Acceleration mid-air.
var air_acceleration = 1
# Acceleration on the ground.
var normal_acceleration = 6
# When the game starts:
# The default speed is the Speed set in the export variables.
var defaultSpeed
# The sprint speed is the Speed added with the SprintSpeedFactor.
var sprintSpeed
# The sprint speed is the Speed decreased with the CrouchSpeedFactor.
var crouchSpeed
# How high and low your player is.
var defaultHeight = 2
var crouchedHeight = .5
# If the player is on a jump pad.
var spring = false
# How high you are jumping from a jump pad (will be set by the SpringStrength).
var bounce = 0
# Locks your camera movement.
var lockCamera = false
# How many ladders are currently touching the player.
var climbed = 0
# Is the player currently climbing?
var climb = false
# Is the player currently falling/not on the ground?
var falling = false
# Is the player still holding sprint even if they ran out of sprint
var stillSprinting = false
# How many times the player has jumped.
var jumpCount = 0
# Default FOV of the player. (modified through the export variables)
var fov = 70

# Default length of the rigid body grabbing system.
var scrollInput = 5
var scroll = 5
# How fast the player climbs up or down.
var climbForce = 0
# The node of the currently holding item.
var Item
# The mesh of the currently holding item.
var ItemMesh

# Is walking and climbing sound effects turned on?
var walkAudio = true
var climbAudio = true
# Volumes of the walking, sprinting and crouching sound effects.
var walkVolume = -40
var sprintVolume = -20
var crouchVolume = -30

# The node of the rigid body that I am currently holding.
var objectGrabbed
# The movement vector of the player.
var direction = Vector3()
# The falling vector.
var fall = Vector3()
# The interpolated movement of the player.
var h_velocity = Vector3()
# The vector used in the move and slide function.
var movement = Vector3()
# The gravity vector of the player (typically translated to the Y value for movement.)
var gravityVec = Vector3()
# The mouse movemement of the player.
var cameraInput = Vector2()
# The interpolated mouse movemement of the player.
var rotationVelocity = Vector2()
# The walking and climbing sound effect files.
onready var WalkAudioFiles = $RandomWalk.AudioFiles
onready var ClimbAudioFiles = $RandomClimb.AudioFiles

# The signal sent when you interact with anything. It also sends the item currently held if there's any.
signal interact(node,item)
# Let go of something you are currently interacting.
signal letGo(node)
# The signal sent when the player dies.
signal kill

# Grabs the node "Spawn Point" in the world. If there's no Spawn Point node, then it
# editor position of the player and saves that as the spawn point. 
var spawnpoint

# RUN TIME  ----------------------------------------------------------------------------
# When the game runs,
func _ready() -> void:
	# The default speed is the Speed set in the export variables.
	defaultSpeed = Speed
	# The sprint speed is the Speed added with the SprintSpeedFactor.
	sprintSpeed = Speed + SprintSpeedFactor
	# The sprint speed is the Speed decreased with the CrouchSpeedFactor.
	crouchSpeed = Speed - (CrouchSpeedFactor / 2)
# locks the mouse if LockMouse is toggled,
	if LockMouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
# set the global variable player to self,
	Global.player = self
	$Head/RayCast.add_exception($ClimbCheck)
# Calls a deferred function, which allows us to do stuff after the ready()
# function is called.
	call_deferred("setspawn")
	# if sprint meter is off, remove it from the screen.
	if not SprintMeter:
		$Sprint.visible = false

# This function detects if there is already a Spawn Point node.
func setspawn():
# If there isn't:
	if not get_parent().has_node("Spawn Point"):
	# It makes a new Position3D node and names it Spawn Point,
		var pos3d = Position3D.new()
		pos3d.name = "Spawn Point"
	# adds that node to the current scene,
		get_parent().add_child(pos3d)
		pos3d.set_owner(get_parent())
	# moves it to where the player is in the editor,
		pos3d.global_transform.origin = global_transform.origin
	# and finally save the location of the newly made node.
		spawnpoint = pos3d.global_transform.origin
	else:
# If there is, detect that node's position and save it.
		spawnpoint = get_parent().get_node("Spawn Point").global_transform.origin
# Then, grab the spawn point coordinates and move the player to that location.
	global_transform.origin = spawnpoint

# INPUT EVENTS  ----------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
# Inputs will only work if the player has pressed the Play button in the menu.
	if Global.Playing:

	# If I move my mouse, it gets the relative mouse movement and assigns it to cameraInput.
		if event is InputEventMouseMotion:
			cameraInput = event.relative

	# If I press the interact button (E),
		if Input.is_action_just_pressed("interact"):
	# if I'm holding an object, let go of that object.
			if objectGrabbed:
				release()
	# otherwise, just let go of any items that the player is carrying.
			else:
				releaseItem()
	# If the raycast is colliding with something, and it's a rigidbody that isn't in the group "immovable" or "item":
				if $Head/RayCast.is_colliding():
					if $Head/RayCast.get_collider() is RigidBody:
						if not $Head/RayCast.get_collider().is_in_group("immovable")\
						and not $Head/RayCast.get_collider().is_in_group("item"):
		# Grab the colliding node,
							objectGrabbed = $Head/RayCast.get_collider()
		# exclude it from the raycast's vision,
							$Head/Hand.add_excluded_object(objectGrabbed)
		# and lock it's current rotation.
							objectGrabbed.axis_lock_angular_x = true
							objectGrabbed.axis_lock_angular_y = true
							objectGrabbed.axis_lock_angular_z = true

		# If it is in the group "item":
						elif $Head/RayCast.get_collider().is_in_group("item"):
			# Grab the colliding node,
							Item = $Head/RayCast.get_collider()
			# remove the item node from the level scene,
							Item.get_parent().remove_child(Item)
			# set it to no gravity, (so it doesn't fall from your hands)
							Item.gravity_scale = 0
			# disable the collision shape it has,
							Item.get_node("CollisionShape").disabled = true
			# grab the mesh instances of the item and turn off cast shadow,
							for i in Item.get_children():
								if i is MeshInstance:
									ItemMesh = i
									i.cast_shadow = false
			# grab the player's item hand node,
							get_node("Head/ItemPosition").add_child(Item)
			# and set the item's global transform to the player's item hand node.
							Item.global_transform = get_node("Head/ItemPosition").global_transform

		# Emits a signal that interacted with something and send that node to it.
					emit_signal("interact", $Head/RayCast.get_collider())


	# If the player releases the interact key, it emits a signal that states that I have let go of the object I am 
	# currently holding.
		elif Input.is_action_just_released("interact"):
			emit_signal("letGo", $Head/RayCast.get_collider())


	# When the player clicks the mouse and if I am holding an object,
		if Input.is_action_just_pressed("click"):
			if objectGrabbed:
			# give that object linear velocity (movement) on the Z axis which would be multiplied by ThrowForce.
				objectGrabbed.linear_velocity = -$Head/Camera.global_transform.basis.z * ThrowForce
				release()
		# Otherwise, if we are colliding with something else,
			if $Head/RayCast.get_collider():
			# emit a signal that we are interacting with the object.
				emit_signal("interact", $Head/RayCast.get_collider())


	# And if you release the mouse button, emit a signal that you are letting go of the colliding node.
		elif Input.is_action_just_released("click"):
			emit_signal("letGo", $Head/RayCast.get_collider())


	# When the player scrolls up or down, add or subtract from scrollInput with ScrollStrength,
		if Input.is_mouse_button_pressed(BUTTON_WHEEL_UP):
			scrollInput += ScrollStrength
		elif Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN):
			scrollInput -= ScrollStrength
	# and clamp the scrollInput with the ScrollLimit, which limits how far your can scroll the object 
	# away from you.
		scrollInput = clamp(scrollInput,3,ScrollLimit)

# PHYSICS PROCESS  ----------------------------------------------------------------------------
# The player can pan around and move only if the player hits the play button in the menu and if the player is not
# currently dead. (You can remove the PauseNode statement as it is only used primarily in this project.)
func _physics_process(delta: float) -> void:
	if Global.Playing\
	and not Global.PauseNode.dead:
		camera(delta)
		movement(delta)

	# If I am currently holding an object, decide what to do with that object with this function.
		if objectGrabbed:
			grab()

# MOVEMENT SYSTEM ----------------------------------------------------------------------------
# warning-ignore:function_conflicts_variable
func movement(delta):

# This makes sure that you don't keep moving when you let go of a key.
	direction = Vector3()


# When the player crouches (Ctrl),
	if Input.is_action_pressed("crouch"):
	# subtract the player's collision height by CrouchSmoothing,
		$CollisionShape.shape.height -= CrouchSmoothing * delta
	# set the current speed to the predetermined crouching speed.
		Speed = crouchSpeed
	# make audio plays 1 second delayed from each other, and lower the volume.
		$RandomWalk/WalkAudioTimer.wait_time = 1
		$RandomWalk.volume_db = crouchVolume
# otherwise, test to see if there's something above the player,
	elif not test_move(transform,Vector3.UP,$CollisionShape.shape.height):
	# and if there are nothing above the player, then add height back with CrouchSmoothing.
		$CollisionShape.shape.height += CrouchSmoothing * delta

# The player's collision shape is clamped to make sure that the lowest point that the player's
# collision shape can be is the crouch height.
	$CollisionShape.shape.height = clamp($CollisionShape.shape.height,crouchedHeight,defaultHeight)
# When the player is colliding with something on top of itself, make the player sink into the ground 
# by -2. (this is useful for crouching to make sure that the player isn't clipping upwards the 
# while crouching)
	if test_move(transform,Vector3.UP,false):
		fall.y = -2


# When the player sprints (Shift),
	if Input.is_action_pressed("run"):
	# and if sprint meter is on,
		if SprintMeter == true:
	# if the current sprint value is more than 0 and is already not holding down the sprint key,
			if $Sprint.value > 0\
			and stillSprinting == false:
		# set the current movement speed with the predetermined sprint speed.
					Speed = sprintSpeed
	#  make the audio play only 0.1 seconds away from each other and increase the volume,
					$RandomWalk/WalkAudioTimer.wait_time = 0.1
					$RandomWalk.volume_db = sprintVolume
		# and if the player is currently pressing any movement keys,
					if Input.is_action_pressed("left")\
					or Input.is_action_pressed("right")\
					or Input.is_action_pressed("up")\
					or Input.is_action_pressed("down"):
			# drain the player's stamina with StaminaDrain.
						$Sprint.value -= StaminaDrain
		# Otherwise, add stamina back with StaminaRegen.
					else:
						$Sprint.value += StaminaRegen
	# otherwise, if the player is out of sprint:
			else:
		# keep track that the player is still holding down the sprint key, revert to normal speed and change the
		# audio parameters accordingly.
				stillSprinting = true
				Speed = defaultSpeed
				$RandomWalk/WalkAudioTimer.wait_time = 0.5
				$RandomWalk.volume_db = walkVolume
				$Sprint.value += StaminaRegen

	# If sprint meter is turned off, just switch the current speed to sprint speed and change audio parameters.
		else:
			Speed = sprintSpeed
			$RandomWalk/WalkAudioTimer.wait_time = 0.1
			$RandomWalk.volume_db = sprintVolume
# When the player is not holding down the sprint key,
	else:
	# keep track that the player is now no longer holding the sprint key, and if sprint meter is on:
		stillSprinting = false
		if SprintMeter == true:
		# set the speed and audio,
			Speed = defaultSpeed
			$RandomWalk/WalkAudioTimer.wait_time = 0.5
			$RandomWalk.volume_db = walkVolume
		# and if the current stamina is not above 100, add stamina back with StaminaRegen.
			if $Sprint.value < 100:
				$Sprint.value += StaminaRegen
	# Otherwise, if sprint meter is turned off, just set the speed back to normal speed and change audio parameters.
		else:
			Speed = defaultSpeed
			$RandomWalk/WalkAudioTimer.wait_time = 0.5
			$RandomWalk.volume_db = walkVolume


# When the player jumps (Space):
	if Input.is_action_just_pressed("jump"):\
	# If the maximum ammount of jumps is 1,
		if MaxJumps < 2:
		# and if the maximum ammount of jumps is not 0, and is touching the ground or a slope through the ground
		# check raycast:
			if MaxJumps > 0\
			and (is_on_floor() or $GroundCheck.is_colliding()):
			# set the Y vector of the current gravity to 1 and multiply it by the jump height variable (Jump).
				gravityVec = Vector3.UP * Jump

	# Otherwise, if max jumps is more than 1:
		else:
		# and if the ammount of jumps done currently is not more than the maximum allowed number of jumps,
			if jumpCount < MaxJumps:
		# set the Y vector of the current gravity to 1 and multiply it by the jump height variable (Jump).
				gravityVec = Vector3.UP * Jump
		# and add 1 jump to current jumps done.
		jumpCount += 1

# When the player hits the ceiling,
	if is_on_ceiling():
	# set the gravity of the player to 0, which means the player will remove all current Y velocity and 
	# start falling.
		gravityVec = Vector3.UP * 0
		h_velocity.y = 0


# When the player is not on the floor:
	if not is_on_floor():
	# the player is now falling
		falling = true
	# and if the player hasn't jumped yet, add 1 to jump count (so if the maximum ammount of jumps is only 1,
	# the player won't be allowed to jump again mid air unless if your max jumps are 2 or above)
		if jumpCount < 1:
			jumpCount = 1
	# If the player is currently not climbing,
		if not climb:
		# set the player's gravity vector (Y) to -1 * gravity variable over time.
			gravityVec += Vector3.DOWN * Gravity * delta
	# set the player's current speed to another variable.
		h_acceleration = air_acceleration

# When the player is on the floor:
	else:
	# and if the player is falling at a certain ammount and Bobbing is turned on,
		if gravityVec.y < -15\
		and Bobbing:
		# play the landing animation.
			$Head/Camera/land.play("land")
	# If the player will not be landing on a jump pad,
		if not ($GroundCheck.get_collider() is Area\
		and $GroundCheck.get_collider().is_in_group("jumppad")):
		# set the landing audio to the gravity vector minus 30
			$LandAudio.volume_db = (-gravityVec.y) - 30
		# cap the landing autio to not blow out anyone's ears when landing from a skyscraper,
			$LandAudio.volume_db = clamp($LandAudio.volume_db,-30,5)
		# and play the landing audio.
			$LandAudio.play()
	# reset all jumps that were previously done when touching the ground.
		jumpCount = 0

	# If the player was falling when touching the ground:
		if falling:
		# Take the point of the ground to push the player back up on the ground.
			gravityVec = -get_floor_normal()
		# Make acceleration as if you are on the ground.
			h_acceleration = normal_acceleration
		# Set it so now the player is not falling anymore.
		falling = false

# If up or down input is  pressed, the local transform corresponding axis is either increased or 
# decreased.
	if Input.is_action_pressed("up"):
		if not climb:
			direction -= transform.basis.z
		if climb\
		and not is_on_floor():
	# If the player is currently in climb mode, we add a climbforce instead of moving the direction.
			climbForce = 10
			ladderSound()
	elif Input.is_action_pressed("down"):
		if not climb\
		or (climb and is_on_floor()):
			direction += transform.basis.z
		if climb\
		and not is_on_floor():
	# Same concept for the down input.
			climbForce = -10
			ladderSound()
	else:
	# If the player is not moving and you are currently climbing and not on the floor, climb force
	# is set to zero.
		if climb\
		and not is_on_floor():
			climbForce = 0

# The same concept is done with the left and right input, with a simpler but similar concept.
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("right"):
		direction += transform.basis.x
# We normalize the direction vector to ensure that the movement is consistent.
	direction = direction.normalized()
# We then interpolate the direction vector smoothly to make the movement smoother.
	h_velocity = h_velocity.linear_interpolate(direction * Speed, h_acceleration * delta)

# Arcade Style = No smoothing in the movement.
	if ArcadeStyle:
	# For arcade style, we only need the raw normalized direction vector with no interpolation.
		direction *= Speed
		movement.x = direction.x
		movement.z = direction.z
	else:
		movement.x = h_velocity.x
		movement.z = h_velocity.z

# If you are currently standing on a spring/jump boost:
	if spring:
	# Add to the Y vector of the player a specified bounce value from the jump pad.
		gravityVec.y += bounce
	# and we want to make sure that you are not just adding more to the Y value other than once.
		spring = false

# If the player is currently climbing:
	if climb:
	# the Y movement of the player is now determined by the climb force, which is changed with
	# the up and down input.
		movement.y = climbForce
	else:
# Otherwise, gravity will be controlling the Y position of the player.
		movement.y = gravityVec.y


# Move and slide moves the player with the movement vector, which is assigned from earlier.
# warning-ignore:return_value_discarded
	move_and_slide(movement, Vector3.UP, true, 4, PI/4, false)

	if direction != Vector3():
	# If the player is currently moving and on the floor and bobbing is on:
		if is_on_floor():
			if Bobbing == true:
		# the bobbing animation speed is changed if the player is walking, crouching or sprinting.
				if Speed == defaultSpeed:
					$Head/Camera/bob.playback_speed = 2
				elif Speed == crouchSpeed:
					$Head/Camera/bob.playback_speed = 1
				elif Speed == sprintSpeed:
					$Head/Camera/bob.playback_speed = 5
				$Head/Camera/bob.play("bobbing")
		# If the random walk sound effect is not playing and the walking timer has been set off. 
			if not $RandomWalk.is_playing()\
			and walkAudio == true:
		# Randomize a seed
				randomize()
		# Grab a random number with the range being the ammount of sound effects that can be used.
				var random_index = randi() % WalkAudioFiles.size()
				$RandomWalk.stream = WalkAudioFiles[random_index]
				$RandomWalk.play()
		# This variable prevents the sound effect to be played again while the player is moving.
				walkAudio = false
		# Start the walking timer.
				$RandomWalk/WalkAudioTimer.start()

# CAMERA SYSTEM  ----------------------------------------------------------------------------
func camera(delta):
# The crosshair's position will allways be at the middle of the screen.
	$Crosshair.position = get_viewport().size / 2

# The mouse movement is interpolated into rotationVelocity with CameraSmoothing. It is also 
# multiplied by the MouseSensitivity.
	rotationVelocity = rotationVelocity.linear_interpolate(cameraInput * (MouseSensitivity * 0.25), delta * CameraSmoothing)
# We interpolate the Z rotation of the camera which gives it a slight tilt.
	$Head/Camera.rotation_degrees.z = lerp($Head/Camera.rotation_degrees.z,
# The value is taken from pressing the left input which is multiplied by TiltAmmount
	(TiltAmmount * (float(Input.is_action_pressed("left")) 
# And the tilt will be zero if the player is not on the ground.
	* float(is_on_floor() ) ) ) + 
# The same concept works for the right input.
	(-TiltAmmount * (float(Input.is_action_pressed("right")) * float(is_on_floor()) ) ),
	delta * TiltSpeed)

# When the player is holding the right mouse button and if I am holding an object:
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
	# Lock the camera movement.
		if objectGrabbed:
	# Rotate the object with the corresponding mouse movement:
	# Rotate the Y axis with the left and right mouse movement.
			objectGrabbed.rotate_y(deg2rad(rotationVelocity.x * 1.5))
	# Rotate the X axis with the up and down mouse movement.
			objectGrabbed.rotate_x(deg2rad(rotationVelocity.y * 1.5))
	# Make sure to keep the object's location at the grabbing position.
			objectGrabbed.global_transform.origin = $Head/Hand/GrabPos.global_transform.origin

# If the camera is not locked:
	elif lockCamera == false:
	# Rotate the whole player's Y axis with the left and right mouse movement.
		rotate_y(-deg2rad(rotationVelocity.x))
	# Rotate the head's X axis with the up and down mouse movement.
		$Head.rotate_x(-deg2rad(rotationVelocity.y))
	# Clamp the X rotation to make sure that you can't turn your camera upside down.
		$Head.rotation.x = clamp($Head.rotation.x,deg2rad(-90),deg2rad(90))
	# Remove all mouse movement information to avoid the mouse movement to stack.
		cameraInput = Vector2.ZERO

# If Sprint FOV is on:
	if SprintFOVToggle:
	# FOV is set by the speed of the player.
		var FOV = h_velocity.length()
	# The camera's FOV is interpolated with FOV:
		$Head/Camera.fov = lerp($Head/Camera.fov, 
	# FOV will never go lower than MinFOV added with MaxFOV that only gets toggled when the player
	# is moving (the higher the player movement, the closer the camera FOV gets to MaxFOV).
	# The camera FOV is also multiplied if the player is running.
	# However, this will be cancelled if the player was still holding sprint even if stamina runs out.
		MinFOV + (MaxFOV/90 * (FOV * (float(Input.is_action_pressed("run")) - float(stillSprinting)))),
	# This is then smoothened by SprintFOVSmooth
		delta * SprintFOVSmooth)

# RIGID BODY GRABBING SYSTEM ----------------------------------------------------------------
# This is the function that allows the player to grab a rigidbody.
func grab():
# Grab the object's vector and subtract that from the player's grabbing posiiton which gives us
# the vector needed to move the object to the middle of the screen.
	var vector = $Head/Hand/GrabPos.global_transform.origin - objectGrabbed.global_transform.origin
# Add that vector to the movement vector of the object to move it to the grabbing position, which
# is smoothened by GrabSmoothing.
	objectGrabbed.linear_velocity = vector * GrabSmoothing
# The spring arm's length that contains the grabbing position can be adjusted by the scroll wheel
# and set the length of that spring arm to that scroll value.
	scroll = lerp(scroll,scrollInput,ScrollSmoothing)
	$Head/Hand.set_length(scroll)
# This is the function when you want to let go of an object you grabbed.
func release():
# Remove all the rotation locks on the grabbed rigid body.
	objectGrabbed.axis_lock_angular_x = false
	objectGrabbed.axis_lock_angular_y = false
	objectGrabbed.axis_lock_angular_z = false
# Remove the node from being excluded on the player's raycast and set object that is grabbed to
# none.
	$Head/Hand.remove_excluded_object(objectGrabbed)
	objectGrabbed = null

# ITEM HOLDING SYSTEM  ----------------------------------------------------------------------------
# This releases the item the player is currently holding.
func releaseItem():
# If the player is holding an item:
	if Item:
	# Get the item node from the player's hand and remove it.
		Item.get_parent().remove_child(Item)
	# Turn on the item's shadow.
		ItemMesh.cast_shadow = true
	# Give the item gravity. 
		Item.gravity_scale = 8
	# Enable the item's collisions.
		Item.get_node("CollisionShape").disabled = false
	# Get the stage node and add the item node in it.
		self.get_parent().add_child(Item)
	# Move the instanced item to the player's hand position.
		Item.global_transform = get_node("Head/ItemPosition").global_transform
	# Now the player is no longer holding an item.
		Item = null
# This loads the item to the player's hand.
func loadItem(item):
# grab the item node, load and instance it in the script.
	var loaded = load(item).instance()
# Turn off its gravity.
	loaded.gravity_scale = 0
# Turn off the item's collisions so the player doesn't collide with the item.
	loaded.get_node("CollisionShape").disabled = true
# Grab the player's item position and add the instanced scene as a child.
	get_node("Head/ItemPosition").add_child(loaded)

# PLAYER RESET SYSTEM ----------------------------------------------------------------------------
# This is what happens when the player dies or resets the game.
func kill():
# Turn off the player's gravity.
	gravityVec = Vector3()
# Turn off the player's movement.
	movement = Vector3()
# Emit a signal.
	emit_signal("kill")
# Updates the new position of the spawn point.
	spawnpoint = get_parent().get_node("Spawn Point").global_transform.origin
# Move the player to the spawn point's location.
	global_transform.origin = spawnpoint

# EXTRAS  ----------------------------------------------------------------------------
# This function makes the player bounce up when touching a jump pad.
# warning-ignore:function_conflicts_variable
func spring(SpringStrength):
# Allow the player to be bounced up.
	spring = true
# Set the bounce height from the variable set on the jump boost.
	bounce = SpringStrength

# When the player touches a ladder:
func _on_ClimbCheck_area_entered(area: Area) -> void:
	if area.is_in_group("ladder")\
	or area.is_in_group("ladderTop"):
	# Add the touched ladder instance to the climb count.
		climbed += 1
	# Allow the player to climb.
		climb = true
# When the player leaves a ladder:
func _on_ClimbCheck_area_exited(area: Area) -> void:
	if area.is_in_group("ladder"):
		# Remove a count from the climbed ladders.
		climbed -= 1
		# And if you are no longer climbing any ladders,
		if climbed == 0:
			# then you are no longer climbing,
			climb = false
			# set the climb force to zero
			climbForce = 0
			# and remove the gravity momentum.
			gravityVec = Vector3()
	if area.is_in_group("ladderTop"):
		climbed -= 1
		# If you are on top of the elevator, a timer starts to allow the player to go up even
		# if they are not touching a ladder
		if climbed == 0:
			$ClimbTimeout.start()
# This is the top ladder climb timer.
func _on_ClimbTimeout_timeout() -> void:
	climb = false
	climbForce = 0
	gravityVec = Vector3()

# The ladder sound effect function.
func ladderSound():
	# Rhe sound effect system works like the walking sound effect system.
	if not $RandomClimb.is_playing()\
	and climb\
	and climbAudio == true:
		climbAudio = false
		randomize()
		var random_index = randi() % ClimbAudioFiles.size()
		$RandomClimb.stream = ClimbAudioFiles[random_index]
		$RandomClimb.play()
		$RandomClimb/ClimbAudioTimer.start()
# Once the timer ends, the walking or climbing sound effect can be played again.
func _on_WalkAudioTimer_timeout() -> void:
	walkAudio = true
func _on_ClimbAudioTimer_timeout() -> void:
	climbAudio = true
