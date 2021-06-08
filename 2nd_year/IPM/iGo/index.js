var definitions_on = false;

function displayDefinitions() {
    if (definitions_on) {
        console.log("true");
        $("#top-defi").attr("style", "color: black");
        definitions_on = false;
        return; 
    }

    if (!definitions_on) {
        console.log("false");
        $("#top-defi").attr("style", "color: rgb(200, 200, 200)");
        definitions_on = true;
    }
}