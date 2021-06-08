// loads calendar tabs and all events stored in localStorage
function loadStuff() {
    var ls_todo = JSON.parse(localStorage.todo);
    var ls_calendar = JSON.parse(localStorage.calendar);
    var ct = $("#calendar-tabs");
    var dc = $("#div-calendar");
    var dp = $(".day-pick");
    var hp = $(".hour-pick");
    var mp = $(".minute-pick");
    var dtss = $("#div-todo-sub-section");

    for (var i = 1; i <= localStorage.numDays; i++) {
        ct.append("<li data-id=\"" + i + "\" onclick=\"topTabClick(event)\">Day " + i + "</li>");
        dc.append("<div style=\"display: none;\" class=\"tabs-sub-section\"><div class=\"calendar-help\">You can add things to any day by clicking the plus sign below.</div></div>");

        if (JSON.parse(localStorage.calendar).find(o => o.day === i.toString()) == null) {
            $(".calendar-help")[i - 1].style.zIndex = 0;
        }
        else {
            $(".calendar-help")[i - 1].style.color = "transparent";
        }

        dp.append("<option value=\"day-" + i + "\">Day " + i + "</option>");
    }
    ct.append("<li data-id=\"plus\" onclick=\"addDay()\" id=\"add-day\">+</li>");

    for (var i = 0; i < ls_calendar.length; i++) {
        $(".tabs-sub-section").eq(ls_calendar[i].day - 1).append("<div data-day=\"" + ls_calendar[i].day + "\" class=\"calendar-event\"><div class=\"calendar-event-sub-section draggable\"><span>" + ls_calendar[i].time + "</span><span>" + ls_calendar[i].description + "</span><div class=\"category-color " + ls_calendar[i].category + "\"></div></div><button style=\"width: 0px\" class=\"fa event-button event-delete\" onclick=\"removeEvent(event)\">&#xf2ed;</button></div>");
    }

    $("#calendar-tabs li")[0].classList.add("active");
    $(".tabs-sub-section")[0].style.display = "block";

    for (var i = 0; i < ls_todo.length; i++) {
        dtss.append("<div class=\"todo-event\"><div class=\"todo-event-sub-section draggable\" " + (ls_todo[i].time ? "style=\"color: rgb(230, 230, 230);\"" : "") + "><input " + (ls_todo[i].time ? "checked" : "") + " onclick=\"checkboxClick(event)\" type=\"checkbox\" name=\"\" class=\"fa todo-checkbox\"><span>" + ls_todo[i].description + "</span><div class=\"category-color " + ls_todo[i].category + "\"></div></div><button style=\"width: 0px\" class=\"fa event-button event-delete\" onclick=\"removeEvent(event)\">&#xf2ed;</button></div>");
    }
    doTheDraggableThing();

    for (var i = 0; i < 24; i++) {
        hp.append("<option value=\"" + ("0" + i.toString()).slice(-2) + "\">" + ("0" + i.toString()).slice(-2) + "</option>");
    }

    for (var i = 0; i < 12; i++) {
        mp.append("<option value=\"" + ("0" + (i * 5).toString()).slice(-2) + "\">" + ("0" + (i * 5).toString()).slice(-2) + "</option>");
    }

    if (localStorage.todo == "[]") {
        $("#todo-help")[0].style.zIndex = 0;
    }
    else {
        $("#todo-help")[0].style.color = "transparent";
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

function topTabClick(evt) {
    var tab = Number(evt.srcElement.dataset.id) - 1;
    var tabs = $("#calendar-tabs li");
    var divs = $("#div-calendar .tabs-sub-section");

    // deselects all tab buttons and hides all tab content divs
    for (var i = 0; i < divs.length; i++) {
        tabs[i].classList.remove("active");
        divs[i].style.display = "none";
    }

    evt.srcElement.classList.add("active");
    divs[tab].style.display = "block";

    //load day's events
}

function addShow(evt) {
    var tab = evt.srcElement.id;

    $("#div-add-" + tab.slice(4)).animate({ bottom: "0" }, 750);
}

function addCancel(evt) {
    var tab = evt.srcElement.parentElement.id;

    $("#" + tab).animate({ bottom: "227px" }, 750);
    $("#" + tab + " .event-description")[0].value = "";
    $("#" + tab + " .category-pick")[0].value = "";
    $(".day-pick")[0].value = "";
    $(".hour-pick")[0].value = "";
    $(".minute-pick")[0].value = "";
    $("#" + tab + " .add-warning").html("");
}

function addTodoConfirm(evt) {
    var tab = evt.srcElement.parentElement.id;
    var i, j1, j2;

    var name = $("#" + tab + " .event-description")[0].value;
    var cat = $("#" + tab + " .category-pick")[0].value;

    if (name == "") {
        $("#" + tab + " .add-warning").html("Please add a description.");
        return;
    }

    if (localStorage.todo == "[]") {
        $("#todo-help")[0].style.zIndex = "-1";
        $("#todo-help")[0].style.color = "transparent";
    }

    var j = JSON.parse(localStorage.todo);

    j.push({"time": 0, "description": name, "category": cat});
    localStorage.todo = JSON.stringify(j);

    $("#div-todo-sub-section").append("<div class=\"todo-event\"><div class=\"todo-event-sub-section draggable\"><input onclick=\"checkboxClick(event)\" type=\"checkbox\" name=\"\" class=\"fa todo-checkbox\"><span>" + name + "</span><div class=\"category-color " + cat + "\"></div></div><button style=\"width: 0px\" class=\"fa event-button event-delete\" onclick=\"removeEvent(event)\">&#xf2ed;</button></div>");
    doTheDraggableThing();

    $("#" + tab).animate({ bottom: "227px" }, 750);
    $("#" + tab + " .event-description")[0].value = "";
    $("#" + tab + " .category-pick")[0].value = "";
    $("#" + tab + " .add-warning").html("");
}

function addCalendarConfirm(evt) {
    var i, j1, j2;
    var tab = evt.srcElement.parentElement.id;

    var day = $("#" + tab + " .day-pick")[0].value;
    var hour = $("#" + tab + " .hour-pick")[0].value;
    var min = $("#" + tab + " .minute-pick")[0].value;
    var name = $("#" + tab + " .event-description")[0].value;
    var cat = $("#" + tab + " .category-pick")[0].value;

    if (name == "") {
        $("#" + tab + " .add-warning").eq(0).html("Please add a description.");
        return;
    }
    if (day == "" || hour == "" || min == "") {
        $("#" + tab + " .add-warning").eq(1).html("Please add correct date.");
        return;
    }

    var d = Number(day.slice(4)) - 1;
    if (JSON.parse(localStorage.calendar).find(o => o.day === (d + 1).toString()) == null) {
        $(".calendar-help")[d].style.zIndex = "-1";
        $(".calendar-help")[d].style.color = "transparent";
    }

    var j = JSON.parse(localStorage.calendar);
    j.push({"day": day.slice(4), "time": hour + ":" + min, "description": name, "category": cat});

    j.sort(function (a, b) {
        if (a.day != b.day) return a.day - b.day;
        return Date.parse("01/01/01 " + a.time) - Date.parse("01/01/01 " + b.time);
    });
    
    localStorage.calendar = JSON.stringify(j);

    $(".tabs-sub-section")[d].innerHTML += "<div data-day=\"" + day.slice(4) + "\" class=\"calendar-event\"><div class=\"calendar-event-sub-section draggable\"><span>" + hour + ":" + min + "</span><span>" + name + "</span><div class=\"category-color " + cat + "\"></div></div><button style=\"width: 0px\" class=\"fa event-button event-delete\" onclick=\"removeEvent(event)\">&#xf2ed;</button></div>";
    doTheDraggableThing();

    $("#" + tab).animate({ bottom: "227px" }, 750);
    $("#" + tab + " .event-description")[0].value = "";
    $("#" + tab + " .category-pick")[0].value = "";
    $(".day-pick")[0].value = "";
    $(".hour-pick")[0].value = "";
    $(".minute-pick")[0].value = "";
    $("#" + tab + " .add-warning").html("");
}

function checkboxClick(evt) {
    var tde = evt.srcElement.parentElement;

    j = JSON.parse(localStorage.todo);

    if (evt.srcElement.checked) {
        tde.style.color = "rgb(230,230,230)";
        j.find(o => o.description === $(tde).children()[1].innerHTML).time = 1;
    }
    else {
        tde.style.color = "black";
        j.find(o => o.description === $(tde).children()[1].innerHTML).time = 0;
    }

    localStorage.todo = JSON.stringify(j);
}

function addDay() {
    $("<li data-id=\"" + Number(Number(localStorage.numDays) + 1) + "\" onclick=\"topTabClick(event)\">Day " + Number(Number(localStorage.numDays) + 1) + "</li>").insertBefore($("#add-day"));
    $("<div style=\"display: none;\" class=\"tabs-sub-section\"><div class=\"calendar-help\" style=\"z-index: 0\">You can add things to any day by clicking the plus sign below.</div></div>").insertAfter($(".tabs-sub-section").eq(Number(localStorage.numDays) - 1));
    localStorage.numDays++;

    $(".day-pick").append("<option value=\"day-" + localStorage.numDays + "\">Day " + localStorage.numDays + "</option>");
}

function doTheDraggableThing() {
    // $("#calendar-tabs").draggable({
    //     axis: "x",
    //     containment: [
    //         0, 0, 1000, 25
    //     ]
    // });

    $(".draggable").draggable({
        axis: "x",

        start: function (evt, ui) {
            $(this).data("start", ui.position.left);
        },

        drag: function (evt, ui) {
            $(this.parentElement).children(".event-button").animate({ width: (ui.position.left) * (-1) }, 0);
        },

        revert: function (evt, ui) {
            var startL = $(this).data("start");
            var currL = $(this)[0].style.left.slice(0, -2);

            if ((startL - currL) <= 15 && startL == 0) {
                $(this[0].parentElement).children(".event-button").animate({ width: 0 }, 500);
            }
            else if ((startL - currL) <= -15 && (startL - currL) < 0 && startL < 0) {
                $(this).animate({ left: "0px" }, 500);
                $(this[0].parentElement).children(".event-button").animate({ width: 0 }, 500);
            }
            else {
                $(this).animate({ left: "-30px" }, 500);
                $(this[0].parentElement).children(".event-button").animate({ width: 30 }, 500);
            }
            return (((startL - currL) <= 15 && startL == 0) || !(((startL - currL) < 0) && (startL - currL) <= -15) && startL < 0);
        }
    });
}

function editEvent(evt) {
    
}

function removeEvent(evt) {
    var listevent = evt.srcElement.parentElement;
    var listindex = $("." + listevent.className).index(listevent);
    var j;

    if (listevent.className == "todo-event") j = JSON.parse(localStorage.todo);
    else if (listevent.className == "calendar-event") j = JSON.parse(localStorage.calendar);

    // removes from the screen and from localStorage
    $(listevent).animate({ height: 0 }, 500, function () {
        // for the todo events
        if (listevent.className == "todo-event") {
            if (j.length == 1) {
                $("#todo-help")[0].style.zIndex = "0";
                $("#todo-help").animate({color: "black"}, 1000);
            }
            j.splice(listindex, 1);
        }
        
        // for the calendar events
        else if (listevent.className == "calendar-event") {
            if (j.filter(o => o.day === $(listevent)[0].dataset.day).length == 1) {
                $(".calendar-help")[$(listevent)[0].dataset.day - 1].style.zIndex = "0";
                $(".calendar-help").eq($(listevent)[0].dataset.day - 1).animate({color: "black"}, 1000);
            }

            a = j.findIndex(function (elm) {
                if (elm.day != $(listevent)[0].dataset.day) return false;
                if (elm.description != $(listevent).children().children("span")[1].innerHTML) return false;
                if (elm.category != $(listevent).children().children("div")[0].className.slice(15)) return false;
                if (elm.time != $(listevent).children().children("span")[0].innerHTML) return false;
                return true;
            });

            j.splice(a, 1);
        }
        
        if (listevent.className == "todo-event") localStorage.todo = JSON.stringify(j);
        else if (listevent.className == "calendar-event") localStorage.calendar = JSON.stringify(j);
        $(listevent).remove();
    });
}