pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	map_y=33
	lava_init()
	oy=map_y+32
	make_veinset(55,oy,veinset_count)
	make_veinset(56,oy,veinset_count)
	make_veinset(57,oy,veinset_count)
end

function _update()
	-- veinsets and veins
	for i in all(veinsets) do
		-- lava vein and particle creation
		if #i.veins<i.count then
			make_vein(i.veins,i.x,i.y)
		end
		for j in all(i.veins) do
			update_vein(i.veins,j)
		end
	end

	-- update lava particles
	for i in all(parts) do
		update_part(i)
	end
end

function _draw()
	cls()
	map(0,0,0,map_y,128,64)
	lava_draw()
end
-->8
-- lava
-- lava init
function lava_init()
	grav=0.1
	lava_cols={8,9,10}
	parts={}
	veinsets={}
	veinset_count=8
	min_vein_len=2
	max_vein_len=10
end

-- lava particles
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
	p.dx+=grav*cos(p.a_rot)
	p.x+=p.dx
	p.age+=1
end

function draw_part(p)
	pset(p.x,p.y,p.col)
end
-->8
-- lava veins
function make_vein(_vein,_x,_y)
	local r_maxdy=rndrangef(0.5,1.6)
	add(_vein, {
		x=_x,
		y=_y,
		len=rndrange(min_vein_len,max_vein_len),
		maxdy=r_maxdy,
		maxage=rndrange(r_maxdy*20,r_maxdy*40),
		angle=rndangle(285,255),
		color=lava_cols[flr(rnd(#lava_cols))+1]
	})
end

function update_vein(_veins,v)
	if v.len==0 then
		del(_veins,v)
		return
	end
	make_part(v.x,v.y,0,0,v.maxdy,v.maxage,v.angle,v.color)
	v.len-=1
end

function make_veinset(_x,_y,_count)
	add(veinsets, {
		x=_x,
		y=_y,
		count=_count,
		veins={}
	})
end

-- Draw the lava particles
function lava_draw()
	for i in all(parts) do
		draw_part(i)
	end
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

-- random number from a range (float)
function rndrangef(lower,upper)
	local interval=upper-lower
	local r=rnd(interval)
	return r+lower
end
__gfx__
000000000000055999550000000000003333333349494444000000000044444444444400000077777777000088899989aa9aa8aaaaaaa8aa0000000000000000
0000000000000559995500000000000043444443444444940000000000444444444444440077777777777700999999a8aa8888999a8998a90000000000000000
007007000000555aaa555500000000004434443449449444000000000044fffffffff444077777777777777089999889aa88899aa89998880000000000000000
000770000000555aaa55550000000000444444449444499400000000440ffffffffff444777777777777777789999999a8888aaa8988998a0000000000000000
0007700000555555aa55555500000000449444944494444400000000440ff55fff55f04477e7e7ee7e77eee79989989a88889aa9898a99880000000000000000
00700700005555aaaa55555500000000444494444666666600000000000ff55fff55f04477e7e7e77e77e7e7989899a98a8aaaa99988888a0000000000000000
00000000555588aa5555555500000000494494446655555500000000000ffffffffff00077eee7ee7e77eee7989989a8888aaa99989889aa0000000000000000
000000005555885aa5aa555500000000444444445555555500000000000ffffffffff00077e7e7e77e77e777a8989a88888aa999a9889aa90000000000000000
000000005555995aa558895500000000909999000000000000000000000000888800000077e7e7ee7ee7e7770000000000000000000000000000000000000000
00000000595599995888895500000000aaaaaa000000000000000000000000888800000077777777777777770000000000000000000000000000000000000000
0000000059559999588555550000000000000aa00099999900000000000555888855500007777777777777700000000000000000000000000000000000000000
00000000588858895885885500000000000009aa0990000000000000000000888800000000777777777777000000000000000000000000000000000000000000
000000005888588588858855000000000000090a0990aa0000000000000000888800000000777777777700000000000000000000000000000000000000000000
000000005555555588555555000000000000090a9090a0aa00000000000000500500000000770000000000000000000000000000000000000000000000000000
0000000055555555885555550000000090000900a090900a00000000000000500500000007700000000000000000000000000000000000000000000000000000
0000000055555599885555550000000090000900a090900000000000000000500500000070000000000000000000000000000000000000000000000000000000
0000000055555555855555550000000009000900a09a900000000000550000000000000000000000000000550000000000000000000000000000000000000000
0000000055555555855555550000000000900900a009900000000000555000000000000000000000000005550000000000000000000000000000000000000000
0000000055aaaa55855555550000000000900900a00a000000000000555500000000000000000000000055550000000000666666566666000000000000000000
0000000055aaa555885555550000000000900900a00a000000000000555550000000000000000000000555550000000000566666666566000000000000000000
00000000aaa55558855555550000000000900900a009a00000000000555555000000000000000000005555550000000000665656666666000000000000000000
00000000aa555888555555550000000000900900a009a00000000000555555500000000000000000055555550000000000666666656566000000000000000000
000000005555885555555555000000000090090a0009a00000000000555555550000000000000000555555550000000000656656666566000000000000000000
000000005558885555555555000000000090090a0009a00000000000555555555000000000000005555555550000000000666656556666000000000000000000
00000000955985555555555500000000000000000000000000000000555555555500000000000055555555550000000000666566666656000000000000000000
00000000999985555555555500000000000000000000000000000000555555555550000000000555555555550000000000666565656666000000000000000000
00000000555588555555555500000000000000000000000000000000555555555555000000005555555555550000000000656666656666000000000000000000
00000000555588555555555500000000000000000000000000000000555555555555500000055555555555550000000000666566666666000000000000000000
00000000555888555555555500000000000000000000000000000000555555555555550000555555555555550000000000665665666566000000000000000000
00000000558855555555555500000000000000000000000000000000555555555555555005555555555555550000000000666666666666000000000000000000
00000000588855555555555500000000000000000000000000000000555555555555555555555555555555550000000000000000000000000000000000000000
00000000588855555555555500000000000000000000000000000000555555555555555555555555555555550000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002c2d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003c3d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000090a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000010200000000191a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000292a1112272807080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000393a2122373817180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040c0b0b0d0404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
