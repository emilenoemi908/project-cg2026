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
	visual_rede.visible = true
	colisao_rede.disabled = false
	som_lancar.play()

func recolher_rede():
	rede_lancada = false
	visual_rede.visible = false
	colisao_rede.disabled = true
	GameManager.finalizar_pescaria()
