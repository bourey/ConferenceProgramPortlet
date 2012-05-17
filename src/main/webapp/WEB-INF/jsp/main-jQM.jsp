<%--

    Licensed to Jasig under one or more contributor license
    agreements. See the NOTICE file distributed with this work
    for additional information regarding copyright ownership.
    Jasig licenses this file to you under the Apache License,
    Version 2.0 (the "License"); you may not use this file
    except in compliance with the License. You may obtain a
    copy of the License at:

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on
    an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied. See the License for the
    specific language governing permissions and limitations
    under the License.

--%>

<jsp:directive.include file="/WEB-INF/jsp/include.jsp"/>
<c:set var="n"><portlet:namespace/></c:set>

<script type="text/javascript">
        
    up.jQuery(function () {
        var $, mysessions, sessions, sessionTimeNode, sessionListingNode, currentDateIndex;
        
        $ = up.jQuery;
        
        currentDateIndex = 1;

        sessionTimeNode = $("#${n} .browse-sessions .session-list .session-time").hide();
        sessionListingNode = $("#${n} .browse-sessions .session-list .session").hide();
        
        mysessions = [];
        <c:forEach items="${ mysessions }" var="session">
        mysessions.push('<spring:escapeBody javaScriptEscape="true">${session}</spring:escapeBody>');
        </c:forEach>
        
        var addSession = function(title) {
            mysessions.push(title);
            $.post("<portlet:resourceURL/>", { add: true, title: title }, null, "json");
        };

        var removeSession = function(title) {
            $.post("<portlet:resourceURL/>", { add: false, title: title }, null, "json");
        };


        var sortSessions = function (a, b) {
            return (a.timestamp - b.timestamp);
        };
        
        var renderSessionList = function(list, container, includeTimes) {
            var lastTime;

            // make sure the sessions are sorted
            list.sort(sortSessions);
            
            // remove any previous results
            container.find("li:gt(1)").remove();

            $(list).each(function (idx, session) { 
                if (includeTimes && session.time !== lastTime) {
                    var newTimeNode = sessionTimeNode.clone().text(session.time);
                    container.append(newTimeNode);
                    lastTime = session.time;
                }

                var newNode = sessionListingNode.clone();
                $(newNode).find("a").click(function () { showDetails(session); });
                $(newNode).find(".session-title").text(session.title);
                $(newNode).find(".session-location").text(includeTimes ? session.room : session.time + " " + session.displayDate);
                container.append(newNode);                    
            });
            
            container.find("li:gt(1)").show();
        };

        var showView = function(clazz) {
            $("#${n} .browse-sessions").hide();
            $("#${n} .search-results").hide();
            $("#${n} .session-search-form").hide();
            $("#${n} .session-details").hide();
            $(clazz).show();
        };
        
        var showSessions = function () {
            var matching = [];
            var dateKey = $("#${n} .session-search-form [name=date]").find("option:eq(" + currentDateIndex + ")").attr("value");
            var dateName = $("#${n} .session-search-form [name=date]").find("option:eq(" + currentDateIndex + ")").text();
            
            $(sessions).each(function (idx, session) {
                if (session.date === dateKey) {
                    matching.push(session);
                }
            });

            $("#${n} .browse-sessions .date-name").text(dateName);
            if (currentDateIndex == 1) {
                $("#${n} .browse-sessions .program-date-back-link").hide();
            } else {
                $("#${n} .browse-sessions .program-date-back-link").show();
            }
            
            if (currentDateIndex == $("#${n} .session-search-form [name=date] option").size()-1) {
                $("#${n} .browse-sessions .program-date-forward-link").hide();
            } else {
                $("#${n} .browse-sessions .program-date-forward-link").show();
            }
            
            renderSessionList(matching, $("#${n} .browse-sessions .session-list"), true);
            showView("#${n} .browse-sessions");
        };
        
        var showDetails = function (session) {
            var detailsView = $("#${n} .session-details");
            
            // bind session to data
            detailsView.find("session-title").text(session.title);
            detailsView.find(".time").text(session.time + " on " + session.displayDate);
            detailsView.find(".room").text(session.room);
            detailsView.find(".track").text(session.track);
            detailsView.find(".level").text(session.level);
            detailsView.find(".details").text(session.details);

            if ($.inArray(session.title, mysessions) >= 0) {
                detailsView.find(".remove-session-link").show().unbind('click').click(function () { removeSession(session.title); });
                detailsView.find(".add-session-link").hide();
            } else {
                detailsView.find(".add-session-link").show().unbind('click').click(function () { addSession(session.title); });
                detailsView.find(".remove-session-link").hide();
            }
            
            showView("#${n} .session-details");
        };

        var changeDate = function (days) {
            currentDateIndex += days;
            showSessions();
        };
        
        var search = function () {
            var matching, title, date, track, level, type;
            
            var form = $("#${n} .session-search-form");
            
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

            renderSessionList(matching, $(".search-results .session-list"), false);

            showView("#${n} .search-results");
            
            return false;

        };

        $(document).ready(function () {
            
            $("#${n} .session-search-form").submit(search);
            
            $("#${n} .program-search-button").click(function () { showView("#${n} .session-search-form"); });
            $("#${n} .search-back-button").click(function() { showView("#${n} .browse-sessions"); });
            $("#${n} .matches-back-button").click(function () { showView("#${n} .session-search-form"); });
            $("#${n} .details-back-button").click(function () { showView("#${n} .browse-sessions"); });
            
            $("#${n} .program-date-back-link").click(function () { changeDate(-1); });
            $("#${n} .program-date-forward-link").click(function () { changeDate(1); });
            
    
            $.get(
                '<c:url value="/service/program.json"/>',
                {},
                function (data) {
                    sessions = data.sessions;
                    showSessions();
                },
                "json"
            );
            
        });
        
    });    

