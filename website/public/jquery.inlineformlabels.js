(function($) {

	$.fn.inlineFormLabels = function() {
		
		var self = this;
		
		// Hide all the labels, because we're going to put them in the input field instead.
		$("label", self).hide();
		
		// Grab all input fields (inputs and textareas) preceded by a label sibling... 
		$("label + input, label + textarea", self).each(function(type) {
			
			// If the field is empty, display the label and add a class that indicates its holding the label.
			if ($(this).val() == "") {
				var labelText = $(this).prev("label, textarea").text().trim();
				$(this).val(labelText).addClass("has-inline-label");
			}
			
			// If we click in the field, remove the label.
			$(this).focus(function() {
				if ($(this).hasClass("has-inline-label")) {
					$(this).removeClass("has-inline-label");
					$(this).val("");
				}
			});
			
			// Not doing anything here yet...
			$(this).keypress(function() {
			});
			
			// If we click out of the field and we haven't entered anything, redisplay the label and add back the label-indicator class.
			$(this).blur(function() {
				if ($(this).val() == "") {
					var labelText = $(this).prev("label").text().trim();
					$(this).val(labelText).addClass("has-inline-label");
				}
			});
			
		});

		// When submitting, remove the values from fields holding a label, so that we don't mistakenly think those are real inputs.
		$(self).submit(function() {
			$("input, textarea", self).each(function() {
				if ($(this).hasClass("has-inline-label")) {
					$(this).val("");
				}
			});
		});
		
		return self;
	};
	
})(jQuery);