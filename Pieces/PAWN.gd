extends "res://piece.gd"

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var capturable_en_passant = true

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

func AddPawnMove(y: int, x: int) -> bool:
	if (y >= 0 and y < 8 and x >= 0 and x < 8):	
		var target_square = get_node("/root/Board").board_data[y][x]
			
		if x != start_x:			
			SetAttackedSquare(y, x)	
			
			if target_square.piece != null:
				if target_square.piece.myColor != myColor:			
					moves.append([y, x])
				
		elif x == start_x and target_square.piece == null:
			moves.append([y, x])
		elif x == start_x and target_square.piece != null:
			return false
		
	else:
		return false

	return true

func AddEnPassant(y: int, x: int) -> bool:
	if (y >= 0 and y < 8 and x >= 0 and x < 8):	
		var target_square = get_node("/root/Board").board_data[y][x]
		
		if target_square.piece != null:
			if target_square.piece.piece_type == piece_types.PAWN and target_square.piece.capturable_en_passant:
				moves.append([y-1, x]) if myColor == colors.WHITE else moves.append([y+1, x])
	else:		
		return false
			
	return true
