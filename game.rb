require 'gosu'
require_relative 'buttons'
require 'debug'

WITH = 600
HEIGHT = 800
#TODO: Revisar los movimientos cuando se va a devolver, con prev 

# revisar el go_up, no hace bien la cosa
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
        @button_start = Buttons.new(
            position_x: 250,
            position_y: 400,
            image: Gosu::Image.from_blob(150, 40, rgba = "\1\107\140\155" * (150 * 40)),
            name: :start,
            active: true,
            &self.method(:start)
        )
        @button_dice = Buttons.new(
            position_x: 415,
            position_y: 405,
            images: [Gosu::Image.new("assets/images/dice/Side_1_Pip.png"), Gosu::Image.new("assets/images/dice/Side_2_Pips.png"),
                Gosu::Image.new("assets/images/dice/Side_3_Pips.png")],
            name: :dice_button,
            scale_x: 0.05,
            scale_y: 0.05,
            &self.method(:roll_dice)
        )
        @button_pick = Buttons.new(
            position_x: 415,
            position_y: 405,
            image: Gosu::Image.new("assets/images/pick.png"),
            name: :pick_button,
            &self.method(:pick)
        )
        @button_drop = Buttons.new(
            position_x: 415,
            position_y: 405,
            image: Gosu::Image.new("assets/images/drop.png"),
            name: :drop_button,
            &self.method(:drop)
        )
        @button_skip = Buttons.new(
            position_x: 415,
            position_y: 455,
            image: Gosu::Image.new("assets/images/skip.png"),
            name: :skip_button,
            &self.method(:skip)
        )
        @button_go_up = Buttons.new(
            position_x: 505,
            position_y: 405,
            image: Gosu::Image.new("assets/images/go_up.png"),
            name: :go_up,
            &self.method(:go_up)
        )

        @submarine = Gosu::Image.new("assets/images/submarine2.png")
        @buttons= [@button_start, @button_dice, @button_pick, @button_drop, @button_skip, @button_go_up]
        @state = :menu
        @low_treasure = Gosu::Image.new("assets/images/treasures/low_treasure.png")
        @mid_treasure = Gosu::Image.new("assets/images/treasures/mid_treasure.png")
        @high_treasure = Gosu::Image.new("assets/images/treasures/high_treasure.png")
        @very_high_treasure = Gosu::Image.new("assets/images/treasures/very_high_treasure.png")
        @empty_treasure = Gosu::Image.new("assets/images/treasures/empty_treasure.png")
        @initial_pos = [300, 400]
        @roll_sound = Gosu::Sample.new("assets/sounds/dice-3.wav")
    end

    def update
        if @state == :game
            @button_start.disable! if @button_start.enable?
            
        elsif @state == :players
            generate_players
            setup
        else
        end
    end

    def setup
        create_players
        @game = Game.new(@players)
        @button_start.enable!
        @game.process
    end

    def start
        puts "start"
        @state = :game
        setup
    end

    def button_down(id)
        #puts mouse_x, mouse_y
        case id
        when Gosu::KB_ESCAPE
            close
        when Gosu::MS_LEFT
            element = element_clicked
            unless element.nil?
                element.process.call
            end
        end
    end

    def element_clicked
        #debugger
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
            draw_go_up if @game.current_player.current_position.class != Submarine && @game.current_player.direction == :down && @game.step == 1
            if @game.step == 2 && !@game.current_player.is_moving?
                @button_dice.disable! if @button_dice.enable?
                draw_pick if @game.current_player.can_pick?
                draw_drop if @game.current_player.can_drop?
                draw_skip
            end
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
        p @game.current_player.current_dice
    end

    def pick
        #pick_sound.play
        @game.process(:pick)
        @button_pick.disable!
        @button_skip.disable!
    end

    def drop
        #drop_sound.play
        @game.process(:drop)
        @button_drop.disable!
        @button_skip.disable! 
    end

    def skip
        #drop_sound.play
        @game.process(:skip)
        @button_skip.disable!
        @button_pick.disable!
        @button_drop.disable!
    end

    def go_up
        @game.process(:direction)
        @button_go_up.disable! 
    end
    
    ### Draw methods:

    def draw_pick
        @button_pick.enable! unless @button_pick.enable?
        @button_pick.image.draw(@button_pick.position_x, @button_pick.position_y)
    end

    def draw_drop
        @button_drop.enable! unless @button_drop.enable?
        @button_drop.image.draw(@button_drop.position_x, @button_drop.position_y)
    end

    def draw_skip
        @button_skip.enable! unless @button_skip.enable?
        @button_skip.image.draw(@button_skip.position_x, @button_skip.position_y)
    end

    def draw_go_up
        @button_go_up.enable! unless @button_go_up.enable?
        @button_go_up.draw
    end

    # Draw the dice according to the result in @game.current_player.roll_dice
    # The draw appears before player click it and while the player is moving.
    def draw_dice
        if @game.current_player.current_position != @game.current_player.rendered_position || @game.step == 1
            @button_dice.enable! unless @button_dice.enable?
            #puts "line 157" unless @button_dice.enable?
            if @game.current_player.current_dice.nil?
                @button_dice.images.first.draw(@button_dice.position_x, @button_dice.position_y, 2, scale_x=0.05, scale_y = 0.05)
                @button_dice.images.first.draw(@button_dice.position_x + @button_dice.size_x, @button_dice.position_y, 2, scale_x=0.05, scale_y = 0.05)
            else
                dice =  @game.current_player.current_dice

                @button_dice.images[dice[0]-1].draw(@button_dice.position_x, @button_dice.position_y, 2, scale_x=0.05, scale_y = 0.05)
                @button_dice.images[dice[1]-1].draw(@button_dice.position_x + @button_dice.size_x, @button_dice.position_y, 2, scale_x=0.05, scale_y = 0.05)
            end
        end
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
            when :empty
                @empty_treasure.draw(aux.pos_x, aux.pos_y, 1)
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
        attr_reader :step

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
            puts "oxigen: #{@submarine.oxigen}"
            if @submarine.oxigen == 0
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
            puts "Step #{@step}"
            case @step
            when 0
                update_oxigen
                @step += 1
                puts "Turno jugador #{@current_player.name}, lleva #{@current_player.loot.count} tesoros"
            when 1
                if button_name == :direction
                    @current_player.change_direction!
                else
                    puts "rolling"
                    @current_player.roll_dice
                    if @current_player.direction == :down
                        @current_player.move_down
                    else
                        @current_player.move_up
                    end
                    @step += 1
                end
            when 2
                if button_name == :pick
                    @current_player.loot.append(@current_player.current_position.treasure)
                    @current_player.current_position.treasure = Treasure.new(:empty, 0)
                elsif button_name == :drop
                    @current_player.current_position.treasure = @current_player.loot.pop 
                end
                next_player
                process
            end
        end

        def next_player
            @current_player = @players[@players.index(@current_player) + 1]
            if @current_player.nil?
                @current_player = @players.first
            end
            if @current_player.return == true
                next_player
            end
            @step = 0
        end

    end

    class Player

        attr_accessor :loot, :name, :color, :current_dice, :current_position, :rendered_position, :image, :status
        attr_reader :steps_left, :direction, :return

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
            @status = :alive
            @return = false
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

        def move_down
            puts "moving_down"
            aux = @current_position
            while @steps_left != 0 && !aux.nil?
                aux = aux.next
                while !aux.player.nil? 
                    aux = aux.next
                end                
                @steps_left -=1
            end
            @current_position.player = nil unless @current_position.class == Submarine
            aux.player = self
            @current_position = aux
            
        end

        def move_up
            puts "moving_up"
            aux = @current_position
            while @steps_left != 0 && aux.class != Submarine
                aux = aux.prev
                while aux.class != Submarine && !aux.player.nil? 
                    aux = aux.prev
                end                
                @steps_left -=1
            end
            @current_position.player = nil unless @current_position.class == Submarine
            aux.player = self unless aux.class == Submarine
            @current_position = aux
            @return = true if @current_position.class == Submarine
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
                if @direction == :down
                    @rendered_position = @rendered_position.next
                else
                    @rendered_position = @rendered_position.prev
                end
                @clock = nil
            end
        end

        def can_pick?
            @current_position.treasure&.type != :empty 
        end

        def can_drop?
            @current_position.treasure&.type == :empty && !@loot.empty?
        end

        def is_moving?
            @rendered_position != @current_position
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
        attr_reader :treasure

        def initialize(x,y)
            @oxigen = 25
            @next = nil
            @pos_x = x
            @pos_y = y
            @treasure = nil
        end

    end

end

DeepSeaAdventure.new.show