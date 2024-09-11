pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- utility functions

function keep_player_in_screen()
    if player.hp > 0 then
        if player.x > 119 then
            player.x = 119
        end
        if player.x < 0 then
            player.x = 0
        end
        if player.y < 0 then
            player.y = 0
        end
        if player.y > 119 then
            player.y = 119
        end
    end
end

function subtract_bullet_delay()
    if bullet_delay > 0 then
        bullet_delay -= 1
    end
end

function move_bullets()
    for bullet in all(bullets) do
        bullet.y -= 2
        if bullet.y < 0 then del(bullets, bullet) end
    end
end

function shoot()
    if player.hp > 0 then
        sfx(0)
        bullet = {
            x = player.x,
            y = player.y - 9
        }
        add(bullets, bullet)
        bullet_delay = 30
    end
end

function flip_burner()
    player.burner_sprite_flip = not player.burner_sprite_flip
end

function score_up()
    if player.hp > 0 then
        score.counter += 1
        if score.counter > 19 then
            score.counter = 0
            score.value += 1
        end 
    end
end

function handle_player_death()
    if player.hp < 1 then
        player.x = 99999
        player.y = 99999
        music(-1)
        sfx(2)
    end
end

function generate_asteroid()
    if player.hp > 0 then
        if flr(rnd(15)) == 1 then
            asteroid = {
                sprite = flr(rnd(6)) + 4,
                x = flr(rnd(119)),
                y = flr(rnd(20)) - 28,
                movement_pattern = flr(rnd(5))
            }
            add(asteroids, asteroid)
        end 
    end
end

function move_asteroids()
    for asteroid in all(asteroids) do
        if asteroid.movement_pattern == 0 then
            asteroid.y += 1
        elseif asteroid.movement_pattern == 1 then
            asteroid.y += 2
        elseif asteroid.movement_pattern == 2 then
            asteroid.y += 3
        elseif asteroid.movement_pattern == 3 then
            asteroid.y += 2
            if asteroid.y > 0 then
                asteroid.x += 1
            end
        elseif asteroid.movement_pattern == 4 then
            asteroid.y += 2
            if asteroid.y > 0 then
                asteroid.x -= 1
            end
        else
            player.hp += 1
        end
    end
end

function dispose_asteroids()
    for asteroid in all(asteroids) do
        if asteroid.y > 127 then del(asteroids, asteroid) end
    end
end

-- checks for overlapping 8x8 hitboxes
function check_for_overlap(entity1, entity2)
    if (entity1.x+7 >= entity2.x and entity1.x <= entity2.x+7)
        and
        (entity1.y+7 >= entity2.y and entity1.y <= entity2.y+7)
        then return true
        else return false
    end
end

function handle_bullet_hits()
    for bullet in all(bullets) do
        for asteroid in all(asteroids) do
            if check_for_overlap(bullet, asteroid)
            then
                del(bullets, bullet)
                del(asteroids, asteroid)
                score.value += 1
                score.destroyed_asteroids += 1
                break
            end
        end
    end
end

function handle_asteroid_collisions()
    for asteroid in all(asteroids) do
        if check_for_overlap(player, asteroid) then
            player.hp -= 1
            if player.hp < 1 then
                handle_player_death()
            else sfx(1) end
            del(asteroids, asteroid)
        end
    end
end

function TEST_generate_asteroids()
    for i = 1, 10 do
        asteroid = {
            sprite = flr(rnd(6)) + 4,
            x = i * 10,
            y = 30,
            movement_pattern = 99
        }
        add(asteroids, asteroid)
    end
end

function restart()
    for i = 0,3 do sfx(-1, i) end
    player.x = 60
    player.y = 80
    player.hp = 3
    score.counter = 0
    score.value = 0
    score.destroyed_asteroids = 0
    for i in all(asteroids) do del(asteroids, i) end
    for i in all(bullets) do del(bullets, i) end
    bullet_delay = 0
end

-- end of utility functions

-- pico-8 functions

function _init()
--    TEST_generate_asteroids()
    player = {
        x = 60,
        y = 80,
        hp = 3,
        burner_sprite_flip = true
    }

    score = {
        counter = 0,
        value = 0,
        destroyed_asteroids = 0
    }

    bullet_delay = 0

    bullets = {}
    asteroids = {}

    menu = true
    music(0)
end

function _update60()
    if menu then
        if btn(4) and btn(5) then
            music(-1)
            menu = false
        end
    else
        flip_burner()

        if btn(0) then player.x -= 1 end
        if btn(1) then player.x += 1 end
        if btn(2) then player.y -= 1 end
        if btn(3) then player.y += 1 end

        subtract_bullet_delay()

        keep_player_in_screen()

        move_asteroids()

        dispose_asteroids()

        generate_asteroid()

        move_bullets()

        if btn(4) and bullet_delay == 0 then
            shoot()
        end

        score_up()

        handle_bullet_hits()

        handle_asteroid_collisions()

        if player.hp < 1 then
            if btn(4) and btn(5) then
                restart()
            end
        end
    end
end

