

extends Area
class_name lmgv1_unsilenced_bullet


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ads:bool=false
const bulletspeed:int=50
var distance:float
var current_damage:int=5
const apply_damage:int=14
const ads_off_damage:int=5
var mesh_instance_visible:bool=true
onready var damage_label:Label=$"/root/world/UI/damage_label"

onready var mesh_instance=$MeshInstance
onready var timer:Timer=$Timer
onready var unsilenced_area_collision_shape:CollisionShape=$unsilenced_area/CollisionShape


# Called when the node enters the scene tree for the first time.
func _ready():
	distance=0
	set_as_toplevel(true) 
	timer.start()
	unsilenced_area_collision_shape.set_deferred("disabled",false)
# warning-ignore:return_value_discarded
	timer.connect("timeout",self,"_on_Timer_timeout")
	#current_damage=ads_off_damage

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _process(delta):

	if ads==true:
		current_damage=apply_damage
	
	if ads==false:
		#print("ads_false")
		current_damage=ads_off_damage
	if mesh_instance_visible==false:
		mesh_instance.visible=false
	else:
		mesh_instance.visible=true
	
	#var rot=Vector3(bulletspeed,0,0).rotated(Vector3(1,0,0),rotation.x)
	#var rot_z=Vector3(0,0,bulletspeed).rotated(Vector3(0,0,1),rotation.z)
	#global_transform.basis.z=global_transform.basis.z*object
	#translate( object.rotated(Vector3(0,0,1),rotation))
	translation=translation-(transform.basis.z*bulletspeed*delta)

	




func _on_Timer_timeout():
	print("bullet_timeout")
	queue_free()


func _on_smgv1_body_entered(_body):
	print("bullet_deleted")
	queue_free()


#func _on_smgv1_body_exited(_body):







func _on_bullet_body_entered(body: Node) -> void:
	print("bullet_deleted")
	if body.has_method('take_damage'):
		body.take_damage(current_damage)
	queue_free()

func _on_bullet_body_exited(body: Node) -> void:
	print("bullet_deleted")
	if body.has_method('take_damage'):
		body.take_damage(current_damage)
	queue_free()
