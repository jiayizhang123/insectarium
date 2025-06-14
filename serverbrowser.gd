extends Control

signal joinGame(ip)
@onready var broadcastTimer : Timer = $broadcasttimer

var serverInfo = {"name":"", "playerCount": 0}
var broadcaster : PacketPeerUDP
var listner : PacketPeerUDP 
@export var listenPort : int = 8911
@export var broadcastPort : int = 8912
var broadcastAddress : String 
var ip1: String
var ip2 = []
var tempf:bool = true #use for the case the listening port fail to be binded
var icon = preload("res://asset/computer.png")

#@export var serverInfo : PackedScene
@onready var serverInfoScene = preload("res://serverinfo.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	setUp()
	
	pass # Replace with function body.
	
func setUp():
	tempf = true
	listner = PacketPeerUDP.new()
	var ok = listner.bind(listenPort)
	
	if ok == OK:
		print("Bound to listen Port "  + str(listenPort) +  " Successful!")
		get_parent().get_node("ItemList").add_item("Bound To Listen Port: true",icon)
	else:
		print("Failed to bind to listen port!")
		get_parent().get_node("ItemList").add_item("Bound To Listen Port: false",icon)
		tempf = false
	
	ip1 = getlocalip()
	ip2 = ip1.split(".")
	broadcastAddress = ip2[0]+"."+ip2[1]+"."+ ip2[2] +".255"
	#get_parent().get_node("Label3").text = broadcastAddress
	
	get_parent().get_node("ItemList").add_item(ip1,icon)
	print(broadcastAddress)

func getlocalip() -> String:
	var iparray = []
	var ip = ""
	var ip192 = ""
	for address in IP.get_local_addresses():
		if "." in address and not address.begins_with("127.") and not address.begins_with("169.254."):
			if address.begins_with("192.168.") or address.begins_with("10.") or (address.begins_with("172.") and int(address.split(".")[1]) >= 16 and int(address.split(".")[1]) <= 31):
				iparray.append(address)
				if address.begins_with("192.168."):
					ip192 = address
					break
	if len(ip192) > 1: #put 192.168.x.x at first
		ip = ip192
	else:
		ip = iparray[0]
	return ip

func setUpBroadCast(sname):
	serverInfo.name = sname
	serverInfo.playerCount = Config.Players.size()
	
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcastAddress, listenPort)
	
	var ok = broadcaster.bind(broadcastPort)
	
	if ok == OK:
		print("Bound to Broadcast Port "  + str(broadcastPort) +  " Successful!")
	else:
		print("Failed to bind to broadcast port!")
		
	broadcastTimer.start()
	$Timer.stop()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	
	if listner.get_available_packet_count() > 0:
		$Timer.stop()
		var serverip = listner.get_packet_ip()
		var serverport = listner.get_packet_port()
		var bytes = listner.get_packet()
		var data = bytes.get_string_from_ascii()
		var serverInfo = JSON.parse_string(data)
		
		print("server Ip: " + serverip +" serverPort: "+ str(serverport) + " server info: " + str(serverInfo))
		
		for i in get_parent().get_node("Panel/VBoxContainer").get_children():
			if i.name == serverInfo.name:
				i.get_node("Ip").text = serverip
				i.get_node("PlayerCount").text = str(serverInfo.playerCount)
				return
		
		var currentInfo = serverInfoScene.instantiate()
		currentInfo.name = serverInfo.name
		currentInfo.get_node("Name").text = serverInfo.name
		currentInfo.get_node("Ip").text = serverip
		currentInfo.get_node("PlayerCount").text = str(serverInfo.playerCount)
		if Config.server_status == 1:
			currentInfo.get_node("Button").disabled = true
		get_parent().get_node("Panel/VBoxContainer").add_child(currentInfo)
		currentInfo.joinGame.connect(joinbyIp)
		if Config.server_status == 0:
			get_parent().get_node("Panel/CheckButton").disabled = true
			
	else:
		if get_tree().get_nodes_in_group("mainscene").size() == 0: #if game starts, don't check 
			if $Timer.is_stopped():
				$Timer.start()
	pass


func cleanUp():
	#listner.close()
	
	$Timer.stop()
	broadcastTimer.stop()
	if broadcaster != null:
		broadcaster.close()
	

func _exit_tree():
	listner.close()
	cleanUp()

func joinbyIp(ip):
	joinGame.emit(ip)


func _on_broadcasttimer_timeout() -> void:
	print("Broadcasting Game!")
	serverInfo.playerCount = Config.Players.size()
	var data = JSON.stringify(serverInfo)
	var packet = data.to_ascii_buffer()
	broadcaster.put_packet(packet)
	broadcaster.put_packet(packet)
	broadcaster.put_packet(packet)
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	for i in get_parent().get_node("Panel/VBoxContainer").get_children():
		get_parent().get_node("Panel/VBoxContainer").remove_child(i)
	if tempf: #used for PC debugging in 2 instances that one is disabled of listening port,who runs isolately
		Config.Players.clear()
	#print(Config.Players.size())
	get_parent().get_node("Panel/CheckButton").disabled = false
	pass # Replace with function body.
