-- sun vs earthmoon

tween = require "tween"

W = 800
H = 800
NUM_STARS = 100
EARTH_DIST = 180
MOON_DIST = 40
MOON_ROT_SPEED = 3.1
EARTH_ROT_SPEED = 1.5
ENEMY_SPEED = 10
ENEMY_W = 25
ENEMY_H = 10

first_game = true
quit_game = false

game = {
    theme = {
        winbg = {0,0.2,0,1},
        bg = {0,0,0.1,1},
    },
    stars = {

    },

    sun = {x=W/2, y=H/2, r=50},
    earth = {dist="TBD", angle="TBD", dx=0, dy=0, r=10},
    moon =  {dist="TBD", angle="TBD", dx=0, dy=0, r=5},

    rotation_dir = -1, -- -1 or 1. rotation direction

    state = "menu", -- "gameplay" "menu"  "dead"

    points = 0,
    health = 100,

    tweens = {},

    enemies = {}
}

canvas = lyte.new_canvas(W, H)

function reset_game()
    game.earth.dist = EARTH_DIST
    game.earth.angle = 0.4
    game.moon.dist = MOON_DIST
    game.moon.angle = 0.4
    game.rotation_dir = -1;

    game.tweens = {}
    game.stars = {}
    for i=1,NUM_STARS do
        table.insert(game.stars, {math.random(0, W), math.random(0, H)})
    end

    game.enemies = {}
    game.points = 0
    game.health = 10

    --temp
    for i=1,60 do
        add_enemy()
    end
end

function draw_stars()
    lyte.set_color(0.5,0.5,0.6,1)
    for i=1,#game.stars do
        local star = game.stars[i]
        lyte.draw_rect(star[1], star[2], 2, 2)
        -- lyte.draw_point(star[1], star[2])
    end
end

function draw_sun()
    lyte.set_color(1,1,0,1)
    lyte.draw_circle(0, 0, game.sun.r)
end

function draw_earth()
    lyte.set_color(0,0.5,1,1)
    lyte.draw_circle(0, 0, game.earth.r)
end

function draw_moon()
    lyte.set_color(1,1,1,1)
    lyte.draw_circle(0, 0, game.moon.r)
end

function draw_enemies()
    for i=1, #game.enemies do
        local enemy = game.enemies[i]

        if enemy.alive then
            lyte.set_color(0.7,0.7,0.7,0.5)
        else
            lyte.set_color(1,0,0,0.8)
        end

        lyte.push_matrix()
        lyte.translate(enemy.x-ENEMY_W/2, enemy.y-ENEMY_H/2)
        lyte.rotate(enemy.angle)
        lyte.draw_rect(0,0, ENEMY_W, ENEMY_H)
        lyte.pop_matrix()
    end
end

function draw_dbg_lines()
    lyte.set_color(1,1,0.4,0.5)
    local sx = game.sun.x
    local sy = game.sun.y
    local ex = sx + game.earth.dx
    local ey = sy + game.earth.dy
    local mx = ex + game.moon.dx
    local my = ey + game.moon.dy
    lyte.draw_line(sx, sy, ex, ey)
    lyte.draw_line(ex, ey, mx, my)
    -- lyte.draw_line(sx, sy, mx, my)

    -- lyte.draw_triangle(sx, sy, ex, ey, mx, my)
end

function draw_game()
    lyte.cls(unpack(game.theme.bg))
    draw_dbg_lines()
    draw_stars()
    draw_enemies()

    lyte.push_matrix()
    lyte.translate(game.sun.x, game.sun.y)
    draw_sun()
    lyte.translate(game.earth.dx, game.earth.dy)
    draw_earth()
    lyte.translate(game.moon.dx, game.moon.dy)
    draw_moon()
    lyte.pop_matrix()

    local points = "Frags: " .. game.points
    local health = "Sun Health: " .. game.health

    local pts_w = lyte.get_text_width(points)
    local hlt_w = lyte.get_text_width(health)
    lyte.draw_text(points, W/2-pts_w/2, 5)
    lyte.draw_text(health, W/2-hlt_w/2, 5+16+5)

end

function draw_menu()
    local title = "OMUA WAR"
    local line  = "--------"
    local title_scale = 3
    local w = lyte.get_text_width(title)
    local h =  lyte.get_text_height(title)
    lyte.set_color(0, 0,0,0.8)
    lyte.draw_rect(100, 100, W-200, H-200)
    lyte.push_matrix()
    lyte.translate((W-w*title_scale)/2, h*title_scale*4)
    lyte.scale(title_scale,title_scale)
    lyte.set_color(0.4,0.4,0.7, 1)
    lyte.draw_text(title, 0, 0)
    lyte.draw_text(line, 0, 16)
    lyte.set_color(1,1,1,0.95)
    lyte.draw_text(title, -2, -1)
    lyte.draw_text(line, -2, 16-1)
    lyte.pop_matrix()

    if not first_game then lyte.draw_text("[Esc] Continue", W/2-w, H/2 + 16*2) end
    lyte.draw_text("[N]   New Game", W/2-w, H/2 + 16*4)
    lyte.draw_text("[Q]   Quit", W/2-w, H/2 + 16*6)
end

function draw_dead()
    local text = "It's over: Sun's dead  "
    local text_w = lyte.get_text_width(text)
    lyte.set_color(1,0,0,1)
    lyte.draw_text(text, W/2-text_w/2, H/2 + 16*2)

end

function draw_bye(w,h)
        lyte.cls(0,0.1,0,1)
        lyte.set_color(1,0.9,0.9,1)
        lyte.draw_text("bye! <3", w/2-30,h/2)
end

