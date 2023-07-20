
class Buttons

    attr_accessor :position_x, :position_y, :size_x, :size_y, :image, :process, :images
    attr_reader :name

    def initialize(position_x:, position_y:, images:nil, image:nil, name: nil, active: nil, scale_x: 1, scale_y: 1, &process)
        @position_x = position_x
        @position_y = position_y
        @image = image
        @images = images
        @active = active || false
        @process = process
        @name = name
        set_sizes(scale_x, scale_y)
    end

    def clicked?(mouse_x, mouse_y)
        
        puts "mouse: x: #{mouse_x}, y: #{mouse_y}"
        puts "position: x: #{@position_x}, y:#{@position_y}"
        puts "position and size: x: #{@position_x + @size_x}, y: #{@position_y + @size_y}"
        if mouse_x >= @position_x && mouse_x < (@position_x + @size_x)
            if mouse_y >= @position_y && mouse_y < (@position_y + @size_y)
                puts "clicked?: #{@name}"
                return true
            end
        end
        false 
    end

    def enable?
        @active
    end

    def disable!
        #puts "Disabling #{name}"
        @active = false
    end

    def enable!
        #puts "Enabling #{name}"
        @active = true
    end

    def draw
        unless image.nil?
            image.draw(@position_x, @position_y)
        end
    end

    private
    def set_sizes(scale_x, scale_y)
        if @image.nil?
            @size_x = @images.first.width * scale_x
            @size_y = @images.first.height * scale_y
        else
            @size_x = image.width * scale_x
            @size_y = image.height * scale_y
        end
    end
end
