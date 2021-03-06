require "thread"
require "monitor"
require "timeout"

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
    @retries ||= 0
    @retry = 0
    @delay ||= 0
    
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
    @timeout ? Timeout::timeout(@timeout) { @block.call(*@vars) } : @block.call(*@vars)
  rescue StandardError => error
    if (@retry += 1) < @retries
      sleep @delay; retry
    end
    report(error, "An error occurred: #{error.inspect}")
  ensure
    @counter.synchronize do
      if @max == @counter.i or @counter.last
        @counter.last = Time.now.to_f
      end
      @counter.dec
      @counter.cond.signal
    end
  end
  
  def report(error, message)
    @silent ? warn(message) : (raise error)
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