var lastSugEventClicked;
var lastSugEventClickedId;

function loadStuff() {
    var j = JSON.parse(localStorage.suggestions);
    var all = $("#div-all");
    var s = "";
    var dp = $(".day-pick");
    var hp = $(".hour-pick");
    var mp = $(".minute-pick");

    for (var i = 0; i < j.length; i++) {
        s = "<div class=\"sug-event\">\
        <div class=\"sug-event-sub-section draggable\" style=\"position: relative;\">\
        <img src=\"" + j[i].person + ".jpg\">\
        <span>" + j[i].person.charAt(0).toUpperCase() + j[i].person.slice(1) +" suggested \"" + j[i].place + "\"</span>\
        <div class=\"category-color " + j[i].category + "\"></div></div>\
        <div style=\"width: 0px;\" class=\"event-sub-div\">\
        <div class=\"event-button event-sug-add\" onclick=\"addEvent(event)\"><span class=\"fa\">&#xf067;</span></div>\
        <button style=\"top: -50px;\" class=\"event-sub-button todo\" onclick=\"addEventTodo(event)\">To-Do</button>\
        <button style=\"top: -50px;\" class=\"event-sub-button calendar\" onclick=\"addEventCalendar(event)\">Calendar</button></div>\
        <button style=\"width: 0px\" class=\"fa event-button event-delete\" onclick=\"removeEvent(event)\">&#xf2ed;</button>\
        </div>";

        all.append(s);
        $("#div-" + j[i].category).append(s);
    }

    doTheDraggableThing();

    for (var i = 1; i <= localStorage.numDays; i++) {
        dp.append("<option value=\"day-" + i + "\">Day " + i + "</option>");
    }

    for (var i = 0; i < 24; i++) {
        hp.append("<option value=\"" + ("0" + i.toString()).slice(-2) + "\">" + ("0" + i.toString()).slice(-2) + "</option>");
    }

    for (var i = 0; i < 12; i++) {
        mp.append("<option value=\"" + ("0" + (i * 5).toString()).slice(-2) + "\">" + ("0" + (i * 5).toString()).slice(-2) + "</option>");
    }

    $(".event-description").on("focus", function (evt) {
        $(evt.target.parentElement.children[2]).fadeIn(250);
    }).on("focusout", function (evt) {
        $(evt.target.parentElement.children[2]).fadeOut(250);
    });
}

function leftTabClick(evt) {
    var tab = evt.srcElement.id;
    var tabs = $(".left-tabs li");
    var divs = $(".tabs-main-section");

    // deselects all tab buttons and hides all tab content divs
    for (var i = 0; i < tabs.length; i++) {
        tabs[i].classList.remove("active");
        divs[i].style.display = "none";
    }

    evt.srcElement.classList.add("active");
    $("#div-" + tab.slice(4))[0].style.display = "block";
}

function doTheDraggableThing() {
    $(".draggable").draggable({
        axis: "x",

        start: function (evt, ui) {
            $(this).data("start", ui.position.left);
        },

        drag: function (evt, ui) {
            $(this.parentElement).children(".event-delete").animate({ width: (ui.position.left * (3/8)) * (-1) }, 0);
            $(this.parentElement).children(".event-sub-div").animate({ width: (ui.position.left * (5/8)) * (-1) }, 0);
            $(this.parentElement).children(".event-sub-div").children(".event-sug-add").animate({ width: (ui.position.left * (5/8)) * (-1) }, 0);
            $(this.parentElement).children(".event-sub-div").children(".event-sub-button").animate({ width: (ui.position.left * (5/8)) * (-1) }, 0);
        },

        revert: function (evt, ui) {
            var startL = $(this).data("start");
            var currL = $(this)[0].style.left.slice(0, -2);

            if ((startL - currL) <= 30 && startL == 0) {
                $(this[0].parentElement).children(".event-delete").animate({ width: 0 }, 500);
                $(this[0].parentElement).children(".event-sub-div").animate({ width: 0 }, 500);
                $(this[0].parentElement).children(".event-sub-div").children(".event-sug-add").animate({ width: 0 }, 500);
                $(this[0].parentElement).children(".event-sub-div").children(".event-sub-button").animate({ width: 0 }, 500);
            }
            else if ((startL - currL) <= -30 && (startL - currL) < 0 && startL < 0) {
                $(this).animate({ left: "0px" }, 500);
                $(this[0].parentElement).children(".event-delete").animate({ width: 0 }, 500);
                $(this[0].parentElement).children(".event-sub-div").animate({ width: 0 }, 500);
                $(this[0].parentElement).children(".event-sub-div").children(".event-sug-add").animate({ width: 0 }, 500, function () {
                    this.style.height = "50px";
                    $(this.parentElement).children(".event-sub-button").animate({ top: -50 }, 500);
                });
                $(this[0].parentElement).children(".event-sub-div").children(".event-sub-button").animate({ width: 0 }, 500);
            }
            else {
                $(this).animate({ left: "-80px" }, 500);
                $(this[0].parentElement).children(".event-delete").animate({ width: 30 }, 500);
                $(this[0].parentElement).children(".event-sub-div").animate({ width: 50 }, 500);
                $(this[0].parentElement).children(".event-sub-div").children(".event-sug-add").animate({ width: 50 }, 500);
                $(this[0].parentElement).children(".event-sub-div").children(".event-sub-button").animate({ width: 50 }, 500);
            }
            return (((startL - currL) <= 30 && startL == 0) || !(((startL - currL) < 0) && (startL - currL) <= -30) && startL < 0);
        }
    });
}

