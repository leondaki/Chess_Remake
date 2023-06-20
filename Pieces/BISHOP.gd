extends "res://piece.gd"

export var myRange: int = 8
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if myColor == colors.BLACK:
		$Sprite.frame = 9


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func GetMoves(y: int, x: int) -> Array:
	moves = []
	
	for upRight in myRange :
		if !AddMove(y-upRight-1, x+upRight+1):
			break

	for upLeft in myRange :
		if !AddMove(y-upLeft-1, x-upLeft-1):
			break

	for downRight in myRange:
		if !AddMove(y+downRight+1, x+downRight+1):
			break

	for downLeft in myRange :
		if !AddMove(y+downLeft+1, x-downLeft-1):
			break

	return moves
