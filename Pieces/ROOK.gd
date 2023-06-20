extends "res://piece.gd"

export var myRange: int = 8
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if myColor == colors.BLACK:
		$Sprite.frame = 7


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func GetMoves(y: int, x: int) -> Array:
	moves = []
	
	for left in myRange:
		if !AddMove(y, x-left-1):
			break
				
	for right in myRange:
		if !AddMove(y, x+right+1):
			break
		
	for down in myRange:
		if !AddMove(y+down+1, x):
			break
		
	for up in myRange:
		if !AddMove(y-up-1, x):
			break

	return moves
