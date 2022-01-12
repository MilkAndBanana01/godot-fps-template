extends Area

# This grabs the Spawnpoint node (Position3D), which is where the player will spawn.
var spawnPoint

func _physics_process(_delta: float) -> void:

# If the player hasn't press played yet in the game screen, audio will not come out of it.
	if not get_node("checkpoint/Idle").playing:
		get_node("checkpoint/Idle").playing = Global.Playing

func _on_Checkpoint_body_entered(body: Node) -> void:
# If the player collides with the checkpoint, it takes the spawnpoint node we called earlier and
# moves it to the position of the checkpoint we touched. It then gets deleted.
	if body == Global.player:
		spawnPoint = body.get_parent().get_node("Spawn Point")
		spawnPoint.global_transform.origin = global_transform.origin
		$checkpoint.visible = false
		$Collect.play()

# When the sound effect finishes playing, the node gets deleted.
func _on_Collect_finished() -> void:
	queue_free()
