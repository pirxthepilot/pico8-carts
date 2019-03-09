pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
x=63
y=10
vx=0
vy=0
g=0.1
j=0.25
end

function _update()
	if btn(2) then vy-=j
	else vy+=g end
 y+=vy
end

function _draw()
	cls()
	circfill(x,y,4,12)
end
