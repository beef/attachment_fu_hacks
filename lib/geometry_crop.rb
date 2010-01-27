Geometry.module_eval do  
  # ! and @ are removed until support for them is added
  FLAGS = ['', '%', '<', '>', '!']#, '@']

  # Convert object to a geometry string
  def to_s
    str = ''
    str << "%g" % @width if @width > 0
    str << 'x' if (@width > 0 || @height > 0)
    str << "%g" % @height if @height > 0
    str << "%+d%+d" % [@x, @y] if (@x != 0 || @y != 0)
    str << RFLAGS.index(@flag)
  end
  
  # attempts to get new dimensions for the current geometry string given these old dimensions.
  # This doesn't implement the aspect flag (!) or the area flag (@).  PDI
  def new_dimensions_for(orig_width, orig_height)
    new_width  = orig_width
    new_height = orig_height
    
    RAILS_DEFAULT_LOGGER.debug "Flag is #{@flag}"

    case @flag
      when  :aspect
        new_width = @width unless @width.nil?
        new_height = @height unless @height.nil?
      when :percent
        scale_x = @width.zero?  ? 100 : @width
        scale_y = @height.zero? ? @width : @height
        new_width    = scale_x.to_f * (orig_width.to_f  / 100.0)
        new_height   = scale_y.to_f * (orig_height.to_f / 100.0)
      when :<, :>, nil
        scale_factor =
          if new_width.zero? || new_height.zero?
            1.0
          else
            if @width.nonzero? && @height.nonzero?
              [@width.to_f / new_width.to_f, @height.to_f / new_height.to_f].min
            else
              @width.nonzero? ? (@width.to_f / new_width.to_f) : (@height.to_f / new_height.to_f)
            end
          end
        new_width  = scale_factor * new_width.to_f
        new_height = scale_factor * new_height.to_f
        new_width  = orig_width  if @flag && orig_width.send(@flag,  new_width)
        new_height = orig_height if @flag && orig_height.send(@flag, new_height)
    end

    [new_width, new_height].collect! { |v| v.round }
  end
end