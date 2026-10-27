#Base Tetris logic adapted from video: 
#Title: Beginner Godot Tutorial - How to Make Tetris
#Author: Coding With Russ
#Date: Nov 5, 2023
#URL: https://youtu.be/2T2Fkzwf6FM?si=EsoPkz0qBYQ7HkaJ

extends Node2D

# === Signals === (snake_case)

# === Enums === (PascalCase, members CONSTANT_CASE)

# === Constants === (CONSTANT_CASE)
#Grid size variables
const COLS : int = 10;
const ROWS : int = 20;

# === Exported Vars === (snake_case)

# === Public Vars === (snake_case)
#The grid is layered as the board in the background and the active piece layer drawn on top of it
@onready var board_layer: TileMapLayer = $BoardLayer
@onready var active_layer: TileMapLayer = $ActiveLayer

#The Teris grid uses a tilemap, then draws the pieces onto the grid as they drop. This simplifies collision and
#objects but does require that every piece be mapped out on a small grid. Think of it as a "memory" of shapes and
#their rotations that the grid can draw on to the tilemap. Each array represents a rotation of a particular 
#tetromino, and each point in the array represents a vector that contains ann X and Y point. The last array for
#each section collects all the rotation of a particular tetromino letter/shape.

#I/Line Tetromino
var i_0 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
var i_90 := [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]
var i_180 := [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)]
var i_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]
var i := [i_0, i_90, i_180, i_270]

#T Tetromino
var t_0 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var t_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var t := [t_0, t_90, t_180, t_270]

#O/Square Tetromino
var o_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_90 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_180 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o := [o_0, o_90, o_180, o_270]

#Z Tetromino
var z_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
var z_90 := [Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var z_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var z_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
var z := [z_0, z_90, z_180, z_270]

#S Tetromino
var s_0 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
var s_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var s_180 := [Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)]
var s_270 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var s := [s_0, s_90, s_180, s_270]

#L Tetromino
var l_0 := [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var l_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var l_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)]
var l_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
var l := [l_0, l_90, l_180, l_270]

#J Tetromino
var j_0 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var j_90 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)]
var j_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var j_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
var j := [j_0, j_90, j_180, j_270]

#This shapes array colects all of the different tetrominoes into one array, with each element being the array that
#collects every rotation for the specific shape
var shapes := [i, t, o, z, s, l, j]

#Variables that define what type o piece the current active one is, and what type of piece the next one will be
var piece_type
var next_piece_type

#Variables that track the current game piece object. piece_type simply defined what the current piece is in a simple
#variable that is easy to access, while active_piece contains all the relevant information for drawing it onto the 
#grid. rotation_index keeps track of the active_piece's current rotation
var active_piece : Array
var rotation_index : int = 0

#Provides the ID of the tileset that is used for drawing the Tetrominoes, referred to as the atlas in functions
var tile_id : int = 0

#Provides an index from the tilest that corresponds to the current and next Tetromino being dropped
var piece_atlas : Vector2i
var next_piece_atlas : Vector2i

# === Private Vars === (_underscored_snake_case)

# === Godot Methods ===

func  _ready() -> void:
	pass

func _process(_delta):
	draw_piece(j[0], Vector2i(5, 1), Vector2i(1, 0))

#This function is used to draw the pieces onto the grid. The first argument it takes is any tetromino as piece, which
#contains the coordinates for how the piece should be drawn onto the grid at any given rotation. The second argument
#is a vector which determines which position on the grid it should start drawing the piece. The last argument is the
#coordinates on the tetromino atlas for the color desired
func draw_piece(piece, pos, atlas):
	#Iterates through the coordinates of the piece fed to the function
	for x in piece:
		#For each coordinate iteration a colored tile is drawn onto the position using the tetromino atlas and the
		#piece position, which is adjusted based on the local coordinates of the individual piece shape
		active_layer.set_cell(pos + x, tile_id, atlas)

# === Further Methods === (public snake_case, private _underscored_snake_case, local vars snake_case)
