extends Node2D

var fallcheckarray = []

func _ready():
	GenerateBoard()


func GenerateBoard():
	for i in range(23):
		var orb = preload("res://test/scenes/orb.tscn").instance()
		add_child(orb)
		orb.set_pos(Vector2(80 + 80*i, 40))
		orb.GetNeighboringPositions()
		print(orb.get_global_pos())

func CheckFall(): #will most likely take one or more kinematic bodies that are the neighboring orbs of the ones that were just matched and killed
	pass
	#do the following for each orb
	#if orb.LookForTop(fallcheckarray) == false
		#foreach orb in fallcheck array:
			#orb.fall()
	#else:
		#fallcheckarray = []
	