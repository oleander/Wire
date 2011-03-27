require "thread"
require "monitor"

class Wire < Thread  
  def self.counter
    @counter ||= Counter.new
  end
  
  def initialize(args, &block)
    args.keys.each { |name| instance_variable_set "@" + name.to_s, args[name] }
    
    @block   = block
    @counter = Wire.counter
    @max    ||= 20
    
    @counter.synchronize do
      @counter.cond.wait_until { @counter.i < @max }
      @counter.inc
    end
    
    if @counter.last and (t = Time.now.to_f - @counter.last) < @wait
      sleep (@wait - t)
    end
    
    super { runner }
  end
  
  def runner
    @block.call(*@vars)
  rescue StandardError => error
    raise error
  ensure
    @counter.synchronize do
      @counter.dec
      @counter.last = Time.now.to_f      
      @counter.cond.signal
    end
  end
end

class Counter
  attr_reader :i, :cond
  attr_accessor :last
  
  def initialize
    extend(MonitorMixin)
    @i = 0
    @cond = new_cond
  end
  
  def inc
    @i += 1
  end

  def dec
    @i -= 1
  end
end