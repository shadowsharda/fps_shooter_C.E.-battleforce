extends KinematicBody



# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var speed:int=5000
export var acceleration:int=5
var mouse_sensitivity:float=0.3
#export var gravity:float=0.98
#export var jump_power:int=30
var velocity:Vector3=Vector3()
onready var head:Spatial=$head
onready var camera:Camera=$head/Camera

var camera_x_rotation:float=0
func _ready():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
# Called when the node enters the scene tree for the first time. # Replace with function body.

func _input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(deg2rad(-event.relative.x*mouse_sensitivity))
		#head.rotate_x(deg2rad(-event.relative.y*mouse_sensitivity))
		var x_delta=event.relative.y*mouse_sensitivity
		if camera_x_rotation+x_delta>-90 && camera_x_rotation+x_delta<90:
			camera.rotate_x(deg2rad(-x_delta))
			camera_x_rotation+=x_delta
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var head_basis=head.get_global_transform().basis
	var direction:Vector3=Vector3()
	if Input.is_action_pressed("move_forward"):
		direction-=head_basis.z
	elif Input.is_action_pressed("move_backword"):
		direction+=head_basis.z
	if Input.is_action_pressed("move_left"):
		direction -=head_basis.x
	elif Input.is_action_pressed("move_right"):
		direction=direction+ head_basis.x
	#velocity.y-=gravity
	velocity=velocity.linear_interpolate(direction*speed,acceleration*delta)
	
	velocity=move_and_slide(velocity)
		
