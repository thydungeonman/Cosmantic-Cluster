extends "orb.gd"

func _ready():
	colour = COLOUR.WHITE


func ActivateAbility():
	print("WHITE ABILITY")
	get_parent().HandleAbility(colour,player)
	#launcher.Freeze()
