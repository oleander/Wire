require "thread"
require "monitor"

class Wire < Thread  
  def self.counter
    @counter ||= Counter.new
  end
  
  def initialize(args, &block)
    args.keys.each { |name| instance_variable_set "@" + name.to_s, args[name] }
    
    if @max.to_i <= 0 or @wait.nil?
      warn "Both max and wait needs to be passed, where max > 0. Using default values"
      @max = 10 if @max.to_i <= 0
      @wait ||= 1
    end
    
    @block   = block
    @counter = Wire.counter
    
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
      if @max - 1 == @counter.i
        @counter.last = Time.now.to_f
      end
      @counter.dec
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