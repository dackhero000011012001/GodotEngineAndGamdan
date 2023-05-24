extends Node2D

# Point
@export var critical_point = 20
@export var energy_point = 20
@export var repair_point = 5
@export var damage_reduce = 5

# Giatri Ingame
var current_robot_health = 0
var current_robot_energy = 0
var current_robot_critical = 0
var current_enemy_health = 0

#
@onready var robot_attack = get_node("AnimationPlayer")

func _ready():
	set_energy($Robot/energy_bar/TextureProgressBar, Robot.current_energy, Robot.max_energy)
	set_critical($Robot/critical_bar/TextureProgressBar, Robot.current_critical, Robot.max_critical)  
	if $Robot/health_bar/TextureProgressBar2.max_value <= Robot.current_health:
		set_health($Robot/health_bar/TextureProgressBar2,  $Robot/health_bar/TextureProgressBar2.max_value,  $Robot/health_bar/TextureProgressBar2.max_value)
	else:
		set_health($Robot/health_bar/TextureProgressBar2,  Robot.current_health,  $Robot/health_bar/TextureProgressBar2.max_value)
	set_health($Robot/health_bar/TextureProgressBar, Robot.current_health , Robot.current_health)
	if $Enemy/health_bar/TextureProgressBar.max_value <= Enemy.current_health:
		set_health($Enemy/health_bar/TextureProgressBar,  $Enemy/health_bar/TextureProgressBar.max_value,  $Enemy/health_bar/TextureProgressBar.max_value)
	else:
		set_health($Enemy/health_bar/TextureProgressBar,  Enemy.current_health,  $Enemy/health_bar/TextureProgressBar.max_value)
	set_health($Enemy/health_bar/TextureProgressBar2, Enemy.current_health, Enemy.current_health)
	
	current_robot_health = Robot.current_health
	current_enemy_health = Enemy.max_health

func set_energy(progress_bar, energy, max_energy):
	progress_bar.value = energy
	progress_bar.max_value = max_energy
	progress_bar.get_node("Label").text = "%d/%d" % [energy, max_energy]
	
func set_critical(progress_bar, critical, max_critical):
	progress_bar.value = critical
	progress_bar.max_value = max_critical
	progress_bar.get_node("Label").text = "%d/%d" % [critical, max_critical]
	
func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health

func _on_grid_end_turn():
	var robot_dmg = randf_range(int(((1 + Robot.damage)/4)*3) , Robot.damage)
	if robot_dmg > Enemy.max_defence:
		$AnimationPlayer.play("robot_attack")
		await $AnimationPlayer.animation_finished
		current_enemy_health = max(0, current_enemy_health - robot_dmg)
		if $Enemy/health_bar/TextureProgressBar.max_value <= current_enemy_health:
			set_health($Enemy/health_bar/TextureProgressBar,  $Enemy/health_bar/TextureProgressBar.max_value,  $Enemy/health_bar/TextureProgressBar.max_value)
		else:
			set_health($Enemy/health_bar/TextureProgressBar,  current_enemy_health,  $Enemy/health_bar/TextureProgressBar.max_value)
		set_health($Enemy/health_bar/TextureProgressBar2, current_enemy_health, Enemy.max_health)
		$AnimationPlayer.play("enemy_damaged")
		await  $AnimationPlayer.animation_finished
	else :
		$AnimationPlayer.play("enemy_shield_on")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("robot_attack")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("enemy_shield_off")          
		await $AnimationPlayer.animation_finished
		
	if current_robot_health < Robot.max_health:
		current_robot_health = max(0, current_robot_health + repair_point)
		if $Robot/health_bar/TextureProgressBar2.max_value <= current_robot_health:
			set_health($Robot/health_bar/TextureProgressBar2,  $Robot/health_bar/TextureProgressBar2.max_value,  $Robot/health_bar/TextureProgressBar2.max_value)
		else:
			set_health($Robot/health_bar/TextureProgressBar2,  current_robot_health,  $Robot/health_bar/TextureProgressBar2.max_value)
		set_health($Robot/health_bar/TextureProgressBar, current_robot_health , Robot.max_health)
	if current_robot_energy < Robot.max_energy:
		current_robot_energy = max(0, current_robot_energy + energy_point)
	if current_robot_critical < Robot.max_critical:	
		current_robot_critical = max(0, current_robot_critical + critical_point)
	set_energy($Robot/energy_bar/TextureProgressBar, current_robot_energy, Robot.max_energy)
	set_critical($Robot/critical_bar/TextureProgressBar, current_robot_critical, Robot.max_critical)  
#	$AnimationPlayer.stop(true)
	if current_enemy_health == 0:
		$AnimationPlayer.play("enemy_died")
		await  $AnimationPlayer.animation_finished
		await  get_tree().create_timer(0.25).timeout
		get_tree().quit()
	get_node("change_time").start()
	
func enemy_turn():
#	var enemy_dmg = Enemy.damage
	var enemy_dmg = randf_range(int(((1 + Enemy.damage)/4)*3) , Enemy.damage)
	
	if enemy_dmg > Robot.max_defence:
		$AnimationPlayer.play("enemy_attack")
		await $AnimationPlayer.animation_finished
		current_robot_health = max(0, current_robot_health - enemy_dmg)
		if $Robot/health_bar/TextureProgressBar2.max_value <= current_robot_health:
			set_health($Robot/health_bar/TextureProgressBar2,  $Robot/health_bar/TextureProgressBar2.max_value,  $Robot/health_bar/TextureProgressBar2.max_value)
		else:
			set_health($Robot/health_bar/TextureProgressBar2,  current_robot_health,  $Robot/health_bar/TextureProgressBar2.max_value)
		set_health($Robot/health_bar/TextureProgressBar, current_robot_health , Robot.max_health)
	else:
		$AnimationPlayer.play("robot_shield_on")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("enemy_attack")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("robot_shield_off")
		await $AnimationPlayer.animation_finished
		
	get_node("robot_turn")

func _on_change_time_timeout():
	enemy_turn()



func _on_robot_turn_timeout():
	_on_grid_end_turn()
