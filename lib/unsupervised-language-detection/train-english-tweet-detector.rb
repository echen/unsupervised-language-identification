# Build an unsupervised language classifier for tweets, 
# using trigrams from a set of 5000 tweets.

require_relative './language-detector'

TWEETS_FILENAME = "datasets/tweets_5000.txt"

training_sentences = File.readlines(TWEETS_FILENAME).map{ |tweet| tweet.normalize }
detector = LanguageDetector.new(:ngram_size => 3)
detector.train(30, training_sentences)
detector.yamlize("english-tweet-detector.yaml")