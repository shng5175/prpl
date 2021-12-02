(function (tr181view, $, undefined) {
    (function (templates, $, undefined) {
        let fetch_html = [
            { name: "switch", uri: "/tr181_web/templates/switch.html" },
            { name: "side-nav", uri: "/tr181_web/templates/sidenav.html" },
            { name: "result-view", uri: "/tr181_web/templates/resultview.html" },
            { name: "result-obj-card", uri: "/tr181_web/templates/result-obj-card.html" },
            { name: "result-obj-param", uri: "/tr181_web/templates/result-obj-param.html" },
            { name: "result-header", uri: "/tr181_web/templates/result-header.html" },
            { name: "result-error", uri: "/tr181_web/templates/result-error.html" },
            { name: "result-message", uri: "/tr181_web/templates/result-message.html" },
            { name: "result-http-request", uri: "/tr181_web/templates/result-http-request-card.html" },
            { name: "result-http-response", uri: "/tr181_web/templates/result-http-response-card.html" },
            { name: "result-event", uri: "/tr181_web/templates/result-http-event-card.html" },
            { name: "request-card", uri: "/tr181_web/templates/request-card.html" },
            { name: "request-card-body-param", uri: "/tr181_web/templates/request-card-body-param.html" },
            { name: "request-card-body-cmd", uri: "/tr181_web/templates/request-card-body-cmd.html" },
            { name: "request-card-sub-body", uri: "/tr181_web/templates/request-card-sub-body.html" },
            { name: "request-card-event-id", uri: "/tr181_web/templates/request-card-event-id.html" },
            { name: "request-card-param", uri: "/tr181_web/templates/request-card-param.html" },
        ];

        let html = { };

        async function load(name, uri) {
            let response = await fetch(uri);
            if (response.ok) {
                html[name] = await response.text();
            }
        }

        templates.fetch = function() {
            fetch_html.forEach((value, index) => {
                if (!html['name']) {
                    load(value['name'], value['uri']);
                }
            });
        }

        templates.get = function(name) {
            return html[name] || '<div></div>';
        }

        templates.load = async function(name, uri) {
            fetch_html.forEach((value, index) => {
                if (name == value['name']) {
                    uri = value['uri'];
                }
            });

            if (uri) {
                let response = await fetch(uri);
                if (response.ok) {
                    html[name] = await response.text();
                    return await html[name];
                }
            }

            return '<div></div>';
        }
        
    } (tr181view.templates = tr181view.template || {}, jQuery ));
}(window.tr181view = window.tr181view || {}, jQuery ));
