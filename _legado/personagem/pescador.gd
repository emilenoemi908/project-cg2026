extends CharacterBody2D

const VELOCIDADE = 200.0

@onready var visual_rede = $visualRede
@onready var colisao_rede = $areaPesca/CollisionShape2D
@onready var som_lancar = $SomLancar
@onready var som_pescar = $SomPescar
@onready var area_pesca = $areaPesca

var rede_lancada = false

func _ready():
	visual_rede.visible = false
	colisao_rede.disabled = true
	area_pesca.area_entered.connect(_ao_pescar)

func _ao_pescar(area):
	som_pescar.play()

func _physics_process(_delta):
	var direcao_x = Input.get_axis("ui_left", "ui_right")
	velocity = Vector2(direcao_x * VELOCIDADE, 0)
	move_and_slide()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if rede_lancada:
			recolher_rede()
		else:
			lancar_rede()

func lancar_rede():
	rede_lancada = true
	colisao_rede.disabled = false
	som_lancar.play()

	visual_rede.visible = true
	visual_rede.scale = Vector2(0.1, 0.1)
	visual_rede.rotation = deg_to_rad(-15)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(visual_rede, "scale", Vector2(0.6, 0.6), 0.4)
	tween.tween_property(visual_rede, "rotation", 0.0, 0.4)

func recolher_rede():
	rede_lancada = false
	colisao_rede.disabled = true
	GameManager.finalizar_pescaria()

	var tween = create_tween()
	tween.tween_property(visual_rede, "scale", Vector2(0.1, 0.1), 0.3)
	tween.tween_callback(func(): visual_rede.visible = false)
