extends CharacterBody3D

@export var spring_arm_3d: SpringArm3D
@export var animation_tree: AnimationTree

var mouse_sensitivity := 0.003
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animation_tree.active = true

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		if spring_arm_3d:
			spring_arm_3d.rotate_x(-event.relative.y * mouse_sensitivity)
			spring_arm_3d.rotation.x = clamp(spring_arm_3d.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	_update_animation_state()

func _update_animation_state() -> void:
	var playback = animation_tree.get("parameters/playback")

	if not is_on_floor():
		playback.travel("jump_lib_jump")
	elif Vector2(velocity.x, velocity.z).length() > 0.1:
		playback.travel("walk_lib_walk")
	else:
		playback.travel("mixamo_com")
