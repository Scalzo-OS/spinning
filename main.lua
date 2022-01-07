function love.load()
    math.randomseed(os.time())
    love.window.setFullscreen(true)

    window = {}
    window.x, window.y = love.graphics.getDimensions()
    centre = {}
    centre.x, centre.y = window.x/2, window.y/2

    audio = {}
    audio.coin = love.audio.newSource('coin.wav', 'static')
    audio.bulletinit = love.audio.newSource('bulletspawn.wav', 'static')
    audio.bulletspawn = love.audio.newSource('bulletfire.wav', 'static')
    audio.levelup = love.audio.newSource('levelup.wav', 'static')
    audio.music = love.audio.newSource('chill song.mp3', 'static')
    audio.static = love.audio.newSource('tv-static-01.wav', 'static')
    audio.sources = {}

    setup()

end

function setup()
    love.audio.stop()
    player = {}
    player.speed = 0.03
    player.angle = 90*math.pi/180
    player.distance = 200
    player.direction = 1
    player.x = centre.x + math.cos(player.angle)*player.distance
    player.y = centre.y + math.sin(player.angle)*player.distance
    player.length = 10
    player.width = 5
    player.cords = {x1 = 0, y1 = 0, x2 = 0, y2 = 0}
    player.dead = false

    coin = {}
    coin.angle = math.random(0, 360)
    coin.x = centre.x + (player.distance) * math.cos(coin.angle)
    coin.y = centre.y + (player.distance) * math.sin(coin.angle)
    coin.r = 8
    coin.colour = {1.00,0.75,0.00}
    coin.font = love.graphics.newFont(150)

    bullets = {} --x, y, speed, direction

    bulletconfig = {}
    bulletconfig.init = false
    bulletconfig.reload = 1
    bulletconfig.timer = 0
    bulletconfig.speed = 3
    bulletconfig.size = 15

    particles = {} --x, y, size, speed, direction

    game = {}
    game.difficulty = 1
    game.font = love.graphics.newFont(30)
    game.over = false
    game.score = 0
    game.timer = 5
    game.point = false

    level = {}
    level.up = false
    level.timer = 0
    level.gap = 1
    level.show = false
    level.font = love.graphics.newFont(60)

    background = {} --x, y, length, width, size, speed, direction
    
    love.audio.setVolume(1)
end

function intable(set, key)
    return set[key] ~= nil
end

function love.update(dt)
    audio.sources = love.audio.pause()
    if not game.over then
        love.audio.play(audio.sources)
        if not intable(audio.sources, audio.music) then love.audio.play(audio.music) end
        game.timer = game.timer - dt
        player.angle = player.angle + player.direction * player.speed
        player.x = centre.x + math.cos(player.angle)*player.distance
        player.y = centre.y + math.sin(player.angle)*player.distance
        player.cords = {x1 = centre.x + math.cos(player.angle)*(player.distance - player.length),
                        y1 = centre.y + math.sin(player.angle)*(player.distance - player.length),
                        x2 = centre.x + math.cos(player.angle)*(player.distance + player.length),
                        y2 = centre.y + math.sin(player.angle)*(player.distance + player.length)}

        if math.sqrt((player.x-coin.x)^2+(player.y-coin.y)^2) <= coin.r then game.point = true end
        if game.point then
            love.audio.stop(audio.coin)
            love.audio.play(audio.coin)
            game.score = game.score + 1
            game.point = false 
            for _=1, 75 do
                table.insert(particles, {coin.x, coin.y, math.random(4, 8), math.random()*math.random(1, 4), math.random(0, 360),
                {1.00,0.75,0.00}})
            end
            coin.angle = math.random(0, 360)
            coin.x = centre.x + (player.distance) * math.cos(coin.angle)
            coin.y = centre.y + (player.distance) * math.sin(coin.angle)
        end

        if game.timer <= 0 then game.over = true end

        for i=#particles, 1, -1 do
            if particles[i][3] <= 0.05 then
                table.remove(particles, i)
            else
                particles[i][3] = particles[i][3] - particles[i][3]/15
                particles[i][1] = particles[i][1] + math.cos(particles[i][5])*particles[i][4]
                particles[i][2] = particles[i][2] + math.sin(particles[i][5])*particles[i][4]
            end
        end

        if game.score == 10 and not bulletconfig.init then
            bulletconfig.init = true
            love.audio.play(audio.bulletinit)
            for i=1, math.random(200, 400) do
                table.insert(particles, {centre.x, centre.y, math.random(4, 8),math.random()* math.random(6, 10), math.random(0, 360),
                {1, 1, 1}})
            end
        end
        if bulletconfig.init then
        table.insert(background, {centre.x, centre.y, math.random(1, 4), math.random(0.2, 2),
            math.random(3, 6)+game.difficulty/2, math.random(0, 360), math.random()})
        elseif math.random(1, 4) == 4 then
            table.insert(background, {centre.x, centre.y, math.random(1, 4), math.random(0.2, 2),
            math.random(3, 6)+game.difficulty, math.random(0, 360), math.random()})
        end
        for i=#background, 1, -1 do
            if background[i][1] < 0 or background[i][2] > window.x
            or background [i][2] < 0 or background[i][2] > window.y then
                table.remove(background, i)
            else
                background[i][1] = background[i][1] + background[i][5]*math.cos(background[i][6])
                background[i][2] = background[i][2] + background[i][5]*math.sin(background[i][6])
            end
        end

        if bulletconfig.init then
            bulletconfig.timer = bulletconfig.timer + dt
            if game.score <= 40 then bulletconfig.reload = 1 - (0.2 * game.difficulty) end
            if bulletconfig.timer >= bulletconfig.reload then
                love.audio.stop(audio.bulletspawn)
                love.audio.play(audio.bulletspawn)
                bulletconfig.timer = 0
                table.insert(bullets, {centre.x, centre.y, bulletconfig.speed+game.difficulty, math.random(player.angle-math.pi/4, player.angle+math.pi/4)})
                for i=1, 20 do
                    table.insert(particles, {centre.x, centre.y, math.random(1, 4), math.random()*math.random(1, 4), math.random(0, 360),
                    {1.00,0, 0}})
                end
            end
            for i=#bullets, 1, -1 do
                if bullets[i][1] < 0 or bullets[i][1] > window.x  or
                bullets[i][2] < 0 or bullets[i][2] > window.y then
                    table.remove(bullets, i)
                else
                    bullets[i][1] = bullets[i][1] + bullets[i][3]*math.cos(bullets[i][4])
                    bullets[i][2] = bullets[i][2] + bullets[i][3]*math.sin(bullets[i][4])
                end
                if math.sqrt((player.cords.x1-bullets[i][1])^2+(player.cords.y1-bullets[i][2])^2) < bulletconfig.size or
                math.sqrt((player.cords.x2-bullets[i][1])^2+(player.cords.y2-bullets[i][2])^2) < bulletconfig.size then player.dead = true end
            end
            --x, y, length, width, speed, direction
            
        end

        if game.score % 10 == 0  and game.score ~= 0 then
            game.difficulty = round(game.score/10, 0)
            bulletconfig.size = 10 + game.difficulty
            level.up = true
            if level.played == 0 then love.audio.play(audio.levelup) end
            level.played = 1
        else level.played = 0 end

        if level.up then
            level.timer = level.timer + dt
            if level.timer >= level.gap then
                level.show = false
                level.up = false
            else level.show = true end
        else level.timer = 0 end

        if player.dead then game.over = true; love.audio.stop() end

    else
        love.audio.setVolume(0.1)
        if not intable(audio.sources, audio.static) then love.audio.play(audio.static) end
    end
