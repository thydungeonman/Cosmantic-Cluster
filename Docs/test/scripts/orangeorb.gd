extends "orb.gd"

func _ready():
	colour = COLOUR.ORANGE


func ActivateAbility():
	print("ORANGE ABILITY")
	var combo = get_parent().HandleAbilityCombo(colour,player)
	if(combo != 0):
		get_parent().NewHandleAbility(player)
	#fire small squares that are the same color as the orb in the launcher
	#if a square collides with an orb
	#if the orb is the same color
	#if lasered != true
	#anim.play(lasered)
	#sqares should be pretty small to avoid being able to hit two orbs
	#at once by shooting rignt in between them