function removeEvent(evt) {
    var listevent = evt.srcElement.parentElement;
    var listindex = $(".tabs-main-section#" + listevent.parentElement.id + " .sug-event").index(listevent);
    var j = JSON.parse(localStorage.suggestions);

    // removes from the screen and from localStorage
    $(listevent).animate({ height: 0 }, 500, function () {
        j.splice(listindex, 1);
        
        localStorage.suggestions = JSON.stringify(j);
        $(listevent).remove();
    });
}

function addEvent(evt) {
    var listevent = evt.srcElement.parentElement.parentElement;

    if (evt.srcElement.localName == "span")
        listevent = listevent.parentElement;

    var listindex = $(".tabs-main-section#" + listevent.parentElement.id + " .sug-event").index(listevent);
    var j = JSON.parse(localStorage.suggestions);

    $(listevent.children[1].children[0]).animate({ height: 0 }, 500);
    $(listevent.children[1]).children(".event-sub-button").animate({ top: 0 }, 500);
}

function addEventTodo(evt) {
    var listevent = evt.srcElement.parentElement.parentElement;

    var listindex = $(".tabs-main-section#" + listevent.parentElement.id + " .sug-event").index(listevent);

    var js = JSON.parse(localStorage.suggestions);
    var jt = JSON.parse(localStorage.todo);

    jt.push({"time": 0, "description": js[listindex].place, "category": js[listindex].category});
    localStorage.todo = JSON.stringify(jt);

    // removes from the screen and from localStorage
    $(listevent).animate({ height: 0 }, 500, function () {
        js.splice(listindex, 1);
        
        localStorage.suggestions = JSON.stringify(js);
        $(listevent).remove();
    });
}

function addEventCalendar(evt) {
    var listevent = evt.srcElement.parentElement.parentElement;

    var listindex = $(".tabs-main-section#" + listevent.parentElement.id + " .sug-event").index(listevent);

    var js = JSON.parse(localStorage.suggestions);
    var jc = JSON.parse(localStorage.calendar);

    $("#add-event .event-description")[0].value = js[listindex].place;
    $("#add-event .category")[0].id = js[listindex].category;
    $("#add-event").animate({ bottom: 0 }, 750);

    lastSugEventClicked = listevent;
    lastSugEventClickedId = listindex;
}

function addCancel(evt) {
    $("#add-event").animate({ bottom: 227 }, 750);

    $("#add-event .event-description")[0].value = "";
    $("#add-event .day-pick")[0].value = "";
    $("#add-event .hour-pick")[0].value = "";
    $("#add-event .minute-pick")[0].value = "";
    $("#add-event .add-warning").html("");
    $("#add-event .category")[0].id = "";
}

function addCalendarConfirm(evt) {
    var i, j1, j2;
    var tab = evt.srcElement.parentElement.id;
    var js = JSON.parse(localStorage.suggestions);

    var day = $("#" + tab + " .day-pick")[0].value;
    var hour = $("#" + tab + " .hour-pick")[0].value;
    var min = $("#" + tab + " .minute-pick")[0].value;
    var name = $("#" + tab + " .event-description")[0].value;
    var cat = $("#" + tab + " .category")[0].id;

    // check if all fields are ok
    if (name == "") {
        $("#" + tab + " .add-warning").eq(0).html("Please add a description.");
        return;
    }
    if (day == "" || hour == "" || min == "") {
        $("#" + tab + " .add-warning").eq(1).html("Please add correct date.");
        return;
    }

    var d = Number(day.slice(4)) - 1;

    var j = JSON.parse(localStorage.calendar);
    j.push({"day": day.slice(4), "time": hour + ":" + min, "description": name, "category": cat});

    j.sort(function (a, b) {
        if (a.day != b.day) return a.day - b.day;
        return Date.parse("01/01/01 " + a.time) - Date.parse("01/01/01 " + b.time);
    });
    
    localStorage.calendar = JSON.stringify(j);

    $(lastSugEventClicked).animate({ height: 0 }, 500, function () {
        js.splice(lastSugEventClickedId, 1);
        
        localStorage.suggestions = JSON.stringify(js);
        $(lastSugEventClicked).remove();

        $("#" + tab).animate({ bottom: "227px" }, 750);
        $("#" + tab + " .event-description")[0].value = "";
        $(".day-pick")[0].value = "";
        $(".hour-pick")[0].value = "";
        $(".minute-pick")[0].value = "";
        $("#" + tab + " .add-warning").html("");
    });
}