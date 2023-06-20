extends "res://piece.gd"

export var myRange: int = 1
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if myColor == colors.BLACK:
		$Sprite.frame = 11


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func GetMoves(y: int, x: int) -> Array:
	moves = []
	
	# rook moves
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
			
	#bishop moves
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

	if !hasMoved and x == 4:
		AddCastleMove(y, x, false)
		AddCastleMove(y, x, true)
		
	return moves
