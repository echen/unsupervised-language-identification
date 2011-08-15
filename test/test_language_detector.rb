require 'test/unit'
require_relative '../lib/unsupervised-language-detection/language-detector'

class LanguageDetectorTests < Test::Unit::TestCase
  def setup
    # Detect vowel-y sentences (the majority language) vs. consonant-y sentences.
    @vowel_detector = LanguageDetector.new(:ngram_size => 2)
    vowel_examples = ["aeiou uoeia auoiao ai", "iouea eou eu eaiou", "ou oi oiea ieau", "eau au aou ia", "aei aae eaee iou aii iaa ooae oaiuuoouie", "aei iou iaou", "aeeeiioouuu uoeiae"]
    consonant_examples = ["bcbcbbccdd bcd cdbcbc dbdb", "cddccdbcbcdbd", "cdc bdc bdb cdc"]
    @vowel_detector.train(20, vowel_examples + consonant_examples)
  end
  
  def test_classify
    assert_equal "majority", @vowel_detector.classify("iou eao oiee aie tee")
    assert_equal "majority", @vowel_detector.classify("aeou one cdf oeaoi ioeae")    
    assert_equal "minority", @vowel_detector.classify("cdccdb")
    assert_equal "minority", @vowel_detector.classify("bcbbd cdcbdcb ae")    
  end
end