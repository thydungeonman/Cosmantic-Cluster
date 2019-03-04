extends RayCast2D


var number = 0
var stop = false
#var trajectory = Vector2(0,0)
var nexttrajectory = Vector2(0,0)
var next = null
var last = null
var limit = 22

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	pass

func ExtendLine(trajectory):
	
	if(number > limit):
		#EndLine()
		return
	
	#move(trajectory)
	#print("trajectory: " + str(trajectory))
	set_global_pos(get_global_pos() + trajectory)
	if(is_colliding()):
		if(get_collider().is_in_group("wall")):
			nexttrajectory = trajectory
			nexttrajectory.x *= -1
		elif(get_collider().is_in_group("orb")):
			stop = true
			return
			#EndLine()
	else:
		next = preload("res://test/scenes/aimingreticule.tscn").instance()
		add_child(next)
		next.number = number + 1
		next.ExtendLine(trajectory)

func ModifyLine(trajectory):
	#print("trajectory: " + str(trajectory))
	set_global_pos(get_parent().get_global_pos() + trajectory)
	set_cast_to(trajectory/5)
	force_raycast_update()
	if(is_colliding()):
		if(get_collider().is_in_group("wall")):
			#trajectory.x *= -1.15
			get_parent().next = null
			EndLine()
			return
		elif(get_collider().is_in_group("orb")):
			stop = true
			get_parent().next = null
			EndLine()
			return
		
	if(next == null):
		next = preload("res://test/scenes/aimingreticule.tscn").instance()
		add_child(next)
		next.number = number + 1
		next.AdjustLine(trajectory)
	else:
		next.ModifyLine(trajectory)

func EndLine():
	if(next != null):
		next.EndLine()
	queue_free()


func AdjustLine(trajectory):
	#move(trajectory)
	#print("trajectory: " + str(trajectory))
	set_global_pos(get_global_pos() + trajectory)
	if(is_colliding()):
		if(get_collider().is_in_group("wall")):
			nexttrajectory = trajectory
			nexttrajectory.x *= -1
			get_parent().next = null
			EndLine()
			return
		elif(get_collider().is_in_group("orb")):
			stop = true
			return
			#EndLine()
	else:
		next = preload("res://test/scenes/aimingreticule.tscn").instance()
		add_child(next)
		next.number = number + 1
		next.ExtendLine(trajectory)