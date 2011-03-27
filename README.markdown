# Wire


## How to use

### Initialize

    list = []
    100.times do |n|
      list << Wire.new(max: 10, wait: 1, vars: [n]) do |var|
        # Do stuff
      end
    end
    list.map(&:join)
    
## How do install

    [sudo] gem install wire