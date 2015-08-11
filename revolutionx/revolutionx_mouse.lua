--quick port of Wild Guns mouse script for Revolution X. Why? That's a damn good question.
MouseLag = 0 --make the mouse pointer lag by this number of frames. to increase the difficulty I guess?

xcursoroffset = -2
ycursoroffset = -2

--addresses
address_p1_cursorx = 0x7E071B
address_p1_cursory = 0x7E0723
--most of these screens aren't used in the script, but I've documented them for reference

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
p1_tertiary = "middleclick"

screenchecka = 0
gui.opacity(0.5)
print("Mouse Control for Revolution X by mntorankusu - AnaLua project")
print("Use the arrow keys to adjust the X and Y offset until the crosshair position matches your mouse. This is likely to change if you resize the emulator window.")

function mousecontrol()
	
	output = {}
	keyinput = {}
	
	keyinput = input.get()
	
	gui.text(2,1, string.format("X: %i - Y: %i", keyinput.xmouse, keyinput.ymouse))
	gui.text(2,216, "Revolution X with Mouse Aiming - AnaLua project Lua script")
	
	if (MouseLag == 0) then
		p1_x = keyinput.xmouse-xcursoroffset
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
		
	if input.get()[p1_primary] then
		output.Y = true
	end

	if input.get()[p1_secondary] then
		output.B = true
	end
	
	if input.get()[p1_tertiary] then
		output.Y = switch
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

function xcursor_set()
	memory.writebyte(0x7E071B, p1_x)
end

function ycursor_set()
	memory.writebyte(0x7E0723, p1_y)
end


emu.registerbefore(mousecontrol)


memory.registerwrite(0x7E0000, gamecurrentscreen)

memory.registerwrite(0x7E071B, 1, xcursor_set)
memory.registerwrite(0x7E0723, 1, ycursor_set)

memory.registerread(0x7E071B, 1, xcursor_set)
memory.registerread(0x7E0723, 1, ycursor_set)