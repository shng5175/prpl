(function (tr181view, $, undefined) {
    async function add_config_switches() {
        let set_check = false;
        let switch_button = await tr181view.templates.load("switch");

        $('#CONFIG').append(switch_button.format('HTTP', 'Show HTTP Request/Response', ''));
        $('#CONFIG').append(switch_button.format('FOLLOW-TYPING', ' Fetch objects while typing', ''));
        $('#CONFIG').append(switch_button.format('FETCH', 'Fetch object after successfull SET/ADD/DELETE', ''));
        $('#CONFIG').append(switch_button.format('ANIMATION', 'Turn on animation', ''));

        set_check = document.get_cookie('HTTP', "true");
        $('#HTTP input').prop('checked', set_check);

        set_check = document.get_cookie('FOLLOW-TYPING', "false");
        $('#FOLLOW-TYPING input').prop('checked', set_check);

        set_check = document.get_cookie('FETCH', "false");
        $('#FETCH input').prop('checked', set_check);

        set_check = document.get_cookie('ANIMATION', "false");
        $('#ANIMATION input').prop('checked', set_check);

        $('#CONFIG input').click(function() {
            document.set_cookie($(this).parent().attr('id'), $(this).is(':checked'));
        });
    }

    async function build_page() {
        let sidenav = await tr181view.templates.load("side-nav");
        let resultview = await tr181view.templates.load("result-view");
        let user = await tr181model.get_user();

        $('body .content').append(sidenav.format(user.user));
        $('body .content').append(resultview);
        
        add_config_switches();

        $('.sidenav').height($(window).height());  
    }

    function toggle_sidenav() {
        let sidenav = $('#SIDENAV');
        let dataview = $('#DATA-VIEW');
        let toggle = $(this);
        if (sidenav.is(":visible")) {
            tr181view.animate(sidenav, "slideOutLeft").then((element) => {
                sidenav.hide();
                dataview.toggleClass('offset-4 col-sm-8 col-sm-12');
                toggle.toggleClass('fa-angle-double-left fa-angle-double-right');
            });
        } else {
            sidenav.show();
            dataview.toggleClass('offset-4 col-sm-8 col-sm-12');
            tr181view.animate(sidenav, "slideInLeft").then((element) => {
                toggle.toggleClass('fa-angle-double-left fa-angle-double-right');
            });
        }
    }

    tr181view.init = async function() {        
        await build_page();
        tr181view.templates.fetch();

        $('#EXEC').click(tr181ctrl.input.path_action);
        $('#PATH').enterKey(tr181ctrl.input.path_action);
        $('#PATH').keypress(tr181ctrl.input.path_keypress);
        $('#ACTION').parent().find('.dropdown-item').click(tr181ctrl.input.action_changed);
        $('#LOGOUT').click(tr181ctrl.logout);
        $('#TOGGLE').click(toggle_sidenav);
        tr181view.input.update_action("GET");
    }

    tr181view.clear = function() {
        $('body .content').empty();
    }

    tr181view.animate = (element, animation, prefix = 'animate__') =>
        // We create a Promise and return it
        new Promise((resolve, reject) => {
            if (tr181view.input.is_checked('ANIMATION')) {
                const animationName = `${prefix}${animation}`;
                const node = element;

                element.addClass([ `${prefix}animated`, animationName ]);

                // When the animation ends, we clean the classes and resolve the Promise
                function handleAnimationEnd(event) {
                    event.stopPropagation();
                    element.removeClass([ `${prefix}animated`, animationName]);
                    resolve(element);
                }

                element.one('animationend', handleAnimationEnd);
            } else {
                resolve(element);
            }
        });

}(window.tr181view = window.tr181view || {}, jQuery ));