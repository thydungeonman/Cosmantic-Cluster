extends Area2D

var timer = 0.0
var s = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_physics_process(true)
	

func _physics_process(delta):
	timer += delta
	if(!s and timer > .2):
		for body in get_overlapping_bodies():
			if(body.is_in_group("orb")):
				body.istouchingtop = true
		s = true

func Reset():
	s = false
	timer = 0.0
