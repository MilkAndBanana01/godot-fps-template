tool
extends Spatial

# How high the elevator is.
export var ElevatorHeight= 1 setget UpdateHeight
# How fast the platform moves (lower = faster).
export var ElevatorSpeed = 1
# How long does the Elevator wait before moving again.
export var WaitTime = 1
# These variables rotate the elevator.
export var XRotation = 0 setget XRotation
export var YRotation = 0 setget YRotation
# If true, the elevator will continue moving.
export var AutoStart = false
# If autostart is false, the elevator returns to it's original position after the player leaves.
export var Return = false
# How long it waits until the elevator goes back to it's original position.
export var ReturnTime = 1

var ElevatorTop
var PlayerOnElevator = false
var Top = false
var wait = false
var middle = preload("res://Elevator/ElevatorMiddle.tscn")
var top = preload("res://Elevator/ElevatorTop.tscn")

# Special thanks to RossenX for making this script <3

# This works similarly with the Fence script.
func GenerateElevator():
	# This script repeats as the number inputed in ElevatorHeight:
	for n in ElevatorHeight:
		var ElevatorChild
	# If n is currently 2 away from ElevatorHeight, it instances the middle part of the elevator.
		if n != ElevatorHeight-1:
			ElevatorChild = middle.instance()
	# Otherwise, it instances the top of the elevator.
		else:
			ElevatorChild = top.instance()
	
	# We move the child depending on how many children are in the scene.
		ElevatorChild.transform.origin.y = 4 + (2 * ($ElevatorBottom.get_child_count() -1))
	#And finally add the child to the node.
		$ElevatorBottom.add_child(ElevatorChild)
		ElevatorChild.set_owner(self)

# If the elevator height variable changes,
func UpdateHeight(_p):
	# and if it's not lower than 2,
	if not _p < 1:
		ElevatorHeight = _p
	# we take all the child nodes and delete them.
	for n in $ElevatorBottom.get_children():
		n.free()
	# And then generate a new elevator with the new elevator height.
	GenerateElevator()

# This rotates the elevator through the corresponding variables. This is to prevent messing with global
# to relative position calculations.
# warning-ignore:function_conflicts_variable
func XRotation(_p):
	XRotation = _p
	$ElevatorBottom.rotation_degrees.x = XRotation * 45
# warning-ignore:function_conflicts_variable
func YRotation(_p):
	YRotation = _p
	$ElevatorBottom.rotation_degrees.y = YRotation * 45
	$Platform.rotation_degrees.y = YRotation * 45


func _physics_process(_delta: float):
	# If autostart is on, the elevator stops moving, and the wait timer is finished:
	if AutoStart:
		if not $Tween.is_active()\
		and not wait:
			wait = true
		# we take the ammount of wait time provided by the user, and adding it to the ammount of 
		# time it takes for the elevator to reach it's position and setting the timer to that.
			$Wait.wait_time = WaitTime + ElevatorSpeed
			$Wait.start()
		# We grab the last child node of the elevator, which will always be the top of the elevator,
		# and get a Position3D node inside that node that marks as the top of our elevator platform.
			ElevatorTop = $ElevatorBottom.get_child(ElevatorHeight - 1).get_node("Position3D").global_transform.origin - translation
		# If the elevator is at the bottom,
			if not Top:
				$Tween.interpolate_property($Platform,
				"translation",
		# We set it to move from the bottom of the elevator, (the global - translation is to compensate
		# with the position of the node in the level, so that the tween still thinks that the elevator
		# is at the center of the world)
				$Position3D.global_transform.origin - translation,
		# to the top node we grabbed earlier.
				ElevatorTop,
		# We move it with the variable ElevatorSpeed.
				ElevatorSpeed,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN)
		# Same process if the elevator is at the top.
			else:
				$Tween.interpolate_property($Platform,
				"translation",
				ElevatorTop,
				$Position3D.global_transform.origin - translation,
				ElevatorSpeed,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN)
			$Tween.start()
			# After that, we reverse the top variable to signfy the opposite of where the platform 
			# should be (if it's true, it will be false, and vice versa).
			Top = !Top


func _on_Area_body_entered(body: Node) -> void:
	if not AutoStart:
		# If a player is on the elevator and the elevator is currently not moving:
		if body == Global.player\
		and not $Tween.is_active():
			# We set a variable to keep track that the player is on the platform, and do the same
			# steps as if it was an autostart elevator.
			PlayerOnElevator = true
			ElevatorTop = $ElevatorBottom.get_child(ElevatorHeight - 1).get_node("Position3D").global_transform.origin - translation
			if not Top:
				$Tween.interpolate_property($Platform,
				"translation",
				$Position3D.global_transform.origin - translation,
				ElevatorTop,
				ElevatorSpeed,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN)
			else:
				$Tween.interpolate_property($Platform,
				"translation",
				ElevatorTop,
				$Position3D.global_transform.origin - translation,
				ElevatorSpeed,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN)
			$Tween.start()
			Top = !Top

# If the player leaves the elevator, the return timer starts.
func _on_Area_body_exited(body: Node) -> void:
	if not AutoStart\
	and body == Global.player:
		PlayerOnElevator = false
		$Return.wait_time = ReturnTime
		$Return.start()

# Once the return timer is up and:
func _on_Timer_timeout() -> void:
	# If the player is not on the elevator, the platform is currently at the top, AutoStart is off,
	# and the elevator is currently not moving.
	if not PlayerOnElevator\
	and Top\
	and not AutoStart\
	and not $Tween.is_active():
		# the platform returns back to its original spot.
		$Tween.interpolate_property($Platform,
		"translation",
		ElevatorTop,
		$Position3D.global_transform.origin - translation,
		ElevatorSpeed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN)
		$Tween.start()
		Top = !Top

# If the wait timer is out, the autostart procedure will trigger again.
func _on_Wait_timeout() -> void:
	wait = false
