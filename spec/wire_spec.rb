require "spec_helper"

def runner(times, options)
  list = []
  times.times do |n|
    list << Wire.new(options) do |var|
      yield
    end
  end
  list.map(&:join)
end

def time
  Time.now.to_f
end

describe Wire do
  before(:each) do
    counter = Counter.new
    Wire.should_receive(:counter).any_number_of_times.and_return(counter)
  end
  
  context "should be able to do run within the time limit" do
    it "< max threads" do
      start = time
      runner(10, {max: 10, wait: 1}) do
        sleep 0.1
      end
  
      (time - start).should < 1.15
    end
  
    it "> max threads" do
      start = time
      runner(11, {max: 10, wait: 1}) do
        sleep 0.1
      end
  
      (time - start).should > 1.2
    end
  end
  
  it "should run using one thread" do
    start = time
    runner(1, {max: 1, wait: 1}) do
      sleep 0.1
    end
  
    (time - start).should < 0.2
  end
  
  it "should run using one thread, using a high max value" do
    start = time
    runner(1, {max: 100, wait: 1}) do
      sleep 0.1
    end

    (time - start).should < 0.2
  end
  
  it "it should not wait" do
    start = time
    runner(11, {max: 10, wait: 0}) do
      sleep 0.1
    end
  
    (time - start).should < 0.25
  end
  
  context "error" do
    it "should use the default values if wrong arguments is being passed" do
      w = Wire.new(max: 0) {}.join
      w.instance_eval do
        @max.should == 10
        @wait.should == 1
      end
    end
    
    it "should use the default values if nothing is being passed" do
      w = Wire.new({}) {}.join
      w.instance_eval do
        @max.should == 10
        @wait.should == 1
      end
    end
    
    it "should use the default values if wrong arguments is being passed" do
      w = Wire.new(wait: 5) {}.join
      w.instance_eval do
        @max.should == 10
        @wait.should == 5
      end
    end
    
    it "should be possible to raise an error" do
      lambda do
        Wire.new(wait: 5, max: 1) do
          raise StandardError.new
        end.join
      end.should raise_error(StandardError)
    end
    
    it "should be silent" do
      lambda do
        Wire.new(wait: 5, max: 1, silent: true) do
          raise StandardError.new
        end.join
      end.should_not raise_error(StandardError)
    end
    
    it "should raise timeout error" do
      lambda do
        Wire.new(wait: 5, max: 1, timeout: 1) do
          sleep 5
        end.join
      end.should raise_error(Timeout::Error)
    end
    
    it "should not raise timeout error" do
      lambda do
        Wire.new(wait: 5, silent: true, max: 1, timeout: 1) do
          sleep 5
        end.join
      end.should_not raise_error(Timeout::Error)
    end
    
     it "should not raise timeout error" do
        lambda do
          Wire.new(wait: 5, silent: true, max: 1, timeout: 2) do
            sleep 1
          end.join
        end.should_not raise_error(Timeout::Error)
      end
  end
end