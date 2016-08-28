extends Timer

onready var _ = get_parent()

func _init( time ):
	set_wait_time( time )
	
func _ready():
	start()
	
	yield( self, "timeout" )
	queue_free()