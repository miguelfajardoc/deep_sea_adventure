require 'gosu'
require_relative 'buttons'

WITH = 600
HEIGHT = 800

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
        @submarine = Gosu::Image.new("assets/images/submarine2.png")
        @buttons.append(@button_start) 
        @game = Game.new([Player.new("ass", "blue"), Player.new("aaa", "yellow")])
        @state = :menu
        @low_treasure = Gosu::Image.new("assets/images/low_treasure.png")
        @mid_treasure = Gosu::Image.new("assets/images/mid_treasure.png")
        @players = [Player.new("caisy", "blue")]
        @initial_pos = [300, 400]
    end

    def update
        if @state == :game
            @button_start.disable!
            setup
        elsif @state == :players
            generate_players
            setup
        else
        end
    end

    def setup
        @game = Game.new(@players)
    end

    def start
        puts "start"
        @state = :game
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

    def draw_treasures
        aux = @game.head
        while !aux.next.nil?
            if aux.treasure.type == :square
                @mid_treasure.draw(aux.pos_x, aux.pos_y, 1)
            else
                @low_treasure.draw(aux.pos_x, aux.pos_y, 1)
            end
            aux = aux.next
        end
    end



    class Game

        TYPES = [:triangular, :square, :pentagonal, :hexagonal]

        attr_accessor :current_player, :head

        def initialize(players)
            @players = players
            @submarine = Submarine.new
            @step = 0
            @initial_pos = [300, 400]
            generate_treasures 
            generate_positions
            generate_position_maping
            @current_player = @players.first
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
                    @current_player.roll_dice
                    if @current_player.steps_left == 0
                        @step += 1
                    end
                    @current_player.move
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

        attr_accessor :loot, :name, :color, :current_dice, :current_position, :desired_position

        def initialize(name, color)
            @name = name
            @color = color
            @direction = :down
            @current_position = nil
            @desired_position = nil
            @loot = []
            @status = :alive
            @steps_left = 0
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
            current_position = current_position.next
            while !current_position.player.nil?
                current_position = current_position.next
            end
            current_position.player = self
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

        attr_accessor :oxigen, :next

        def initialize
            @oxigen = 25
            @next = nil
        end

    end



end

DeepSeaAdventure.new.show