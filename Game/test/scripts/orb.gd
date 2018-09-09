extends KinematicBody2D

export(Vector2) var trajectory = Vector2(0,0)
export(bool) var ismoving = false
var incannon = false #if an orb is neither in the cannon nor moving then it is on the board
onready var width = 0
onready var ray = get_node("RayCast2D")
var matchingorbs = []


#neighboring orbs  Kinematic bodies
var topleft
var topright
var left
var right
var bottomleft
var bottomright

#neighboring orb positions  Vector2s
var topleftspot
var toprightspot
var leftspot
var rightspot
var bottomleftspot
var bottomrightspot

func _ready():
	set_fixed_process(true)
	width = get_node("Sprite").get_texture().get_width() * self.get_scale().x

func _fixed_process(delta):
	if(ismoving):
		Move(delta)

func GetNeighboringPositions():
	var pos = get_pos()
	var inversescale = 1/get_scale().x
	
	topleftspot = pos + (Vector2(-width,-width) * Vector2(1.07337749,1.8417709).normalized())
	toprightspot = pos + (Vector2(width,-width) * Vector2(1.07337749,1.8417709).normalized())
	leftspot = pos + (Vector2(-width * inversescale,0) * Vector2(1.07337749,1.8417709).normalized())
	rightspot = pos + (Vector2(width * inversescale,0) * Vector2(1.07337749,1.8417709).normalized())
	bottomleftspot = pos + (Vector2(-width,width) * Vector2(1.07337749,1.8417709).normalized())
	bottomrightspot = pos + (Vector2(width,width) * Vector2(1.07337749,1.8417709).normalized())

func Move(delta):
	move(trajectory * delta)
	if(is_colliding()):
		var collider = get_collider()
		if(collider.is_in_group("wall")):
			trajectory.x *= -1
		elif(collider.is_in_group("roof")):
			trajectory.y *= -1
		elif(collider.is_in_group("orb")):
			if(!collider.ismoving):
				ismoving = false
				var positiondifference = get_pos() - collider.get_pos()
				positiondifference = positiondifference.normalized()
				var dotproductnorth = positiondifference.dot(Vector2(0,-1))
				var dotproductwest = positiondifference.dot(Vector2(-1,0))
				
				print(dotproductnorth)
				print(dotproductwest)
				
				if((dotproductnorth <= -.33 and dotproductnorth >= -1) and (dotproductwest <= 1 and dotproductwest > 0)): #collided on bottomleft
					set_pos(collider.bottomleftspot)
					collider.bottomleft = self 
				elif((dotproductnorth <= -.33 and dotproductnorth >= -1) and (dotproductwest <= 0 and dotproductwest >= -1)): #collided on bottom right side
					set_pos(collider.bottomrightspot)
					collider.bottomright = self
				elif((dotproductnorth <= .33 and dotproductnorth > -.33) and (dotproductwest <= 1 and dotproductwest > 0)):#left
					set_pos(collider.leftspot)
					collider.topleft = self
				elif((dotproductnorth <= .33 and dotproductnorth > -.33) and (dotproductwest <= 0 and dotproductwest >= -1)):#right
					set_pos(collider.rightspot)
					collider.topright = self
				elif((dotproductnorth <= 1 and dotproductnorth >.33) and (dotproductwest <= 1 and dotproductwest > 0)):#topleft
					set_pos(collider.topleftspot)
					collider.topleft = self
				elif((dotproductnorth <= 1 and dotproductnorth >.33) and (dotproductwest <= 0 and dotproductwest >= -1)):#topright
					set_pos(collider.toprightspot)
					collider.topright = self
				GetNeighboringPositions()
				GetNeihbors()
				#var match = CheckMatch(matchingorbs)
				#if(match):
					#ColorPower()
					#foreach(orb in matchingorbs):
						#orb.kill

func click():
	var mousepos = get_viewport().get_mouse_pos()
	var positiondifference = mousepos - get_pos()
	positiondifference = positiondifference.normalized()
	var dotproductnorth = positiondifference.dot(Vector2(0,-1))
	var dotproductwest = positiondifference.dot(Vector2(-1,0))
	print(dotproductnorth)
	print(dotproductwest)

func GetNeihbors():
	ray.set_cast_to(topleftspot)
	topleft = ray.get_collider()
	
	ray.set_cast_to(toprightspot)
	topright = ray.get_collider()
	
	ray.set_cast_to(leftspot)
	left = ray.get_collider()
	
	ray.set_cast_to(rightspot)
	right = ray.get_collider()
	
	ray.set_cast_to(bottomleftspot)
	bottomleft = ray.get_collider()
	
	ray.set_cast_to(bottomrightspot)
	bottomright = ray.get_collider()

func CheckMatch(matchingorbs): #accepts array of kinematic bodies2d
	#var match = false
	#Add self to array
	#goes through neihbors
	#if neighbor is correct color
		#if neighbor is not in array
			#neighbor.CheckMatch(array)
	#if array.length >= orbs:
		#match = true
	#return match