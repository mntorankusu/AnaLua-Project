--[[Options]]--
--[[
this structure is so I can pass this information to the server and allow game configuration
in the server itself. it will be pretty cool.
]]--

booloptions = {
SingleTapToBarrelRoll = true,
AnalogTriggersLR = false,
FreeRoll = false,
LockCameraToRoll = false;
}

optionlabels = {
"Single Tap to Barrel Roll",
"Analog Triggers Activate L/R",
"Free Roll",
"Lock Z-Rotation to Roll"
}

optiondescriptions = {
"If enabled, you only need to tap the L or R button once to do a barrel roll.",
"If enabled, analog trigger press will activate the L/R buttons.",
"If enabled, you can roll your Arwing freely.",
"If enabled, the camera's Z-rotation will stay locked to the Arwing's roll."
}

local socket = require "socket"
udp = socket.udp()
udp:settimeout(0)
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
modfy = 36

triggerthreshold = -120

rollintent = 0
turnrollintent = 0
pitchintent = 0
yawintent = 0

rollmax = 64
turnrollmax = 1536
pitchmax = 3584
yawmax = pitchmax

roll = 0
freeroll = 0
turnroll = 0
pitch = 0
yaw = 0

rollspeed = 3
turnrollspeed = 70
pitchspeed = 70
yawspeed = 70

cameraoffset = 0
sendstring = "starfoxu"
udp:send(sendstring) 
--for some reason it doesn't work until a datagram has been sent.
--this isn't really a problem but I've had cases where it randomly doesn't work so I'd like to figure out why


FreeRollLag = 30
freerollbuffer = 0
freerollintent = {}

for i = 1,FreeRollLag do
	freerollintent[i] = 20
end

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
			gui.text(0,2,string.format("LSX: %i, LSY: %i", players[1].AnalogLeftX, players[1].AnalogLeftY))
			gui.text(0,9,string.format("RollI: %i, Roll: %i", rollintent, roll))
		end
	until data == nil 
	
	rollintent = (players[1].LT - players[1].RT) * rollmax/127
	pitchintent = (players[1].AnalogLeftY * pitchmax)/128
	turnrollintent = -(players[1].AnalogLeftX * turnrollmax)/128
	yawintent = -(players[1].AnalogLeftX * (yawmax + math.abs(roll*modfy)))/128
	
	roll = roll + ((rollintent - roll) * (rollspeed*2)) / rollmax
	pitch = pitch + ((pitchintent - pitch) * (pitchspeed*2)) / pitchmax
	yaw = yaw + ((yawintent - yaw) * ((yawspeed+math.abs(roll))*2)) / (yawmax + math.abs(roll*modfy))
	turnroll = turnroll + ((turnrollintent - turnroll) * (turnrollspeed*2)) / turnrollmax
	
	for i = 1,FreeRollLag-1 do
		freerollintent[i] = freerollintent[i+1]
	end
	
	freerollintent[FreeRollLag] = rollintent
	
	for i = 1,FreeRollLag do
		freerollbuffer = freerollbuffer + freerollintent[i]
	end
	
	freerollbuffer = freerollbuffer / FreeRollLag
	--freerollbuffer = freerollintent[1]
	
	if (booloptions.FreeRoll) then freeroll = freeroll + (freerollbuffer/10) end
	
	if (freeroll > 127) then freeroll = freeroll -255
	elseif (freeroll < -127) then freeroll = freeroll + 255 end
	
	if (booloptions.AnalogTriggersLR) then
		if (players[1].RT > -100) then output.R = true end
		if (players[1].LT > triggerthreshold) then output.L = true end
	end
	
	padinput = joypad.get(1)
	
	if (booloptions.SingleTapToBarrelRoll) then
		if (padinput.R or padinput.L) then
			setdoubletapcounter()
		end
	end
	
	print(roll)
	
	gui.text(2, 16, yawmax + math.abs(roll*modfy))
	
	

	joypad.set(1, output)
	
	ycameralagbuffer = 0
	xcameralagbuffer = 0
	
	for i = 1,cameralag-1 do
		xcameralag[i] = xcameralag[i+1]
		ycameralag[i] = ycameralag[i+1]
	end
	
	xcameralag[cameralag] = players[1].AnalogRightX
	ycameralag[cameralag] = players[1].AnalogRightY
	
	for i = 1,cameralag do
		ycameralagbuffer = ycameralagbuffer + ycameralag[i]
		xcameralagbuffer = xcameralagbuffer + xcameralag[i]
	end
	
	ycameralagbuffer = ycameralagbuffer / cameralag
	
	camerayoffset = 0-ycameralagbuffer/16
	cameraxoffset = 0-xcameralagbuffer/16
	
end

function setroll()
	if (booloptions.FreeRoll) then memory.writebyte(0x7E1509, freeroll) end
	if (not booloptions.FreeRoll) then memory.writebyte(0x7E1509, roll) end
end

function setpitch()
	memory.writeword(0x7E1232, pitch)
end 

function setyaw()
	memory.writeword(0x7E1236, turnroll)
	memory.writeword(0x7E1234, yaw)
end

function setdoubletapcounter()
	memory.writebyte(0x7E1502, 3)
end

cameralag = 30

xcameralag = {}
ycameralag = {}

for i = 1,cameralag do
	xcameralag[i] = 0
	ycameralag[i] = 0
end

function camerahacks()
	
	memory.writebyte(0x7E1630, camerayoffset)
	memory.writebyte(0x7E1636, camerayoffset)
	memory.writebyte(0x7E18C8, camerayoffset)
	
	if (booloptions.LockCameraToRoll) then
		memory.writebyte(0x7E1634, -roll)
		memory.writebyte(0x7E064E, -roll)
		memory.writebyte(0x7E163A, -roll) --3D camera roll
		--I can't find the 2D rotation value, so the background doesn't rotate yet!
	end
	
end

--if (booloptions.SingleTapToBarrelRoll) then memory.registerread(0x7E1502, 1, setdoubletapcounter) end
memory.registerread(0x7E1830, 1, camerahacks)
memory.registerread(0x7E1836, 1, camerahacks)
memory.registerread(0x7E18C8, 1, camerahacks)

memory.registerread(0x7E163D, 1, camerahacks)
memory.registerread(0x7E163A, 1, camerahacks)
memory.registerread(0x7E18C8, 1, camerahacks)

memory.registerwrite(0x7E1509, 2, setroll)
memory.registerwrite(0x7E1232, 2, setpitch)
memory.registerwrite(0x7E1234, 2, setyaw)
memory.registerread(0x7E1234, 1, mainloop)
--emu.registerbefore(mainloop)