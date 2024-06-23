local maxBullets = 1000

local Man = {}
Man.__index = Man

function Man:new(x, y)
    local man = setmetatable({}, Man)
    man.x = x
    man.y = y
    man.dy = 0
    man.life = 100
    man.name = ""
    man.currentSprite = 4
    man.walking = false
    man.facingLeft = false
    man.shooting = false
    man.visible = true
    man.alive = true
    man.sheetTexture = love.graphics.newImage("sheet.png")
    return man
end

local Bullet = {}
Bullet.__index = Bullet

function Bullet:new(x, y, dx)
    local bullet = setmetatable({}, Bullet)
    bullet.x = x
    bullet.y = y
    bullet.dx = dx
    return bullet
end

local bullets = {}
local enemy
local globalTime = 0

function addBullet(x, y, dx)
    if #bullets < maxBullets then
        table.insert(bullets, Bullet:new(x, y, dx))
    end
end

function removeBullet(i)
    table.remove(bullets, i)
end

function love.load()
    love.window.setMode(640, 480)
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    local windowHeight = love.graphics.getHeight()
    local playerInitialY = windowHeight / 2 - 25 - 20
    local enemyInitialY = windowHeight / 2 - 25 - 20

    player = Man:new(50, playerInitialY)
    enemy = Man:new(250, enemyInitialY)
    enemy.sheetTexture = love.graphics.newImage("badman_sheet.png")
    backgroundTexture = love.graphics.newImage("background.png")
    bulletTexture = love.graphics.newImage("bullet.png")
end

function love.update(dt)
    globalTime = globalTime + 1
    
    if not player.shooting then
        if love.keyboard.isDown("left") then
            player.x = player.x - 3
            player.walking = true
            player.facingLeft = true
            if globalTime % 6 == 0 then
                player.currentSprite = (player.currentSprite % 4) + 1
            end
        elseif love.keyboard.isDown("right") then
            player.x = player.x + 3
            player.walking = true
            player.facingLeft = false
            if globalTime % 6 == 0 then
                player.currentSprite = (player.currentSprite % 4) + 1
            end
        else
            player.walking = false
            player.currentSprite = 4
        end
    end

    if not player.walking then
        if love.keyboard.isDown("space") then
            if globalTime % 6 == 0 then
                if player.currentSprite == 4 then
                    player.currentSprite = 5
                else
                    player.currentSprite = 4
                end

                if not player.facingLeft then
                    addBullet(player.x + 35, player.y + 20, 3)
                else
                    addBullet(player.x + 5, player.y + 20, -3)
                end
            end
            player.shooting = true
        else
            player.currentSprite = 4
            player.shooting = false
        end
    end

    if love.keyboard.isDown("up") and player.dy == 0 then
        player.dy = -8
    end

    player.y = player.y + player.dy
    player.dy = player.dy + 0.5
    if player.y > (love.graphics.getHeight() / 2 - 25 - 20) then
        player.y = love.graphics.getHeight() / 2 - 25 - 20
        player.dy = 0
    end

    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.x = bullet.x + bullet.dx

        if bullet.x > enemy.x and bullet.x < enemy.x + 40 and 
           bullet.y > enemy.y and bullet.y < enemy.y + 50 then
            enemy.alive = false
        end

        if bullet.x < -1000 or bullet.x > 1000 then
            removeBullet(i)
        end
    end

    if not enemy.alive and globalTime % 6 == 0 then
        if enemy.currentSprite < 6 then
            enemy.currentSprite = 6
        elseif enemy.currentSprite >= 6 then
            enemy.currentSprite = enemy.currentSprite + 1
            if enemy.currentSprite > 7 then
                enemy.visible = false
                enemy.currentSprite = 7
            end
        end
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(backgroundTexture, 0, 0, 0, 2, 2)
    
    if player.visible then
        local quad = love.graphics.newQuad(40 * player.currentSprite, 0, 40, 50, player.sheetTexture:getWidth(), player.sheetTexture:getHeight())
        love.graphics.draw(player.sheetTexture, quad, player.x, player.y, 0, player.facingLeft and -1 or 1, 1, 20, 25)
    end

    if enemy.visible then
        local quad = love.graphics.newQuad(40 * enemy.currentSprite, 0, 40, 50, enemy.sheetTexture:getWidth(), enemy.sheetTexture:getHeight())
        love.graphics.draw(enemy.sheetTexture, quad, enemy.x, enemy.y, 0, enemy.facingLeft and -1 or 1, 1, 20, 25)
    end

    for _, bullet in ipairs(bullets) do
        love.graphics.draw(bulletTexture, bullet.x, bullet.y, 0, 2, 2)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
