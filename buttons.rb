
class Buttons

    attr_accessor :position_x, :position_y, :size_x, :size_y, :image, :process

    def initialize(position_x, position_y, image, &process)
        @position_x = position_x
        @position_y = position_y
        @size_x = image.width
        @size_y = image.height
        @image = image
        @active = true
        @process = process
    end

    def clicked?(mouse_x, mouse_y)
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
end
