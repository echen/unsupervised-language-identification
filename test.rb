require_relative './detector'

# Create training set.
=begin
test_set = IO.readlines("data/gutenberg-training-en.txt") + IO.readlines("data/gutenberg-training-sp.txt")
test_set = test_set.select{ |x| !x.strip.empty? }.sort_by{ rand }
File.open("data/gutenberg-training.txt", "w") do |f|
  test_set.each{ |line| f.puts line }
end
=end

detector = Detector.new(:ngram_size => 3, :num_iterations => 30)
detector.train("data/gutenberg-training.txt")

total_count = 0
count = 0
IO.foreach("data/gutenberg-test-en.txt") do |line|
  next if line.strip.empty?
  total_count += 1
  p = detector.compute_english_prob(line)
  if p < 0.5
    puts line
    count += 1
  end
end
puts count.to_f / total_count

puts
total_count = 0
count = 0
IO.foreach("data/gutenberg-test-sp.txt") do |line|
  next if line.strip.empty?
  total_count += 1  
  p = detector.compute_english_prob(line)
  if p > 0.5
    puts line
    count += 1
  end
end
puts count.to_f / total_count