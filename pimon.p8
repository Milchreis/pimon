pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- pimon
-- by milchreis
-- inspired by simon game

-- game states
sm={
	states={"menu","game", "gameover"},
	current="menu",
}

function sm:in_game()
	return sm.current == sm.states[2]
end

function sm:in_menu()
	return sm.current == sm.states[1]
end

function sm:in_gameover()
	return sm.current == sm.states[3]
end

function sm:to_game()
	sm.current = sm.states[2]
end

function sm:to_menu()
	sm.current = sm.states[1]
end

function sm:to_gameover()
	sm.current = sm.states[3]

	local correct = (#rounds.expected) - 2
	local global_best = dget(0)
	
	if correct > global_best then
		dset(0, correct)
		best = correct
	end

end

-->8
-- particles
function new_emitter(x, y) 
	local e = {}
	e.position_x = x
    e.position_y = y
	e.color = {8, 8, 8, 14}
	e.width = 1
    e.height = 1
	e.drag = 0.9
	e.ttl = 60
	e.gravity_x = 0.0
	e.gravity_y = 0.3
	e.gravity_x = 0 
	e.emitter = {}
	e.particles = {}
	e.particle_limit = 10
	e.ticks = 0

	e.start = function(ticks)
		e.ticks = ticks
	end

	e.emit = function()
		if #e.particles >= e.particle_limit then
			del(e.particles, e.particles[1])
		end
		add(e.particles, {})
		e.particles[#e.particles].emitter = e.emitter
		e.particles[#e.particles].position_x = e.position_x + rnd(e.width-1)
		e.particles[#e.particles].position_y = e.position_y + rnd(e.height-1)
		e.particles[#e.particles].velocity_x = e.velocity_x
		e.particles[#e.particles].velocity_y = e.velocity_y
		e.particles[#e.particles].ttl = e.ttl
	end

	e.update = function()
		if e.ticks <= 0 then
		e.particles = {}
			return
		end
		
		e.ticks = max(0, e.ticks - 1)

		e.velocity_x = rnd(4)-2
    	e.velocity_y = rnd(4)-2
		e.emit()

		for particle in all(e.particles) do
			if particle.ttl > 0 then
				particle.velocity_y += e.gravity_x
				particle.velocity_y += e.gravity_y
				particle.velocity_x = particle.velocity_x * e.drag
				particle.velocity_y = particle.velocity_y * e.drag
				particle.old_position_x = particle.position_x
				particle.old_position_y = particle.position_y
				particle.position_x += particle.velocity_x
				particle.position_y += particle.velocity_y
				particle.ttl -= 1
			else
				del(e.particles, particle)
			end       
    	end
	end

	e.draw = function() 
		for particle in all(e.particles) do
			local col = flr(rnd(#e.color)+1)
			line(particle.old_position_x, 
				particle.old_position_y, 
				particle.position_x, 
				particle.position_y,
				e.color[col])
		end
	end

	return e
end


-->8
-- sprite
function new_sprite(sprites, x, y) 
	local s={}
	s.x, s.y = x, y
	s.tick, s.frame, s.step=0,1,5
	s.sprites=sprites
	s.started=true
	s.loop=false

	s.start_loop = function()
		s.started=true
		s.loop=true
	end

	s.start_once = function()
		s.started=true
	end

	s.stop = function()
		s.started=false
	end

	s.update = function()
		if s.started then
			s.tick=(s.tick+1)%s.step
			if (s.tick==0) s.frame=s.frame% #s.sprites+1
		end
	end

	s.draw = function()
		spr(s.sprites[s.frame],s.x,s.y)
	end

	return s
end

-->8
-- score
function new_score()
	local s = {}
	s.x = 2
	s.y = 2
	s.color = 7
	s.points = 0
	s.last_points = 0
	s.vel = 0
	
	s.draw = function()
		-- aniamtion for new points
		s.vel = max(0, s.vel - 1.1)
	
		print("★ " .. s.points, 
								s.x, s.y-s.vel, 7)
	end
	
	s.draw_best = function(best)
		print("best ★ " .. best, s.x, s.y, 7)
		if not best == nil then
		end
	end
	
	s.inc_score = function()
		s.points += 1
		s.vel = 4
	end
	
	s.reset = function()
		s.last_points = s.points
		s.points = 0
	end
	
	return s
end

-->8
-- livebar
function new_livebar()
	local s = {}
	s.lives = 0
	s.steps = 0
	s.vel = 0
	s.emitter = new_emitter(122, 5)

	s.reset = function()
		s.lives = 0
		s.steps = 0
	end

	s.inc_steps = function()
		s.steps += 1

		if s.steps > 3 then
			s.steps = 0
			s.inc_lives()
			sfx(6)
		end
	end

	s.inc_lives = function()
		s.lives = min(3, s.lives + 1)
		s.vel = 6
	end

	s.decr_lives = function()
		s.lives = max(0, s.lives - 1)
		s.emitter.position_x = 121 - (s.lives*9)
		s.emitter.start(20)
	end

	s.update = function()
		s.emitter.update()
		s.vel = max(0, s.vel - 1.1)
	end

	s.draw = function()
		-- lives
		fillp(pat[4])
		for i=2,0,-1 do
			local sprite = s.lives-i > 0 and 13 or 12
			spr(sprite, 118 - (i*9), 1 - (s.vel*(i+2)))
		end
		fillp()

		-- steps
		for i=2,0,-1 do
			local col = s.steps-i > 0 and 8 or 14
			rectfill(119 - (i*9), 11, 125 - (i*9), 12, col)
		end
		
		s.emitter.draw()
	end

	return s
end

-->8
-- button
function new_btn(x, y, i, k, s)
	local b = {}
	b.x = x
	b.y = y
	b.down=false
	b.preview=false
	b.released=false
	b.circ_r=0
	b.circ_on=false
	b.sparkle=new_sprite({11,10,9}, b.x+9, b.y)

	b.draw_click_effect = function()
		if b.circ_on then
			if b.circ_r > 10 then
				oval(b.x-5 - b.circ_r, b.y+6-b.circ_r/2,
						b.x+19+b.circ_r, b.y+16+b.circ_r, 5)
			else
				oval(b.x-5 - b.circ_r, b.y+6-b.circ_r/2,
						b.x+19+b.circ_r, b.y+16+b.circ_r, 7)
			end
		end
	end

	b.draw = function()
		
		if b.down or b.preview then
			ovalfill(
				b.x-5, b.y+6,
				b.x+19, b.y+16, 
				7
			)
		 spr(i+32,b.x,b.y,2,2)
		else		
			ovalfill(
				b.x-4, b.y+4,
				b.x+18, b.y+16, 
				6
			)
			spr(i,b.x,b.y,2,2)
		end

		if b.down == false then
			b.sparkle.draw()
		end
	end

	b.update = function()
		if btnp(k) and not(rounds.in_presentation) then
			b.down=true
		end
		
		b.released=not btn(k)
		
		if (b.down or b.preview) and b.released then
			sfx(s)
			b.circ_on = true
			shake_offset=0.03
			if b.down then
				add(rounds.acutal, s)
			end
		end
	
		if (b.released) then
			b.down=false
		end

		if b.circ_on then
			b.circ_r+=1.8

			if b.circ_r > 14 then
				b.circ_r=0
				b.circ_on=false
			end
		end
		
		b.sparkle.update()
 	end
 return b
end

-->8
-- logo
function draw_logo()
	local pulse_off=(cos(time() * 0.85) * 3)
	
	for i=1,10 do
		local pat_index = min(ceil(-pulse_off+9), #pat)
		fillp(pat[pat_index])
		circfill(41+i*4, 14, 10+pulse_off, 1)
	end

	fillp()

	for i=0,3 do
		local off = i / 10
		local ly = sin(t() * 1.7+off) * 2

		spr(64 + i, 
			48 + (i*8), 
			10 + ly, 1, 2)
	end
end

-->8
-- game_over screen
function popup(x, y, show_time)
	local s = {}
	s.fade = 0
	s.init_x = x
	s.init_y = y
	s.init_show_time = show_time
	s.x = x
	s.y = y
	s.fade_in_speed=10
	s.fade_out_speed=20
	s.show_time=show_time

	s.reset = function()
		s.x = s.init_x
		s.y = s.init_y
		s.show_time = s.init_show_time
	end

	s.draw = function(message)

		if s.show_time >= 0 then
			s.x = max(-10, s.x - s.fade_in_speed)
			s.y = max(s.init_y - 10, s.y - 1)
			s.show_time-=1
			rectfill(s.x, s.y, 128 - s.x, s.y + 10, 0)
		else
			s.x = max(-128, s.x - s.fade_out_speed)
			rectfill(s.x, s.y, s.x + 127, s.y + 10, 0)
		end

		print(message, s.x + 35, s.y + 3, 7)
	end
	return s
end

-->8
-- camera_shake
function screen_shake()
	local fade = 0.85
	local offset_x=16-rnd(32)
	local offset_y=16-rnd(32)
	offset_x*=shake_offset
	offset_y*=shake_offset

	camera(offset_x,offset_y)
	shake_offset*=fade
	if shake_offset<0.02 then
		shake_offset=0
	end
end

-->8
-- rounds

rounds={
	current=1,
	speed=1000,
	next_sound_time=nil,
	next_sound=nil,
	expected={},
	acutal={},
	in_presentation=true
}

function rounds:reset()
	rounds.in_presentation=true
	rounds.next_sound_time=time()+1
	rounds.pause=0.72
	rounds.next_sound=1
	rounds.acutal={}
	rounds.expected={ceil(rnd(4)), ceil(rnd(4))}
end

function rounds:repeat_round()
	rounds.in_presentation=true
	rounds.acutal={}
	rounds.next_sound=1
	rounds.next_sound_time=time()+rounds.pause+1
end

function rounds:next_round()
	rounds.in_presentation=true
	rounds.pause=max(0.35, rounds.pause-0.08)
	rounds.acutal={}
	rounds.next_sound=1
	rounds.next_sound_time=time()+rounds.pause
	add(rounds.expected, ceil(rnd(4)))
end

function rounds:update()

	local input_equal=true
	for i=1,#rounds.acutal do
		if rounds.acutal[i] != rounds.expected[i]	then
			if lives.lives == 0 then
				sm.to_gameover()
				score.reset()
				rounds.reset()
				input_equal=false
				sfx(0)
			else
				lives.decr_lives()
				sfx(7)
				rounds.repeat_round()
			end

			shake_offset=0.5
		end
	end
		
	if #rounds.acutal == #rounds.expected and input_equal then
		score.inc_score()
		lives.inc_steps()
		rounds.next_round()
		sfx(5)
	end

	if rounds.next_sound > #rounds.expected then
		rounds.in_presentation=false
		for button in all(buttons) do
			button.preview=false
		end
		return
	end

	if t() > rounds.next_sound_time then
		local btn_index = rounds.expected[rounds.next_sound]
		local button = buttons[btn_index]
		button.preview=true
		rounds.next_sound_time=time()+rounds.pause
		rounds.next_sound+=1
	else
		for button in all(buttons) do
			button.preview=false
		end
	end
end

-->8
-- dithering

pat={
 0B1000000000000000,
 0B1000000000100000,
 0B1010000000100000,
 0B1010000010100000,
 0B1010010010100001,
 0B1110010110100101,
 0B1110010110110101,
 0B1111010110110101,
 0B1111010111110101,
 0B1111110111110111
}

function draw_vignette(x, y, c1, c2, iw, w) 
	for i=10,1,-1 do
		fillp(pat[i])
		local offset = w*i
		circfill(x, y, iw+offset, c1, c2)
	end
	
	fillp()
	circfill(64, 64, iw, c1)
end

function draw_gradient(x, y, w, h, c1, c2)
	
	for i=x,x+(w*4),4 do
		for j=y,y+(h*4),4 do
			local cur = ceil((((j-y)/4) / h) * #pat)
			fillp(pat[cur])
			rectfill(i, j, i+4, j+4, c1, c2)
		end
	end
	fillp()
end

-->8
-- game

function _init()	

	-- buttons
	local x=56
	local y=35
	yellow=new_btn(x,y,1,⬆️,1)
	blue=new_btn(x,y+40,3,⬇️,2)
	pink=new_btn(x+20,y+20,7,➡️,3)
	green=new_btn(x-20,y+20,5,⬅️,4)
	
	buttons={yellow, blue, pink, green}

	points_gameover = popup(64, 64, 250)
	best_gameover = popup(64-10, 64 + 12, 260)

	shake_offset=0
	score = new_score()
	lives = new_livebar()

	cartdata("pimon")
	best = dget(0)
end

function _update()
	if not sm.in_game() and btnp(❎) then
		sm.to_game()
		rounds.reset()
		lives.reset()
		points_gameover.reset()
		best_gameover.reset()
	end

	for button in all(buttons) do
		button.update()
	end

	if sm.in_game() then
		rounds.update()
		lives.update()
	end
end

function _draw()
	cls(0)

	draw_vignette(64, 64, 1, 0, 53, 3)

	if sm.in_menu() or sm.in_gameover() then

		local y = 110+ (cos(time() * 0.8) * 2)
		print("      ❎", 20, y+1, 5)
		print("press ❎ to start game", 
								20, y, 7)
		draw_logo()
	end
	
	for button in all(buttons) do
		button.draw_click_effect()
	end

	for button in all(buttons) do
		button.draw()
	end

	if sm.in_gameover() then
		points_gameover.draw("your points " .. score.last_points)
		best_gameover.draw("your best " .. best)
	end

	if sm.in_game() then
		
		score.draw()
		lives.draw()

		if rounds.in_presentation then
			local x = 62
			local y = 15 + (cos(time() * 1) * 2)
			circfill(x+1, y+2, 4, 12)
			circ(x+1, y+2, 6+((17-y)), 12)
			print("!", x, y, 7)
		end
	end

	screen_shake()

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e000e000e000e00000000000000000
00700700000009999900000000000ccccc00000000000bbbbb00000000000eeeee0000000070700000070000000000000e0e0e0e088e088e0000000000000000
00077000009999999999900000ccccccccccc00000bbbbbbbbbbb00000eeeeeeeeeee0000000000000707000000700000e00e00e088888880000000000000000
0007700009979997999999000cc7cc777ccccc000bb7bbb7bbbbbb000ee7eee7eeeeee000070700000070000000000000e00000e088888880000000000000000
007007009979997779999990cc7ccc777cccccc0bb7bbb7777bbbbb0ee7ee7777eeeeee000000000000000000000000000e000e0008888800000000000000000
000000009999977777999990ccccc77777ccccc0bbbbb77777bbbbb0eeeee77777eeeee0000000000000000000000000000e0e00000888000000000000000000
000000009999997779999990cccccc777cccccc0bbbbbb7777bbbbb0eeeee7777eeeeee00000000000000000000000000000e000000080000000000000000000
0000000049999977799997401cccccc7ccccc7103bbbbbb7bbbbb7302eeeeee7eeeee72000000000000000000000000000000000000000000000000000000000
00000000449999999999744011cccccccccc711033bbbbbbbbbb733022eeeeeeeeee722000000000000000000000000000000000000000000000000000000000
0000000044449999977444401111ccccc77111103333bbbbb77333302222eeeee772222000000000000000000000000000000000000000000000000000000000
00000000044444444444440001111111111111000333333333333300022222222222220000000000000000000000000000000000000000000000000000000000
00000000004444444444400000111111111110000033333333333000002222222222200000000000000000000000000000000000000000000000000000000000
00000000000044444440000000001111111000000000333333300000000022222220000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009999900000000000ccccc00000000000bbbbb00000000000eeeee00000000000000000000000000000000000000000000000000000000000000
00000000009999999999900000ccccccccccc00000bbbbbbbbbbb00000eeeeeeeeeee00000000000000000000000000000000000000000000000000000000000
0000000009979997999999000cc7cc777ccccc000bb7bbb7bbbbbb000ee7eee7eeeeee0000000000000000000000000000000000000000000000000000000000
000000009979997779999990cc7ccc777cccccc0bb7bbb7777bbbbb0ee7ee7777eeeeee000000000000000000000000000000000000000000000000000000000
000000009999977777999990ccccc77777ccccc0bbbbb77777bbbbb0eeeee77777eeeee000000000000000000000000000000000000000000000000000000000
0000000049999977799997401ccccc777cccc7103bbbbb7777bbb7302eeee7777eeee72000000000000000000000000000000000000000000000000000000000
00000000049999777999740001ccccc7cccc710003bbbbb7bbbb730002eeeee7eeee720000000000000000000000000000000000000000000000000000000000
0000000000449999997440000011cccccc7110000033bbbbbb7330000022eeeeee72200000000000000000000000000000000000000000000000000000000000
00000000000044444440000000001111111000000000333333300000000022222220000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaa0aa0ccc0ccc00bbbb00eee0ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaa0aa0ccc0ccc0bb33bb0eee0ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa99aa0aa0cc1c1cc0bb00bb0ee2eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa00aa0aa0cc0c0cc0bb00bb0ee0eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaa0aa0cc010cc0bb00bb0ee02ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaa0aa0cc000cc0bb00bb0ee00ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa99990aa0cc000cc0bb00bb0ee00ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa00000aa0cc000cc03bbbb30ee00ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99000009901100011003333002200220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0005000037150301502b150241501d15018150131500f1500a1500515000150001500015000150001500015000150001501b0001f000220002300022000200001c0001a000180001500014000150001600017000
0004000013050130501305013050000002100028000030002c0002f000330003600038000390003a0003a000380000100035000320002d000000002900025000210001e00018000100000b0000a0000a0000a000
000400001a0501a0501a0501a0500e40001400004003940030400274003300035000350000000035000000000000034000330000000032000300002a000260001d00000000000000000000000000000000000000
000400001705017050170501705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001f0501f0501f0501f05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300002b530275302e530270002e000050000200030000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000033030370303a03035030300302b0001d00018000110000100006000030001570014700137001370013700147000000000000000000000000000000000000000000000000000000000000000000000000
020300001b2501b25013250132500c2500c25005250052500a1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
