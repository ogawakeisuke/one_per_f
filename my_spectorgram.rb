require "ruby-audio"
require "narray"
require "fftw3"
require 'cairo'
# require './fft_scratch'



window_size = 1024


def sample_wave(rate = 1024)
  arr = (0...rate).map do |n|
    Math.sin(2 * 2 * Math::PI * n / rate) * 2
    # v + Math.cos(4 * 2 * Math::PI * n / rate) #　加算合成してる
  end
  return arr
end

# fftスライスのサイズの2倍分の配列数が必要
target_array = Array.new(window_size).collect.with_index {|a, i| a = Math.sin(i) }

p sample_wave
na = NArray.to_na(target_array)

fft_slice = FFTW3.fft(na).to_a[0, window_size / 2]



def window_size
  1024
end

def amp(complex)
  complex.abs / (window_size / 2)
end


def ret_color_rows(compleces)
  ret_array = []
  compleces.each do |complex|
    ret_array << color_pick_print(amp(complex).scale_between)
  end
  ret_array
end

def ret_scale_rows(compleces)
  ret_array = []
  compleces.each do |complex|
    ret_array << amp(complex).scale_between
  end
  ret_array
end


#
# Numericのオーバーライドでスケールメソッド
#
class Numeric
  def scale_between(from_min = 0.0, from_max = 1.0, to_min = 0, to_max = 255)
   ( ((to_max - to_min) * (self - from_min)) / (from_max - from_min) + to_min ).round  # + 1
  end
end


#
# 描画空間
#
format = Cairo::FORMAT_ARGB32
width = 1024
height = 512
radius = 5 # 半径

surface = Cairo::ImageSurface.new(format, width, height)
context = Cairo::Context.new(surface)

# 背景
context.set_source_rgb(1, 1, 1) # 白
context.rectangle(0, 0, width, height)
context.fill

fft_slice.each_with_index do |complex, i|
  context.set_source_rgb(255, 0, 0)
  context.arc(i * 2, amp(complex).scale_between, radius, 0, 10 * Math::PI)
  context.fill
end

surface.write_to_png("spectologram.png")

