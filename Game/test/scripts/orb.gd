extends KinematicBody2D

enum COLOUR {BLACK,BLUE,GREEN,GREY,ORANGE,PURPLE,RED,WHITE,YELLOW}
export(Vector2) var trajectory = Vector2(0,0)
export(bool) var ismoving = false
var inlauncher = false #if an orb is neither in the launcher nor moving then it is on the board
onready var width = get_node("Sprite").get_texture().get_width() * get_node("Sprite").get_scale().x #maybe should be renamed to diameter
onready var ray = get_node("RayCast2D")
var matchingorbs = []
onready var pos = get_pos()
onready var inversescale = 1/get_scale().x

var colour = COLOUR.RED
#neighboring orbs  Kinematic bodies
var topleft
var topright
var left
var right
var bottomleft
var bottomright
#neighboring orb global positions  Vector2s
var topleftspot
var toprightspot
var leftspot
var rightspot
var bottomleftspot
var bottomrightspot
#neighboring orb local positions for raycast Vector2s
onready var ltopleftspot = Vector2(-width,-width) * Vector2(1.07337749,1.8417709).normalized()
onready var ltoprightspot = Vector2(width,-width) * Vector2(1.07337749,1.8417709).normalized()
onready var lleftspot = Vector2(-width,0)
onready var lrightspot = Vector2(width ,0)
onready var lbottomleftspot = Vector2(-width,width) * Vector2(1.07337749,1.8417709).normalized()
onready var lbottomrightspot = Vector2(width,width) * Vector2(1.07337749,1.8417709).normalized()

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if(ismoving):
		Move(delta)

func GetNeighboringPositions():
	var pos = get_pos()
	#print(width)
	
	topleftspot = pos + (Vector2(-width,-width) * Vector2(1.07337749,1.8417709).normalized())
	toprightspot = pos + (Vector2(width,-width) * Vector2(1.07337749,1.8417709).normalized())
#	leftspot = pos + (Vector2(-width * inversescale,0) * Vector2(1.07337749,1.8417709).normalized())
#	rightspot = pos + (Vector2(width * inversescale,0) * Vector2(1.07337749,1.8417709).normalized())
	leftspot = pos + (Vector2(-width,0))
	rightspot = pos + (Vector2(width ,0))
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
				
#				print(dotproductnorth)
#				print(dotproductwest)
				
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
				GetNeighbors()
				print(CountNeighbors())
				if(CheckMatch(matchingorbs)):
					ActivateAbility()
					for orb in matchingorbs:
						orb.queue_free()

func click():
	var mousepos = get_viewport().get_mouse_pos()
	ray.set_cast_to(mousepos - get_pos())
	print(ray.get_collider())
	#var positiondifference = mousepos - get_pos()
	#positiondifference = positiondifference.normalized()
	#var dotproductnorth = positiondifference.dot(Vector2(0,-1))
	#var dotproductwest = positiondifference.dot(Vector2(-1,0))

func GetNeighbors():
	ray.set_cast_to(ltopleftspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self):
		topleft = ray.get_collider()
		ray.get_collider().bottomright = self
		ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .10)
	
	ray.set_cast_to(ltoprightspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self):
		topright = ray.get_collider()
		ray.get_collider().bottomleft = self
		ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .10)
	
	ray.set_cast_to(lleftspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self):
		left = ray.get_collider()
		ray.get_collider().right = self
		ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .10)
	
	
	ray.set_cast_to(lbottomleftspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self):
		bottomleft = ray.get_collider()
		ray.get_collider().topright = self
		ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .10)
	
	ray.set_cast_to(lbottomrightspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self):
		bottomright = ray.get_collider()
		ray.get_collider().topleft = self
		ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .10)
	
	ray.set_cast_to(lrightspot)
	ray.force_raycast_update()
	if(ray.is_colliding() and ray.get_collider() != self):
		right = ray.get_collider()
		ray.get_collider().left = self
		ray.get_collider().set_opacity(ray.get_collider().get_opacity() - .10)
	

func CheckMatch(matchingorbs): #accepts array of kinematic bodies2d
	#this function checks all neighbors to see if any of them are the same colour
	#matching neighbors will check their neighbors and so on until there are no more matches
	#returns true if their are more than three orbs touching with the same colour
	
	var match = false
	matchingorbs.push_front(self)
	if(topleft != null):
		if(topleft.colour == self.colour):
			if(!matchingorbs.has(topleft)):
				topleft.CheckMatch(matchingorbs)
	if(topright != null):
			if(topright.colour == self.colour):
				if(!matchingorbs.has(topright)):
					topright.CheckMatch(matchingorbs)
	if(left != null):
		if(left.colour == self.colour):
			if(!matchingorbs.has(left)):
				left.CheckMatch(matchingorbs)
	if(right != null):
		if(right.colour == self.colour):
			if(!matchingorbs.has(right)):
				right.CheckMatch(matchingorbs)
	if(bottomleft != null):
		if(bottomleft.colour == self.colour):
			if(!matchingorbs.has(bottomleft)):
				bottomleft.CheckMatch(matchingorbs)
	if(bottomright != null):
		if(bottomright.colour == self.colour):
			if(!matchingorbs.has(bottomright)):
				bottomright.CheckMatch(matchingorbs)
				
	if(matchingorbs.size() >= 3):
		match = true
	return match



#the topmost orbs will neighbor an area that is in the group "top"
func LookForTop(var array): #will most likely take an array and return a boolean
	pass
	#var foundtop = false
	#array.add(self)
	#starting with the topmost neighbors 
	#if neighbor is not in group "top" and is not null and not in array
		#foundtop = neighbor.LookForTop(array)
		#if foundtop:
			#return foundtop
	#elif neighbor is in group 'top":
		#return true

func ActivateAbility():
	pass

func CountNeighbors():
	var count = 0
	if(topleft != null):
		count+=1
	if(topright != null):
		count+=1
	if(left != null):
		count+=1
	if(right != null):
		count+=1
	if(bottomleft != null):
		count+=1
	if(bottomright != null):
		count+=1
	return count