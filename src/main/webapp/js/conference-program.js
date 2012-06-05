
var conference = conference || {};


if (!conference.init) {
    conference.init = function ($) {

        var sessions, itemTemplate, linkItemTemplate, headerTemplate, currentDateIndex, currentView, lastView;
        
        currentDateIndex = 1;
        
        var addSession = function(title, container, preferences) {
            preferences.mysessions.push(title);
            $.post(preferences.updateUrl, { add: true, title: title }, null, "json");
        };

        var removeSession = function(title, container, preferences) {
            preferences.mysessions.splice($.inArray(title, preferences.mysessions), 1);
            $.post(preferences.updateUrl, { add: false, title: title }, null, "json");
        };


        var sortSessions = function (a, b) {
            return (a.timestamp - b.timestamp);
        };
        
        var renderSessionList = function(list, includeTimes, container, preferences) {
            var lastTime, subcontainer, isBrowse;
            
            subcontainer = container.find("" + currentView + " .session-list");
            isBrowse = (currentView == ".browse-sessions");

            // make sure the sessions are sorted
            list.sort(sortSessions);
            
            // remove any previous results
            subcontainer.find("li").remove();

            $(list).each(function (idx, session) { 
                if (includeTimes && session.time !== lastTime) {
                    var newTimeNode = headerTemplate.clone().text(session.time);
                    subcontainer.append(newTimeNode);
                    lastTime = session.time;
                }

                var newNode = linkItemTemplate.clone();
                $(newNode).find("a").click(function () { showDetails(session, container, preferences); });
                $(newNode).find("h3").text(session.title);

                var img = $(document.createElement("img")).attr("src", $.inArray(session.title, preferences.mysessions) >= 0 ? preferences.selectedImg : preferences.unselectedImg).click(function () {
                    if ($.inArray(session.title, preferences.mysessions) >= 0) {
                        removeSession(session.title, container, preferences);
                        $(this).attr("src", preferences.unselectedImg)
                    } else {
                        addSession(session.title, container, preferences);
                        $(this).attr("src", preferences.selectedImg);
                    }
                    return false;
                });
                $(newNode).find("p").html("").append(img).append($(document.createElement("span")).text(includeTimes ? session.room : session.time + " " + session.displayDate));
                subcontainer.append(newNode);                    
            });
            
            subcontainer.find("li").show();
        };
        
        var showView = function(view, container, preferences) {
            container.find(".browse-sessions").hide();
            container.find(".my-sessions").hide();
            container.find(".search-results").hide();
            container.find(".session-search-form").hide();
            container.find(".session-details").hide();

            if (view) {
                lastView = currentView;
                currentView = view;
            }
            
            if (currentView == '.my-sessions' || currentView == '.browse-sessions') {
                showSessions(container, preferences);
            } else if (currentView == '.search-results') {
                search(container, preferences);
            }
            
            container.find("" + currentView).show();
        };
        
        var showSessions = function (container, preferences) {
            var matching = [];
            var dateKey = container.find(".session-search-form [name=date]").find("option:eq(" + currentDateIndex + ")").attr("value");
            var dateName = container.find(".session-search-form [name=date]").find("option:eq(" + currentDateIndex + ")").text();

            $(sessions).each(function (idx, session) {
                if (session.date === dateKey && (currentView != '.my-sessions' || $.inArray(session.title, preferences.mysessions) >= 0)) {
                    matching.push(session);
                }
            });

            container.find(".date-name").text(dateName);
            if (currentDateIndex == 1) {
                container.find(".program-date-back-link").hide();
            } else {
                container.find(".program-date-back-link").show();
            }
            
            if (currentDateIndex == container.find(".session-search-form [name=date] option").size()-1) {
                container.find(".program-date-forward-link").hide();
            } else {
                container.find(".program-date-forward-link").show();
            }
            
            renderSessionList(matching, true, container, preferences);
        };
        
        var showDetails = function (session, container, preferences) {
            var detailsView = container.find(".session-details");
            
            // bind session to data
            detailsView.find(".session-title").text(session.title);
            detailsView.find(".time").text(session.time + " on " + session.displayDate);
            detailsView.find(".room").text(session.room);
            if (session.track && session.track !== 'Unknown') {
                detailsView.find(".track").show().find(".track-name").text(session.track);
            } else {
                detailsView.find(".track").hide().find(".track-name").text("");
            }
            if (session.level && session.level !== 'Unknown') {
                detailsView.find(".level").show().find(".level-name").text(session.level);
            } else {
                detailsView.find(".level").hide().find(".level-name").text("");
            }
            detailsView.find(".details").text(session.details);
            
            if (session.presenters.length > 0) {
                $(".presenter-list").text("");
                $(session.presenters).each(function (idx, presenter) {
                    $(detailsView).find(".presenter-list").append($(document.createElement("li")).text(presenter));
                });
                $(detailsView).find(".presenters").show();
            } else {
                $(detailsView).find(".presenters").hide();
            }

            detailsView.find(".remove-session-link").show().unbind('click').click(function () { 
                removeSession(session.title, container, preferences); 
                $(detailsView).find(".remove-session-link").hide();
                $(detailsView).find(".add-session-link").show();
            });
            detailsView.find(".add-session-link").show().unbind('click').click(function () { 
                addSession(session.title, container, preferences);
                $(detailsView).find(".remove-session-link").show();
                $(detailsView).find(".add-session-link").hide();
            });

            if ($.inArray(session.title, preferences.mysessions) >= 0) {
                detailsView.find(".add-session-link").hide();
            } else {
                detailsView.find(".remove-session-link").hide();
            }

            showView(".session-details", container, preferences);
        };

        var changeDate = function (days, container, preferences) {
            currentDateIndex += days;
            showSessions(container, preferences);
        };
        
        var search = function (container, preferences) {
            var matching, title, date, track, level, type;
            
            var form = container.find(".session-search-form");
            
            title = form.find("[name=title]").val();
            date = form.find("[name=date]").val();
            track = form.find("[name=track]").val();
            level = form.find("[name=level]").val();
            type = form.find("[name=type]").val();
            presenter = form.find("[name=presenter]").val();
            
            matching = [];
            $(sessions).each(function (idx, session) {
                if (
                    (!title || session.title.toLowerCase().indexOf(title.toLowerCase()) >= 0) &&
                    (!date || session.date === date) &&
                    (!track || session.track === track) &&
                    (!level || session.level === level) &&
                    (!type || session.type === type) &&
                    (!presenter || session.presenters.join(",").toLowerCase().indexOf(presenter.toLowerCase()) >= 0)
                ) {
                    matching.push(session);
                }
            });

            renderSessionList(matching, false, container, preferences);

            return false;

        };
        
        conference.program = function (container, preferences) {
            
            itemTemplate = container.find(".list-template .item-template");
            linkItemTemplate = container.find(".list-template .link-item-template");
            headerTemplate = container.find(".list-template .header-template");

            container.find(".session-search-form").submit(function () { showView(".search-results", container, preferences); return false; });
            
            container.find(".program-search-button").click(function () { showView(".session-search-form", container, preferences); });
            container.find(".search-back-button").click(function() { showView(".browse-sessions", container, preferences); });
            container.find(".matches-back-button").click(function () { showView(".session-search-form", container, preferences); });
            container.find(".details-back-button").click(function () { showView(lastView, container, preferences); });
            
            container.find(".program-date-back-link").click(function () { changeDate(-1, container, preferences); });
            container.find(".program-date-forward-link").click(function () { changeDate(1, container, preferences); });
            
            container.find(".my-sessions-button").click(function () { showView(".my-sessions", container, preferences); });
            container.find(".browse-sessions-button").click(function () { showView(".browse-sessions", container, preferences); });
                
            $.get(preferences.programUrl,
                {},
                function (data) {
                    sessions = data.sessions;
                    showView(".browse-sessions", container, preferences);
                },
                "json"
            );
        };
        
    };
    
}