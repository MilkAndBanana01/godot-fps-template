tool
extends Spatial

# This sets how many buttons you wanna spawn.
export var Buttons = 0 setget UpdateButtons
# This sets how many rotating levers you wanna spawn.
export var RotationLevers = 0 setget UpdateRotLevers
# This sets how many moving levers you wanna spawn.
export var TranslationLevers = 0 setget UpdateTranLevers
# This sets how many pressure plates you wanna spawn.
export var Plates = 0 setget UpdatePlates

# If the value is lower than 0, it doesn't allow the value.
# It then generates the new values given to the export variables.
func UpdateButtons(b):
	if b > -1:
		Buttons = b
		GenerateChildren()
func UpdateRotLevers(b):
	if b > -1:
		RotationLevers = b
		GenerateChildren()
func UpdateTranLevers(b):
	if b > -1:
		TranslationLevers = b
		GenerateChildren()
func UpdatePlates(b):
	if b > -1:
		Plates = b
		GenerateChildren()

func GenerateChildren():
# This deletes all children of the node except the door itself.
	for i in get_children():
		if i.name != "Doorway":
			i.free()
# This function repeats as many times as the number of the Buttons variable.
	for i in Buttons:
		# It grabs an instance of the button scene,
		var button = load("res://Button/Button.tscn").instance()
		# adds it as a child of button.
		add_child(button)
		button.set_owner(self)
		# and connects a signal to the door.
		button.connect("buttonPress",$Doorway,"_on_Button_buttonPress")
# This then repeats to the other spawned elements.
	for i in RotationLevers:
		var rotlever = load("res://Levers/Rotation Lever.tscn").instance()
		add_child(rotlever)
		rotlever.set_owner(self)
		rotlever.connect("leverActivated",$Doorway,"_on_rotation_lever_leverActivated")
	for i in TranslationLevers:
		var tranlever = load("res://Levers/Translation Lever.tscn").instance()
		add_child(tranlever)
		tranlever.set_owner(self)
		tranlever.connect("leverActivated",$Doorway,"_on_rotation_lever_leverActivated")
	for i in Plates:
		var plate = load("res://Plates/Plate.tscn").instance()
		add_child(plate)
		plate.set_owner(self)
		plate.connect("platePress",$Doorway,"_on_plate_platePress")
