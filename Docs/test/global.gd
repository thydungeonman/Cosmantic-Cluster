extends Node

func _ready():
	set_physics_process(true)
	

func _physics_process(delta):
	if(Input.is_action_pressed("ui_fullscreen")):
		OS.set_window_fullscreen(!OS.is_window_fullscreen())

