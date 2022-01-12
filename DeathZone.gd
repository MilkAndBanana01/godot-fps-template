extends Area

# This area s at the bottom and top of the level to kill the player.
func _on_Death_body_entered(body: Node) -> void:
	if body == Global.player:
		body.kill()
		Pause.kill()