function add_enemy()
    -- local x = math.random(10, W-10)
    -- local y = math.random(10, H-10)
    -- local angle = math.atan2(game.sun.y - y, game.sun.x - x)
    local angle = math.random()*math.pi*2
    local dist = math.random(100,500)
    local x = - math.sin(angle)*dist + game.sun.x
    local y = - math.cos(angle)*dist + game.sun.y
    angle = math.atan2(game.sun.y - y, game.sun.x - x)

    table.insert(game.enemies, { x = x, y = y, angle = angle, alive = true })
end

function fire_moon(N, dir)
    dir = dir or 1
    if dir == 1 then
        game.moon.angle = game.earth.angle
    else
        game.moon.angle =  game.earth.angle - math.pi
    end
    game.moon.dist = game.moon.dist + N
    game.tweens.moon_return = tween.new(0.5, game.moon, {dist=MOON_DIST}, tween.easing.outQuad)
end

function point_in_circle(px, py, cx, cy, cr)
    dx = math.abs(px - cx)
    dy = math.abs(py - cy)
    if dx*dx + dy*dy < cr*cr then
        return true
    else
        return false
    end
end

function check_collisions()
    local sx = game.sun.x
    local sy = game.sun.y
    local sr = game.sun.r
    local ex = sx + game.earth.dx
    local ey = sy + game.earth.dy
    local er = game.earth.r
    local mx = ex + game.moon.dx
    local my = ey + game.moon.dy
    local mr = game.moon.r * 2

    for i=1, #game.enemies do
        local e = game.enemies[i]
        -- local ang = e.angle
        local minx = e.x - (ENEMY_W)
        local maxx = e.x + (ENEMY_W)
        local miny = e.y - (ENEMY_W)
        local maxy = e.y + (ENEMY_W)
        -- with moon
        if  e.alive and
            (   point_in_circle(minx, miny, mx, my, mr)
            or  point_in_circle(minx, maxy, mx, my, mr)
            or  point_in_circle(maxx, miny, mx, my, mr)
            or  point_in_circle(maxx, maxy, mx, my, mr))
        then
            e.alive = false
            game.points = game.points + 1
        end
        -- with sun
        if  e.alive and
            (   point_in_circle(minx, miny, sx, sy, sr)
            or  point_in_circle(minx, maxy, sx, sy, sr)
            or  point_in_circle(maxx, miny, sx, sy, sr)
            or  point_in_circle(maxx, maxy, sx, sy, sr))
        then
            e.alive = false
            game.health = game.health - 10
            if game.health < 0 then game.health = 0 end
        end

    end
end

function update_enemies(dt)
    for i=1, #game.enemies do
        local e = game.enemies[i]
        e.y = e.y + math.sin(e.angle) * dt * ENEMY_SPEED
        e.x = e.x + math.cos(e.angle) * dt * ENEMY_SPEED
    end
end

function update_game(dt)
    game.earth.angle = game.earth.angle + dt/2 * game.rotation_dir
    game.moon.angle = game.moon.angle + dt * MOON_ROT_SPEED * game.rotation_dir * -1

    game.earth.dx = math.sin(game.earth.angle) * game.earth.dist
    game.earth.dy = -math.cos(game.earth.angle) * game.earth.dist

    game.moon.dx = math.sin(game.moon.angle) * game.moon.dist
    game.moon.dy = -math.cos(game.moon.angle) * game.moon.dist

    update_enemies(dt)
    check_collisions()

    if game.health == 0 then game.state = "dead"; first_game = true end

    local d_angle = dt*EARTH_ROT_SPEED
    local d_dist = 100*dt

    if game.tweens.moon_return then game.tweens.moon_return:update(dt) end

    if lyte.is_key_down("left") then game.rotation_dir = -1; game.earth.angle = game.earth.angle - d_angle end
    if lyte.is_key_down("right") then game.rotation_dir = 1; game.earth.angle = game.earth.angle + d_angle end
    if lyte.is_key_down("up") then fire_moon(dt*60*12, 1) end
    if lyte.is_key_down("down") then fire_moon(dt*60*4, -1) end

    if lyte.is_key_pressed("escape") then game.state = "menu" end
end

function update_menu(dt)
    if lyte.is_key_pressed("escape") then
        if game.state == "dead" then reset_game() end
        game.state = "gameplay"; first_game = false
    end
    if lyte.is_key_pressed("n") then reset_game(); game.state = "gameplay"; first_game = false end
    if lyte.is_key_pressed("q") then quit_game = true end
end

function lyte.tick(dt, w, h, rs)
    -- general key handling
    if lyte.is_key_pressed("f4") then quit_game = true; lyte.quit() end -- hard quit
    if lyte.is_key_pressed("f10") then lyte.set_window_vsync(not lyte.is_window_vsync()) end

    if quit_game then -- lyte.quit on WASM is a no-op, so we show a message
        draw_bye(w,h)
        lyte.quit()
        return
    end

    -- state specific updates
    if      game.state == "menu" or game.state == "dead"       then update_menu(dt)
    elseif  game.state == "gameplay"                           then update_game(dt)
    end

    -- draw game to canvas
    lyte.set_canvas(canvas)
    draw_game()
    if game.state == "menu" then draw_menu() end
    if game.state == "dead" then draw_menu(); draw_dead() end
    lyte.reset_color()
    lyte.reset_canvas()

    -- draw canvas to screen (in the center)
    lyte.cls(unpack(game.theme.winbg))
    -- lyte.draw_image(canvas, (w-W)/2, (h-H)/2)
    lyte.draw_image(canvas, 0, 0)

    -- debug overlay
    -- lyte.draw_text("FPS: " .. 1/dt, 0, 0)
end


function init()
    lyte.set_window_minsize(W, H)
    -- lyte.set_window_size(W, H)
    lyte.set_window_title("Omua War - (Lua Jam)")
    reset_game()
end


init()