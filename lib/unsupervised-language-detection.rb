require File.expand_path('../unsupervised-language-detection/language-detector', __FILE__)

module UnsupervisedLanguageDetection
  def self.is_english_tweet?(tweet)
    @detector ||= LanguageDetector.load_yaml(File.expand_path('../unsupervised-language-detection/english-tweet-detector.yaml', __FILE__))
    @detector.classify(tweet) == "majority"
  end
end