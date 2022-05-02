class Ui
  def initialize t
    @title = t
    @html = []
  end
  def html
    return %[<fieldset><legend>#{@title}</legend>#{@html.join('')}</fieldset>]
  end
  def button(t, h={});
    a = [];
    h.each_pair { |k,v|
      a << %[#{k}='#{v}']
    };
    @html << %[<button #{a.join(' ')}>#{t}</button>]
  end
  def input(h={});
    a = [];
    h.each_pair { |k,v|
      a << %[#{k}='#{v}']
    };
    @html << %[<input #{a.join(' ')}>];
  end
end

class UI
  def initialize
    @ui = Hash.new {|h,k| h[k] = Ui.new(k) }
  end
  def [] k
    @ui[k]
  end
  def html
    a = []
    @ui.each_pair {|k,v| a << v.html }
    return a.join('') 
  end
end