(function (tr181crtl, $, undefined) {
    (function (input, $, undefined) { 

        let action = "GET";
        input.path_action = function() {
            let path = tr181view.input.path();
            let params = { };
            if (path === "") {
                return;
            }
            switch(action) {
                case 'GET':
                    tr181ctrl.execute_request(action, path);
                    tr181view.input.add_card(path, action);
                    break;
                case 'SET':
                    tr181view.input.add_card(path, action);
                    break;
                case 'ADD':
                    tr181view.input.add_card(path, action);
                    break;
                case 'DELETE':
                    tr181view.input.add_card(path, action);
                    break;
                case 'CMD':
                    tr181view.input.add_card(path, action);
                    break;
                case 'SUB':
                    tr181view.input.add_card(path, action);
                    break;
                }
        }
    
        let delayed_get = undefined;
        input.path_keypress = function(event) {
            if (delayed_get) {
                clearTimeout(delayed_get);
                delayed_get = undefined;
            }
            if (tr181view.input.is_checked('FOLLOW-TYPING')) {
                if (event.key == '.') {
                    let input = $(this);
                    delayed_get = setTimeout(function() {
                        let path = input.val();
                        tr181ctrl.execute_request("GET", path);
                    }, 500);
                }
            }
        }
    
        input.action_changed = function() {
            action = $(this).text();
            tr181view.input.update_action(action);
        }
    
        input.handle_card_button = function(card, button) {
            let action = button.attr('btn-action');
            switch(action) {
                case 'collapse':
                    tr181view.input.collapse_card(card);
                    break;
                case 'add-param':
                    tr181view.input.add_param(card);
                    break;
                case 'del-param':
                    tr181view.input.remove_param(card, button);
                break;
                case 'del-card':
                    tr181view.animate(card, 'hinge').then((element) => { 
                        let event_id = tr181view.input.get_card_event_id(card);
                        if (event_id) {
                            document.event_stream.removeEventListener(event_id, tr181ctrl.handle_event);
                            document.event_stream.unsubscribe(event_id);
                        }
                        element.remove();
                    });
                    tr181view.input.set_focus();                  
                    break;
                case 'submit': {
                    let path = tr181view.input.get_card_path(card);
                    let method = tr181view.input.get_card_method(card);
                    let params = tr181view.input.get_params(card);
                    let toggles = tr181view.input.get_toggles(card);
                    tr181ctrl.execute_request(method, path, params, toggles).then(result => {
                        if (result >= 200 && result <= 299) {
                            if (method == "DELETE") {
                                card.remove();
                                tr181view.input.remove_cards(path);
                            }
                            tr181view.input.set_focus();
                        }
                    });
                }
                break;
                case 'start-watch': {
                    let path = tr181view.input.get_card_path(card);
                    let event_id = "";
                    let filter = "";
                    let toggles = {};
                    if (tr181view.input.get_card_method(card) == "SUB") {
                        toggles = tr181view.input.get_toggles(card);
                        event_id = tr181view.input.get_card_event_id(card);
                        filter = tr181view.input.get_card_filter(card);
                    } else {
                        event_id = document.uuid();
                        tr181view.input.show_event_id(card, event_id);
                    }
                    document.event_stream.addEventListener(event_id, tr181ctrl.handle_event);
                    document.event_stream.subscribe(event_id, path, toggles, filter);
                    tr181view.input.set_card_event_id(card, event_id);
                    tr181view.input.set_watch_button(button, false);
                }
                break;
                case 'stop-watch': {
                    let event_id = tr181view.input.get_card_event_id(card);
                    document.event_stream.removeEventListener(event_id, tr181ctrl.handle_event);
                    document.event_stream.unsubscribe(event_id);
                    if (tr181view.input.get_card_method(card) != "SUB") {
                        tr181view.input.set_card_event_id(card);
                    }
                    if (tr181view.input.get_card_method(card) == "GET") {
                        tr181view.input.hide_event_id(card);
                    }
                    tr181view.input.set_watch_button(button, true);
                }
                break;
            }
        }
    } (tr181ctrl.input = tr181ctrl.input || {}, jQuery ));
}(window.tr181ctrl = window.tr181ctrl || {}, jQuery ));