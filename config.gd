extends Node

var Players = {}
var players_info = {}

var server_status = 0

var max_players = 5
var player_health = 10
var spider_hitpoint = 10
var npc_hitpoint = 3
var progressBarTime = 3

var tiles = [1,2,3,4]
var tiles1 = []
var puzzles = 1
var playerpuzzles 
var tilesa = [5,6,7,8]
var tiles1a = []
var puzzlesa= 1
var playerpuzzlesa 
var dialogf = false
var beetle = 3
var chameleon = 1
var treefrog = 2
var pumpkin = 1
var strawberry = 1
var lemon = 1
var reward = 1
var reward2 = 1

var dialogi = [0,0,0] #each three npcs has three sentences
var dialog = ["I'm curator of this insectarium, we need insects for research, \
 two [b]tree frogs[/b], one [b]chameleon[/b], three [b]beetles[/b] and one [b]pumpkin[/b], one [b]strawberry[/b] and\
 one [b]lemon[/b] for feeding insects,could you help us?", \
"[b]If you got hurt, you may get cured when close to the insectarium.",\
"En... the pumpkin seems to grow in the forest.",\
"There has some stranger stone tiles, if you step on them in a certain\
 order, ... cross direction?, you may find something valuable, good luck!",\
"... cross direction",\
"... cross direction",\
"There has some stranger stone tiles, if you step on them in a certain\
 order, ... clockwise?, you may find something valuable , good luck!",\
"... clockwise",\
"... clockwise"]

var game = ["[center][b][color=red]********You lose, game over!********", "[center][b][color=purple]********You win, congratulate!********",\
 "[center]********You are disconnected to server!********"]
var thank = "Thank you for your great help, we can do some meaningful research on these\
 insects and make some nature herb!!!"

var firstm = "Let's find the [b]curtor of insectarium[/b], ask him what help he need."

var grassposition =[[118,0,60],[70,0,86],[-112,0,80],[90,0,-58],[124,0,-36],[-18,0,-8],
[128,0,-12],[114,0,-78],[-128,0,60],[68,0,-12],[96,0,-56],[-88,0,-64],
[22,0,-34],[132,0,60],[38,0,64],[-130,0,8],[-126,0,22],[-148,0,62],
[-162,0,84],[74,0,-48],[-146,0,-64],[82,0,36],[120,0,22],[-152,0,22],
[86,0,2],[-86,0,34],[138,0,50],[-116,0,52],[-26,0,-46],[14,0,88],
[-166,0,24],[-92,0,64],[40,0,82],[26,0,-60],[16,0,-46],[-8,0,88],
[76,0,0],[60,0,-62],[-94,0,-16],[-112,0,-76],[-122,0,8],[56,0,54],
[-102,0,76],[80,0,-40],[18,0,22],[126,0,-56],[-60,0,-16],[-40,0,50],
[-134,0,-50],[-184,0,54],[88,0,38],[70,0,-46],[-126,0,42],[-56,0,26],
[24,0,-24],[-90,0,10],[76,0,8],[-58,0,64],[-154,0,-34],[12,0,-80],
[-158,0,2],[-60,0,38],[-170,0,-34],[-152,0,56],[-40,0,26],[-134,0,18],
[-130,0,12],[112,0,-28],[-78,0,32],[-100,0,60],[18,0,94],[132,0,-64],
[48,0,-58],[14,0,-36],[130,0,-82],[-152,0,4],[86,0,-18],[32,0,24],
[-60,0,66],[100,0,90],[-20,0,70],[-110,0,-16],[-142,0,28],[-34,0,18],
[94,0,90],[58,0,84],[-58,0,40],[106,0,46],[26,0,-76],[-144,0,24],
[-100,0,-30],[-52,0,-48],[-16,0,70],[-8,0,-34],[-52,0,-50],[-188,0,40],
[-58,0,-84],[144,0,24],[-188,0,74],[124,0,22],[-134,0,56],[-140,0,-82],
[-124,0,30],[54,0,60],[104,0,-62],[-14,0,24],[-126,0,-12],[-118,0,56],
[-96,0,-36],[-166,0,-18],[112,0,-68],[-8,0,-78],[28,0,18],[-130,0,-62],
[-96,0,76],[62,0,-50],[78,0,30],[-168,0,22],[-8,0,12],[-18,0,66],
[-30,0,38],[86,0,14],[80,0,8],[52,0,-68],[-96,0,81],[-18,0,-34],[-76,0,-30],
[-24,0,-60],[44,0,-12],[120,0,-28],[34,0,64],[80,0,62],[40,0,76],
[-126,0,0],[112,0,-70],[-118,0,-64],[-184,0,70],[48,0,-42],[-108,0,66],
[-50,0,-76],[140,0,-52],[116,0,22],[132,0,22],[-22,0,82],[52,0,42],
[-136,0,-82],[-68,0,72],[-64,0,-72],[-172,0,80],[-26,0,62]
]
