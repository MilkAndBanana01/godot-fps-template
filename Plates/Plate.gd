extends Spatial

# How many rigid bodies are currently pressed on the plate.
var bodies = 0

signal platePress(node)

func _on_Area_body_entered(_body: Node) -> void:
# If there's currently no bodies on the plate, it will emit a signal and play a pressed animation.
# This state will remain until there is no more bodies on the plate.
	if bodies < 1:
		$AnimationPlayer.play("press")
		emit_signal("platePress",self)
# Add a body coujnt on the plate.
	bodies += 1

func _on_Area_body_exited(_body: Node) -> void:
# Subtract a body from the plate.
	bodies -= 1
# If there are now no bodies on the plate, the plate will return to normal and emit another signal.
	if bodies == 0:
		$AnimationPlayer.play_backwards("press")
		emit_signal("platePress",self)
# To make sure that we don't get any negative values, we put this check on the body count.
	elif bodies < 0:
		bodies = 0
