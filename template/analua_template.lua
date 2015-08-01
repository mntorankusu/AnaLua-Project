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

sendstring = "generic"
udp:send(sendstring)

function mainloop()
	udpsendreceive()
end

function udpsendreceive()
timedout = false
	repeat 
		data = nil
		data = udp:receive()
		if data then
			if string.byte(data,1) == 141 then
				udpcontrol_timer = 0
				p1current.AnalogLeftX = string.byte(data,2)-127
				p1current.AnalogLeftY = string.byte(data,3)-127
				p1current.AnalogRightX = string.byte(data,4)-127
				p1current.AnalogRightY = string.byte(data,5)-127
				p1current.LT = string.byte(data,6)-127
				p1current.RT = string.byte(data,7)-127
				if (timedout) then
					timedout = false
					udpcontrol_timer = 0
					writemessage(string_receivedmessage)
				end
			else
				udpcontrol_timer = udpcontrol_timer + 1
			end
		else
				udpcontrol_timer = udpcontrol_timer + 1
		end
	until data == nil 
	
	if (udpcontrol_timer >= udptimeout) then
		timedout = true
		if (udpcontrol_timer == udptimeout) then
			writemessage(string_timedout)
		end
		udpcontrol_timer = udptimeout+1
	end
	
	udp:send(string_announce)
end

emu.registerbefore(mainloop)