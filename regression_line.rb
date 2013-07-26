class RegLine
  attr_reader :x_points, :y_points

  def initialize(fft_array)
    @x_points = fft_array.collect.with_index { |val, i| i }
    @y_points = fft_array
  end


  def regression_slope
    residual_sum_of_x_and_y / residual_sum_of_x
  end

  #
  # 残差平方和はデータと推定モデルとの(ry 平均をとるよという意味
  #
  def residual_sum_of_x_and_y
    sum_x_and_y -  ( sum(x_points) * sum(y_points) / x_points.length.to_f )
  end

  #xの平均
  def residual_sum_of_x
    sum_sq_x - sum(x_points) ** 2 / x_points.length.to_f
  end


  def sum_sq_x
    x_points.inject(0) { |sum, x| sum += x * x  }
  end


  #
  # これは引数をもつように
  #
  def sum(points)
    points.inject(0) { |sum, x| sum += x }
  end

  def sum_x_and_y
    ret_val = 0
    x_points.each_with_index do |x, i|
      ret_val += x * y_points[i]
    end
    ret_val
  end
end


# r = RegLine.new(data)
# p r.regression_slope


