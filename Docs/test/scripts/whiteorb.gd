extends "orb.gd"

func _ready():
	colour = COLOUR.WHITE


func ActivateAbility():
	print("WHITE ABILITY")
	var combo = get_parent().HandleAbilityCombo(colour,player)
	#launcher.Freeze()

