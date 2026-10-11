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
const TEMPO_FEEDBACK := 1.2

func _ready():
	
	if get_tree().get_nodes_in_group("ui_desafio").size() > 0:
		queue_free()
		return
	add_to_group("ui_desafio")

	var largura = get_viewport().get_visible_rect().size.x
	var larg_painel := 470.0
	panel.size = Vector2(larg_painel, 196)
	panel.position = Vector2(max((largura - larg_painel) / 2.0, 352.0), 16)
	label_pergunta.position = Vector2(16, 10)
	label_pergunta.size = Vector2(438, 78)
	label_pergunta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var botoes = [botao_a, botao_b, botao_c]
	for i in 3:
		botoes[i].position = Vector2(16 + i * 150, 94)
		botoes[i].size = Vector2(138, 44)
	label_feedback.position = Vector2(16, 144)
	label_feedback.size = Vector2(438, 48)
	label_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	panel.visible = false
	botao_a.pressed.connect(func(): _responder(0))
	botao_b.pressed.connect(func(): _responder(1))
	botao_c.pressed.connect(func(): _responder(2))
	GameManager.desafio_pronto.connect(_mostrar_desafio)

	EstiloUI.painel(panel)
	for b in [botao_a, botao_b, botao_c]:
		EstiloUI.botao(b, 20)
	EstiloUI.rotulo(label_pergunta, 20, Color.WHITE, 5)
	EstiloUI.rotulo(label_feedback, 18, Color("ffd978"), 5)

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
	if TEMPO_FEEDBACK > 0.0:
		await get_tree().create_timer(TEMPO_FEEDBACK).timeout
	if meu_id == id_desafio:
		panel.visible = false
