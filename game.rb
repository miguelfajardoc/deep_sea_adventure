require 'gosu'
require_relative 'buttons'

WITH = 600
HEIGHT = 800
#TODO: Revisar los movimientos cuando se va a devolver, con prev 

class DeepSeaAdventure < Gosu::Window

    def initialize
        
        super WITH, HEIGHT
        self.caption = "DeepSeaAdventure"
        @buttons = []
        @title = Gosu::Image.new("assets/images/title.png")
        #@background_image = Gosu::Image.new("assets/images/Ocean.png")
        @background_image = Gosu::Image.from_blob(WITH, HEIGHT, rgba = "\4\105\142\255" * (WITH * HEIGHT))
        @background_image_2 = Gosu::Image.new("assets/images/submarine_title.png")
        @start_text = Gosu::Image.from_text("Start", 30, options = {bold: true})
        @button_start = Buttons.new(250, 400, Gosu::Image.from_blob(150, 40, rgba = "\1\107\140\155" * (150 * 40)), &self.method(:start))
        @button_dice = Buttons.new(415, 405, Gosu::Image.new("assets/images/dice/Side_1_Pip.png"), &self.method(:roll_dice))
        @submarine = Gosu::Image.new("assets/images/submarine2.png")
        @buttons= [@button_start, @button_dice]
        @state = :menu
        @low_treasure = Gosu::Image.new("assets/images/low_treasure.png")
        @mid_treasure = Gosu::Image.new("assets/images/mid_treasure.png")
        @high_treasure = Gosu::Image.new("assets/images/high_treasure.png")
        @very_high_treasure = Gosu::Image.new("assets/images/very_high_treasure.png")
        @initial_pos = [300, 400]
        @roll_sound = Gosu::Sample.new("assets/sounds/dice-3.wav")
    end

    def update
        if @state == :game
            @button_start.disable!
            
        elsif @state == :players
            generate_players
            setup
        else
        end
    end

    def setup
        create_players
        @game = Game.new(@players)
        @game.process
    end

    def start
        puts "start"
        @state = :game
        setup
    end

    def button_down(id)
        puts mouse_x, mouse_y
        case id
        when Gosu::KB_ESCAPE
            close
        when Gosu::MS_LEFT
            element = element_clicked
            unless element.nil?
                puts element.process
                element.process.call
            end
        end
    end

    def element_clicked
        @buttons.each do |button|
            if button.enable?
                return button if button.clicked?(mouse_x, mouse_y)
            end
        end
        nil
    end

    def draw
        @background_image.draw(0,0,0)
        

        if @state == :game
            #@submarine.draw(0,0,3, scale_x = 0.1, scale_y = 0.1)
            @submarine.draw(30,100,3)
            draw_treasures
            draw_players
            draw_dice
        elsif @state == :players
            p "player"
        elsif @state == :menu
            @title.draw(150, 0, 1)
            @background_image_2.draw(150, 140, 1)
            #@button_instructions.draw(50, 300, 2)
            @start_text.draw(280,405,3)
            @button_start.image.draw(@button_start.position_x, @button_start.position_y, 2)
        end
    end

    def create_players
        @players = [Player.new("caisy", "blue", Gosu::Image.new("assets/images/divers/diver_blue.png")),
            Player.new("kala", "green", Gosu::Image.new("assets/images/divers/diver_green.png"))]

    end

    def roll_dice
        @roll_sound.play
        @game.process(:roll)
        
        #@button_dice.image.draw()
    end

    def draw_dice
        @button_dice.image.draw(@button_dice.position_x, @button_dice.position_y, 2, scale_x=0.1, scale_y = 0.1)
    end

    def draw_treasures
        aux = @game.head
        while !aux.next.nil?
            case aux.treasure.type
            when :triangular
                @low_treasure.draw(aux.pos_x, aux.pos_y, 1)
            when :square
                @mid_treasure.draw(aux.pos_x, aux.pos_y, 1)
            when :pentagonal
                @high_treasure.draw(aux.pos_x, aux.pos_y, 1)
            when :hexagonal
                @very_high_treasure.draw(aux.pos_x, aux.pos_y, 1)
            end
            aux = aux.next
        end
    end

    def draw_players
        @players.each do |player|
            player.calculate_rendered_position unless player.current_position == player.rendered_position
            if player.down? && player.rendered_position.class != Submarine
                player.image.draw_rot(player.rendered_position.pos_x, player.rendered_position.pos_y, z = 3, angle = 180)
            else
                player.image.draw(player.rendered_position.pos_x, player.rendered_position.pos_y,3)
            end
        end
    end



    class Game

        TYPES = [:triangular, :square, :pentagonal, :hexagonal]

        attr_accessor :current_player, :head, :initial_pos, :submarine

        def initialize(players)
            @initial_pos = [300, 400]
            @submarine = Submarine.new(314, 322)
            @players = setup_players(players)
            @step = 0
            generate_treasures 
            generate_positions
            generate_position_maping
            @current_player = @players.first
        end

        def setup_players(players)
            players.each do |p|
                p.current_position = @submarine
            end
        end

        def update_oxigen
            puts "updatin oxigen"
            @players.each do |player|
                @submarine.oxigen -= player.loot.count
            end
            if @oxigen == 0
                check_dead_players
            end
        end

        def check_dead_players
            @players.each do |player|
                if player.current_position != @submarine
                    player.status = :dead
                end
            end
        end

        def generate_treasures
            @treasures = []
            i = 0
            (0..15).each do |value|
                type = TYPES[i/4]
                @treasures.append(Treasure.new(type, value))
                @treasures.append(Treasure.new(type, value))
                i += 1
            end
        end

        def generate_positions
            @head = Box.new(nil)
            aux = @head
            TYPES.each do |type|
                treasures_type = @treasures.filter {|t| t.type == type}
                while !treasures_type.empty?
                    sample = treasures_type.sample
                    aux.treasure = sample
                    aux.next = Box.new(nil)
                    aux.next.prev = aux
                    aux = aux.next
                    treasures_type -= [sample]
                end      
            end
            @head.prev = @submarine
            @submarine.next = @head
        end

        def generate_position_maping
            @head.pos_x = @initial_pos[0]
            @head.pos_y = @initial_pos[1]
            desp_x = 60
            desp_y = 5
            aux = @head.next
            x = @initial_pos[0]
            y = @initial_pos[1]
            dir_x = -1
            dir_y = 1
            flag = 'x'
            while !aux.nil?
                if flag == 'y'
                    desp_x = 60
                    desp_y = 5
                end
                if  x + desp_x * dir_x < 0 || x + desp_x * dir_x > WITH - 50
                    dir_x *= -1
                    desp_x = 0
                    desp_y = 62
                    flag = 'y'
                end
                x += desp_x * dir_x
                y += desp_y * dir_y
                aux.pos_x = x
                aux.pos_y = y
                aux = aux.next
            end
        end

        def process(button_name = nil, options: nil)
            #puts "#{@players.first.name}'s turn #{@players.first.color}"
            puts @step
            case @step
            when 0
                update_oxigen
                @step += 1
            when 1
                if button_name == :direction
                    @current_player.change_direction!
                else
                    puts "rolling"
                    @current_player.roll_dice
                    @current_player.move
                    @step += 1
                end
            when 2
                if button_name == :pick
                    @current_player.loot.append(@positions[@current_player.current_position].treasure)
                    @current_player.current_position.treasure = Treasure.new(:blank, nil)
                elsif button_name == :drop
                    @current_player.current_position.treasure = @current_player.loot[options[index_loot]] 
                    #Revisar si extraer la logica de los pasos como botones visuales
                end
                next_player
            end
        end

        def next_player
            @current_player = @players[@players.index(@current_player) + 1]
            if @current_player.nil?
                @current_player = @players.first
            end
        end

    end

    class Player

        attr_accessor :loot, :name, :color, :current_dice, :current_position, :rendered_position, :image

        def initialize(name, color, image)
            @name = name
            @color = color
            @direction = :down
            @current_position = nil
            @rendered_position = nil
            @loot = []
            @status = :alive
            @steps_left = 0
            @image = image
            @clock = nil
        end

        def change_direction!
            if @direction == :down
                @direction = :up
            else
                @direction = :down
            end
        end

        def roll_dice
            @current_dice = [rand(1..3), rand(1..3)]
            @steps_left = calculate_movement
        end

        def calculate_movement
            value = @current_dice[0] + @current_dice[1] - loot.count
            return 0 if value <= 0
            value
        end

        def move

            aux = @current_position
            while @steps_left != 0
                aux = aux.next
                while !aux.player.nil? 
                    aux = aux.next
                end                
                @steps_left -=1
            end
            @current_position.player = nil unless @current_position.class == Submarine
            @current_position = aux
            
        end

        def down?
            @direction == :down
        end

        def calculate_rendered_position
            if @rendered_position.nil?
                @rendered_position = @current_position
                return
            end
            @clock = Time.now if @clock == nil
            if Time.now - @clock > 0.5
                @rendered_position = @rendered_position.next
                @clock = nil
            end
        end

    end

    class Treasure

        attr_accessor :type, :value

        def initialize(type, value)
            @type = type
            @value = value
            #@owner = nil
        end

    end

    class Box

        attr_accessor :treasure, :player, :next, :prev, :pos_x, :pos_y

        def initialize(treasure)
            @treasure = treasure
            @player = nil
            @next = nil
            @prev = nil
            @pos_x = 0
            @pos_y = 0
        end

    end

    class Submarine

        attr_accessor :oxigen, :next, :pos_x, :pos_y

        def initialize(x,y)
            @oxigen = 25
            @next = nil
            @pos_x = x
            @pos_y = y
        end

    end



end

DeepSeaAdventure.new.show