end

function round(num, dp)
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5)/mult
end

function love.draw()
    if not game.over then
        love.graphics.setColor(1, 1, 1)
        for i=1, #background do
            love.graphics.setLineWidth(background[i][4])
            love.graphics.setColor(1, 1, 1, background[i][7])
            love.graphics.line(background[i][1]-background[i][5]*math.cos(background[i][6]), 
                background[i][2]-background[i][5]*math.sin(background[i][6]),
                background[i][1]+background[i][5]*math.cos(background[i][6]), 
                background[i][2]+background[i][5]*math.sin(background[i][6]))
        end
        for i=1, #particles do
            love.graphics.setColor(particles[i][6][1], particles[i][6][2], particles[i][6][3])
            love.graphics.circle('fill', particles[i][1], particles[i][2], particles[i][3])
        end

        love.graphics.setFont(coin.font)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print({{1, 1, 1, 1-game.timer/2}, round(game.timer, 2)}, centre.x-200, centre.y-100)

        if bulletconfig.init then
            love.graphics.setLineWidth(2)
            love.graphics.setColor(1, 1, 1)
            for i=1, #bullets do
                love.graphics.circle('fill', bullets[i][1], bullets[i][2], bulletconfig.size + 2)
            end
            love.graphics.setColor(1, 0, 0)
            love.graphics.circle('fill', centre.x, centre.y, 15)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle('line', centre.x, centre.y, 20)
            love.graphics.setColor(1, 0, 0)
            for i=1, #bullets do
                love.graphics.circle('fill', bullets[i][1], bullets[i][2], bulletconfig.size)
            end
        end

        love.graphics.setColor(0, 200/255, 1)
        love.graphics.setLineWidth(player.width)
        love.graphics.line(player.cords.x1, player.cords.y1, player.cords.x2, player.cords.y2)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(game.font)
        love.graphics.print(game.score, centre.x, window.y/2 - player.distance - 100)

        love.graphics.setColor(coin.colour[1], coin.colour[2], coin.colour[3])
        love.graphics.circle('fill', coin.x, coin.y, coin.r)

        love.graphics.setColor(1, 1, 1)
        if level.show then
            love.graphics.setFont(level.font)
            love.graphics.printf('level up', 0, window.y-200, window.x, 'center')
        end
    else
        love.graphics.print('GAME OVER', centre.x-150, centre.y-100)
        love.graphics.print('score: '..game.score, centre.x-150, centre.y + 100)
        love.graphics.print('type r to restart and esc to quit', centre.x-200, window.y-100)
    end
end

function love.keypressed(key)
    if key == 'space' then
        game.timer = 5 - (0.4 * game.difficulty)
        if player.direction == -1 then player.direction = 1 else player.direction = -1 end
    end
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'r' then
        setup()
    end
end