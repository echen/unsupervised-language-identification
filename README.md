# What?
Given a set of strings from different languages, build a detector for the majority language (often, but not necessarily, English). More information on the algorithm [here](http://blog.echen.me/2011/05/01/unsupervised-language-detection-algorithms/).

# Example

	training_sentences = File.readlines("datasets/gutenberg-training.txt")
	detector = LanguageDetector.new(:ngram_size => 3)
	detector.train(30, training_sentences)

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
	
![Example](https://img.skitch.com/20110303-qfrnb8gstgheh4xech4iutfskd.jpg)

# Demo
See a demo [here](http://babel-fett.heroku.com).