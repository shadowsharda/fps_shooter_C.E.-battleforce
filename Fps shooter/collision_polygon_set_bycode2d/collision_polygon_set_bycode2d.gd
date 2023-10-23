extends Area2D
var code_generated_polygon_shape:PoolVector2Array
onready var collision_polygon=$CollisionPolygon2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#collision_polygon.set_polygon(PoolVector2Array())
	collision_polygon.set_polygon(code_generated_polygon_shape)
	code_generated_polygon_shape=PoolVector2Array()
	#code_generated_polygon_shape.set(3,Vector2())
	code_generated_polygon_shape.size()
	code_generated_polygon_shape.insert(1,Vector2())
	if code_generated_polygon_shape.empty()==true:
		print("empty")
		print(str(code_generated_polygon_shape.size()))
	#code_generated_polygon_shape=PoolVector2Array.resize(3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
