extends Node2D

var before #follower before this
var after
var frame = false #must wait one frame to send the movement down
var position = null #place to move to and then send along
var oldposition = null

func _ready():
	pass
#	set_fixed_process(true)
	

#func _fixed_process(delta):
#	if(position != null):
#		oldposition = position
#		set_global_pos(position)
#		position = before.oldposition

func Move():
	#old position = position
	#after.position = oldposition
	
	
	#laser
	#oldposition = position
	#move
	
#	laser
#	I remember my current position as my old position
#	I move
#	I tell you to remmber your current position as your old position
#	I tell you to move to my old position
#	i tell you to remember your current position
#	
#	
#	follower
#	I tell you to remember your current position as your old position
#	i tell you to move to my old position
	if(after != null):
		after.oldposition = after.position
		if(oldposition != null):
			after.set_global_pos(oldposition)
		after.position = after.get_global_pos()