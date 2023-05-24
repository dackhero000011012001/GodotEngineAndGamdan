extends Node2D

enum {wait, move}
var state

signal end_turn

@export var width: int
@export var height: int
@export var x_start: int
@export var y_start: int
@export var offset: int
@export var y_offset: int



# Mang cac piece
var possible_pieces = [
	preload("res://Scenes/attack_piece.tscn"),
	preload("res://Scenes/critical_piece.tscn"),
	preload("res://Scenes/energy_piece.tscn"),
	preload("res://Scenes/repair_piece.tscn"),
	preload("res://Scenes/shield_piece.tscn")
]

# Nhung piece hien co trong scene
var all_pieces = []

# Trao nguoc
var piece_one = null
var piece_two = null
var last_place = Vector2(0, 0)
var last_direction = Vector2(0, 0)
var move_checked = false

# Chon piece
var first_touch = Vector2(0, 0)
var final_touch = Vector2(0, 0)
var controlling = false

func  _ready():
	state = move
	randomize()
	all_pieces = make_2d_array()
	spawn_pieces()



func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array
	
func spawn_pieces():
	for i in width:
		for j in height:
			var rand = floor(randf_range(0, possible_pieces.size()))
			var loops = 0
			var piece = possible_pieces[rand].instantiate()
			while (match_at(i, j, piece.type ) && loops <100):
				rand = floor(randf_range(0, possible_pieces.size()))
				loops += 1
				piece = possible_pieces[rand].instantiate()
			add_child(piece)
			piece.position = grid_to_pixel(i, j)
			all_pieces[i][j] = piece
			
func match_at(i, j, type):
	if i > 1:
		if all_pieces[i-1][j] != null && all_pieces[i-2][j] != null:
			if all_pieces[i-1][j].type == type && all_pieces[i-2][j].type == type:
				return true
	if j > 1:
		if all_pieces[i][j-1] != null && all_pieces[i][j-2] != null:
			if all_pieces[i][j-1].type == type && all_pieces[i][j-2].type == type:
				return true

	
func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y) 
	
func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x, new_y)

func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true
		return false
	
func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
#		first_touch = get_global_mouse_position()
#		var grid_position = pixel_to_grid(first_touch.x, first_touch.y)
##		print( grid_position)
#		if is_in_grid(grid_position.x, grid_position.y):
##			print("dc day")
#			controlling = true
#		else:
#			print("deo")
		if is_in_grid(pixel_to_grid( get_global_mouse_position().x,get_global_mouse_position().y)):
			first_touch = pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		final_touch = get_global_mouse_position()
#		var grid_position = pixel_to_grid(final_touch.x, final_touch.y)
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)) && controlling:
			controlling = false
			final_touch = pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)
			touch_difference(first_touch, final_touch)
			
	
func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null && other_piece != null:
		store_info(first_piece, other_piece, Vector2(column, row), direction)
		state = wait
		all_pieces[column][row] = other_piece
		all_pieces[column + direction.x][row + direction.y] = first_piece
		first_piece.drag(grid_to_pixel(column + direction.x, row + direction.y))
		other_piece.drag(grid_to_pixel(column, row))
		if !move_checked:
			find_matches()

func  store_info(first_piece, other_piece, place, direction):
	piece_one = first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction


func swap_back():
#	print("bruh")
	if piece_one != null && piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction)
	state = move 
	move_checked = false 


func  touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0))
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1,0))
	elif abs(difference.x) < abs(difference.y):		
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))

		
	
func find_matches():
	for i in width:
		for j in height:
			if !is_piece_null(i, j):
				var current_type = all_pieces[i][j].type
				if i > 0 && i < width - 1 :
					if !is_piece_null(i-1, j) && !is_piece_null(i+1, j):
						if all_pieces[i-1][j].type == current_type && all_pieces[i+1][j].type == current_type:
							match_and_dim(all_pieces[i-1][j])
							match_and_dim(all_pieces[i][j])
							match_and_dim(all_pieces[i+1][j])
				if j > 0 && j < height - 1:
					if !is_piece_null(i, j-1) && !is_piece_null(i, j+1):
						if all_pieces[i][j-1].type == current_type && all_pieces[i][j+1].type == current_type:
							match_and_dim(all_pieces[i][j-1])
							match_and_dim(all_pieces[i][j])
							match_and_dim(all_pieces[i][j+1])
	get_parent().get_node("destroy_time").start()

func is_piece_null(column, row):
	if all_pieces[column][row] == null:
		return true
	return false

func match_and_dim(item):
	item.matched = true
	item.dim()

func _process(delta):
	if state == move:
		touch_input()


func destroy_matched():
	var was_matched = false
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					was_matched = true
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
	move_checked = true
	if was_matched:
		get_parent().get_node("collapse_time").start()
	else :
		swap_back()
	
func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].drag(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node("refill_time").start()

func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				var rand = floor(randf_range(0, possible_pieces.size()))
				var loops = 0
				var piece = possible_pieces[rand].instantiate()
				while (match_at(i, j, piece.type ) && loops <100):
					rand = floor(randf_range(0, possible_pieces.size()))
					loops += 1
					piece = possible_pieces[rand].instantiate()
				add_child(piece)
				piece.position = grid_to_pixel(i, j + y_offset)
				piece.drag(grid_to_pixel(i, j))
				all_pieces[i][j] = piece
	after_refill()
				
func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].type):
					find_matches()
					get_parent().get_node("destroy_time").start()
					return
	state = move
	move_checked = false
	end_turn.emit()

func _on_destroy_time_timeout():
	destroy_matched()


func _on_collapse_time_timeout():
	collapse_columns()


func _on_refill_time_timeout():
	refill_columns()
