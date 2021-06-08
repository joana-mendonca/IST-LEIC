$(document).ready(function () {
    localStorage.clear();
    localStorage.numDays = 3;
    localStorage.todo = "[]";
    localStorage.calendar = "[]";
    localStorage.mapMarkers = "[[569,410]]";
    localStorage.suggestions = "[{\"person\": \"joana\", \"category\": \"poi\", \"place\": \"Museum of Stuff\"},{\"person\": \"filipe\", \"category\": \"food\", \"place\": \"Com.ISTo\"},{\"person\": \"joana\", \"category\": \"food\", \"place\": \"Foodz\"},{\"person\": \"jacinto\", \"category\": \"sleep\", \"place\": \"SleepyHead Inn\"},{\"person\": \"jacinto\", \"category\": \"poi\", \"place\": \"IST Tagupark\"}, {\"person\": \"filipe\", \"category\": \"sleep\", \"place\": \"Something Funny\"}]";
    localStorage.darkMode = "0";

    $("#clock").html(("0" + today.getHours()).slice(-2) + ":" + ("0" + today.getMinutes()).slice(-2));
    
    $("#date").html(days[today.getDay()] + ", " + months[today.getMonth()] + " " + today.getDate().toString() + suffix[today.getDate() - 1] + " " + today.getFullYear().toString());
    
    $("#enter").on("mousedown", function () {
        timeS = new Date();

        $("#listening").fadeIn(250);
        $("#swiperinos").fadeOut(250);
    }).on("mouseup", function () {
        timeF = new Date();


        if (timeF - timeS < 1500) {
            $("#listening").fadeOut(250);
            $("#swiperinos").fadeIn(250);
            return;
        }
        $("#listening").fadeOut(250, function () {
            $("#done")[0].style.fontSize = 0;
            $("#done").show().animate({ "font-size": 26 }, 250);
        });
        
        setTimeout(function () {
            window.location.replace("main.html");
        }, 2000);
    });
});

var timeS, timeF, timeD;
var today = new Date();
var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
var suffix = ["st", "nd", "rd", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "st", "nd", "rd", "th", "th", "th", "th", "th", "th", "th", "st"];

var timer = setInterval(function () {
    var today = new Date();
    $("#clock").html(("0" + today.getHours()).slice(-2) + ":" + ("0" + today.getMinutes()).slice(-2));
    $("#date").html(days[today.getDay()] + ", " + months[today.getMonth()] + " " + today.getDate().toString() + suffix[today.getDate() - 1] + " " + today.getFullYear().toString());
}, 30000);