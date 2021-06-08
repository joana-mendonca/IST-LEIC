var help_on = false;
var today = new Date();

$(document).ready(function () {
    $("#clock").html(("0" + today.getHours()).slice(-2) + ":" + ("0" + today.getMinutes()).slice(-2));

    var timer = setInterval(function () {
        var today = new Date();
        $("#clock").html(("0" + today.getHours()).slice(-2) + ":" + ("0" + today.getMinutes()).slice(-2));
    }, 30000);
});


function loadColorScheme() {
    if (localStorage.darkMode == "1") {
        $('link[href="dark-mode.css"]').prop('disabled', false);
        $("#top-defi").attr("style", "color: white");
    }
    else {
        $('link[href="dark-mode.css"]').prop('disabled', true);
        $("#top-defi").attr("style", "color: #6893ee");
    }
}

function displayDefinitions() {
    // definitions are on screen; pulls them up
    if (localStorage.darkMode == "1") {
        $("style").html("* { transition: color 1s,  background-color 1s, border-color 1s, box-shadow 1s; }");
        $('link[href="dark-mode.css"]').prop('disabled', true);

        $("#top-defi").attr("style", "color: white");
        setTimeout(function () {
            $("style").html("");
        }, 1000);

        localStorage.darkMode = "0";
        return; 
    }

    // definitions are off: pulls them down
    if (localStorage.darkMode == "0") {
        $("style").html("* { transition: color 1s,  background-color 1s, border-color 1s, box-shadow 1s; }");
        $('link[href="dark-mode.css"]').prop('disabled', false);
        
        $("#top-defi").attr("style", "color: #6893ee");
        setTimeout(function () {
            $("style").html("");
        }, 1000);

        localStorage.darkMode = "1";
    }
}

function displayHelp() {
    // definitions are on screen; pulls them up
    if (help_on) {
        $("#top-help").attr("style", "");
        $("#help").animate({ bottom: "227px" }, 750);

        help_on = false;
        return; 
    }

    // definitions are off: pulls them down
    if (!help_on) {
        $("#top-help").attr("style", "color: " + (localStorage.darkMode == "0" ? "rgb(200, 200, 200)" : "white"));

        $("#help").animate({ bottom: "0px" }, 750);
        help_on = true;
    }
}