require File.expand_path('../language-detector', __FILE__)

TWEETS_FILENAME = "datasets/tweets_5000.txt"

training_sentences = File.readlines(TWEETS_FILENAME).map{ |tweet| tweet.normalize }
detector = LanguageDetector.new(:ngram_size => 2)
detector.train(30, training_sentences)
detector.yamlize("detector.yaml")

puts detector.classifier.get_prior_category_probability(0)
puts detector.classifier.get_prior_category_probability(1)