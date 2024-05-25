/*
Name:           contactForm.js
Date:           December 20, 2023
Author:         Casey Sparks
Description:    Sends a POST request to "https://rf7ofwmksublonho3jiuo5wlyu0osasb.lambda-url.us-west-2.on.aws/" an (AWS API
                gateway endpoint).
*/

/*global $, alert, document, location*/

function submitEvent(e) {
    "use strict";
    e.preventDefault();

    var data = {                                                                // Format data.
        sender_name: $("#sender_name").val(),
        sender_email: $("#sender_email").val(),
        subject: $("#subject").val(),
        message: $("#message").val(),
        };

    $.ajax({                                                                    // Send POST request to API gateway endpoint.
        url: "https://rf7ofwmksublonho3jiuo5wlyu0osasb.lambda-url.us-west-2.on.aws/",
        type: "POST",
        dataType: "json",
        crossDomain: "true",
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify(data),
        success: function () {
            alert("Success");
            document.getElementById("contact-form").reset();
            location.reload();
            },
        error: function () {
            alert("Error");
            }
        });
    }
