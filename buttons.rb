
class Buttons

    attr_accessor :position_x, :position_y, :size_x, :size_y, :image, :process, :images

    def initialize(position_x, position_y, image={}, &process)
        @position_x = position_x
        @position_y = position_y
        @image = image[:image]
        @images = image[:images]
        @active = true
        @process = process
        set_sizes
    end

    def clicked?(mouse_x, mouse_y)
        puts "clicked?:"
        puts mouse_x, mouse_y
        puts @position_x, @position_y
        if mouse_x >= @position_x && mouse_x < (@position_x + size_x)
            if mouse_y >= @position_y && mouse_y < (@position_y + size_y)
                return true
                
            end
        end
        false 
    end

    def enable?
        @active
    end

    def disable!
        @active = false
    end

    def enable!
        @active = true
    end

    private
    def set_sizes
        if @image.nil?
            @size_x = @images.first.width
            @size_y = @images.first.height
        else
            @size_x = image.width
            @size_y = image.height
        end
    end
end
