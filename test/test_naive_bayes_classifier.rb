require 'test/unit'
require_relative '../src/naive-bayes-classifier'

class NaiveBayesClassifierTests < Test::Unit::TestCase
  def setup
    # Test with all prior parameters set to zero.
    @mle = NaiveBayesClassifier.new(:num_categories => 2, :prior_token_count => 0, :prior_category_counts => [0, 0])
    example_colors = %w( red green blue )
    example_numbers = %w( one two three )
    @mle.train(example_colors, 0)
    @mle.train(example_colors, 0)
    @mle.train(example_numbers, 0)       
    @mle.train(example_numbers, 1)
    @mle.train(example_numbers, 1)
    @mle.train(example_colors, 1)
    
    # Test smoothing.
    @smoothed = NaiveBayesClassifier.new(:num_categories => 2, :prior_token_count => 0.001, :prior_category_counts => [1, 1])
    @smoothed.train(example_colors, 0)
    @smoothed.train(example_numbers, 1)
    
    # Test three categories.
    @three = NaiveBayesClassifier.new(:num_categories => 3, :prior_token_count => 0.001, :prior_category_counts => [1, 1, 1])
    @three.train(example_colors, 0)
    @three.train(example_numbers, 1)
    example_planets = %w( mars earth venus )
    @three.train(example_planets, 2)
  end
  
  def test_classify
    assert_equal 0, @mle.classify(%w( blue green red ))
    assert_equal 0, @mle.classify(%w( blue green one ))
    assert_equal 1, @mle.classify(%w( blue two one ))
    assert_equal 1, @mle.classify(%w( three two one ))    
    
    assert_equal 0, @smoothed.classify(%w( blue green red ))
    assert_equal 0, @smoothed.classify(%w( blue green one ))
    assert_equal 1, @smoothed.classify(%w( blue two one ))
    assert_equal 1, @smoothed.classify(%w( three two one ))
    
    assert_equal 0, @three.classify(%w( blue green venus ))
    assert_equal 1, @three.classify(%w( one two mars ))
    assert_equal 2, @three.classify(%w( one three mars earth venus green))
    assert_equal 2, @three.classify(%w( mars green venus ))        
  end

  def test_posterior_probabilities
    assert_equal [8.0 / 9, 1.0 / 9], @mle.get_posterior_category_probabilities(%w( blue green red )) 
    assert_equal [1.0 / 9, 8.0 / 9], @mle.get_posterior_category_probabilities(%w( three two one ))    

    p, q = @mle.get_posterior_category_probabilities(%w( blue green one ))
    assert_in_delta p, 2.0 / 3, 0.00001
    assert_in_delta q, 1.0 / 3, 0.00001
    
    p, q = @smoothed.get_posterior_category_probabilities(%w( blue green red ))
    assert p > 0
    assert q > 0
    assert_in_delta 1, p + q, 0.00001
  end  
end