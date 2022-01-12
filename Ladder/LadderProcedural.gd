tool
extends Spatial
 
export var LadderHeight = 1 setget UpdateLadder
 
var LadderTop = preload("res://Ladder/LadderTop.tscn")
var LadderBottom = preload("res://Ladder/Ladder.tscn")


func GenerateLadder():
	for n in LadderHeight:
		var LadderChild
		if n != LadderHeight-1:
			LadderChild = LadderBottom.instance()
		else:
			LadderChild = LadderTop.instance()
 
		LadderChild.transform.origin.y = 2 + (2 * (self.get_child_count() -1))
		add_child(LadderChild)
		LadderChild.set_owner(self)

func UpdateLadder(_p):
	LadderHeight = _p
	for n in self.get_children():
		n.free()
	GenerateLadder()
