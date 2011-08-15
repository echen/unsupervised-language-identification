require 'yaml'
require_relative './naive-bayes-classifier'

class String  
  # Returns a set of character `n`-grams computed from this string.
  def to_ngrams(n)
    self.normalize_tweet.scan(/.{#{n}}/)
  end
  
  # TODO: Try not normalizing out all non-ASCII characters! Should significantly reduce false positive rate.
  def normalize_tweet
    self.remove_tweeters.remove_links.remove_hashtags.downcase.gsub(/\s/, " ").gsub(/[^a-z0-9\s]/, "").strip
  end  
  
  # Remove mentions of other twitter users.
  def remove_tweeters
    self.gsub(/@\w+/, "")
  end
  
  # Remove any words beginning with '#'.
  def remove_hashtags
    self.gsub(/#\w+/, "")
  end
  
  # Remove anything beginning with 'http', 'www', or ending with '.com'.
  # (Not the most sophisticated link remover, I know.)
  def remove_links
    ret = self.gsub(/http\S+/, "")
    ret = ret.gsub(/www\S+/, "")
    ret = ret.gsub(/\S+\.com/, "")
    ret
  end
end

# Given a set of sentences in multiple languages, build a classifier to detect the majority language.
class LanguageDetector
  attr_reader :classifier
  
  def initialize(options = {})
    options = {:ngram_size => 3}.merge(options)    
    @ngram_size = options[:ngram_size]
    @classifier = NaiveBayesClassifier.new(:num_categories => 2)
  end
  
  def train(max_epochs, training_sentences)
    @classifier = NaiveBayesClassifier.train_em(max_epochs, training_sentences.map{ |sentence| sentence.to_ngrams(@ngram_size) })
    @classifier.category_names = 
      if @classifier.get_prior_category_probability(0) > @classifier.get_prior_category_probability(1)
        %w( majority minority )
      else
        %w( minority majority )
      end    
  end
  
  # Returns the (named) category the sentence belongs to.
  def classify(sentence)
    category_index = @classifier.classify(sentence.to_ngrams(@ngram_size))
    @classifier.category_names[category_index]
  end
  
  def probabilities(sentence)
    @classifier.get_posterior_category_probabilities(sentence.to_ngrams(@ngram_size))
  end
  
  # Dumps the language model to a file.
  def yamlize(filename)
    File.open(filename, "w") do |f|
      f.puts self.to_yaml
    end
  end
  
  # Loads the language model from a file.
  def self.load_yaml(filename)
    return YAML::load(File.read(filename))
  end  
end