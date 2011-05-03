require_relative './src/language-detector'

# Train on a mix of English and Spanish sentences, pulled from Project Gutenberg text.
training_sentences = File.readlines("datasets/gutenberg-training.txt")
detector = LanguageDetector.new(:ngram_size => 3)
detector.train(30, training_sentences)

# See how well we can classify English text (sentences from a different Project Gutenberg text, not the one we trained on).
puts "Testing on English sentences..."
true_english = 0
false_spanish = 0
IO.foreach("datasets/gutenberg-test-en.txt") do |line|
  next if line.strip.empty?
  if detector.classify(line) == "majority"
    true_english += 1
  else
    puts line
    false_spanish += 1    
  end
end
puts false_spanish
puts true_english

# See how well we can classify Spanish text.
puts
puts "Testing on Spanish sentences..."
true_spanish = 0
false_english = 0
IO.foreach("datasets/gutenberg-test-sp.txt") do |line|
  next if line.strip.empty?
  if detector.classify(line) == "majority"
    puts line
    false_english += 1
  else
    true_spanish += 1
  end
end
puts false_english
puts true_spanish