extends StaticBody

# Keeps track how many ladder nodes is the player currently touching.
var climbed = 0

func _on_Area_body_entered(body: Node) -> void:
	climbing(body)
func _on_Area2_body_entered(body: Node) -> void:
	climbing(body)
func _on_Area_body_exited(body: Node) -> void:
	falling(body)
func _on_Area2_body_exited(body: Node) -> void:
	falling(body)

# If the body that was touching was the player,
func climbing(body):
	if body == Global.player:
		# the player's variable climb is now true.
		if climbed < 1:
			Global.player.climb = true
		# It then adds the touched ladder node to the variable count.
		climbed += 1

# If the body that was leaving was the player,
func falling(body):
	if body == Global.player:
		# We remove 1 count from the climbed variables.
			climbed -= 1
		# If you are no longer touching any ladders, then the player is no longer climbing.
			if climbed == 0:
				Global.player.climb = false





