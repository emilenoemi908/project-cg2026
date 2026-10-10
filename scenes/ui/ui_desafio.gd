extends CanvasLayer

@onready var panel = $Panel
@onready var label_pergunta = $Panel/LabelPergunta
@onready var label_feedback = $Panel/LabelFeedback
@onready var botao_a = $Panel/BotaoA
@onready var botao_b = $Panel/BotaoB
@onready var botao_c = $Panel/BotaoC
@onready var som_certo = $SomCerto
@onready var som_errado = $SomErrado

var opcoes: Array = []
var respondido := false
var id_desafio := 0

func _ready():
	var largura = get_viewport().get_visible_rect().size.x
	panel.size = Vector2(560, 260)
	panel.position = Vector2((largura - 560) / 2.0, 20)
	label_pergunta.position = Vector2(20, 14)
	label_pergunta.size = Vector2(520, 110)
	label_pergunta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var botoes = [botao_a, botao_b, botao_c]
	for i in 3:
		botoes[i].position = Vector2(20 + i * 180, 140)
		botoes[i].size = Vector2(160, 54)
	label_feedback.position = Vector2(20, 206)
	label_feedback.size = Vector2(520, 48)
	label_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	panel.visible = false
	botao_a.pressed.connect(func(): _responder(0))
	botao_b.pressed.connect(func(): _responder(1))
	botao_c.pressed.connect(func(): _responder(2))
	GameManager.desafio_pronto.connect(_mostrar_desafio)

func _mostrar_desafio():
	id_desafio += 1
	respondido = false
	label_pergunta.text = GameManager.enunciado
	label_feedback.text = ""
	opcoes = GameManager.gerar_opcoes()
	botao_a.text = GameManager.texto_opcao(opcoes[0])
	botao_b.text = GameManager.texto_opcao(opcoes[1])
	botao_c.text = GameManager.texto_opcao(opcoes[2])
	panel.visible = true

func _responder(i: int):
	if respondido:
		return
	respondido = true
	if GameManager.verificar_resposta(opcoes[i]):
		label_feedback.text = "Certo! " + GameManager.explicacao
		som_certo.play()
	else:
		label_feedback.text = "Ainda não. " + GameManager.explicacao
		som_errado.play()

	var meu_id := id_desafio
	await get_tree().create_timer(3.0).timeout
	if meu_id == id_desafio:
		panel.visible = false
