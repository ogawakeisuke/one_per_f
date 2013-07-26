require "ruby-audio"
require "narray"
require "fftw3"
require './regression_line'



fname = "pinknoise.aif"
window_size = 1024
results = Array.new


buf = RubyAudio::Buffer.float(window_size)

RubyAudio::Sound.open(fname) do |snd|
  while snd.read(buf) != 0
    na = NArray.to_na(buf.to_a)

    fft_slice = FFTW3.fft(na, -1).to_a[0, window_size / 2].collect { |complex| complex.abs * 10 / (window_size / 2) }
    
    results << RegLine.new(fft_slice).regression_slope
  end
end


p results

p (results.inject { |sum, x| sum += x } / results.size)



# -1.0に近づけば高評価