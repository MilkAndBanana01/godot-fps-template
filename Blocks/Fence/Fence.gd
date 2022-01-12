tool
extends Spatial
 
export var FenceWidth = 1 setget UpdateFence

var FenceLeft = preload("res://Blocks/Fence/Left.tscn")
var FenceRight = preload("res://Blocks/Fence/Right.tscn")
var FenceMiddle = preload("res://Blocks/Fence/Middle.tscn")


func GenerateFence():

# Special thanks to RossenX for teaching me this method <3

# This takes the export variable FenceWidth and loops this function that many times, if it's the first
# fence, then the right fence scene is instanced, and if it's equal to FenceWidth, we now instance
# the left fence scene. Anything in the middle is the middle fence scene. 
	for n in FenceWidth:
		var FenceChild
		if n == 0:
			FenceChild = FenceRight.instance()
		elif n != FenceWidth-1:
			FenceChild = FenceMiddle.instance()
		else:
			FenceChild = FenceLeft.instance()
 
# It then takes that instance, and moves it according to how many childen are already in the node.
# For our case, we just want to move it 2 steps to the Z axis for every children added.

		FenceChild.transform.origin.z = 2 + (2 * (self.get_child_count() -1))
		add_child(FenceChild)
		FenceChild.set_owner(self)

# If you notice the FenceWidth variable, it has a thing called setget, which calls this function everytime
# the value changes. It also grabs the value of the variable, for this instance, we left it underscored
# since we don't need the value for this function.
func UpdateFence(_p):

# This is to quickly check if the number entered is lower than 2, then the value shouldn't be allowed. Nice
# way to make sure tool scripts don't bug out when you accidentally set it to a wrong value.
	if not _p < 2:
		FenceWidth = _p

# It then grabs all the children in the node and deletes them all, after which we generate a new set of 
# fences based on the new value.
	for n in self.get_children():
		n.free()
	GenerateFence()
