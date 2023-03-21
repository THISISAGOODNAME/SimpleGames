local hex = require("hexmaniac")

function love.load()
    -- For ZeroBrane debugger
    -- if arg[#arg] == "-debug" then require("mobdebug").start() end
    
    love.graphics.setNewFont(30)
    
    background_color_game = "92877d"
    background_color_cell_empty = "9e948a"
    background_color_dict = {
        [    2] = "eee4da", [    4] = "ede0c8", [    8] = "f2b179",
        [   16] = "f59563", [   32] = "f67c5f", [   64] = "f65e3b",
        [  128] = "edcf72", [  256] = "edcc61", [  512] = "edc850",
        [ 1024] = "edc53f", [ 2048] = "edc22e",

        [ 4096] = "eee4da", [ 8192] = "edc22e", [16384] = "f2b179",
        [32768] = "f59563", [65536] = "f67c5f",
    }

    cell_color_dict = {
        [    2] = "776e65", [    4] = "776e65", [    8] = "f9f6f2", [16]= "f9f6f2",
        [   32] = "f9f6f2", [   64] = "f9f6f2", [  128] = "f9f6f2",
        [  256] = "f9f6f2", [  512] = "f9f6f2", [ 1024] = "f9f6f2",
        [ 2048] = "f9f6f2",
        [ 4096] = "776e65", [ 8192] = "f9f6f2", [16384] = "776e65",
        [32768] = "776e65", [65536] = "f9f6f2",
    }
    
    love.graphics.setBackgroundColor(hex.rgb(background_color_game))
    
    border = 20
    piece_size = 100
    half_border = border * 0.5
    
    board_size = 4
    
    board={}
    temp_board={}
    
    function init_grid()
        local temp = {}
        for y=1,board_size do
            temp[y] = {}
            for x=1,board_size do
                temp[y][x] = 0
            end
        end
        return temp
    end
    
    board = init_grid()
    temp_board = init_grid()
    
    function print_board()
        for i=1,board_size do
            for j=1,board_size do 
                io.write(board[i][j]) 
                io.write(" ")
            end
            print("")
        end
    end
    
    function transpose(board)
        local temp = init_grid()
        
        for y=1, board_size do
            for x=1, board_size do
                temp[x][y] = board[y][x]
            end
        end
        
        return temp
    end

    function reverse(board)
        local temp = init_grid()
        
        for y=1, board_size do
            for x=1, board_size do
                temp[y][x] = board[board_size - y + 1][x]
            end
        end
        
        return temp
    end

    function cover_up(board)
        local temp = init_grid()
        
        for x=1, board_size do
            local up = 1
            for y=1, board_size do
                if board[y][x] ~= 0 then
                    temp[up][x] = board[y][x]
                    up = up + 1
                end
            end
        end
        
        return temp
    end
    
    function merge(board)
        for y=2, board_size do
            for x=1, board_size do
                if board[y][x] == board[y - 1][x] then
                    board[y - 1][x] = board[y - 1][x] * 2
                    board[y][x] = 0
                end
            end
        end

        return board
    end
    
    function up()
        temp = cover_up(board)
        temp = merge(temp)
        temp = cover_up(temp)
        temp_board = temp
    end

    function down() 
        temp = reverse(board)
        temp = merge(temp)
        temp = cover_up(temp)
        temp = reverse(temp)
        temp_board = temp
    end

    function right()
        temp = reverse(transpose(board))
        temp = merge(temp)
        temp = cover_up(temp)
        temp = transpose(reverse(temp))
        temp_board = temp
    end

    function left()
        temp = transpose(board)
        temp = merge(temp)
        temp = cover_up(temp)
        temp = transpose(temp)
        temp_board = temp
    end

    function add_two_or_four()
        local indexes = {}
        local count = 0

        for y=1, board_size do
            for x=1, board_size do
                if  board[y][x] == 0 then
                    count = count + 1
                    indexes[count] = { y, x }
                end
            end
        end

        if count == 0 then
            return 
        else
            local index = math.random(1,count)
            local prob = math.random()
            if prob > 0.9 then
                board[indexes[index][1]][indexes[index][2]] = 4
            else
                board[indexes[index][1]][indexes[index][2]] = 2
            end
        end
        
    end
  
    function verify_game_state()
        for y=1, board_size do
            for x=1, board_size do
                if  board[y][x] == 0 then
                    return false
                end
            end
        end

        for y=2, board_size do
            for x=2, board_size do
                if board[y][x] == board[y-1][x] then
                    return false
                end
                if board[y][x] == board[y][x - 1] then
                    return false
                end
            end
        end

        for y=2, board_size do
            if board[y][1] == board[y - 1][1] then
                return false
            end
        end

        for x=2, board_size do
            if board[1][x] == board[1][x - 1] then
                return false
            end
        end

        return true
    end
    
    function confirm_move()
        local equal = true
        
        for line=1, board_size do
            for column=1, board_size do
                if temp_board[line][column] ~= board[line][column] then
                    equal = false
                end
            end
        end
        
        if equal == false then
            for y=1, board_size do
                for x=1, board_size do
                    board[y][x] = temp_board[y][x]
                end
            end
            
            add_two_or_four()
            -- print_board()
        end
    end
    
    function make_move(move)
        if move == 0 then
            up()
        elseif move == 1 then
            down()
        elseif  move == 2 then
            right()
        else 
            left()
        end
        
        confirm_move()
    end 

    function reset_game()
        board = init_grid()
        temp_board = init_grid()
        add_two_or_four()
        add_two_or_four()
        
        -- print_board()
    end
    
    reset_game()
    
    function move(direction)
        if direction == 'up' then
            make_move(0)
        elseif direction == 'down' then
            make_move(1)
        elseif direction == 'right' then
            make_move(2)
        elseif direction == 'left' then
            make_move(3)
        end
    end
    
end

function love.update(dt)

end

function love.keypressed(key)
    if key == 'down' or key == "s" then
        move('down')
    elseif key == 'up' or key == "w" then
        move('up')
    elseif key == 'right' or key == "d" then
        move('right')
    elseif key == 'left' or key == "a" then
        move('left')
    end
    
    if verify_game_state() then
        love.timer.sleep(5)
        reset_game()
    end
end

function love.draw()
    local grid = board
    
    for y = 1, board_size do
        for x = 1, board_size do
            local piece_draw_size = piece_size - border
            if grid[x][y] == 0 then
                love.graphics.setColor(hex.rgb(background_color_cell_empty))
                love.graphics.rectangle('fill', half_border + (y - 1) * piece_size, half_border +(x - 1) * piece_size, piece_draw_size, piece_draw_size)
            else
                love.graphics.setColor(hex.rgb(background_color_dict[grid[x][y]]))
                love.graphics.rectangle('fill', half_border + (y - 1) * piece_size, half_border + (x - 1) * piece_size, piece_draw_size, piece_draw_size)
                
                love.graphics.setColor(hex.rgb(cell_color_dict[grid[x][y]]))
                love.graphics.printf(grid[x][y], half_border + (y - 1) * piece_size, half_border + (x - 0.8) * piece_size, 80, "center")
            end

        end
    end
end