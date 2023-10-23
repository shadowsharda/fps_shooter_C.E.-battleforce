extends Spatial
const clipsize:int=60
onready var parent =get_parent()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var defult_position:Vector3=Vector3(0.554,-0.188,0.157)
export var aim_down_sight_position:Vector3=Vector3(0.517,-0.188,0)
onready var smgv1_bullet=preload("res://bullets/smg/tmp_smg/smgv1_bullet.tscn")
onready var ammo_label:Label=$"/root/world/UI/Label"
onready var head:Spatial=$"/root/world/newplayer/head"
onready var fire_rate_timer:Timer=$firerate_timer
onready var camera:Camera=$"/root/world/newplayer/head/Camera"
#var canfire:bool=true
#onready var damage_label:Label=$"/root/world/UI/damage_label"
export var camera_defult_fov:int=70
export var camera_ads_fov:int=40
export var ads_acceleration:float=0.3
export var reload_rate:float=2
var current_ammo:int=0
var reloading:bool=false
var is_aiming_down_sight:bool=false


# Called when the node enters the scene tree for the first time.
func _ready():
	#set_process(false)
	#if parent is Node:
		#set_process(true)
	transform.origin=defult_position
	current_ammo=clipsize
	set_process(true)
func _process(_delta):
	if parent is Spatial:
		if reloading==true:
			ammo_label.set_text("RELOADING")
		else:
			ammo_label.set_text("%d/%d" % [current_ammo,clipsize])
		if Input.is_action_just_pressed("primary_fire"):
			if current_ammo>0&&reloading==false: 
			
				var b=smgv1_bullet.instance()
				b.rotation_degrees=head.global_transform.basis.get_euler()
				if is_aiming_down_sight==true:
					b.ads=true
				if is_aiming_down_sight==false:
					b.ads=false
				b.mesh_instance_visible=false
				head.add_child(b)
				current_ammo=current_ammo-1
				fire_rate_timer.start()
			else:
				if reloading==false:
					reload()
				
		if Input.is_action_just_released("primary_fire"):
			fire_rate_timer.stop()
		if Input.is_action_just_pressed("reload"):
			reload()
		if Input.is_action_pressed("aim_down_sight"):
			#is_aiming_down_sight=false
			transform.origin=transform.origin.linear_interpolate(aim_down_sight_position,ads_acceleration)
			camera.fov=lerp(camera.fov,camera_ads_fov,ads_acceleration)
			is_aiming_down_sight=true
		else:
			#is_aiming_down_sight=true
			transform.origin=transform.origin.linear_interpolate(defult_position,ads_acceleration)
			camera.fov=lerp(camera.fov,camera_defult_fov,ads_acceleration)
			is_aiming_down_sight=false
	else:
		set_process(false)


func _on_firerate_timer_timeout():
	if current_ammo>0&&reloading==false:
		var b=smgv1_bullet.instance()
		b.rotation_degrees=head.global_transform.basis.get_euler()
		b.mesh_instance_visible=false
		current_ammo=current_ammo-1
		head.rotation.x =head.rotation.x+deg2rad(0.125)
		if is_aiming_down_sight==true:
			b.ads=true
		if is_aiming_down_sight==false:
			b.ads=false
		#damage_label.set_text(str(b.current_damage))
		head.add_child(b)
func reload()->void:
	print("RELOADING")
	$AnimationPlayer.play("reload")
	#canfire=false
	reloading=true 
	yield(get_tree().create_timer(reload_rate),"timeout")
	current_ammo=clipsize
	reloading=false
	#canfire=true
	print("RELOAD COMPLETE")
