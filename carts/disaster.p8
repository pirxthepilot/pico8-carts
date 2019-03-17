pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	-- starting y
	map_y=33

	-- lava
	lava_init()
	oy=map_y+32
	make_veinset(55,oy,veinset_count)
	make_veinset(56,oy,veinset_count)
	make_veinset(57,oy,veinset_count)
 make_veinset(58,oy,veinset_count)

	-- magma
	magma_init(40,56+map_y,0.2)

	-- char
	make_char(80,40+map_y)

	-- help!
	make_help(12)

	-- instructions
	make_text()

	-- volcano sound
	sfx(0)
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
	
	-- update magma movement
	magma_update()
	
	-- char
	char_update()
	
	-- help!
	help_update()
	
	-- instructions
	text_update()
end

function _draw()
	cls()
	text_draw()
	magma_draw()
	backdrop_draw()
	lava_draw()
	char_draw()
	help_draw()
end
-->8
-- lava
-- lava init
function lava_init()
	grav=0.1
	lava_cols={8,9,10}
	parts={}
	veinsets={}
	veinset_count=6
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

-- draw the lava particles
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

-- backdrop
function backdrop_draw()
	palt(0,false)
	map(0,0,0,map_y,128,64)
	palt()
end
-->8
-- magma
function magma_init(_sx,_sy,_spd)
	magma={
		cx=16,
		cy=0,
		sx=_sx,
		sy=_sy,
		og_sy=_sy,
		cw=4,
		ch=2,
		spd=_spd
	}
end

function magma_update()
	magma.sy-=magma.spd
	if magma.og_sy-magma.sy>=magma.ch*8 then
		magma.sy=magma.og_sy
	end
end

function magma_draw()
	map(magma.cx,magma.cy,magma.sx,magma.sy,magma.cw,magma.ch)
	map(magma.cx,magma.cy,magma.sx,magma.sy+(magma.ch*8),magma.cw,magma.ch)
	rectfill(magma.sx,magma.og_sy+32,magma.sx+(magma.cw*8),magma.og_sy+(magma.ch*8),0)
end
-->8
-- help!
--	note: dependent on char
function make_help(_maxage)
	hlp={
		on=false,
		age=0,
		maxage=_maxage
	}
end

function help_update()
	if btnp(4) then
		hlp.on=true
		hlp.age=0
		sfx(1)
	else
		if hlp.age<hlp.maxage then
			hlp.age+=1
		else
			hlp.on=false
			hlp.age=0
		end
	end
end

function help_draw()
	if hlp.on then
		spr(9,char.x+16,char.y-16,2,2)
	end
end

-->8
-- character
function make_char(_x,_y)
	char={
		x=_x,
		y=_y,
		dx=0,
		maxdx=2,
		acc=0.5,		--walk accel
		frc=0.65,		--walk friction
		s={},     		--sprites
		sid=1,			--sprite index
		sdly=4,			--dly bet frames
		stime=0,
		w=2,
		h=2,
	}
end

function char_update()
	local s_stand={7,64}
	local s_left={66,68}
	local s_right={70,72}
	
	if btn(0) then
		if char.dx>-char.maxdx then
			char.dx-=char.acc
		end
		char.s=s_left
	elseif btn(1) then
		if char.dx<char.maxdx then
			char.dx+=char.acc
		end
		char.s=s_right
	else
		if char.dx!=0 then
			char.dx*=char.frc
		end
		char.s=s_stand
	end
	if not on_edge() then
		char.x+=char.dx
	else
		char.dx=0
	end
	char_anim()
end

function char_draw()
	spr(char.s[char.sid],char.x,char.y,char.w,char.h)
end

function char_anim()
	if char.stime<char.sdly then
		char.stime+=1
	else
		char.stime=0
		if char.sid<#char.s then
			char.sid+=1
		else
			char.sid=1
		end
	end
end
-->8
-- text instructions
function make_text()
	text={
		start_y=0,
		w={
			"\139 \145 to run!",
			"\142 to cry"
		},
		pressed=false,
	}
end

function text_update()
	if btn(0) or btn(1) or btn(4) then
		text.pressed=true
	end
end

function text_draw()
	if not text.pressed then
		for i=1,#text.w do
			local ind=64-#text.w[i]*2
			print(text.w[i],ind,text.start_y+(i*8)-8)
		end
	end
end

function on_edge()
	if
		(char.x<0 and not btn(1)) or
		(char.x+(char.w*8)>127 and not btn(0))
	then
		return true
	else
		return false
	end
