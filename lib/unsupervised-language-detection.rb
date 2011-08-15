require_relative './unsupervised-language-detection/language-detector'

module UnsupervisedLanguageDetection
  def self.is_english_tweet?(tweet)
    @detector ||= LanguageDetector.load_yaml(File.expand_path('../unsupervised-language-detection/english-tweet-detector.yaml', __FILE__))
    @detector.classify(tweet) == "majority"
  end
end

UnsupervisedLanguageDetection.is_english_tweet?("http://www.test.com/ ")