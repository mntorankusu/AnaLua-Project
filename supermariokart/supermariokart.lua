--[[Options]]--
--[[
this structure is so I can pass this information to the server and allow game configuration
in the server itself. it will be pretty cool.
]]--

booloptions = {

}

optionlabels = {

}

optiondescriptions = {

}

local socket = require "socket"
udp = socket.udp()
udp:settimeout(1)
udp:setpeername("localhost", 3478)
udpcontrol_timeout = 120
udpcontrol_timer = 0

udp_sendevery = 60
udp_counter = 0

controls = {
AnalogLeftX = 0, 
AnalogLeftY = 0, 
AnalogRightX = 0, 
AnalogRightY = 0, 
LT = 0, 
RT = 0, 
LS = false,
RS = false,
A = false, 
B = false, 
X = false, 
Y = false, 
up = false, 
down = false,
left = false, 
right = false, 
L = false, 
R = false, 
sl = false, 
st = false  
}

players = {
controls,
controls
}

output = {}

CanMove = true

turn = 0
turnintent = 0
turnmax = 10

cameraoffset = 0
sendstring = "supermku"
udp:send(sendstring) 
--for some reason it doesn't work until a datagram has been sent.
--this isn't really a problem but I've had cases where it randomly doesn't work so I'd like to figure out why

function mainloop()
	output = {}
	padinput = {}
	repeat 
		data = nil
		data = udp:receive()
		if data then
			if string.byte(data,1) == 141 then
				--print(string.byte(data,1))
				udpcontrol_timer = 0
				players[1].AnalogLeftX = string.byte(data,2)-127
				players[1].AnalogLeftY = string.byte(data,3)-127
				players[1].AnalogRightX = string.byte(data,4)-127
				players[1].AnalogRightY = string.byte(data,5)-127
				players[1].LT = string.byte(data,6)-127
				players[1].RT = string.byte(data,7)-127
			else
				udpcontrol_timer = udpcontrol_timer + 1
			end
		end
	until data == nil 
	
	padinput = joypad.get(1)
	
	if (padinput.L or padinput.R) then turnmax = 11 else turnmax = 10 end
	
	turnintent = (players[1].AnalogLeftX * turnmax)/128
	
	if (turnintent > 1) then output.right = true end
	if (turnintent < -1) then output.left = true end
	
	turn = turnintent
	
	
	
	joypad.set(1, output)
	
end

ingame_turnintent = 0

function setturn()
	ingame_turnintent = memory.readbyte(0x7E10B3) 
	if (ingame_turnintent > 0 and turn > 0 and ingame_turnintent > turn) then
		memory.writeword(0x7E10B3, turn)
	elseif (ingame_turnintent < 0 and turn < 0 and ingame_turnintent < turn) then
		memory.writeword(0x7E10B3, turn)
	end
end

memory.registerwrite(0x7E10B3, setturn)
emu.registerbefore(mainloop)