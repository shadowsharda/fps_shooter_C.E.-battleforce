extends KinematicBody
var  capsuleshape
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const max_health:int=100
var health:int
export var speed:int=150
export var acceleration:int=5
var mouse_sensitivity:float=0.3
export var gravity:float=0.98

var velocity:Vector3=Vector3(0,0,0)
onready var head:Spatial=$head
#onready var camera:=$head/Camera
onready var heath_label:Label=$"/root/world/UI/health_label"
onready var player_standing_area_collision_shape:CollisionShape=$player_standing_area/CollisionShape
onready var player_crouching_area_collision_shape:CollisionShape=$player_crouching/CollisionShape
onready var head_spatial:Spatial=$head


#var camera_x_rotation:float=0
func _ready():
	#locks the mouse in the window
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player_crouching_area_collision_shape.set_deferred("disabled",true)
	player_standing_area_collision_shape.set_deferred("disabled",false)
	#setting collision shape radius by code
	#instead of setting manually
	capsuleshape=CapsuleShape.new()
	$CollisionShape.shape=capsuleshape
	$CollisionShape.shape.set_height(1.5)
	$CollisionShape.shape.set_radius(1.0)
	health=max_health
	heath_label.set_text(str(health))
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x*mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y*mouse_sensitivity))
		head.rotation.x= clamp(head.rotation.x,deg2rad(-90),deg2rad(90))
func _physics_process(delta):
	var head_basis=head.get_global_transform().basis
	var direction:Vector3=Vector3(0,0,0)
	if Input.is_action_pressed("move_forward"):
		direction=direction-head_basis.z
	if Input.is_action_pressed("move_backword"):
			direction=direction+head_basis.z
	if Input.is_action_pressed("move_left"):
		direction -=head_basis.x
	#if Input.is_action_just_pressed("reload"):
		#$head/Camera/weapon/tump_gun/AnimationPlayer.play("reload")
	if Input.is_action_pressed("move_right"):
			direction=direction+ head_basis.x
	if Input.is_action_pressed("aim_down_sight"):
		speed=100
	else:
		speed=250
	if Input.is_action_pressed("crouch"):
		#collision_shape_sie reduced by 50 percent_hardcoded
		#contacted me for soft code
		#$CollisionShape.shape=CapsuleShape.new()
		$CollisionShape.shape.set_height(0.75)
		player_standing_area_collision_shape.set_deferred("disabled",true)
		player_crouching_area_collision_shape.set_deferred("disabled",false)
		head_spatial.translation.y=0.5
	if Input.is_action_just_pressed("stand"):
		head_spatial.translation.y=1.0
		$CollisionShape.shape.set_height(1.5)
		player_standing_area_collision_shape.set_deferred("disabled",false)
		player_crouching_area_collision_shape.set_deferred("disabled",true)
	velocity.y=velocity.y-gravity
	direction=direction.normalized()
	velocity=velocity.linear_interpolate(direction*speed*delta,acceleration*delta)
	velocity=move_and_slide(velocity)
	
		
	#velocity= velocity+(direction*speed)
	#velocity=move_and_slide(velocity)
func take_damage(amount:int)->void:
	health = health-amount
	#emit_signal("health_changed",health)
	heath_label.set_text(str(health))
	health= int(clamp(health,0,max_health))
	if health==0:
		explode()
func explode()->void:
	pass
	#get_tree().reload_current_scene()
	#explosion code for player