</script>

<div id="${n}">
    <!-- session list by date -->
    <div class="browse-sessions">
        <div data-role="header" class="titlebar portlet-titlebar">
            <h2>
                <a data-role="button" data-icon="arrow-l" data-iconpos="notext" data-inline="true" class="program-date-back-link" href="javascript:;">&lt;</a>
                <span class="date-name"></span>
                <a data-role="button" data-icon="arrow-r" data-iconpos="notext" data-inline="true" class="program-date-forward-link" href="javascript:;">&gt;</a>
            </h2>
            <a href="javascript:;" class="ui-btn-right program-search-button" data-icon="search">
                <span>Search</span>
            </a>
        </div>
        <div data-role="content" class="portlet-content">
            <ul data-role="listview" class="session-list">
                <li data-role="list-divider" class="session-time">Time</li>
                <li class="session">
                    <a href="javascript:;"><h3 class="session-title">Session</h3>
                    <p class="session-location">Location</p>
                </li>
            </ul>
        </div>
    </div>

    <!-- session search results -->
    <div class="search-results" style="display:none">
        <div data-role="header" class="titlebar portlet-titlebar">
            <a data-role="button" data-icon="back" data-inline="true" class="matches-back-button" href="javascript:;">Back</a>
            <h2>Matches</h2>
        </div>
        <div data-role="content" class="portlet-content">
            <ul data-role="listview" class="session-list">
            </ul>
        </div>
    </div>

    <!-- session search form -->
    <div class="session-search-form" style="display:none">
        <div data-role="header" class="titlebar portlet-titlebar">
            <a data-role="button"  data-icon="back" data-inline="true" href="javascript:;" class="search-back-button">Back</a>
            <h2>Search</h2>
        </div>
        <div data-role="content" class="portlet-content">
            <form class="session-search-form">
                <div data-role="fieldcontain">
                    <label for="date">Date</label>
                    <select name="date" id="date">
                        <option value="">Any</option>
                        <c:forEach items="${ dates }" var="date">
                            <option value="${ date.key }">${ date.value }</option>
                        </c:forEach>
                    </select>
                </div>
                <div data-role="fieldcontain">
                    <label for="level">Level</label>
                    <select name="level" id="level">
                        <option value="">Any</option>
                        <c:forEach items="${ levels }" var="level">
                            <option>${ level }</option>
                        </c:forEach>
                    </select>
                </div>
                <div data-role="fieldcontain">
                    <label for="type">Type</label>
                    <select name="type" id="type">
                        <option value="">Any</option>
                        <c:forEach items="${ types }" var="type">
                            <option>${ type }</option>
                        </c:forEach>
                    </select>
                </div>
                <div data-role="fieldcontain">
                    <label for="track">Track</label>
                    <select name="track" id="track">
                        <option value="">Any</option>
                        <c:forEach items="${ tracks }" var="track">
                            <option>${ track }</option>
                        </c:forEach>
                    </select>
                </div>
                <div data-role="fieldcontain">
                    <label for="title">Title</label>
                    <input id="title" name="title" type="text"/>
                </div>
                <div data-role="fieldcontain">
                    <label for="presenter">Presenter</label>
                    <input name="presenter" id="presenter" type="text"/>
                </div>
                <div data-role="fieldcontain">
                    <input type="submit" value="Search"/>
                </div>
            </form>
        </div>
    </div>
        
    <div class="session-details" style="display:none">
        <div data-role="header" class="titlebar portlet-titlebar">
            <a data-role="button" data-icon="back" data-inline="true" href="javascript:;" class="details-back-button">Back</a>
            <h2>Details</h2>
        </div>
        <div data-role="content" class="portlet-content">
            <h2 class="session-title"></h2>
            <p>When: <span class="time"/> on <span class="date"/></p>
            <p>Where: <span class="room"/></p>
            <p class="track"></p>
            <p class="level"></p>
            <ul class="presenters">
            </ul>
            <p class="details"></p>
            <p><a href="javascript:;" class="add-session-link">Add to my schedule</a></p>
            <p><a href="javascript:;" class="remove-session-link">Remove from my schedule</a></p>
        </div>
    </div>
</div>
