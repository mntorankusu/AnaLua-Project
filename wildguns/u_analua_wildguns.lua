--[[Wild Guns Mouse Control Script]]--
--[[
This script will allow you to play Wild Guns with your mouse. 

this app will also accept messages over UDP for analog control, and send messages back for vibration feedback.

Use the Page Up and Page Down keys to adjust the X offset until the crosshair position matches your mouse. this will change if you resize the emulator window.
--]]

--[[Here are some options!]]--
EnforceHardMode = true --always use Hard mode setting. The game is much easier with a mouse or dual analog, so this will make the game a little more balanced.
CanMoveWhileJumping = true --if true, allows you to adjust your jump in the air
CanMoveWhileDoubleJumping = true --if true, allows you to adjust your jump in the air after double jumping
OriginalDoubleJumpPhysics = true --if true, allows you to change your direction midair instantly when doublejumping. if false, you will keep any existing momentum when double jumping
AnnieMaxWalkingSpeed = 2 --2 is the default walking speed.  values are dithered so fractions are fine
ClintMaxWalkingSpeed = 1 --clint's walking speed is actually 1.5(?). the game uses integers only, though, so it's 1 and 1+1 with some dithering happening somewhere(?)
AccelerationRate = 0.125 --this is the rate of speed that your character will increase their walking speed when using analog controls
DecelerationRate = 0.25 --this is the rate of speed that your character will decrease their walking speed when using analog controls
JumpAccelerationRate = 0.05 --speed at which you can change your jump trajectory, if CanMoveWhileJumping is true.
deadzone = 50 --deadzone of the analog stick, range 0 to 128


local socket = require "socket"

udp = socket.udp()
udp:settimeout(0)
udp:setpeername("localhost", 3478)

clamp = 0.125

xoffset = -2
yoffset = -2
screenoffset = 0

udpcontrol_timeout = 120
udpcontrol_timer  = 0

moveintent = 0
movespeed = 0
movespeed_buffer = 0
movespeed_output = 0

player1 = {
xmouse = 0, 
ymouse = 0, 
character = 0, 
state = 0, 
canmove = false, 
isjumping = false, 
AnalogLeftX = 0, 
AnalogLeftY = 0, 
AnalogRightX = 0, 
AnalogRightY = 0, 
A = nil, 
B = nil, 
X = nil, 
Y = nil, 
up = nil, 
down = nil,
left = nil, 
right = nil, 
L = nil, 
R = nil, 
LT = nil, 
RT = nil, 
sel = nil, 
start = nil  
}

p1_x = 0
p1_y = 0

p1_character = 1

p1_lanalogx = 0
p1_lanalogy = 0
p1_ranalogx = 0
p1_ranalogy = 0

p1_state = 0
p1_canmove = true
p1_isjumping = false

switch = true

p1_Y = "leftclick"
p1_B = "rightclick"
p1_lasso = "middleclick"
p1_X = "space"

sendstring = "wildgunu"
udp:send(sendstring)
print("hola")

