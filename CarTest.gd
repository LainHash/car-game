extends Node3D


@onready var Ball = $Ball
@onready var Car = $Car
@onready var RightWheel = $"Car/Model/wheel-front-right"
@onready var LeftWheel = $"Car/Model/wheel-front-left"
@onready var CarBody = $"Car/Model/body"

var acceleration = 70.0
var steering = 12.0
var turn_speed = 5
var body_tilt = 30

var speed_input = 0
var rotate_input = 0

var Drifting = false
var DriftingDirection = 0
var MinimumDrift = false
var Boost = 1
var DriftBoost = 1.75

func _physics_process(_delta):
	Car.transform.origin = Ball.transform.origin
	Ball.apply_central_force(-Car.global_transform.basis.z * speed_input)
	
func _process(delta):
	speed_input = (Input.get_action_strength("Accelerate") - Input.get_action_strength("Brake")) * acceleration
	rotate_input = deg_to_rad(steering) * (Input.get_action_strength("SteerLeft") - Input.get_action_strength("SteerRight"))
	RightWheel.rotation.y = rotate_input
	LeftWheel.rotation.y = rotate_input
	
	if Ball.linear_velocity.length() > 0.75:
		RotateCar(delta)
	
func RotateCar(delta):
	var new_basis = Car.global_transform.basis.rotated(Car.global_transform.basis.y, rotate_input)
	Car.global_transform.basis = Car.global_transform.basis.slerp(new_basis, turn_speed * delta)
	Car.global_transform = Car.global_transform.orthonormalized()
	var t = -rotate_input * Ball.linear_velocity.length() / body_tilt
	CarBody.rotation.z = lerp(CarBody.rotation.z, t, 10 * delta)
