--[[Wild Guns Mouse Control Script]]--
--by mntorankusu for AnaLua project
--only supports single player, the second player must use a standard controller for now
--[[Here are the settings]]--
EnableMouseAiming = true --if true, enable mouse controls. If you only want to use this script for the other features, set to false.
EnforceHardMode = true --If true, always play on hard mode. I don't actually know if this works.
MouseLag = 0 --make the mouse pointer lag by this number of frames. to increase the difficulty I guess?
SkipNatsumeLogo = false --if true, skip the natsume logo and go straight to the title screen.
EasyLasso = true --if true, hold the middle mouse button to ready the lasso
EasySkipToStageSelect = true --if true, hold L and press Start on the character select screen to skip the intro stage
--normally, you hold select and press AAAABBBBABABABAB to accomplish this
EasySkipToFinalBoss = true --if true, press L on the level select screen to skip to the final boss
--I also discovered that the same cheat code allows you to skip to the final boss from the level select. this seems to be new information?


xcursoroffset = -2
ycursoroffset = -2
xscreenoffset = 0

currentscreen = 0


--addresses
address_p1_cursorx = 0x7E1609 --this one is 16-bit. everything else is 8-bit, or at least never goes above 255/127 or below 0/-127
address_p1_cursory = 0x7E1709
address_p1_character = 0x7E0000
address_currentscreen = 0x7E0000
address_xscreenoffset = 0x7E0020

--most of these screens aren't used in the script, but I've documented them for reference
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

p1_x = 0
p1_y = 0

p1_character = 0

switch = true

p1_primary = "leftclick"
p1_secondary = "rightclick"
p1_tertiary = "space"

p1_lasso = "middleclick"

screenchecka = 0
gui.opacity(0.5)
print("Mouse Control for Wild Guns by mntorankusu - AnaLua project")
print("Use the arrow keys to adjust the X and Y offset until the crosshair position matches your mouse. This is likely to change if you resize the emulator window.")

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
	
	gui.text(2,1, string.format("X: %i - Y: %i", keyinput.xmouse, keyinput.ymouse))
	gui.text(2,8, string.format("Screen: %i", currentscreen))
	gui.text(2,216, "Wild Guns with Mouse Aiming - AnaLua project Lua script")
	
	if (MouseLag == 0) then
		p1_x = keyinput.xmouse+xscreenoffset-xcursoroffset
		p1_y = keyinput.ymouse-ycursoroffset
	else
		for i = 1,MouseLag-1 do
			xmouselag[i] = xmouselag[i+1]
			ymouselag[i] = ymouselag[i+1]
		end
		xmouselag[MouseLag] = keyinput.xmouse+xscreenoffset-xcursoroffset
		ymouselag[MouseLag] = keyinput.ymouse-ycursoroffset
		p1_x = xmouselag[1]
		p1_y = ymouselag[1]
	end
	
	gui.line(p1_x-xscreenoffset-5, p1_y-2, p1_x-xscreenoffset+1, p1_y-2, 999999)
	gui.line(p1_x-xscreenoffset-2, p1_y-5, p1_x-xscreenoffset-2, p1_y+1, 999999)
	
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
		if (p1_x >= 92 and  p1_x <= 163) then
			if (p1_y >= 19 and p1_y <= 82) then
				output.up = true
			elseif (p1_y >= 147 and p1_y <= 210) then
				output.down = true
			end
		elseif (p1_y <= 147 and p1_y >= 82) then
			if (p1_x <= 82 and p1_x >= 12) then
				output.left = true
			elseif (p1_x <= 243 and p1_x >= 172) then
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
		
		if (p1_x > 128 and p1_character == 0) then
			output.right = true
		elseif (p1_x < 128 and p1_character == 1) then
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
	
	joypad.set(1, output)
end

function nullfunction()
end

function hardmode()
	memory.writebyte(0x7EFF34, 2)
end

function xcursor_set()
	if (screen_ingame) then memory.writeword(0x7E1609, p1_x) end
end

function ycursor_set()
	if (screen_ingame) then memory.writebyte(0x7E1709, p1_y) end
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

memory.registerwrite(0x7E0000, gamecurrentscreen)

memory.registerwrite(0x7E1609, 2, xcursor_set)
memory.registerwrite(0x7E1709, 1, ycursor_set)

memory.registerread(0x7E1609, 2, xcursor_set)
memory.registerread(0x7E1709, 1, ycursor_set)
