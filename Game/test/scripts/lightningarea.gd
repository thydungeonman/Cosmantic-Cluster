extends Area2D
#this class is not to be used on its own
#must be the child of an orb
#and should only be childed when the orb is fired from the launcher to avoid potential bugs

#a bool in the launcher should be used to show that a lightning ability is active


func _ready():
	pass

func ReturnOverlappingOrbs():
	var overlaporbs = get_overlapping_bodies()
	var correctorbs = []
	for orb in overlaporbs:
		if(orb.colour == get_parent().colour):
			correctorbs.push_back(orb)
	return correctorbs