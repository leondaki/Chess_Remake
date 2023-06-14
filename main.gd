extends Node2D

# Declare member variables here. Examples:
var starting_fen = "R7/8/N7/8/2K5/8/8/b2qr3"
#var starting_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
var piece = preload("res://piece.tscn")
var move_indicator = load("res://move_indicator.tscn")
var attack_indicator = load("res://attack_indicator.tscn")

var height = 8
var width = 8

var board_data = []
var whites_turn = true

var black_moves = []
var white_moves = []

class Square:
	var x
	var y
	
	var piece
	var move_indicator
	
	var attack_indicator
	
	var canMoveHere = false
	
	var is_attacked_by_white = false
	var is_attacked_by_black = false
	
	func _init(_x: int, _y: int):
		x = _x
		y = _y

class Move:
	var piece_color
	var piece_type
	var start = []
	var destination = []
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# create empty board
	for y in height:
		board_data.append([])
		for x in width:
			board_data[y].append(Square.new(x, y))

			var indicator = move_indicator.instance()
			board_data[y][x].move_indicator = indicator
			
			indicator.position.x = x*64 + 32
			indicator.position.y = y*64 + 32
			
			indicator.visible = false
			add_child(indicator)
			
			
			var atk_indicator = attack_indicator.instance()
			board_data[y][x].attack_indicator = atk_indicator
			
			atk_indicator.position.x = x*64 + 16
			atk_indicator.position.y = y*64 + 16
			
			add_child(atk_indicator)
			
	# read the starting fen
	var i = 0
	var j = 0	
	for s in starting_fen:
		if s != "/" and !s.is_valid_integer():
			AddPiece(i, j, s == s.to_lower(), s)
			j += 1
			if j == width:
				j = 0
				i += 1
		elif s.is_valid_integer():
			j += int(s)
			if j == width:
				j = 0
				i += 1	
	
	
func AddPiece(i: int, j: int, isBlack: bool, type: String) -> void:
	var new_piece = piece.instance()

	board_data[i][j].piece = new_piece

	new_piece.position.x = j * 64 + 32
	new_piece.position.y = i * 64 + 32

	match type.to_upper():
		"P":
			new_piece.myType = new_piece.piece_types.PAWN
		"R":
			new_piece.myType = new_piece.piece_types.ROOK
		"N":
			new_piece.myType = new_piece.piece_types.KNIGHT
		"B":
			new_piece.myType = new_piece.piece_types.BISHOP
		"Q":
			new_piece.myType = new_piece.piece_types.QUEEN
		"K":
			new_piece.myType = new_piece.piece_types.KING
			
	if isBlack:
		new_piece.myColor = new_piece.colors.BLACK
	else:
		new_piece.myColor = new_piece.colors.WHITE
		
	add_child(new_piece)


func AssignAttackedSquares() -> void:
	for y in 8:
		for x in 8:
			board_data[y][x].is_attacked_by_black = false
			board_data[y][x].is_attacked_by_white = false

	for y in 8:
		for x in 8:
			var target_square = board_data[y][x]
			if target_square.piece != null:
				target_square.piece.GetLegalMoves(y, x, target_square.piece.myType)
		
	for y in 8:
		for x in 8:
			if board_data[y][x].is_attacked_by_white:
				 board_data[y][x].attack_indicator.get_child(0).visible = true
			if board_data[y][x].is_attacked_by_black:
				 board_data[y][x].attack_indicator.get_child(1).visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
