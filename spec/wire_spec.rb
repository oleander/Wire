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
  context "should be able to do run within the time limit" do
    it "< max threads" do
      start = time
      runner(10, {max: 10, wait: 1}) do
        sleep 0.1
      end

      (time - start).should < 1.05
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
      w = Wire.new(max: 0) {}
      w.instance_eval do
        @max.should == 10
        @wait.should == 1
      end
    end
    
    it "should use the default values if nothing is being passed" do
      w = Wire.new({}) {}
      w.instance_eval do
        @max.should == 10
        @wait.should == 1
      end
    end
    
    it "should use the default values if wrong arguments is being passed" do
      w = Wire.new(wait: 5) {}
      w.instance_eval do
        @max.should == 10
        @wait.should == 5
      end
    end
  end
end