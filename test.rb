require_relative './detector'

detector = Detector.new(:ngram_size => 2, :num_iterations => 30)
detector.train("datasets/gutenberg-training.txt")

true_english = 0
false_spanish = 0
IO.foreach("datasets/gutenberg-test-en.txt") do |line|
  next if line.strip.empty?
  p = detector.compute_english_prob(line)
  if p < 0.5
    puts line
    false_spanish += 1
  else
    true_english += 1
  end
end
puts false_spanish
puts true_english

puts
true_spanish = 0
false_english = 0
IO.foreach("datasets/gutenberg-test-sp.txt") do |line|
  next if line.strip.empty?
  p = detector.compute_english_prob(line)
  if p > 0.5
    puts line
    false_english += 1
  else
    true_spanish += 1
  end
end
puts false_english
puts true_spanish