end
__gfx__
000000000000055999550000000000003333333349494444000000000044444444444400000077777777000088899989aa9aa8aaaaaaa8aaaaaa999800000000
0000000000000559995500000000000043444443444444940000000000444444444444440077777777777700999999a8aa8888999a8998a99999aa9800000000
007007000000555aaa555500000000004434443449449444000000000044fffffffff444077777777777777089999889aa88899aa8999888a999aaa800000000
000770000000555aaa55550000000000444444449444499400000000440ffffffffff444777777777777777789999999a8888aaa8988998aa999a99800000000
0007700000555555aa55555500000000449444944494444400000000440ff55fff55f04477e7e7ee7e77eee79989989a88889aa9898a9988a9a8998a00000000
00700700005555aaaa55555500000000444494444666666600000000000ff55fff55f04477e7e7e77e77e7e7989899a98a8aaaa99988888a89a9998a00000000
00000000555588aa5555555500000000494494446655555500000000000ffffffffff00077eee7ee7e77eee7989989a8888aaa99989889aa9998898a00000000
000000005555885aa5aa555500000000444444445555555500000000000ffffffffff00077e7e7e77e77e777a8989a88888aa999a9889aa988a899a800000000
000000005555995aa558895500000000909999000000000000000000000000888800000077e7e7ee7ee7e777899aaaa99aaaaa889899aa998888888800000000
00000000595599995888895500000000aaaaaa000000000000000000000000888800000077777777777777778999aaa9aaaa8a9999aaa9998998888800000000
0000000059559999588555550000000000000aa00099999900000000000ddd8888ddd000077777777777777089a999a9aaa8a999889aa99899a9999800000000
00000000588858895885885500000000000009aa099000000000000000000088880000000077777777777700a9a999a99aaa9999898aa999aaaaaa9900000000
000000005888588588858855000000000000090a0990aa000000000000000088880000000077777777770000aa8999aa8a999999999aaaaa9999999800000000
000000005555555588555555000000000000090a9090a0aa00000000000000e00e0000000077000000000000a99999a999aa9999999aaaaa8888888800000000
0000000055555555885555550000000090000900a090900a00000000000000e00e0000000770000000000000a98899a9aaaaa99999aaaaaa9999988800000000
0000000055555599885555550000000090000900a090900000000000000000e00e0000007000000000000000a99999a9aaaaa99889aaa999aaaaa99900000000
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
00444444444444000044444444444400004444444444440000444444444444000044444444444400000000000000000000000000000000000000000000000000
00444444444444440044444444444444004444444444444400444444444444440044444444444444000000000000000000000000000000000000000000000000
0044fffffffff4440044fffffffff4440044fffffffff4440044fffffffff4440044fffffffff444000000000000000000000000000000000000000000000000
440ffffffffff444440ffffffffff444440ffffffffff444440ffffffffff444440ffffffffff444000000000000000000000000000000000000000000000000
440ff55fff55f044440f55fff55ff044440f55fff55ff044440fff55fff55044440fff55fff55044000000000000000000000000000000000000000000000000
000ff55fff55f044000f55fff55ff044000f55fff55ff044000fff55fff55044000fff55fff55044000000000000000000000000000000000000000000000000
000ffffffffff000000ffffffffff000000ffffffffff000000ffffffffff000000ffffffffff000000000000000000000000000000000000000000000000000
000ffffffffff000000ffffffffff000000ffffffffff000000ffffffffff000000ffffffffff000000000000000000000000000000000000000000000000000
000d00888800d0000000008888000000000d00888800d0000000008888000000000d00888800d000000000000000000000000000000000000000000000000000
0000d088880d000000000088880000000000d088880d000000000088880000000000d088880d0000000000000000000000000000000000000000000000000000
00000d8888d00000000ddd8888ddd00000000d8888d00000000ddd8888ddd00000000d8888d00000000000000000000000000000000000000000000000000000
00000088880000000000008888000000000000888800000000000088880000000000008888000000000000000000000000000000000000000000000000000000
00000088880000000000008888000000000000888800000000000088880000000000008888000000000000000000000000000000000000000000000000000000
000000e00e000000000000e00e000000000000e00e000000000000e00e000000000000e00e000000000000000000000000000000000000000000000000000000
000000e00e000000000000e00e000000000000e00e000000000000e00e000000000000e00e000000000000000000000000000000000000000000000000000000
000000e00e0000000000000e0e000000000000e000e00000000000e0e000000000000e000e000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000000000000b0c0d0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002c2d000000000000000000000000001b1c1d1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003c3d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000292a1112272800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000393a2122373800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404000000000404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00080020116500e6500c6500a65007650046500c65010650106500d6500a6500865004650066500c6500f650116500f6500d6500b6500765004650076500a6500d6500f650106500d65009650076500b6500d650
000400002f7502e7502d7502d7502b75025750237501d7501975001700127000e7000b70007700027000170000700007000070000700007000070000700007000070000700007000070000700007000070000700
