require 'test/unit'
require_relative '../lib/unsupervised-language-detection/language-detector'
require_relative '../lib/unsupervised-language-detection'

class TweetLanguageDetectionTests < Test::Unit::TestCase
  def setup
    @detector = LanguageDetector.load_yaml("lib/unsupervised-language-detection/english-tweet-detector.yaml")
  end
  
  def test_classification
    assert_equal "majority", @detector.classify("Hello")
    assert_equal "majority", @detector.classify("http://www.test.com/")
    assert_equal "majority", @detector.classify("http://www.test.com/ ")    
    assert_equal "majority", @detector.classify("I am an English sentence.") 
    
    assert_equal "minority", @detector.classify("Bonjour, je m'appelle Edwin.")     
    assert_equal "minority", @detector.classify("Ni hao.")
    assert_equal "minority", @detector.classify("Hasta la vista.")    
    assert_equal "minority", @detector.classify("Kuch kuch hota hai.")    
    assert_equal "minority", @detector.classify("Ich kann dich kaum noch sehen.")    
  end
  
  def test_empty_classification
    assert_equal "majority", @detector.classify("")
  end
  
  def test_normalization
    assert_equal @detector.classify("Hi there!"), @detector.classify("@miguelgonzales Hi there!")
    assert_equal @detector.classify("I am testing putting a link inside."), @detector.classify("I am testing http://miguelgonzales.com putting a link inside.")
    assert_equal @detector.classify("Hashtag test."), @detector.classify("Hashtag test #bonjour #hola.")
  end
  
  def test_module
    assert UnsupervisedLanguageDetection.is_english_tweet?("Hello")
    assert UnsupervisedLanguageDetection.is_english_tweet?("http://www.test.com/")
    assert UnsupervisedLanguageDetection.is_english_tweet?("http://www.test.com/ ")    
    assert UnsupervisedLanguageDetection.is_english_tweet?("I am an English sentence.") 
    
    assert !UnsupervisedLanguageDetection.is_english_tweet?("Bonjour, je m'appelle Edwin.")     
    assert !UnsupervisedLanguageDetection.is_english_tweet?("Ni hao.")
    assert !UnsupervisedLanguageDetection.is_english_tweet?("Hasta la vista.")    
    assert !UnsupervisedLanguageDetection.is_english_tweet?("Kuch kuch hota hai.")    
    assert !UnsupervisedLanguageDetection.is_english_tweet?("Ich kann dich kaum noch sehen.")
    
    assert UnsupervisedLanguageDetection.is_english_tweet?("@miguelgonzales Hi there!")
    assert UnsupervisedLanguageDetection.is_english_tweet?("I am testing http://miguelgonzales.com putting a link inside.")
    assert UnsupervisedLanguageDetection.is_english_tweet?("Hashtag test #bonjour #hola.")
  end
end