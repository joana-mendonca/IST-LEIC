var today = new Date();
$("#clock").html(("0" + today.getHours()).slice(-2) + ":" + ("0" + today.getMinutes()).slice(-2));

var timer = setInterval(function () {
    var today = new Date();
    $("#clock").html(("0" + today.getHours()).slice(-2) + ":" + ("0" + today.getMinutes()).slice(-2));
}, 30000);