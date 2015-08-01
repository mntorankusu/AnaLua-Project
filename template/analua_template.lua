local socket = require "socket"
udp = socket.udp()
udp:settimeout(0)
udp:setpeername("localhost", 3478)
udpcontrol_timeout = 120
udpcontrol_timer  = 0

controls = {
AnalogLeftX = 0, 
AnalogLeftY = 0, 
AnalogRightX = 0, 
AnalogRightY = 0, 
LT = 0, 
RT = 0, 
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

p1isdown = controls
p1wasdown = controls
p1press = controls

p2isdown = controls
p2press = controls

sendstring = "generic"
udp:send(sendstring)
print("hola")

function mainloop()
	repeat 
		data = nil
		data = udp:receive()
		if data then
			if string.byte(data,1) == 141 then
				udpcontrol_timer = 0
				p1isdown.AnalogLeftX = string.byte(data,2)-127
				p1isdown.AnalogLeftY = string.byte(data,3)-127
				p1isdown.AnalogRightX = string.byte(data,4)-127
				p1isdown.AnalogRightY = string.byte(data,5)-127
			else
				udpcontrol_timer = udpcontrol_timer + 1
			end
			gui.text(0,0,string.format("LSX: %i, LSY: %i", p1isdown.AnalogLeftX, p1isdown.AnalogLeftY))
		end
	until data == nil 
	
	i = 0
	consoleprint = 6
	repeat 
		if (p1wasdown[i] ~= p1isdown[i]) then
			--p1press[i] = true
			gui.text(0,consoleprint, p1isdown[i])
			consoleprint = consoleprint + 6
		end
	until p1isdown[i] == nil
	p1wasdown = p1isdown
	
end

emu.registerbefore(mainloop)