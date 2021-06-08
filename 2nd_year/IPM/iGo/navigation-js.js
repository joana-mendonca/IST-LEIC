var imapMarkers;

function loadStuff() {
    var newLine;
    var jsug = JSON.parse(localStorage.suggestions);
    var r = Math.floor(Math.random() * (jsug.length - 1));

    $(".notification .text").html(jsug[r].place + ", suggested by " + jsug[r].person.charAt(0).toUpperCase() + jsug[r].person.slice(1) + ", is " + (Math.floor(Math.random() * 100) + 5) + "m away from you.<br/><span style=\"letter-spacing: -0.5px;\">Swipe left for more options, or up to ignore...</span>")

    setTimeout(function () {
        var rx = Math.floor(Math.random() * (675 - 463) + 463);
        var ry = Math.floor(Math.random() * (481 - 417) + 417);

        $("#canvas-map").append("<div class=\"map-marker temp-marker\" style=\"display: none; top: " + (ry - 24) + "px; left: " + (rx - 9) + "px;\"><span class=\"map-marker-fa fa\">&#xf041;</span></div>");
        $("#canvas-map .temp-marker").fadeIn(750);

        $(".notification").animate({ "top": 25 }, 750);
    }, 2000);

    imapMarkers = 1;
    $(".notification").draggable({
        axis: "y",

        start: function (evt, ui) {
            $(this).data("start", ui.position.top);
        },

        revert: function (evt, ui) {
            var startL = $(this).data("start");
            var currL = $(this)[0].style.top.slice(0, -2);
            if (((startL - currL) <= 15 && (startL - currL) > 0) || (startL - currL) <= 0) {
                $(this).animate({ top: "25px" }, 500);
            }
            else {
                $(this).animate({ top: "-60px" }, 500);
                $('.temp-marker').fadeOut(750);
            }
            return (((startL - currL) <= 15 && (startL - currL) > 0) || (startL - currL) <= 0);
        }
    });

    $(".draggable-x").draggable({
        axis: "x",

        start: function (evt, ui) {
            $(this).data("start", ui.position.left);
        },

        drag: function (evt, ui) {
            $(this.parentElement).children(".noti-button").animate({ width: (ui.position.left / 3) * (-1) }, 0);
        },

        revert: function (evt, ui) {
            var startL = $(this).data("start");
            var currL = $(this)[0].style.left.slice(0, -2);

            if ((startL - currL) <= 71.66 && startL == 0) {
                $(this[0].parentElement).children(".noti-button").animate({ width: 0 }, 500);
            }
            else if ((startL - currL) <= -71.66 && (startL - currL) < 0 && startL < 0) {
                $(this).animate({ left: "0px" }, 500);
                $(this[0].parentElement).children(".noti-button").animate({ width: 0 }, 500);
            }
            else {
                $(this).animate({ left: "-227px" }, 500);
                $(this[0].parentElement).children(".noti-button").animate({ width: "71.66px" }, 500);
            }
            return (((startL - currL) <= 71.66 && startL == 0) || !(((startL - currL) < 0) && (startL - currL) <= -71.66) && startL < 0);
        }
    });

    $("#canvas-map").draggable({
        containment: [
            $("#canvas-container").offset().left - $("#canvas-map")[0].style.width.slice(0,-2) + 227,
            $("#canvas-container").offset().top - $("#canvas-map")[0].style.height.slice(0,-2) + 164,
            $("#canvas-container").offset().left,
            $("#canvas-container").offset().top
        ]
    });

    $("#canvas-map").on("mousewheel", function (evt) {
        var zoom;
        var bs = this.style.backgroundSize.split(" ");
        var mms = $(".map-marker");
        var svglines = $("line");

        //scrolling up (zoom in)
        if (evt.originalEvent.wheelDelta > 0) {
            if (bs[0].slice(0,-2) >= 3650) return;
            zoom = 1/.9;
            this.style.backgroundSize = bs[0].slice(0,-2) * zoom + "px " + bs[1].slice(0,-2) * zoom + "px";
            this.style.width = bs[0].slice(0,-2) * zoom + "px";
            this.style.height = bs[1].slice(0,-2) * zoom + "px";

            $(".iAmHere")[0].style.left = ((Number($(".iAmHere")[0].style.left.slice(0,-2)) + 5) * zoom - 5) + "px";
            $(".iAmHere")[0].style.top = ((Number($(".iAmHere")[0].style.top.slice(0,-2)) + 6) * zoom - 6) + "px";

            for (var i = 0; i < imapMarkers; i++) {
                mms[i].style.left = ((Number(mms[i].style.left.slice(0,-2)) + 9) * zoom - 9) + "px";
                mms[i].style.top = ((Number(mms[i].style.top.slice(0,-2)) + 24) * zoom - 24) + "px";
            }

            for (var i = 0; i < svglines.length; i++) {
                svglines[i].x1.baseVal.value *= zoom;
                svglines[i].x2.baseVal.value *= zoom;
                svglines[i].y1.baseVal.value *= zoom;
                svglines[i].y2.baseVal.value *= zoom;
            }
        }
        // scrolling down (zoom out)
        else {
            if (bs[0].slice(0,-2) <= 240) return;
            zoom = 0.9;
            this.style.backgroundSize = bs[0].slice(0,-2) * zoom + "px " + bs[1].slice(0,-2) * zoom + "px";
            this.style.width = bs[0].slice(0,-2) * zoom + "px";
            this.style.height = bs[1].slice(0,-2) * zoom + "px";

            $(".iAmHere")[0].style.left = ((Number($(".iAmHere")[0].style.left.slice(0,-2)) + 5) * zoom - 5) + "px";
            $(".iAmHere")[0].style.top = ((Number($(".iAmHere")[0].style.top.slice(0,-2)) + 6) * zoom - 6) + "px";

            for (var i = 0; i < imapMarkers; i++) {
                mms[i].style.left = ((Number(mms[i].style.left.slice(0,-2)) + 9) * zoom - 9) + "px";
                mms[i].style.top = ((Number(mms[i].style.top.slice(0,-2)) + 24) * zoom - 24) + "px";
            }

            for (var i = 0; i < svglines.length; i++) {
                svglines[i].x1.baseVal.value *= zoom;
                svglines[i].x2.baseVal.value *= zoom;
                svglines[i].y1.baseVal.value *= zoom;
                svglines[i].y2.baseVal.value *= zoom;
            }
        }

        $("#canvas-map").draggable("option", "containment", [
            $("#canvas-container").offset().left - $("#canvas-map")[0].style.width.slice(0,-2) + 227,
            $("#canvas-container").offset().top - $("#canvas-map")[0].style.height.slice(0,-2) + 164,
            $("#canvas-container").offset().left,
            $("#canvas-container").offset().top
        ]);
    });

    // $("#canvas-map").on("mousewheel", function (evt) {
    //     var x = this.style.backgroundPositionX;
    //     var y = this.style.backgroundPositionY;
    //     var bs = this.style.backgroundSize.split(" ");
    //     var zoom;

    //     if (evt.originalEvent.wheelDelta > 0) {
    //         // scrolling up
    //         if (this.style.backgroundSize.slice(0,-1) > 280) return;
    //         zoom = 1/.9;
    //         //this.style.backgroundPositionX = Number(x.slice(0,-2)) - evt.offsetX * (1/.9) + "px";
    //         //this.style.backgroundPositionY = Number(y.slice(0,-2)) - evt.offsetY * (1/.9) + "px";
    //         this.style.backgroundSize = bs[0].slice(0,-2) * zoom + "px " + bs[1].slice(0,-2) * zoom + "px";
    //         this.style.backgroundPositionX = ((1 / zoom) - 1) * (bs[0].slice(0,-2) * zoom) / 2 - evt.offsetX + "px";
    //         this.style.backgroundPositionY = ((1 / zoom) - 1) * (bs[1].slice(0,-2) * zoom) / 2 - evt.offsetY + "px";
    //     }
    //     else {
    //         // scrolling down
    //         if (this.style.backgroundSize.slice(0,-1) < 21) return;
    //         zoom = 0.9;
    //         //this.style.backgroundPositionX = Number(x.slice(0,-2)) + evt.offsetX * 0.9 + "px";
    //         //this.style.backgroundPositionY = Number(y.slice(0,-2)) + evt.offsetY * 0.9 + "px";
    //         this.style.backgroundSize = bs[0].slice(0,-2) * zoom + "px " + bs[1].slice(0,-2) * zoom + "px";
    //         this.style.backgroundPositionX = ((1 / zoom) - 1) * (bs[0].slice(0,-2) * zoom) / 2 + evt.offsetX + "px";
    //         this.style.backgroundPositionY = ((1 / zoom) - 1) * (bs[1].slice(0,-2) * zoom) / 2 + evt.offsetY + "px";
    //     }

    $("#canvas-map").on("click", function (evt) {
        var oe;

        if (evt.originalEvent == null) {
            oe = evt;
        }
        else {
            oe = evt.originalEvent;
        }

        var x = oe.offsetX * (1000 / $("#canvas-map")[0].style.width.slice(0,-2));
        var y = oe.offsetY * (1000 / $("#canvas-map")[0].style.width.slice(0,-2));

        if (evt.target.id != "canvas-map" && evt.target.id != "svg-map") return;

        var j = JSON.parse(localStorage.mapMarkers);
        j.push([x, y]);
        localStorage.mapMarkers = JSON.stringify(j);

        $("#canvas-map").append("<div class=\"map-marker\" style=\"top: " + (oe.offsetY - 24) + "px; left: " + (oe.offsetX - 9) + "px;\"><span class=\"map-marker-fa fa\">&#xf041;</span><span class=\"map-marker-number\">" + imapMarkers + "</span></div>");
        
        if (imapMarkers >= 1) {
            newLine = document.createElementNS("http://www.w3.org/2000/svg","line");

            newLine.setAttribute("id","line2");
            newLine.setAttribute("x1", oe.offsetX);
            newLine.setAttribute("y1", oe.offsetY);
            newLine.setAttribute("x2", j[imapMarkers-1][0] / (1000 / $("#canvas-map")[0].style.width.slice(0,-2)));
            newLine.setAttribute("y2", j[imapMarkers-1][1] / (1000 / $("#canvas-map")[0].style.width.slice(0,-2)));

            $("#svg-map").append(newLine);
        }

        imapMarkers++;
    });

    $(".map-marker").on("click", function (evt) {
        var m_info = $("#marker-info");


        if (m_info[0].style.top == "141px");
    });

    var j = JSON.parse(localStorage.mapMarkers);

    $("#canvas-map").append("<div class=\"iAmHere\" style=\"top: " + (j[0][1] - 6) + "px; left: " + (j[0][0] - 5) + "px;\"><div></div></div>");
    
    for (var i = 1; i < j.length; i++) {
        $("#canvas-map").append("<div class=\"map-marker\" style=\"top: " + (j[i][1] - 24) + "px; left: " + (j[i][0] - 9) + "px;\"><span class=\"map-marker-fa fa\">&#xf041;</span><span class=\"map-marker-number\">" + imapMarkers + "</span></div>");
        imapMarkers++;
    }

    for (var i = 1; i < j.length; i++) {
        newLine = document.createElementNS("http://www.w3.org/2000/svg","line");

        newLine.setAttribute("id","line2");
        newLine.setAttribute("x1", j[i][0]);
        newLine.setAttribute("y1", j[i][1]);
        newLine.setAttribute("x2", j[i-1][0]);
        newLine.setAttribute("y2", j[i-1][1]);

        $("#svg-map").append(newLine);
    }
}

function now() {
    $(".temp-marker").fadeOut(750, function () {
        var e = new jQuery.Event("click");
        e.offsetX = Number($(".temp-marker")[0].style.left.slice(0,-2)) + 9;
        e.offsetY = Number($(".temp-marker")[0].style.top.slice(0,-2)) + 24;
        $("#canvas-map").trigger(e);
        ignore();
    });
}

function later() {

}

function ignore() {
    $('.notification').animate({ top: '-60px' }, 500);
    $('.temp-marker').fadeOut(750);
}