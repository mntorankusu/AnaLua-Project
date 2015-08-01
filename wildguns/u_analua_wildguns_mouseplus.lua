--[[Wild Guns Mouse Control Script]]--
--by mntorankusu for AnaLua project
--only supports single player, the second player must use a standard controller for now
--[[Here are the settings]]--
EnableMouseAiming = true --if true, enable mouse controls. If you only want to use this script for the other features, set to false.
EnforceHardMode = true --If true, always play on hard mode. I don't actually know if this works.
MouseLag = 0 --make the mouse pointer lag by this number of frames. to increase the difficulty I guess?
SkipNatsumeLogo = true --if true, skip the natsume logo and go straight to the title screen.
EasyLasso = true --if true, hold the middle mouse button to ready the lasso
EasySkipToStageSelect = true --if true, hold L and press Start on the character select screen to skip the intro stage
--normally, you hold select and press AAAABBBBABABABAB to accomplish this
EasySkipToFinalBoss = true --if true, press L on the level select screen to skip to the final boss
--I also discovered that the same cheat code allows you to skip to the final boss from the level select. this seems to be new information?

--[[these settings are related to analog control ignore them if you don't want to use a controller]]
LeftAnalogControl = true --experimental? analog stick control. this game doesn't work especially well with it, but it's a neat thing to try.
RightAnalogControl = true --aiming with right analog. will automatically disable mouse aiming if a packet is received with controller data. if false, you can use the left side of your controller and the mouse at the same time.
CanMoveWhileJumping = true --if true, allows you to adjust your jump in the air
CanMoveWhileDoubleJumping = true --if true, allows you to adjust your jump in the air after double jumping
OriginalDoubleJumpPhysics = false --if true, allows you to change your direction midair instantly when doublejumping. if false, you will keep any existing momentum when double jumping
AnnieMaxWalkingSpeed = 2 --2 is the default walking speed.  values are dithered so fractions are fine
ClintMaxWalkingSpeed = 1 --clint's walking speed is actually 1.5(?). the game uses integers only, though, so it's 1 and 1+1 with some dithering happening somewhere(?)
AccelerationRate = 0.125 --this is the rate of speed that your character will increase their walking speed when using analog controls
DecelerationRate = 0.25 --this is the rate of speed that your character will decrease their walking speed when using analog controls
JumpAccelerationRate = 0.05 --speed at which you can change your jump trajectory, if CanMoveWhileJumping is true.
deadzone = 50 --deadzone of the analog stick, range 0 to 128
udptimeout = 100 --in frames, how long to wait without input before abandoning analog input
--[[end of settings]]


xcursoroffset = -2
ycursoroffset = -2
xscreenoffset = 0
currentscreen = 0
--addresses
address_p1_cursorx = 0x7E1609 --this one is 16-bit. everything else is 8-bit, or at least never goes above 255/127 or below 0/-127
address_p1_cursory = 0x7E1709
address_p1_character = 0x7E04B6
address_currentscreen = 0x7E0000
address_xscreenoffset = 0x7E0020
--most of these aren't used in the script, but I've documented them for reference
screen_natsume = 0
screen_title = 2
screen_beatfinalboss = 8
screen_ending = 10
screen_option = 12
screen_characterselect = 16
screen_stageselect = 18
screen_continue = 20
screen_colortest = 22
screen_ingame = 26 
screen_gameresults = 28
screen_versusmode_2p = 34
screen_versusmode_com = 42
screen_versusmoderesults = 44
screen_copyright = 46

xmouselag = {}
ymouselag = {}

for i = 1,MouseLag do
	xmouselag[i] = 0
	ymouselag[i] = 0
end

controls = {
AnalogLeftX = 0, 
AnalogLeftY = 0, 
AnalogRightX = 0, 
AnalogRightY = 0,
MouseX = 0,
MouseY = 0, 
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

moveintent = 0
movespeed = 0
movespeed_buffer = 0
movespeed_output = 0

clamp = .125

p1current = controls
p1last = controls
p1changed = controls

p2current = controls
p2last = controls
p2changed = controls

p1_character = 0

switch = true

messagelength = 200
messagetimer = 0
announceevery = 60
announcetimer = 0

p1_primary = "leftclick"
p1_secondary = "rightclick"
p1_tertiary = "space"
p1_lasso = "middleclick"

string_receivedmessage = "Analog mode enabled."
string_timedout = nil
string_announce = "wildgunu"

screenchecka = 0
gui.opacity(0.5)
print("Mouse Control for Wild Guns by mntorankusu - AnaLua project")
print("Use the arrow keys to adjust the X and Y offset until the crosshair position matches your mouse. This is likely to change if you resize the emulator window.")

if (LeftAnalogControl) then
	local socket = require "socket"
	udp = socket.udp()
	udp:settimeout(0)
	udp:setpeername("localhost", 3478)
	udpcontrol_timer = 0
	sendstring = "wildgunu"
	udp:send(sendstring)
end

function writemessage(themessage)
	if (themessage) then
		messagetimer = 0
		osdmessage = themessage
	end
end

writemessage("Wild Guns Mouse Control Script - AnaLua project")

function mousecontrol()
	
	output = {}
	keyinput = {}
	
	xscreenoffset = memory.readbyte(address_xscreenoffset)
	currentscreen = memory.readbyte(address_currentscreen)
	p1_character = memory.readbyte(address_p1_character)

	keyinput = input.get()
	
	if (keyinput.plus) then
		screenchecka = screenchecka + 0.1
	end
	
	print(string.format("X: %i", keyinput.xmouse))
	print(string.format("Y: %i", keyinput.ymouse))
	
	if (osdmessage) then
		gui.text(2,219, osdmessage)
		messagetimer = messagetimer + 1
		if (messagetimer > messagelength) then
			osdmessage = nil
		end
	end
	
	if (MouseLag == 0) then
		p1current.MouseX = keyinput.xmouse+xscreenoffset-xcursoroffset
		p1current.MouseY = keyinput.ymouse-ycursoroffset
	else
		for i = 1,MouseLag-1 do
			xmouselag[i] = xmouselag[i+1]
			ymouselag[i] = ymouselag[i+1]
		end
		xmouselag[MouseLag] = keyinput.xmouse+xscreenoffset-xcursoroffset
		ymouselag[MouseLag] = keyinput.ymouse-ycursoroffset
		p1current.MouseX = xmouselag[1]
		p1current.MouseY = ymouselag[1]
	end
	
	gui.line(p1current.MouseX-xscreenoffset-5, p1current.MouseY-2, p1current.MouseX-xscreenoffset+1, p1current.MouseY-2, 999999)
	gui.line(p1current.MouseX-xscreenoffset-2, p1current.MouseY-5, p1current.MouseX-xscreenoffset-2, p1current.MouseY+1, 999999)
	
	if (currentscreen == screen_ingame) then
		
		if input.get()[p1_primary] then
			output.Y = true
		end

		if input.get()[p1_secondary] then
			output.B = true
		end
	
		if input.get()[p1_lasso] and EasyLasso then
			output.Y = switch
			switch = not switch
		end

	end
	
	
	if (currentscreen == screen_stageselect) then
		if (p1current.MouseX >= 92 and  p1current.MouseX <= 163) then
			if (p1current.MouseY >= 19 and p1current.MouseY <= 82) then
				output.up = true
			elseif (p1current.MouseY >= 147 and p1current.MouseY <= 210) then
				output.down = true
			end
		elseif (p1current.MouseY <= 147 and p1current.MouseY >= 82) then
			if (p1current.MouseX <= 82 and p1current.MouseX >= 12) then
				output.left = true
			elseif (p1current.MouseX <= 243 and p1current.MouseX >= 172) then
				output.right = true
			end
		end
		
		if joypad.get(1).L and joypad.get(1).Start and EasySkipToFinalBoss then
			memory.writebyte(0x7E05F0, -1)
			memory.writebyte(0x7E05F1, -1)
		end
		
		if input.get()[p1_primary] then
			output.start = true
		end
		
	elseif (currentscreen == screen_characterselect) then
		gui.text(0,16,p1_character)
		if (p1current.MouseX > 128 and p1_character == 0) then
			output.right = true
		elseif (p1current.MouseX < 128 and p1_character == 1) then
			output.left = true
		end
		
		if input.get()[p1_primary] then
			output.start = true
		end
		
		if (joypad.get(1).L or input.get()[p1_secondary]) and EasySkipToStageSelect then
			memory.writebyte(0x7E05F0, -1)
			memory.writebyte(0x7E05F1, -1)
		end
		
	elseif (currentscreen == screen_title) then
		if input.get()[p1_primary] then
			output.start = true
		end
	end
	
	if input.get().left then
			xcursoroffset = xcursoroffset+0.25
			print(string.format("increase offset to %i", xcursoroffset))
		elseif input.get().right then
			xcursoroffset = xcursoroffset-0.25
			print(string.format("decrease offset to %i", xcursoroffset))
		elseif input.get().up then
			ycursoroffset = ycursoroffset+0.25
			print(string.format("increase y offset to %i", ycursoroffset))
		elseif input.get().down then
			ycursoroffset = ycursoroffset-0.25
			print(string.format("decrease y offset to %i", ycursoroffset))
		end 
		
	if (LeftAnalogControl) then
		udpsendreceive()
		analogcontrol()
	end
	
	joypad.set(1, output)
	
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

function analogcontrol()
	
	if p1_state ~= 8 and memory.readbyte(0x7E1100) == 8 and OriginalDoubleJumpPhysics then
		movespeed = moveintent
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
	
	if (p1_character == 0) then
		maxspeed_l = ClintMaxWalkingSpeed+1
		maxspeed_r = ClintMaxWalkingSpeed
	else
		maxspeed_l = AnnieMaxWalkingSpeed
		maxspeed_r = AnnieMaxWalkingSpeed
	end
	
	AccelMultiplier = maxspeed_l / maxspeed_r
	
	if p1current.AnalogLeftX > deadzone then
		moveintent = (p1current.AnalogLeftX * maxspeed_r) / 127
	elseif p1current.AnalogLeftX < -deadzone then
		moveintent = (p1current.AnalogLeftX * maxspeed_l) / 127
	elseif joypad.get(1).left == true then
		moveintent = -maxspeed_l
	elseif joypad.get(1).right == true then
		moveintent = maxspeed_r
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
	 
	 moveit()
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

function hardmode()
	memory.writebyte(0x7EFF34, 2)
end


function p1_current_gun()
	p1_currentgun = memory.readbyte(0x7E1FA8)
end

function xcursor_set()
	if (screen_ingame) then memory.writeword(0x7E1609, p1current.MouseX) end
end

function ycursor_set()
	if (screen_ingame) then memory.writebyte(0x7E1709, p1current.MouseY) end
end

function gamecurrentscreen()
	currentscreen = memory.readbyte(0x7E0000)
	if (SkipNatsumeLogo and currentscreen == screen_natsume) then
		memory.writebyte(0x7E0000, 2)
		currentscreen = 2
	end
end

emu.registerbefore(mousecontrol)

if (EnforceHardMode) then
	memory.register(0x7EFF34, hardmode)
end

function moveit()
	if p1_canmove and (currentscreen == screen_ingame or currentscreen == screen_versusmode_2p or currentscreen == screen_versusmode_com) then
		memory.writebyte(0x7E1C01, movespeed_output)
	end
end

memory.registerwrite(0x7E0000, gamecurrentscreen)

if (LeftAnalogControl) then
	memory.register(0x7E1FA8, p1_current_gun)
	memory.register(0x7E1400, p1_effect_gunshoot)
	memory.register(0x7E1C01, moveit)
end

memory.registerwrite(0x7E1609, 2, xcursor_set)
memory.registerwrite(0x7E1709, 1, ycursor_set)
memory.registerread(0x7E1609, 2, xcursor_set)
memory.registerread(0x7E1709, 1, ycursor_set)
