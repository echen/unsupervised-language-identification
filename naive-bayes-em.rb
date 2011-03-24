=begin
require_relative './naive-bayes-classifier'

class NaiveBayesEm
  attr_reader :classifier
  
  def initialize(num_categories = 2, prior_token_count = 0.001, prior_category_counts = nil)
    @classifier = NaiveBayesClassifier.new(num_categories, prior_token_count, prior_category_counts)
  end
  
  # Performs a Naive Bayes EM algorithm on `training_examples`, an array of examples, where each example is an array of tokens.
  def train(max_epochs, training_examples)
    prev_classifier = @classifier    
    max_epochs.times do
      classifier = NaiveBayesClassifier.new(prev_classifier.num_categories, prev_classifier.prior_token_count, prev_classifier.prior_category_counts)
    
      # E-M training
      training_examples.each do |example|
        # E-step: for each training example, recompute its classification probabilities.
        posterior_category_probs = prev_classifier.get_posterior_category_probabilities(example) 
              
        # M-step: for each category, recompute the probability of generating each token.
        posterior_category_probs.each_with_index do |p, category|
          classifier.train(example, category, p) 
        end
      end
    
      prev_classifier = classifier
    
      # TODO: add a convergence check, so we can break out early if we want.
    end  
    @classifier = prev_classifier
  end
  
  def classify(example)
    @classifier.classify(example)
  end
end
=end