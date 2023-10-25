/*
Date:           October 20, 2023
Author:         Casey Sparks
Description:    Sends a POST request to backend API to send an email to the default recipient.
*/

function submitEvent(e) {
    e.preventDefault();

    var data = {                                                                // Format data.
        sender_name: $("#sender_name").val(),
        sender_email: $("#sender_email").val(),
        subject: $("#subject").val(),
        message: $("#message").val(),
    };

    $.ajax({                                                                    // Send POST request.
        type: "POST",
        url: "https://2thztj5px2.execute-api.us-west-2.amazonaws.com/contact",                                                // AWS API Gateway invocation URL.
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
