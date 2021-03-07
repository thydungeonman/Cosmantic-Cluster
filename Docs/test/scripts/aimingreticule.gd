extends RayCast2D


var number = 0
var stop = false
#var trajectory = Vector2(0,0)
var nexttrajectory = Vector2(0,0)
var next = null
var last = null
var limit = 70
onready var sprite = get_node("Sprite")

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	pass

func ExtendLine(trajectory):
	
	if(number > limit):
		#EndLine()
		return
		
	set_global_position(get_global_position() + trajectory)
	next = preload("res://test/scenes/aimingreticule.tscn").instance()
	add_child(next)
	next.number = number + 1
	if(next != null):
		next.ExtendLine(trajectory)
	if(number == 0):
		CutShort()

func CutShort():
	if(number != 25):
		next.CutShort()
	else:
		EndLine()

func CheckCollision():
	if(is_colliding()):
		if(get_collider().is_in_group("orb") or get_collider().is_in_group("wall")):
			EndLine()
			return
	else:
		if(next != null):
			next.CheckCollision()

func ModifyLine(trajectory):
	if(number > limit):
		#EndLine()
		return
	#print("trajectory: " + str(trajectory))
	sprite.show()
	set_global_position(get_parent().get_global_position() + trajectory)
	set_cast_to(trajectory)
	force_raycast_update()
	next.ModifyLine(trajectory)
	if(number == 0):
		CheckCollision()


func EndLine():
	if(next != null):
		next.EndLine()
	sprite.hide()
	

