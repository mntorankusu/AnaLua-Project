--quick port of Wild Guns mouse script for Revolution X. Why? That's a damn good question.
MouseLag = 0 --make the mouse pointer lag by this number of frames. to increase the difficulty I guess?

xcursoroffset = 0
ycursoroffset = 0

xmouselag = {}
ymouselag = {}

for i = 1,MouseLag do
	xmouselag[i] = 0
	ymouselag[i] = 0
end

controls = {
MouseX = 0,
MouseY = 0, 
addresses = {},
values = {
	primary = "leftclick",
	secondary = "rightclick",
	tertiary = "middleclick",
	},
}

players = {
	controls
}

players[1].addresses.cursorx = 0x7E071B
players[1].addresses.cursory = 0x7E0723

p1_primary = "leftclick"
p1_secondary = "rightclick"
p1_tertiary = "middleclick"

screenchecka = 0
gui.opacity(0.5)
print("Mouse Control for Revolution X by mntorankusu - AnaLua project")
print("Use the arrow keys to adjust the X and Y offset until the crosshair position matches your mouse. This is likely to change if you resize the emulator window.")
messagelength = 60
function writemessage(themessage)
	if (themessage) then
		messagetimer = 0
		osdmessage = themessage
	end
end

writemessage("Revolution X with Mouse Aiming - AnaLua project Lua script")

function mousecontrol()

	gui.line(players[1].MouseX-1, players[1].MouseY, players[1].MouseX+1, players[1].MouseY, AAAAAAA)
	gui.line(players[1].MouseX, players[1].MouseY-1, players[1].MouseX, players[1].MouseY+1, AAAAAAA)

	if (osdmessage) then
		gui.text(2,219, osdmessage)
		messagetimer = messagetimer + 1
		if (messagetimer > messagelength) then
			osdmessage = nil
		end
	end
	
	output = {}
	keyinput = {}
	
	keyinput = input.get()
	
	--gui.text(2,1, string.format("X: %i - Y: %i", keyinput.xmouse, keyinput.ymouse))
	
	
	if (MouseLag == 0) then
		players[1].MouseX = keyinput.xmouse-xcursoroffset
		players[1].MouseY = keyinput.ymouse-ycursoroffset
	else
		for i = 1,MouseLag-1 do
			xmouselag[i] = xmouselag[i+1]
			ymouselag[i] = ymouselag[i+1]
		end
		xmouselag[MouseLag] = keyinput.xmouse+xscreenoffset-xcursoroffset
		ymouselag[MouseLag] = keyinput.ymouse-ycursoroffset
		players[1].MouseX = xmouselag[1]
		players[1].MouseY = ymouselag[1]
	end
	
	if players[1].MouseX > 255 then players[1].MouseX = 255 end
	if players[1].MouseY > 224 then players[1].MouseY = 224 end
		
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
			writemessage(string.format("X offset: %i", xcursoroffset))
		elseif input.get().right then
			xcursoroffset = xcursoroffset-0.25
			writemessage(string.format("X offset: %i", xcursoroffset))
		elseif input.get().up then
			ycursoroffset = ycursoroffset+0.25
			writemessage(string.format("Y offset %i", ycursoroffset))
		elseif input.get().down then
			ycursoroffset = ycursoroffset-0.25
			writemessage(string.format("Y offset %i", ycursoroffset))
		end 
	
	joypad.set(1, output)
end

function xcursor_set()
	memory.writebyte(0x7E071B, players[1].MouseX)
end

function ycursor_set()
	memory.writebyte(0x7E0723, players[1].MouseY)
end


emu.registerbefore(mousecontrol)


memory.registerwrite(0x7E0000, gamecurrentscreen)

memory.registerwrite(0x7E071B, 1, xcursor_set)
memory.registerwrite(0x7E0723, 1, ycursor_set)

memory.registerread(0x7E071B, 1, xcursor_set)
memory.registerread(0x7E0723, 1, ycursor_set)