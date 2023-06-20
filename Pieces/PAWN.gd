extends "res://piece.gd"

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var capturable_en_passant = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if myColor == colors.BLACK:
		$Sprite.frame = 6


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func GetMoves(y: int, x: int) -> Array:
	moves = []

	var myRange = [1, 2] if !hasMoved else [1]
	
	if myColor == colors.WHITE:
		for moveForward in myRange:
			if !AddPawnMove(y - moveForward, x):
				break
		
		# captures
		AddPawnMove(y - 1, x - 1)
		AddPawnMove(y - 1, x + 1)
		
		if y == 3:
			AddEnPassant(y, x - 1)
			AddEnPassant(y, x + 1)
		
	elif myColor == colors.BLACK:
		
		for moveForward in myRange:
			if !AddPawnMove(y + moveForward, x):
				break
			
		# captures
		AddPawnMove(y + 1, x-1)
		AddPawnMove(y + 1, x+1)
		
		if y == 4:
			AddEnPassant(y, x - 1)
			AddEnPassant(y, x + 1)
			
	return moves
