extends "orb.gd"

func _ready():
	colour = COLOUR.BLUE


func ActivateAbility():
	print("BLUE ABILITY")
	#instance x amount of grey orbs
	#they spawn at random horizontal positions on enemy board making sure to not overlap
	#set moving equal to true with completely vertical trajectories
	#enemy launcher can not fire while this is happening
	#shouldn't take more than a second
