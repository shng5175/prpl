 (function (tr181model, $, undefined) {

    let friendlyHttpStatus = {
        '200': 'OK',
        '201': 'Created',
        '202': 'Synchronous Action Invoked. (Accepted)',
        '203': 'Non-Authoritative Information',
        '204': 'Service element {0} (No content)',
        '205': 'Reset Content',
        '206': 'Partial Content',
        '300': 'Multiple Choices',
        '301': 'Moved Permanently',
        '302': 'Found',
        '303': 'See Other',
        '304': 'Not Modified',
        '305': 'Use Proxy',
        '306': 'Unused',
        '307': 'Temporary Redirect',
        '400': 'Service Element {0} failed (Bad Request)',
        '401': 'Unauthorized',
        '402': 'Payment Required',
        '403': 'Forbidden',
        '404': 'Not Found',
        '405': 'Method Not Allowed',
        '406': 'Not Acceptable',
        '407': 'Proxy Authentication Required',
        '408': 'Request Timeout',
        '409': 'Conflict',
        '410': 'Gone',
        '411': 'Length Required',
        '412': 'Precondition Required',
        '413': 'Request Entry Too Large',
        '414': 'Request-URI Too Long',
        '415': 'Unsupported Media Type',
        '416': 'Requested Range Not Satisfiable',
        '417': 'Expectation Failed',
        '418': 'I\'m a teapot',
        '429': 'Too Many Requests',
        '500': 'Internal Server Error',
        '501': 'Not Implemented',
        '502': 'Bad Gateway',
        '503': 'Service Unavailable',
        '504': 'Gateway Timeout',
        '505': 'HTTP Version Not Supported',
    };

    let event_stream = {};

    //let watchers = { };

    // Private Methods
    function build_se_uri(path) {
        let host = location.protocol.concat("//").concat(window.location.host);
        let uri = host.concat("/serviceElements/").concat(encodeURI(path))
    
        return uri;
    }

    function build_cmd_uri() {
        let host = location.protocol.concat("//").concat(window.location.host);
        let uri = host.concat("/commands");

        return uri;
    }

    function build_session_uri(element) {
        let host = location.protocol.concat("//").concat(window.location.host);
        let uri = host.concat("/session/").concat(encodeURI(element));

        return uri;
    }

    function build_event_uri(stream_id, event_id) {
        let host = location.protocol.concat("//").concat(window.location.host);
        let uri = host.concat("/events/").concat(encodeURI(stream_id));

        if (event_id) {
            uri = uri.concat("/").concat(encodeURI(event_id));
        }

        return uri;
    }

    async function subscribe(event_id, path, notifications, filter) {
        let stream_id = this.id;
        let uri = build_event_uri(stream_id);
        let body = {
            path: path,
        }
        body["subs-id"] = event_id;
        if (notifications) {
            body["notifications"] = [];
            for (let [key, value] of Object.entries(notifications)) {
                if (value) {
                    body["notifications"].push(key);
                }
            }
            if (body["notifications"].length == 0) {
                delete body["notifications"];
            }
        }
        if (filter) {
            body["filter"] = filter;
        }
        let msg = {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        }
        let response = await fetch(uri, msg);

        if (!response.ok) {
            throw new Error('Status:' + response.status + ' ' + friendlyHttpStatus[response.status]);
        }

        return {
            data: await response.json(),
            status: response.status + ' ' + friendlyHttpStatus[response.status]
        }
    }

    async function ubsubscribe(event_id) {
        let stream_id = this.id;
        let uri = build_event_uri(stream_id, event_id);
        let msg = {
            method: 'DELETE',
        }
        let response = await fetch(uri, msg);

        if (!response.ok) {
            throw new Error('Status:' + response.status + ' ' + friendlyHttpStatus[response.status]);
        }

        return {
            data: await response.json(),
            status: response.status + ' ' + friendlyHttpStatus[response.status]
        }
    }

    // public methods
    tr181model.get = async function(path) {
        let uri = build_se_uri(path);
        let response = await fetch(uri);

        if (!response.ok) {
            throw new Error('Status:' + response.status + ' ' + friendlyHttpStatus[response.status]);
        }

        return { 
            data: await response.json(),
            status: response.status + ' ' + friendlyHttpStatus[response.status]
        }
    }

    tr181model.set = async function(path, params) {
        let uri = build_se_uri(path);
        let body = {
            parameters: params
        }
        let msg = {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        }
        let response = await fetch(uri, msg);

        if (!response.ok) {
            throw new Error('Status:' + response.status + ' ' + friendlyHttpStatus[response.status].format('update'));
        }

        return  {
            data: undefined,
            status: await response.status + ' ' + friendlyHttpStatus[response.status].format('updates applied')
        }   
    }

    tr181model.add = async function(path, params) {
        let uri = build_se_uri(path);
        let body = {
            parameters: params
        }
        let msg = {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        }
        let response = await fetch(uri, msg);

        if (!response.ok) {
            throw new Error('Status:' + response.status + ' ' + friendlyHttpStatus[response.status]);
        }

        return {
            data: await response.json(),
            status: response.status + ' ' + friendlyHttpStatus[response.status]
        }
    }

    tr181model.del = async function(path) {
        let uri = build_se_uri(path);
        let msg = {
            method: 'DELETE',
        }
        let response = await fetch(uri, msg);

        if (!response.ok) {
            throw new Error('Status:' + response.status + ' ' + friendlyHttpStatus[response.status].format('instance removal'));
        }

        return  {
            data: undefined,
            status: await response.status + ' ' + friendlyHttpStatus[response.status].format('instance removed')
        }   
    }

    tr181model.cmd = async function(path, params, sendresp) {
        let uri = build_cmd_uri();
        let body = {
            command: path,
            commandkey: "",
            sendresp: sendresp,
            inputArgs: params
        };
        let msg = {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        };

        let response = await fetch(uri, msg);

        if (!response.ok) {
            throw new Error('Status:' + response.status + ' ' + friendlyHttpStatus[response.status].format("action invocation"));
        }

        if (sendresp) {
            return {
                data: await response.json(),
                status: response.status + ' ' + friendlyHttpStatus[response.status].format("action invocation")
            }
        } else {
            return {
                status: response.status + ' ' + friendlyHttpStatus[response.status].format("action invocation")
            }
        }
    }

    tr181model.open_event_stream = function(stream_id) {
        stream_id = encodeURI(stream_id);
        if (event_stream[stream_id] == undefined) {
            event_stream[stream_id] = new EventSource('/events/'.concat(stream_id));

            event_stream[stream_id].addEventListener("error", (error) => {
                if (error.data) {
                    let data = JSON.parse(error.data);
                    console.error(data);
                }
            });

            event_stream[stream_id].id = stream_id;
            event_stream[stream_id].subscribe = subscribe;
            event_stream[stream_id].unsubscribe = ubsubscribe;
        }
        return event_stream[stream_id];
    }
    
    tr181model.get_user = async function() {
        let uri = build_session_uri('user');
        let response = await fetch(uri);
        return await response.json();
    }

    tr181model.uri = function(path, method) {
        if (method == "CMD") {
            return build_cmd_uri();
        } else {
            return build_se_uri(path);
        }
    }

    tr181model.status_code = function(status) {
        code = status.split(' ')[0];
        if (!isNaN(code)) {
            status = JSON.parse(code);
            return status;
        }
        return 400;
    }

    tr181model.is_ok = function(status) {
        code = status.split(' ')[0];
        if (!isNaN(code)) {
            status = JSON.parse(code);
            return (status >= 200 && status < 299);
        }
    }
}(window.tr181model = window.tr181model || {}, jQuery ));