function _draw()
    cls()
    if menu then
        print("space flight", 40, 64, 8)
        print("hit 🅾️ and ❎ to start", 25, 72, 7)
        print("use arrows to fly and 🅾️ to shoot", 0, 80)
        print("avoid asteroids and shoot them", 3, 88)
    else
        -- player and flame
        spr(1, player.x, player.y)
        spr(2, player.x, player.y + 8, 1, 1, player.burner_sprite_flip)

        print("score: " .. score.value)

        -- draw bullets
        for bullet in all(bullets) do
            spr(3, bullet.x, bullet.y)
        end

        -- draw hearts
        for i = 0, player.hp - 1 do
            spr(16, 0 + (i * 9), 5)
        end

        --draw asteroids
        for asteroid in all(asteroids) do
            spr(asteroid.sprite, asteroid.x, asteroid.y)
        end

        if player.hp < 1 then
            print("game over", 45, 64, 8)
            print(
            "destroyed asteroids: " .. score.destroyed_asteroids,
            20, 70, 7)
            print("hit 🅾️ and ❎ to restart", 17, 80)
        end
    end
end

-- end of pico-8 functions

__gfx__
000000000006600000088000000770000110011000999900000cc000000aa000000ee00000660060000000000000000000000000000000000000000000000000
00000000000660000088880000077000111111100999999000cccc00000aa000000ee00066600666000000000000000000000000000000000000000000000000
0070070000b11b00088888000007700010111111999999990cccccc0000aa00000eeee0066666600000000000000000000000000000000000000000000000000
000770000061160008888800000770000111111199999999ccccccccaaaaaaaaeeeeeeee66666060000000000000000000000000000000000000000000000000
000770000b1111b000888800000770001111111199999999ccccccccaaaaaaaaeeeeeeee06666666000000000000000000000000000000000000000000000000
0070070006166160088888000007700011111110999999990cccccc0000aa00000eeee0006666600000000000000000000000000000000000000000000000000
00000000618008160808088000077000101101100999999000cccc00000aa000000ee00066660660000000000000000000000000000000000000000000000000
000000008600006800080080000770001011011100999900000cc000000aa000000ee00006600066000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08700870000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888887000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888887000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888870000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00087000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
06600660066066606660000000006660666000000000000000000000000000000000006666cccccc000000000000000000000000000000000000000000000000
6000600060606060600006000000006060600000000000000000000000000000000006666cccccccc00000000000000000000000000000000000000000000000
6660600060606600660000000000066066600000000000000000000000000000000000660cccccccc00000000000000000000000000000000000000000000000
00606000606060606000060000000060606000000000000000000000000000000000000000cccccc000000000000000000000000000000000000000000000000
660006606600606066600000000066606660000000000000000000000000000000000000000cccc0000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000cc00000000000000000000000000000000000000000000000000
08700870008700870008700870000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888088888888088888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888887088888887088888887000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888887088888887088888887000000000000000000006600600000000000000000000000000000000000000000000000000000000000000000000000000000
08888870008888870008888870000000000000000000666006660000000000000000000000000000000000000000000000000000000000000000000000000000
00888700000888700000888700000000000000000000666666000000000000000000000000000000000000000000000000000000000000000000000000000000
00087000000087000000087000000000000000000000666660600000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000066666660000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000066666000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000666606600000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000066000660000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccc00000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc0000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc0000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000cc00000000000cccc00000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000cccc00000000000cc00000000000000cc00000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000cccccc0000000000000000000000000cccc0000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000cccccccc00000000000000000000000cccccc000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000cccccccc0000000000000000000000cccccccc00000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000cccccc00000000000000000000000cccccccc00000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000cccc0000000000000000000000000cccccc00000000000000000e
0000000000000000000000000000000000000000000000000000000000000000000000000000cc000000000000000000000000000cccc0000000000000000eee
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc00000000000000000eee
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000110011000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001011111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001011011000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001011011100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000066006000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000006660066600000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000006666660000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000006666606000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000666666600000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000666660000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000006666066000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000660006600000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000aa00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000aa00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000aa00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000aa00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000aa00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000aa00000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000eeee00000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000aa000000000000000eeee00000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000aa0000000000000000ee000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000aa0000000000000000ee000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000aaaaaaaa000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000aaaaaaaa000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000aa000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000aa000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000aa000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000cccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000cccccc0000000000000000000000000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000cccccccc000000000000000000000000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000cccccccc0000000000000000000000000b11b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000cccccc0000000000000000000000000061160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000cccc00000000000000000000000000b1111b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000cc000000000000000000000000000616616000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000006180081600000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000008600006800000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000088880000000000000000000000000000000000000000000000000000000000000000000000011001100000000000
00000000000000000000000000000000000088888000000000000000000000000000000000000000000000000000000000000000000000111111100000000000
00000000000000000000000000000000000088888000000000000000000000000000000000000000000000000000000000000000000000101111110000000000
00000000000000000000000000000000000088880000000000000000000000000000000000000000000000000000000000000000000000011111110000000000
00000000000000000000000000000000000088888000000000000000000000000000000000000000000000000000000000000000000000111111110000000000
00000000000000000000000000000000000880808000000000000000000000000000000000000000000000000000000000000000000000111111100000000000
00000000000000000000000000000000000800800000000000000000000000000000000000000000000000000000000000000000000000101101100000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101101110000000000
0000cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
00010000000000000000000000000000000000300502e0502a0502805026050250502305021050200501d0501b0501a0501805015050120500f0500d0500b0500a05009050070500605006050040500405003050
000100000805008050070500705006050050500405003050020500205001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105000050
001000001f0501f0501f0501305013050130500f0500f0500e0500c0500a050090500905009050080500705007050060500505005050010500105001050010500105001050010500105001050010500105000000
000b0000030500305003050030500305003050030500305013050130501305003050030500305003050080500805008050030500305003050030501a0501a0501a05003050030500305003050110501305015050
__music__
02 03424344

