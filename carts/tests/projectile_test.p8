pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	grav=0.1
	oy=80
	parts={}
	for i=0,15 do
		local r_maxdy=rnd(2)
		local r_maxage=rndrange(r_maxdy*20,r_maxdy*50)
		local r_angle=rndangle(135,90)
		make_part(31,oy,0,0,r_maxdy,r_maxage,r_angle,i)
	end
end

function _update()
	for i=0,1 do
		local r_maxdy=rnd(2)
		local r_maxage=rndrange(r_maxdy*20,r_maxdy*40)
		local r_angle=rndangle(135,90)
		local r_color=rnd(15)
		make_part(31,oy,0,0,r_maxdy,r_maxage,r_angle,r_color)
	end
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
function make_part(_x,_y,_dx,_dy,_maxdy,_maxage,_a_rot,_col)
	add(parts, {
		x=_x,
		y=_y,
		dx=_dx,
		dy=_dy,
		maxdy=_maxdy,
		age=0,
		maxage=_maxage,
		a_rot=_a_rot,
		up=true,
		col=_col
	})
end

function update_part(p)
	if p.age>=p.maxage then
		del(parts,p)
		return
	end
	if p.up then
		if p.dy>-p.maxdy then
			p.dy-=grav
		else
			p.up=false
		end
	else
		p.dy+=grav
	end
	p.y+=p.dy
	p.x+=grav*1.5*cos(a_rot)
	p.age+=1
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

-- random number from a range
function rndrange(lower,upper)
	local interval=upper-lower+1
	local r=flr(rnd(interval))
	return r+lower
end