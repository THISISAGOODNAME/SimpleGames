function love.load()
    -- For ZeroBrane debugger
    -- if arg[#arg] == "-debug" then require("mobdebug").start() end
    
    love.graphics.setNewFont(20)
    
    sequence = {} 

    function addToSequence()
        table.insert(sequence, love.math.random(4))
    end

    addToSequence()
    
    current = 1
    
    timer = 0
    
    state = 'watch' -- 'watch', 'repeat', 'gameover'
    
    flashing = false
end

function love.update(dt)
    if state == 'watch' then
        timer = timer + dt
        if timer >= 0.5 then
            timer = 0
            flashing = not flashing
            if not flashing then
                current = current + 1
                if current > #sequence then
                    state = 'repeat'
                    current = 1
                end
            end
        end
    end
end

function love.keypressed(key)
    if state == 'repeat' then
        if tonumber(key) == sequence[current] then
            current = current + 1
            if current > #sequence then
                current = 1
                addToSequence()
                state = 'watch'
            end
        else
            state = 'gameover'
        end
    elseif state == 'gameover' then
        love.load()
    end
end

function love.draw()
    local function drawSquare(number, color, colorFlashing)
        local squareSize = 50
        
        if state == 'watch'  and flashing and number == sequence[current] then
            love.graphics.setColor(colorFlashing)
        else
            love.graphics.setColor(color)
        end
        
        love.graphics.rectangle('fill', squareSize * (number - 1), 0, squareSize, squareSize)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(number, squareSize * (number - 1) + 19, 14)
    end

    drawSquare(1, {.2,  0,  0}, {1, 0, 0})
    drawSquare(2, { 0, .2,  0}, {0, 1, 0})
    drawSquare(3, { 0,  0, .2}, {0, 0, 1})
    drawSquare(4, {.2, .2,  0}, {1, 1, 0})
    
    if state == 'repeat' then
        love.graphics.print(current..'/'..#sequence, 20, 60)
    elseif state == 'gameover' then
        love.graphics.print('Game over!', 20, 60)
    end
    
    -- Debug info
    -- love.graphics.print('sequence[current]: '..sequence[current], 20, 100)
    -- love.graphics.print(table.concat(sequence, ', '), 20, 140)
    -- love.graphics.print('state: '..state, 20, 180)
    -- love.graphics.print('flashing: '..tostring(flashing), 20, 220)
end