extends Weapon


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var fire_range:int

# Called when the node enters the scene tree for the first time.
func _ready():
	 raycast.cast_to= Vector3(0,0,-fire_range)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
