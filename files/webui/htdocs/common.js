if (!String.prototype.format) {
    String.prototype.format = function () {
        let args = arguments;
        return this.replace(/{(\d+)}/g,
            function (match, number) {
                return typeof args[number] != 'undefined'
                    ? args[number] : match;
            }
        );
    }
}

document.uuid = function () {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

document.get_cookie = function (name, def_val) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) {
        try {
            return JSON.parse(parts.pop().split(';').shift());
        }
        catch (err) {
            return JSON.parse(def_val);
        }
    } else {
        return JSON.parse(def_val);
    }
}

document.set_cookie = function (name, value) {
    if (value) {
        document.cookie = '{0}={1}'.format(name, value);
    } else {
        document.cookie = '{0}=false'.format(name);
    }
}

window.onload = function () {
    document.event_stream = tr181model.open_event_stream(document.uuid());
    populate_page();
    add_listeners();
}

function getPathParametersFromResponse(response, path) {
    var parameters = null;
    try {
        for (var i = 0; i < response["data"].length; i++) {
            if (response["data"][i]["path"] == path) {
                parameters = response["data"][i]["parameters"]
            }
        }
    } catch (error) {
        console.warn("Could not get parameters for " + path);
    }
    return parameters;
}