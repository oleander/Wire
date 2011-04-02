# Wire

Run a strict amount of threads during a time interval, primarily used for [web scraping](http://en.wikipedia.org/wiki/Web_scraping).

## How to use

### Example 1 - Basic

Start 100 threads, only run 10 at the same time, with a 3 second delay between each new thread, except the first 10.

    100.times do
      Wire.new(max: 10, wait: 3) do
        # Do stuff
      end
    end

### Example 2 - Timer

    11.times do
      Wire.new(max: 10, wait: 1) do
        sleep 0.1
      end
    end

Time to run: ~ *1.2 seconds*.

This is how it works.

- 11 threads is created, done at time 0.
- Running 10 threads, done at time 0.1
- Wait 1 second, done at time 1.1
- Start the 11th thread, done at time 1.2
    
### Example 3 - Pass arguments

    Wire.new(max: 10, wait: 1, vars: ["A", "B"]) do |first, last|
      puts first # => "A"
      puts last # => "B"
    end

    100.times do |n|
      Wire.new(max: 10, wait: 1, vars: [n]) do |counter|
        puts counter
      end
    end
    
    # => 1 2 3 4 5 ...

### Example 4 - Scraping

This project was originally build to solve the request limit problem when using [Spotify´s Meta API](http://developer.spotify.com/en/metadata-api/overview/).

> In order to make the Metadata API snappy and open for everyone to use, rate limiting rules apply. If you make too many requests too fast, you’ll start getting 403 Forbidden responses. When rate limiting has kicked in, you’ll have to wait 10 seconds before making more requests. The rate limit is currently 10 request per second per ip. This may change.

We wanted to make as many request as possible without being banned due to the rate limit.

    require "rest-client"
    require "wire"
    require "uri"

    a_very_large_list_of_songs = ["Sweet Home Alabama", ...]
    
    a_very_large_list_of_songs.each do |s|
      Wire.new(max: 10, wait: 1, vars: [s]) do |song|
        data = RestClient.get "http://ws.spotify.com/search/1/track.json?q=#{URI.encode(song)}"
        # Do something with the data
      end
    end

### Tip

Don't forget to join your threads using `Thread#join`.
 
    list = []
    10.times do |n|
      list << Thread.new do
        # Do stuff
      end
    end
    list.map(&:join)
    
Read more about [#join](http://corelib.rubyonrails.org/classes/Thread.html#M001145) here.

## Arguments to pass

Ingoing arguments to `new`.

- **max** (Integer) The maximum amount of threads to run a the same time. The value 10 will be used if `max` is nil or zero.
- **wait** (Integer) The time to wait before starting a new thread.
- **vars** (Array) A list of arguments to the block.
- **silent** (Boolean) The given block will not raise error if set to true. Default is false.
- **timeout** (Integer) The maximum time to run *one* thread, default is *no limit*.
- **retries** (Integer) How many times should we retry? Default is 0.
- **delay** (Float) Time between each retry. Default is 0.

## How do install

    [sudo] gem install wire
    
## Requirements

Wire is tested on OS X 10.6.7 using Ruby 1.9.2.