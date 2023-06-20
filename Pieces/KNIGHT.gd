extends "res://piece.gd"

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if myColor == colors.BLACK:
		$Sprite.frame = 8


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func GetMoves(y: int, x: int) -> Array:
	moves = []
	
	AddMove(y - 2, x - 1)
	AddMove(y - 2, x + 1)
	AddMove(y + 1, x - 2)
	AddMove(y - 1, x - 2)
	AddMove(y + 1, x + 2)
	AddMove(y - 1, x + 2)
	AddMove(y + 2, x + 1)
	AddMove(y + 2, x - 1)

	return moves
