extends Spatial

# How high the player will be bounced up.
export var SpringStrength = 50

func _on_Area_body_entered(body: Node) -> void:
# If the body is a rgidbody that is currently not being grabbed, add a linear force to the body by
# SpringStrength.
	if body is RigidBody\
	and not body == Global.player.objectGrabbed:
		$JumpAudio.play()
		body.linear_velocity.y += SpringStrength
	elif body == Global.player:
		$JumpAudio.play()
# If it's a player, we send trigger a function in the player that adds the jump boost.
		body.spring(SpringStrength)
