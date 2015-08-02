--[[This template can be used as a basis to make new scripts. It has the basic stuff for receiving control data from the remote. More will be added to this template as the other scripts develop.
	It should always be kept up to date so new scripts don't end up using an outdated template.]]

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
addresses = {}
}

players = {
player1 = controls,
player2 = controls
}

string_receivedmessage = "Input received."
string_timedout = "Network input timed out."
string_announce = "genericx"

function mainloop()
	udpsendreceive()
end

function udpsendreceive()
	timedout = false
	repeat 
		data = nil
		player = 0
		data = udp:receive()
		if data then
			if string.byte(data,1) > 140 and string.byte(data,1) < 145 then
				player = string.byte(data,1)-140;
				udpcontrol_timer = 0
				players[player].AnalogLeftX = string.byte(data,2)-127
				players[player].AnalogLeftY = string.byte(data,3)-127
				players[player].AnalogRightX = string.byte(data,4)-127
				players[player].AnalogRightY = string.byte(data,5)-127
				players[player].LT = string.byte(data,6)-127
				players[player].RT = string.byte(data,7)-127
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