function mousecontrol()
sendstring = "wildgunu"
--udp:send(sendstring)

	output = {}
	keyinput = {}
	screenoffset = memory.readbyte(0x7E0020)
	
	if p1_state ~= 8 and memory.readbyte(0x7E1100) == 8 and OriginalDoubleJumpPhysics then
		movespeed = moveintent
		print("set it")
	end
	
	p1_state = memory.readbyte(0x7E1100)
	
	
	p1_canmove = false
	p1_isjumping = false
	
	if p1_state == 2 then 
		p1_canmove = true 
	end
	
	if p1_state == 6 then
		p1_isjumping = true
		if CanMoveWhileJumping then
			p1_canmove = true
		end
	end

	if p1_state == 8 then
		p1_isjumping = true
		if CanMoveWhileDoubleJumping then
			p1_canmove = true
		end
	end
	
	keyinput = input.get()
	switch = not switch
	
	p1_x = keyinput.xmouse+screenoffset-xoffset
	p1_y = keyinput.ymouse-yoffset

	memory.writeword(0x7E1609, p1_x)
	memory.writebyte(0x7E1709, p1_y)

	--print(string.format("X: %i, Y: %i", p1_x, p1_y))
	--print(string.format("Player 1 State: %i", p1_state))

	
	repeat 
		data = nil
		data = udp:receive()
		if data then
			if string.byte(data,1) == 141 then
				udpcontrol_timer = 0
				p1_lanalogx = string.byte(data,2)-127
				p1_lanalogy = string.byte(data,3)-127
				p1_ranalogx = string.byte(data,4)-127
				p1_ranalogy = string.byte(data,5)-127
			else
				udpcontrol_timer = udpcontrol_timer + 1
			end
		end
	until data == nil 
	
	if input.get()[p1_Y] then
		output.Y = true
	end

	if input.get()[p1_B] then
		output.B = true
	end
	
	if input.get()[p1_lasso] then
		output.Y = switch
	end
	
	if input.get().left then
		xoffset = xoffset+1
		print(string.format("increase offset to %i", xoffset))
	elseif input.get().right then
		xoffset = xoffset-1
		print(string.format("decrease offset to %i", xoffset))
	elseif input.get().up then
		yoffset = yoffset+1
		print(string.format("increase y offset to %i", yoffset))
	end

	if input.get().down then
		yoffset = yoffset-1
		print(string.format("decrease y offset to %i", yoffset))
	end 
	
	
	--clint's walking speed is different from annie's, so I need to know which character you're playing as.
	if (p1_character == 0) then
		maxspeed_l = ClintMaxWalkingSpeed+1
		maxspeed_r = ClintMaxWalkingSpeed
	else
		maxspeed_l = AnnieMaxWalkingSpeed
		maxspeed_r = AnnieMaxWalkingSpeed
	end
	
	AccelMultiplier = maxspeed_l / maxspeed_r
	
	if p1_lanalogx > deadzone then
		moveintent = (p1_lanalogx * maxspeed_r) / 127
	elseif p1_lanalogx < -deadzone then
		moveintent = (p1_lanalogx * maxspeed_l) / 127
	else
		moveintent = 0
	end
	
	if (movespeed < moveintent) then 
		if (p1_isjumping) then movespeed = movespeed + (JumpAccelerationRate) 
		elseif (movespeed < 0) then movespeed = movespeed + (DecelerationRate*AccelMultiplier)
		else movespeed = movespeed + (AccelerationRate) end
	end
	
	if (movespeed > moveintent) then 
		if (p1_isjumping) then movespeed = movespeed - (JumpAccelerationRate*AccelMultiplier)
		elseif (movespeed > 0) then movespeed = movespeed - (DecelerationRate)
		else movespeed = movespeed - (AccelerationRate*AccelMultiplier) end
	end
	
	if (not p1_canmove) then movespeed = 0 end
	
	if (movespeed > 0) then output.right = true end
	if (movespeed < 0) then output.left = true end
	
	if (moveintent > 0 and not p1_canmove) then output.right = true end
	if (moveintent < 0 and not p1_canmove) then output.left= true end
	
	if (moveintent == 0 and movespeed > 0 and movespeed <= clamp) then movespeed = 0
	elseif (moveintent == 0 and movespeed < 0 and movespeed >= -clamp*AccelMultiplier) then movespeed = 0 end
	
	movespeed_buffer = movespeed_buffer + movespeed
	
	movespeed_output = 0
	
	 while movespeed_buffer > 1 do
		 movespeed_output = movespeed_output  + 1
		 movespeed_buffer = movespeed_buffer - 1
	 end
	
	 while movespeed_buffer < -1 do
		 movespeed_output = movespeed_output  - 1
		 movespeed_buffer = movespeed_buffer + 1
	 end
	
	print("values")
	print(movespeed)
	print(AccelMultiplier)
		

	
	joypad.set(1, output)
	
	if (p1_canmove) then memory.writebyte(0x7E1C01, movespeed_output) end
	
end

function nullfunction()
end

function hardmode()
	memory.writebyte(0x7EFF34, 2)
end

function p1_effect_gunshoot()
    if (memory.readbyte(0x7E1400) == 5) then
		print("SHOOT")
		if (p1_currentgun == 6) then
			udp:send("r2")
		else
			udp:send("r1")
		end
	end
end

function p1_current_gun()
	p1_currentgun = memory.readbyte(0x7E1FA8)
end

function xcursor_stabilize()
	memory.writeword(0x7E1609, p1_x)
end

function ycursor_stabilize()
	memory.writebyte(0x7E1709, p1_y)
end

function moveit()
	if p1_canmove then
		memory.writebyte(0x7E1C01, movespeed_output)
	end
end

memory.register(0x7EFF34, hardmode)
memory.register(0x7E1FA8, p1_current_gun)
memory.register(0x7E1400, p1_effect_gunshoot)

emu.registerbefore(mousecontrol)
memory.register(0x7E1C01, moveit)
memory.register(0x7E1609, 2, xcursor_stabilize)
memory.register(0x7E1709, 2, ycursor_stabilize)
