pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	grav=0.1
	oy=80
	parts={}
	for i=0,15 do
		local r_maxdy=rnd(2)
		local r_angle=rndangle(135,90)
		make_part(31,oy,0,0,r_maxdy,r_angle,i)
	end
end

function _update()
	for i in all(parts) do
		update_part(i)
	end
end

function _draw()
	cls()
	rectfill(0,oy,127,oy+2,10)
	for i in all(parts) do
		draw_part(i)
	end
end
-->8
-- particles
function make_part(_x,_y,_dx,_dy,_maxdy,_a_rot,_col)
	add(parts, {
		x=_x,
		y=_y,
		dx=_dx,
		dy=_dy,
		maxdy=_maxdy,
		a_rot=_a_rot,
		up=true,
		col=_col
	})
end

function update_part(p)
	if p.up then
		if p.dy>-p.maxdy then
			p.dy-=grav
		else
			p.up=false
		end
	else
		if p.dy<p.maxdy then
			p.dy+=grav
		else
			p.up=true
		end
	end
	p.y+=p.dy
	p.x+=grav*cos(a_rot)
	//p.x+=cos(a_rot)
end

function draw_part(p)
	//print('x:'..p.x..' y:'..p.y)
	pset(p.x,p.y,p.col)
end
-->8
-- helper functions

-- convert degrees to rotation
function rotval(degrees)
	return degrees/360
end

-- get angle diff
-- input: rightmost,leftmost
--        (clockwise dir)
-- input in rotation!
function rotdiff(_r,_l)
	return (_r-_l)%1
end

-- random angle given r and l
-- input in degrees!
function rndangle(_r,_l)
	local r=rotval(_r)
	local l=rotval(_l)
	local diff=rotdiff(r,l)
	return (l+(rnd()*diff))%1
end