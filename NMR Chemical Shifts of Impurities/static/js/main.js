$(document).ready(function() {
    // Event handler for real-time solvent suggestions
    $('#solvent-input').on('input', function() {
        var userInput = $(this).val();
        var suggestionsBox = $('#suggestions');
        
        if (userInput.length >= 2) { // Trigger request for 2 or more characters
            $.ajax({
                url: '/suggest_solvent',
                data: { 'input': userInput },
                dataType: 'json', // Expecting a JSON response
                success: function(data) {
                    suggestionsBox.empty(); // Clear previous suggestions
                    if (data.length > 0) {
                        var suggestionsList = $('<ul>').appendTo(suggestionsBox);
                        $.each(data, function(i, solvent) {
                            suggestionsList.append($('<li>').text(solvent));
                        });
                    }
                },
                error: function(xhr, status, error) {
                    suggestionsBox.empty();
                    console.error("Error fetching suggestions: ", status, error);
                }
            });
        } else {
            suggestionsBox.empty(); // Clear suggestions if input is less than 2 characters
        }
    });

    // Intercept the form submission
    $('#data-form').on('submit', function(e) {
        e.preventDefault(); // Prevent the default form submission

        // Determine which input (shift or solvent) is used for the search
        var shiftInput = $('#shift-input').val();
        var solventInput = $('#solvent-input').val();
        var isShiftSearch = shiftInput.length > 0 && solventInput.length === 0;
        var isSolventSearch = solventInput.length > 0 && shiftInput.length === 0;

        // Ensure that either shift or solvent is entered, not both
        if (isShiftSearch || isSolventSearch) {
            // Create the form data based on the type of search
            var formData = {
                'nmr_type': $('#nmr-type-select').val(),
                'nmr_solvent': $('#nmr-solvent-select').val(),
            };

            // Add the appropriate search parameter
            if (isShiftSearch) {
                formData['shift'] = shiftInput;
            } else if (isSolventSearch) {
                formData['solvent'] = solventInput;
            }

            // Proceed with the AJAX request
            $.ajax({
                type: 'POST',
                url: '/filter_data',
                contentType: 'application/json',
                data: JSON.stringify(formData),
                success: function(response) {
                    var resultsContainer = $('#results-container');
                    resultsContainer.empty(); // Clear any existing results
                    resultsContainer.css('background-color', '#fff'); // Set the background to white

                    // Extract the selected values
                    var nmrType = $('#nmr-type-select').val();
                    var nmrSolvent = $('#nmr-solvent-select').val();
                    var solvent = $('#solvent-input').val();
                    // Construct the message with only the variable parts in red
                    var message = $('<p>').css({'position': 'relative', 'padding-left': '20px'}); // Add padding to leave space for the red bar

                    // Create the red bar element and position it absolutely within the message
                    var redBar = $('<div>').addClass('red-bar').css({
                        'position': 'absolute',
                        'left': '0',
                        'top': '50%',
                        'transform': 'translateY(-50%)' // Center it vertically
                    });

                    // Add the red bar to the message
                    message.append(redBar);

                    // Add the text to the message
                    message.append(
                        "<span class='red-text'>" + nmrType + "</span> data by chemical shifts(ppm) in " + 
                        "<span class='red-text'>" + nmrSolvent + "</span>, where <span class='red-text'>" + 
                        solvent + "</span> selection."
                    );

                    // Append the message to the results container
                    resultsContainer.append(message);
                
                    if (response && response.length > 0) {
                        var resultsTable = $('<table>').addClass('nmr-results').appendTo(resultsContainer);
                
                        // Define the headers for the columns you want to display
                        var columnHeaders = {
                            'shift': 'Chemical Shift',
                            'solvent': 'Solvent Name',
                            'proton': 'Proton Environment',
                            'mult': 'Multiplicity'
                        };
                
                        // Create table headers
                        var thead = $('<thead>').appendTo(resultsTable);
                        var headerRow = $('<tr>').appendTo(thead);
                        $.each(columnHeaders, function(key, header) {
                            headerRow.append($('<th>').text(header));
                        });
                
                        // Create table body with the results
                        var tbody = $('<tbody>').appendTo(resultsTable);
                        $.each(response, function(i, item) {
                            var row = $('<tr>').appendTo(tbody);
                            $.each(columnHeaders, function(key, header) {
                                var value = item[key] || 'N/A'; // Provide 'N/A' if the item is undefined
                                row.append($('<td>').text(value));
                            });
                        });
                    } else {
                        resultsContainer.append($('<p>').text('No results found'));
                    }
            },
            error: function(request, status, error) {
                // Handle error
                console.error("Error fetching filter data: ", status, error);
            }
        });
    } else {
        // Handle the case where both or none inputs are provided
        alert("Please enter either a shift value or a solvent name, not both.");
        // Optionally, clear the form or highlight the fields that need correction
    }
});
});