class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def bold
    colorize(1)
  end
  def rev
    colorize(3)
  end
  def underline
    colorize(4)
  end
  def blink
    colorize(5)
  end
  def dark
    colorize(30)
  end
  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def purple
    colorize(35)
  end

  def teal
    colorize(36)
  end
  

end
