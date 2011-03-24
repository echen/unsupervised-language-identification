require 'test/unit'
require './naive-bayes-em'

class NaiveBayesEmTests < Test::Unit::TestCase
  def setup
    @two = NaiveBayesEm.new(2)
    number_examples = [%w(one two three), %w(two three four five six), %w(seven three one four five eight nine), %w(ten one two six three seven), %w(one five six seven two eight ten nine)]
    color_examples = [%w(red blue green), %w(red blue yellow purple red), %w(brown green purple red blue black white)]
    @two.train(20, number_examples + color_examples)
  end
  
  def test_classify
    color_classifications = [%w(red rainbow green grass), %w(one red blue green), %w(brown cow)].map do |example|
      @two.classifier.classify(example)
    end    
    number_classifications = [%w(one hundred two three red), %w(one nine one one eight), %w(three cows)].map do |example|
      @two.classifier.classify(example)
    end
    
    assert_equal 1, color_classifications.uniq.size
    assert_equal 1, number_classifications.uniq.size
    assert_not_equal color_classifications.first, number_classifications.first
  end
end
