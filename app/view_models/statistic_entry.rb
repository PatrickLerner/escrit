class StatisticEntry
  attr_accessor :data, :labels

  def initialize(data: nil, labels: nil)
    @data   = data
    @labels = labels
  end

  def sum
    data.sum
  end

  def count
    data.count
  end

  def average
    sum.to_f / count.to_f
  end
end
