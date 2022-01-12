extends RigidBody

var spawnPos

# When the game starts, assign the spawn location of the nod in the level.
func _ready() -> void:
	spawnPos = global_transform
# Connect the player retry and death signal to the reset function of this node.
	Global.PauseNode.connect("dead", self, "reset")
	Global.player.connect("kill", self, "reset")

# When the game is restarted or the player dies, the node goes back to it's spawn location.
func reset():
	global_transform = spawnPos
