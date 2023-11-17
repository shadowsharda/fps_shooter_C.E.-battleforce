extends KinematicBody
var target
#variable will get current world node

var health:int
const max_health:int=100

export var speed:int=3
const look_sen:float=1.0
var movevel:Vector3=Vector3(0,0,0)
onready var position3d_barrel:Position3D=$MeshInstance2/barrel
onready var aiming_activator_area:CollisionShape=$enemy_aiming_area/CollisionShape
const bullet= preload ("res://bullets/lmg_bullets/unsilenced_lmg_bullets/lmg v1_unsilenced_bullet/lmgV1_bullet/lmgV1_unsilenced_bullet.tscn")
func _ready():
	health=max_health
	#aiming is set to off at intitial
	aiming_activator_area.set_deferred("disabled",true)


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		#target=body
		#print(body.name +"entered")
		#$fire_Timer.start()
		#set_color_red()
		aiming_activator_area.set_deferred("disabled",false)
func take_damage(amount:int)->void:
	health = health-amount
	#emit_signal("health_changed",health)
	#heath_label.set_text(str(health))
	health= int(clamp(health,0,max_health))
	if health==0:
		explode()
func explode()->void:
	queue_free()


func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		aiming_activator_area.set_deferred("disabled",true)
		#print(body.name+"exited")
		#target=null
		#$fire_Timer.stop()
		#set_color_green()
func set_color_red()->void:
	$body.get_surface_material(0).set_albedo(Color(1,0,0))
func set_color_green()->void:
	$body.get_surface_material(0).set_albedo(Color(0,1,0))
func _physics_process(delta):
	if target:
		movevel=(target.global_transform.origin-self.global_transform.origin).normalized()
		movevel=movevel.normalized()
		self.rotation.y=lerp_angle(rotation.y,atan2(-movevel.x,-movevel.z),delta*look_sen)
		#cast a ray_cast toards the player
		#if result.collider.is_in_group("Player"):
			#movevel=global_transform.origin.linear_interpolate(target.global_transform.origin,look_sen*delta)
			#movevel=movevel.normalized()
			#look_at(target.global_transform.origin,Vector3.UP)
			#look_at(global_transform.origin.linear_interpolate(target.global_transform.origin,0.1*delta),Vector3.UP)
			#look_at(movevel,Vector3.UP)
		move_to_target(delta)
			
			
		set_color_red()
	else:
		set_color_green()
func move_to_target(delta)->void:
	var velocity:Vector3
	var direction:Vector3=(target.transform.origin-transform.origin).normalized()
	velocity=direction*speed*delta
	velocity.y=velocity.y-0.5
	velocity=move_and_slide(velocity,Vector3(0,1,0))


func _on_fire_Timer_timeout():
	print("bullet_fired")
	var bull=bullet.instance()
	
	#bull.translation=$MeshInstance2/barrel.global_transform.origin
	#bull.rotation=rotation
	
	#add_child(bull)
	bull.rotation_degrees=position3d_barrel.global_transform.basis.get_euler()
	position3d_barrel.add_child(bull)
	


func _on_enemy_aiming_area_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		target=body
		print(body.name +"entered")
		$fire_Timer.start()
		#set_color_red()


func _on_enemy_aiming_area_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		print(body.name+"exited")
		target=null
		$fire_Timer.stop()
		#set_color_green()


func _on_bullet_hit_area_area_entered(area: Area) -> void:
	if area.is_in_group("bullet"):
		aiming_activator_area.set_deferred("disabled",false)
