local socket = require "socket"

udp = socket.udp()
udp:settimeout(0)
udp:setpeername("localhost", 3478)
udpcontrol_timeout = 120
udp_sendevery = 60
udp_counter = 0

meow = "meow"

function mainloop()
		data = nil
		data = udp:receive()
		
		udp:send(meow)
		
		if data then
			print(data)
		end
end

emu.registerbefore(mainloop)