require_relative './naive-bayes-em'
require_relative './naive-bayes-classifier'

class String  
  # Returns a set of `n`-grams computed from this string.
  def to_ngrams(n)
    self.normalize.scan(/.{#{n}}/)
  end
  
  # TODO: Try not normalizing out all non-ASCII characters! Should significantly reduce false positive rate.
  def normalize
    self.remove_tweeters.remove_links.remove_hashtags.downcase.gsub(/\s/, " ").gsub(/[^a-z0-9\s]/, "")    
  end  
  
  # Remove mentions of other twitter users.
  def remove_tweeters
    self.gsub(/@.+?\s/, "")
  end
  
  def remove_hashtags
    self.gsub(/#.+?\s/, "")
  end
    
  def remove_links
    self.gsub(/http.+?\s/, "")
  end
end

class LanguageDetector
  def initialize
    @em = NaiveBayesEm.new(2)
  end
  
  def train(max_epochs, training_examples)
    @em.train(max_epochs, training_examples)
    @em.classifier.category_names = 
      if @classifier.get_prior_category_probability(0) > @classifier.get_prior_category_probability(1)
        %w( majority minority )
      else
        %w( minority majority )
      end    
  end
  
  def classify(example)
    @em.classifier.category_names[@em.classify(example)]
  end
end