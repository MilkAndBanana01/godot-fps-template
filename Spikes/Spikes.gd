extends StaticBody

# If the player touches the spike,
func _on_Area_body_entered(body: Node) -> void:
	if body == Global.player:
		# call the player kill function
		body.kill()
		# and trigger the death screen.
		Pause.kill()

# If the player hasn't started playing yet and the audio player's have not played yet, audio will not play.
func _physics_process(_delta: float) -> void:
	if is_in_group("long") and not get_node("long saw/Cube017/AudioStreamPlayer3D").playing:
		get_node("long saw/Cube017/AudioStreamPlayer3D").playing = Global.Playing
	elif is_in_group("small") and not get_node("AudioStreamPlayer3D").playing:
		get_node("AudioStreamPlayer3D").playing = Global.Playing
