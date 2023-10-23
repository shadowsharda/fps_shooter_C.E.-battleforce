extends Spatial
class_name Weapon

export var firerate_interval:float=0.1
export var clipsize:int=50
export var reload_rate:float=2
var current_ammo:int=0
export var defult_position:Vector3=Vector3(0.554,-0.188,0.157)
export var aim_down_sight_position:Vector3=Vector3(0.517,-0.188,0)
export var ads_acceleration:float=0.3
export var camera_defult_fov:int=70
export var camera_ads_fov:int=40
#preload raycast for collision detection with enemies and eviroment 
onready var raycast:RayCast =$"/root/world/newplayer/head/Camera/RayCast"
onready var ammo_label:Label=$"/root/world/UI/Label"
onready var camera:Camera=$"/root/world/newplayer/head/Camera"
var canfire:bool=true
var reloading:bool=false
func _ready():
	#raycast=get_node(raycastpath)
	current_ammo=clipsize
func _process(_delta):
	if reloading==true:
		ammo_label.set_text("RELOADING")
	else:
		ammo_label.set_text("%d/%d" % [current_ammo,clipsize])
	#for weapon firing
	if Input.is_action_pressed("primary_fire")&&canfire==true:
		if current_ammo>0&&reloading==false:
			shoot()

		else:
			if reloading==false:
				reload()
	if Input.is_action_just_pressed("reload"):
		reload()
	if Input.is_action_pressed("aim_down_sight"):
		transform.origin=transform.origin.linear_interpolate(aim_down_sight_position,ads_acceleration)
		camera.fov=lerp(camera.fov,camera_ads_fov,ads_acceleration)
	else:
		transform.origin=transform.origin.linear_interpolate(defult_position,ads_acceleration)
		camera.fov=lerp(camera.fov,camera_defult_fov,ads_acceleration)
func shoot()->void:
	canfire=false
	print("fired weapon")
	check_collision()
	current_ammo=current_ammo-1
	#pauses the code till the fire rate interval passed
	yield(get_tree().create_timer(firerate_interval),"timeout")
	canfire=true
	

func check_collision()->void:
	print("check_collision_called")
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group("enemies"):
			collider.queue_free()
			print("enemies ELIMINATED")
func reload()->void:
	print("RELOADING")
	$AnimationPlayer.play("reload")
	canfire=false
	reloading=true 
	yield(get_tree().create_timer(reload_rate),"timeout")
	current_ammo=clipsize
	reloading=false
	canfire=true
	print("RELOAD COMPLETE")
