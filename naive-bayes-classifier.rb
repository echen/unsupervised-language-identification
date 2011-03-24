class Array
  def sum
    self.reduce(0) { |total, element| total + element }
  end
  
  def product
    self.reduce(1) { |total, element| total * element }
  end
end

class NaiveBayesClassifier
  attr_reader :num_categories, :prior_token_count, :prior_category_counts
  attr_accessor :category_names
  
  # `num_categories`: number of categories we want to classify.
  # `prior_category_counts`: array of parameters for a Dirichlet prior that we place on the prior probabilities of each category. Set the array to all 0's if you want to use maximum likelihood estimates. Defaults to uniform reals from the unit interval if nothing is set.
  # `prior_token_count`: parameter for a beta prior that we place on p(token|category). Set to 0 if you want to use maximum likelihood estimates.
  def initialize(num_categories = 2, prior_token_count = 0.001, prior_category_counts = nil, category_names = nil)
    @num_categories = num_categories
    @prior_token_count = prior_token_count
    @prior_category_counts = prior_category_counts || Array.new(@num_categories) { rand }
    @category_names = category_names || (0..num_categories-1).map(&:to_s).to_a
    
    @token_counts = Array.new(@num_categories) do # `@token_counts[category][token]` is the (weighted) number of times we have seen `token` with this category
      Hash.new { |h, token| h[token] = 0 }
    end
    @total_token_counts = Array.new(@num_categories, 0) # `@total_token_counts[category]` is always equal to `@token_counts[category].sum`
    @category_counts = Array.new(@num_categories, 0) # `@category_counts[category]` is the (weighted) number of training examples we have seen with this category
  end
  
  # `example`: an array of tokens.
  def train(example, category_index, probability = 1)
    example.each do |token|
      @token_counts[category_index][token] += probability
      @total_token_counts[category_index] += probability
    end
    @category_counts[category_index] += probability
  end
  
  def classify(tokens)
    max_prob, max_category = -1, -1
    get_posterior_category_probabilities(tokens).each_with_index do |prob, category|
      max_prob, max_category = prob, category if prob > max_prob
    end
    return max_category
  end
  
  # Returns p(category | token), for each category, in an array.
  def get_posterior_category_probabilities(tokens)
    unnormalized_posterior_probs = (0..@num_categories-1).map do |category|
      p = tokens.map { |token| get_token_probability(token, category) }.product # p(tokens | category)
      p * get_prior_category_probability(category) # p(tokens | category) * p(category)
    end
    normalization = unnormalized_posterior_probs.sum
    normalization = 1 if normalization == 0
    return unnormalized_posterior_probs.map{ |p| p / normalization }
  end    
  
  private
  
  # p(token | category)
  def get_token_probability(token, category_index)
    denom = @total_token_counts[category_index] + @token_counts[category_index].size * @prior_token_count    
    if denom == 0
      return 0
    else
      return (@token_counts[category_index][token] + @prior_token_count).to_f / denom
    end
  end
  
  # p(category)
  def get_prior_category_probability(category_index)
    denom = @category_counts.sum + @prior_category_counts.sum    
    if denom == 0
      return 0
    else
      return (@category_counts[category_index] + @prior_category_counts[category_index]).to_f / denom
    end
  end  
end