require "ruby-audio"
require "narray"
require "fftw3"
require 'cairo'
# require './fft_scratch'



window_size = 1024

#
# 512個の空の配列が造られる
#
fft = Array.new(window_size / 2).collect { Array.new }


target_array = Array.new(512).collect {|a| a = rand }
p target_array
  

na = NArray.to_na(target_array)

fft_slice = FFTW3.fft(na).to_a[0, window_size / 2]
fft_slice.each_with_index do |complex, i| 
  fft[i] << complex
end



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
width = 3000
height = 600
radius = 10 # 半径

surface = Cairo::ImageSurface.new(format, width, height)
context = Cairo::Context.new(surface)

# 背景
context.set_source_rgb(1, 1, 1) # 白
context.rectangle(0, 0, width, height)
context.fill

fft.each_with_index do |compleces, i|
  ret_scale_rows(compleces).each_with_index do |val, j|
    context.set_source_rgb(val, 0, 0)
    context.arc(j*10, i, radius, 0, 10 * Math::PI)
    context.fill
  end
end

surface.write_to_png("sonogram.png")

