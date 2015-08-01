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

p1current = controls

p1last = controls

p2 = controls
p2last = controls

rollintent = 0
turnrollintent = 0
pitchintent = 0
yawintent = 0

rollmax = 64
turnrollmax = 1536
pitchmax = 3584
yawmax = pitchmax

roll = 0
turnroll = 0
pitch = 0
yaw = 0

rollspeed = 4
turnrollspeed = 160
pitchspeed = 160
yawspeed = 160

cameraoffset = 0

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
				p1current.AnalogLeftX = string.byte(data,2)-127
				p1current.AnalogLeftY = string.byte(data,3)-127
				p1current.AnalogRightX = string.byte(data,4)-127
				p1current.AnalogRightY = string.byte(data,5)-127
				p1current.LT = string.byte(data,6)-127
				p1current.RT = string.byte(data,7)-127
			else
				udpcontrol_timer = udpcontrol_timer + 1
			end
			gui.text(0,2,string.format("LSX: %i, LSY: %i", p1current.AnalogLeftX, p1current.AnalogLeftY))
			gui.text(0,9,string.format("RollI: %i, Roll: %i", rollintent, roll))
		end
	until data == nil 
	
	rollintent = (p1current.LT - p1current.RT) * rollmax/127
	pitchintent = (p1current.AnalogLeftY * pitchmax)/128
	turnrollintent = -(p1current.AnalogLeftX * turnrollmax)/128
	yawintent = -(p1current.AnalogLeftX * yawmax)/128

	roll = roll + ((rollintent - roll) * (rollspeed*2)) / rollmax
	pitch = pitch + ((pitchintent - pitch) * (pitchspeed*2)) / pitchmax
	yaw = yaw + ((yawintent - yaw) * (yawspeed*2)) / yawmax
	turnroll = turnroll + ((turnrollintent - turnroll) * (turnrollspeed*2)) / turnrollmax
	
	if (input.get().space)
		then cameraoffset = cameraoffset + 1
	elseif (input.get().backspace)
		then cameraoffset = cameraoffset - 1
	end
	
	gui.text(0,16,string.format("testvalue: %i",cameraoffset))
	
end

function setroll()
	memory.writebyte(0x7E1509, roll)
end

function setpitch()
	memory.writeword(0x7E1232, pitch)
end 

function setyaw()
	memory.writeword(0x7E1236, turnroll)
	memory.writeword(0x7E1234, yaw)
end



function camerafuckery()

	--memory.writebyte(0x7E0348, cameraoffset) --another pitch value from -127 to 127
	--memory.writebyte(0x7E0349, cameraoffset) --another yaw value from -127 to 127
	--memory.writebyte(0x7E034A, cameraoffset) --another roll value from -127 to 127
	
	--memory.writebyte(0x7E00C3, memory.readbyte(0x7E00C3) - (p1current.AnalogRightY / 32)) -- camera Y
	--memory.writebyte(0x7E00C1, memory.readbyte(0x7E00C1) + (p1current.AnalogRightX / 32)) -- camera X
	
	--memory.writebyte(0x7E1234, cameraoffset) -- camera X again?
	--memory.writebyte(0x7E1235, cameraoffset) -- camera X again?
	
	--memory.writebyte(0x7E03E4, cameraoffset) -- camera X again?
	
	--memory.writebyte(0x7E00C2, cameraoffset) -- camera Y-Rotation -- really low resolution?
	
	--memory.writebyte(0x7E034B, 0) --movement speed?
	--memory.writebyte(0x7E034C, cameraoffset) --crash
	--memory.writebyte(0x7E034D, cameraoffset) --crash
	
end

function cameracontrol()
	--memory.writebyte(0x7E00C3, memory.readbyte(0x7E00C3) - (p1current.AnalogRightY / 16)) -- camera Y
	--memory.writebyte(0x7E00C1, memory.readbyte(0x7E00C1) + (p1current.AnalogRightX / 16)) -- camera X
	--memory.writeword(0x7E00C2, (p1current.AnalogRightX / 2))
end



memory.registerread(0x7E00C3, 1, cameracontrol)

memory.registerread(0x7E0346, 4, camerafuckery)

memory.registerwrite(0x7E1509, 2, setroll)
memory.registerwrite(0x7E1232, 2, setpitch)
memory.registerwrite(0x7E1234, 2, setyaw)
emu.registerbefore(mainloop)