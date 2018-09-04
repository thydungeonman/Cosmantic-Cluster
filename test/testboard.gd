extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	GenerateBoard()


func GenerateBoard():
	for i in range(23):
		var orb = preload("res://test/scenes/orb.tscn").instance()
		add_child(orb)
		orb.set_pos(Vector2(80 + 80*i, 40))
		orb.GetNeighboringPositions()
		print(orb.get_global_pos())