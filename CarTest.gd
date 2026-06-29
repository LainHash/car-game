extends Node3D


@onready var Ball = $Ball
@onready var Car = $Car
@onready var RightWheel = $"Car/Model/wheel-front-right"
@onready var LeftWheel = $"Car/Model/wheel-front-left"
@onready var CarBody = $"Car/Model/body"
@onready var DriftTimer = $DriftTimer
@onready var BoostTimer = $BoostTimer
@onready var Anim = $AnimationPlayer

var acceleration = 70.0
var steering = 12.0
var turn_speed = 5
var body_tilt = 30

var speed_input = 0
var rotate_input = 0

var Drifting = false
var DriftDirection = 0
var MinimumDrift = false
var Boost = 1
var DriftBoost = 1.75

func _physics_process(_delta):
	Car.transform.origin = Ball.transform.origin
	Ball.apply_central_force(-Car.global_transform.basis.z * speed_input * Boost)
	
func _process(delta):
	speed_input = (Input.get_action_strength("Accelerate") - Input.get_action_strength("Brake")) * acceleration
	rotate_input = deg_to_rad(steering) * (Input.get_action_strength("SteerLeft") - Input.get_action_strength("SteerRight"))
	RightWheel.rotation.y = rotate_input
	LeftWheel.rotation.y = rotate_input
	
	if Input.is_action_just_pressed("Drift") and not Drifting and rotate_input != 0 and speed_input > 0:
		StartDrift()
	
	if Drifting:
		var DriftAmount = 0
		DriftAmount += Input.get_action_strength("SteerLeft") - Input.get_action_strength("SteerRight")
		DriftAmount *= deg_to_rad(steering * 0.55)
		rotate_input = DriftDirection * DriftAmount
		
	if Drifting and (Input.is_action_just_pressed("Drift") or speed_input < 1):
		StopDrift()
	
	if Ball.linear_velocity.length() > 0.75:
		RotateCar(delta)
	
func RotateCar(delta):
	var new_basis = Car.global_transform.basis.rotated(Car.global_transform.basis.y, rotate_input)
	Car.global_transform.basis = Car.global_transform.basis.slerp(new_basis, turn_speed * delta)
	Car.global_transform = Car.global_transform.orthonormalized()
	var t = -rotate_input * Ball.linear_velocity.length() / body_tilt
	CarBody.rotation.z = lerp(CarBody.rotation.z, t, 10 * delta)

func StartDrift():
	Drifting = true
	Anim.play("Hop")
	MinimumDrift = false
	DriftDirection = rotate_input
	DriftTimer.start()


func StopDrift():
	if MinimumDrift:
		Boost = DriftBoost
		BoostTimer.start()
		Anim.play("ZoomOut")
	Drifting = false
	MinimumDrift = false


func _on_drift_timer_timeout() -> void:
	if Drifting:
		MinimumDrift = true


func _on_boost_timer_timeout() -> void:
	Boost = 1.0
	Anim.play("ZoomIn")
