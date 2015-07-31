--[[Wild Guns Mouse Control Script]]--
--by mntorankusu for AnaLua project
--only supports single player, the second player must use a standard controller for now
--[[Here are the settings]]--
EnforceHardMode = true --If true, always play on hard mode.
MouseLag = 0 --make the mouse pointer lag by this number of frames. to increase the difficulty I guess?
SkipNatsumeLogo = false --if true, skip the natsume logo and go straight to the title screen.
EasyLasso = true --if true, hold the middle mouse button to ready the lasso
EasySkipToStageSelect = false --if true, press select instead of start on the character select screen to skip to the stage select
--normally, you hold select and press AAAABBBBABABABAB to accomplish this
EasySkipToFinalBoss = false --if true, press select on the level select screen to skip to the final boss
--I also discovered that the same cheat code allowed you to skip to the final boss. this seems to be new information?


xcursoroffset = -2
ycursoroffset = -2
xscreenoffset = 0

currentscreen = 0

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

p1_tertiary = 0
p1_primary = 0

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
	
	gui.text(0,8, math.floor(screenchecka))
	gui.text(0,16, currentscreen)
	
	output = {}
	keyinput = {}
	
	xscreenoffset = memory.readbyte(0x7E0020)
	currentscreen = memory.readbyte(0x7E0000)
	
	keyinput = input.get()
	
	if (keyinput.plus) then
		screenchecka = screenchecka + 0.1
	end
	
	print(string.format("X: %i", keyinput.xmouse))
	print(string.format("Y: %i", keyinput.ymouse))
	
	if (MouseLag == 0) then
		p1_tertiary = keyinput.xmouse+xscreenoffset-xcursoroffset
		p1_primary = keyinput.ymouse-ycursoroffset
	else
		for i = 1,MouseLag-1 do
			xmouselag[i] = xmouselag[i+1]
			ymouselag[i] = ymouselag[i+1]
		end
		xmouselag[MouseLag] = keyinput.xmouse+xscreenoffset-xcursoroffset
		ymouselag[MouseLag] = keyinput.ymouse-ycursoroffset
		p1_tertiary = xmouselag[1]
		p1_primary = ymouselag[1]
	end
	
	gui.line(p1_tertiary-xscreenoffset-5, p1_primary-2, p1_tertiary-xscreenoffset+1, p1_primary-2, 999999)
	gui.line(p1_tertiary-xscreenoffset-2, p1_primary-5, p1_tertiary-xscreenoffset-2, p1_primary+1, 999999)
	
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
		if (p1_tertiary >= 92 and  p1_tertiary <= 163) then
			if (p1_primary >= 19 and p1_primary <= 82) then
				output.up = true
			elseif (p1_primary >= 147 and p1_primary <= 210) then
				output.down = true
			end
		elseif (p1_primary <= 147 and p1_primary >= 82) then
			if (p1_tertiary <= 82 and p1_tertiary >= 12) then
				output.left = true
			elseif (p1_tertiary <= 243 and p1_tertiary >= 172) then
				output.right = true
			end
		end
		
		if input.get()[p1_primary] then
			output.start = true
		end
		
	elseif (currentscreen == screen_characterselect) then
		p1_character = memory.readbyte(0x7E04B6)
		if (p1_tertiary > 128 and p1_character == 0) then
			output.right = true
		elseif (p1_tertiary < 128 and p1_character == 1) then
			output.left = true
		end
		
		if input.get()[p1_primary] then
			output.start = true
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
	memory.writeword(0x7E1609, p1_tertiary)
end

function ycursor_set()
	memory.writebyte(0x7E1709, p1_primary)
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
memory.registerread(0x7E1609, 2, xcursor_set)
memory.registerread(0x7E1709, 2, ycursor_set)
