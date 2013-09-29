class Array
  def special_sort metric
    new = []
    new << self.item[1].first
    self.each do |item|
      if item[1][metric] > new[new.length-1]
        new << item

    end
  end
end