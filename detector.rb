require 'yaml'

class String
  # If `all_ngrams` is passed in, only keep ngrams in that set.
  # (Because we may want to ignore low-frequency ngrams.)
  def to_ngrams(n, all_ngrams = nil)
    x = self.normalize.scan(/.{#{n}}/)
    x = x.select{ |ngram| all_ngrams.include?(ngram) } if all_ngrams
    x
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

class Hash
  def puts_sorted(n = 25)
    self.sort_by{ |k, v| -v }.first(n).each{ |k, v| puts [k, v].join("\t") }
  end
end

class Array
  def sum
    self.inject{ |s, t| s + t }
  end
end

class Language
  SMOOTHING_FACTOR = 0.00001 # This probably shouldn't be hard-coded =(.
  attr_accessor :base_prob, :ngram_counts, :ngram_probs, :total_num_ngrams  
    
  def initialize(base_prob, total_num_ngrams)
    @base_prob = base_prob
    @total_num_ngrams = total_num_ngrams
    @ngram_counts = Hash.new(0)
    @ngram_probs = Hash.new{ |h, k| h[k] = rand } # It's okay to use rand, since the probabilities get normalized out in the end. # (1.0 / @total_num_ngrams)
  end    
  
  # Compute the unnormalized probability of generating this set of ngrams.
  def unnormalized_prob(ngrams)
    @base_prob * ngrams.inject(1) { |prob, ngram| prob * ((@ngram_probs[ngram] || rand) + SMOOTHING_FACTOR)}
  end
  
  # Add the set of ngrams to our (probability-weighted) count.
  def add_ngrams(ngrams, probability)
    ngrams.each{ |ngram| @ngram_counts[ngram] += probability }
  end  
  
  # Recompute the probability of generating each ngram.
  def m_step
    total_count = @ngram_counts.values.sum
    @base_prob = total_count / @total_num_ngrams    
    @ngram_counts.each do |ngram, count|
      @ngram_probs[ngram] = count.to_f / total_count
      @ngram_counts[ngram] = 0 # Reset this count.
    end
  end
end

class Detector
  def initialize(options = {})
    @options = {:ngram_size => 3,
                :min_ngram_count => 5,
                :english_prior_prob => 0.7,
                :num_iterations => 30}.merge(options)
  end
  
  def train(training_set_filename)
    # Filter out low-frequency ngrams.
    all_ngram_counts = Hash.new(0)
    IO.foreach(training_set_filename) do |line|
      ngrams = line.to_ngrams(@options[:ngram_size])
      ngrams.each{ |ngram| all_ngram_counts[ngram] += 1 }
    end
    all_ngrams = all_ngram_counts.select{ |ngram, count| count > @options[:min_ngram_count] }
    total_num_ngrams = all_ngrams.map{ |ngram, count| count }.sum
    all_ngrams = all_ngrams.map{ |ngram, count| ngram }

    # Perform the training.
    @english = Language.new(@options[:english_prior_prob], total_num_ngrams)
    @other = Language.new(1 - @options[:english_prior_prob], total_num_ngrams)
    @options[:num_iterations].times do |i|
      # E step - for each document, recompute the probability that it comes from language i.
      IO.foreach(training_set_filename) do |line|
        ngrams = line.to_ngrams(@options[:ngram_size], all_ngrams)

        p_english = @english.unnormalized_prob(ngrams)
        p_other = @other.unnormalized_prob(ngrams)
        p_e = p_english / (p_english + p_other)
        p_o = 1 - p_e

        @english.add_ngrams(ngrams, p_e)
        @other.add_ngrams(ngrams, p_o)
      end

      # M step - for each language, recompute the probability that it generates ngram i.
      @english.m_step
      @other.m_step
    end
    
    # We assume English is the majority language.
    # While converging, the languages may have switched around, so switch back.
    if @english.base_prob < @other.base_prob
      @english, @other = @other, @english
    end
  end
  
  # TODO: rename this, since the majority language doesn't necessarily have to be English.
  def compute_english_prob(document)
    ngrams = document.to_ngrams(@options[:ngram_size])
    p_english = @english.unnormalized_prob(ngrams)
    p_other = @other.unnormalized_prob(ngrams)
    p_e = p_english / (p_english + p_other)
    p_o = 1 - p_e
    
    return p_e
  end
  
  def is_english?(document)
    return compute_english_prob(document) > 0.5
  end
  
  def yamlize(filename)
    File.open(filename, "w") do |f|
      f.puts self.to_yaml
    end
  end
  
  def self.load_yaml(filename)
    return YAML::load(File.read(filename))
  end    
end

=begin
detector = Detector.new(:num_iterations => 10)
detector.train("smiley_tweets_tiny.txt")
=end