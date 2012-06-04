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
        var $, mysessions, sessions, itemTemplate, linkItemTemplate, headerTemplate, currentDateIndex, currentView, lastView;
        
        $ = up.jQuery;
        
        currentDateIndex = 1;

        itemTemplate = $("#${n} .list-template .item-template");
        linkItemTemplate = $("#${n} .list-template .link-item-template");
        headerTemplate = $("#${n} .list-template .header-template");
        
        mysessions = [];
        <c:forEach items="${ mysessions }" var="session">
        mysessions.push('<spring:escapeBody javaScriptEscape="true">${session}</spring:escapeBody>');
        </c:forEach>
        
        var addSession = function(title) {
            mysessions.push(title);
            $.post("<portlet:resourceURL/>", { add: true, title: title }, null, "json");
        };

        var removeSession = function(title) {
            mysessions.splice($.inArray(title, mysessions), 1);
            $.post("<portlet:resourceURL/>", { add: false, title: title }, null, "json");
        };


        var sortSessions = function (a, b) {
            return (a.timestamp - b.timestamp);
        };
        
        var renderSessionList = function(list, includeTimes) {
            var lastTime, container, isBrowse;
            
            container = $("#${n} " + currentView + " .session-list");
            isBrowse = (currentView == ".browse-sessions");

            // make sure the sessions are sorted
            list.sort(sortSessions);
            
            // remove any previous results
            container.find("li").remove();

            $(list).each(function (idx, session) { 
                if (includeTimes && session.time !== lastTime) {
                    var newTimeNode = headerTemplate.clone().text(session.time);
                    container.append(newTimeNode);
                    lastTime = session.time;
                }

                var newNode = linkItemTemplate.clone();
                $(newNode).find("a").click(function () { showDetails(session); });
                $(newNode).find("h3").text(session.title);

                var selectedImg = '<c:url value="/images/bookmark-selected.png"/>';
                var unselectedImg = '<c:url value="/images/bookmark-unselected.png"/>';
                
                var img = $(document.createElement("img")).attr("src", $.inArray(session.title, mysessions) >= 0 ? selectedImg : unselectedImg).click(function () {
                    if ($.inArray(session.title, mysessions) >= 0) {
                        removeSession(session.title);
                        $(this).attr("src", unselectedImg)
                    } else {
                        addSession(session.title);
                        $(this).attr("src", selectedImg);
                    }
                    return false;
                });
                $(newNode).find("p").html("").append(img).append($(document.createElement("span")).text(includeTimes ? session.room : session.time + " " + session.displayDate));
                container.append(newNode);                    
            });
            
            container.find("li").show();
        };
        
        var showView = function(view) {
            $("#${n} .browse-sessions").hide();
            $("#${n} .my-sessions").hide();
            $("#${n} .search-results").hide();
            $("#${n} .session-search-form").hide();
            $("#${n} .session-details").hide();

            if (view) {
                lastView = currentView;
                currentView = view;
            }
            
            if (currentView == '.my-sessions' || currentView == '.browse-sessions') {
                showSessions();
            } else if (currentView == '.search-results') {
                search();
            }
            
            $("#${n} " + currentView).show();
        };
        
        var showSessions = function () {
            var matching = [];
            var dateKey = $("#${n} .session-search-form [name=date]").find("option:eq(" + currentDateIndex + ")").attr("value");
            var dateName = $("#${n} .session-search-form [name=date]").find("option:eq(" + currentDateIndex + ")").text();

            $(sessions).each(function (idx, session) {
                if (session.date === dateKey && (currentView != '.my-sessions' || $.inArray(session.title, mysessions) >= 0)) {
                    matching.push(session);
                }
            });

            $("#${n} .date-name").text(dateName);
            if (currentDateIndex == 1) {
                $("#${n} .program-date-back-link").hide();
            } else {
                $("#${n} .program-date-back-link").show();
            }
            
            if (currentDateIndex == $("#${n} .session-search-form [name=date] option").size()-1) {
                $("#${n} .program-date-forward-link").hide();
            } else {
                $("#${n} .program-date-forward-link").show();
            }
            
            renderSessionList(matching, true);
        };
        
        var showDetails = function (session) {
            var detailsView = $("#${n} .session-details");
            
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
                removeSession(session.title); 
                $(detailsView).find(".remove-session-link").hide();
                $(detailsView).find(".add-session-link").show();
            });
            detailsView.find(".add-session-link").show().unbind('click').click(function () { 
                addSession(session.title);
                $(detailsView).find(".remove-session-link").show();
                $(detailsView).find(".add-session-link").hide();
            });

            if ($.inArray(session.title, mysessions) >= 0) {
                detailsView.find(".add-session-link").hide();
            } else {
                detailsView.find(".remove-session-link").hide();
            }

            showView(".session-details");
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

            renderSessionList(matching, false);

            return false;

        };

        $(document).ready(function () {
            
            $("#${n} .session-search-form").submit(function () { showView(".search-results"); return false; });
            
            $("#${n} .program-search-button").click(function () { showView(".session-search-form"); });
            $("#${n} .search-back-button").click(function() { showView(".browse-sessions"); });
            $("#${n} .matches-back-button").click(function () { showView(".session-search-form"); });
            $("#${n} .details-back-button").click(function () { showView(lastView); });
            
            $("#${n} .program-date-back-link").click(function () { changeDate(-1); });
            $("#${n} .program-date-forward-link").click(function () { changeDate(1); });
            
            $("#${n} .my-sessions-button").click(function () { showView(".my-sessions"); });
            $("#${n} .browse-sessions-button").click(function () { showView(".browse-sessions"); });
                
            $.get(
                '<c:url value="/service/program/${hash}.json"/>',
                {},
                function (data) {
                    sessions = data.sessions;
                    showView(".browse-sessions");
                },
                "json"
            );
            
        });
        
    });    

</script>

<div id="${n}">

    <ul class="list-template" data-role="listview" style="display:none">
        <li data-role="list-divider" class="header-template">Header</li>
        <li class="link-item-template">
            <a href="javascript:;"><h3>Title</h3><p>Desc</p></a>
        </li>
        <li class="item-template">Item</li>
    </ul>

    <!-- session list by date -->
    <div class="browse-sessions">
        <div data-role="header" class="titlebar portlet-titlebar">
            <h2>
                <a data-role="button" data-icon="arrow-l" data-iconpos="notext" data-inline="true" class="program-date-back-link" href="javascript:;">&lt;</a>
                <span class="date-name"></span>
                <a data-role="button" data-icon="arrow-r" data-iconpos="notext" data-inline="true" class="program-date-forward-link" href="javascript:;">&gt;</a>
            </h2>
            <a href="javascript:;" class="ui-btn-right program-search-button" data-icon="search" data-iconpos="notext">
                <span>Search</span>
            </a>
            <a href="javascript:;" class="ui-btn-left my-sessions-button" data-icon="star" data-iconpos="notext">
                <span>Mine</span>
            </a>
        </div>
        <div data-role="content" class="portlet-content">
            <ul data-role="listview" class="session-list"></ul>
        </div>
    </div>

    <div class="my-sessions" style="display: none;">
        <div data-role="header" class="titlebar portlet-titlebar">
            <h2>
                <a data-role="button" data-icon="arrow-l" data-iconpos="notext" data-inline="true" class="program-date-back-link" href="javascript:;">&lt;</a>
                <span class="date-name"></span>
                <a data-role="button" data-icon="arrow-r" data-iconpos="notext" data-inline="true" class="program-date-forward-link" href="javascript:;">&gt;</a>
            </h2>
            <a href="javascript:;" class="ui-btn-right program-search-button" data-icon="search" data-iconpos="notext">
                <span>Search</span>
            </a>
            <a href="javascript:;" class="ui-btn-left browse-sessions-button" data-icon="home" data-iconpos="notext">
                <span>Home</span>
            </a>
        </div>
        <div data-role="content" class="portlet-content">
            <ul data-role="listview" class="session-list"></ul>
        </div>
    </div>

    <!-- session search results -->
    <div class="search-results" style="display:none">
        <div data-role="header" class="titlebar portlet-titlebar">
            <a data-role="button"  data-icon="back" data-inline="true" href="javascript:;" class="matches-back-button">Back</a>
            <h2>Search</h2>
        </div>
        <div data-role="content" class="portlet-content">
            <ul data-role="listview" class="session-list"></ul>
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
                <div data-role="fieldcontain" class="ui-hidden-accessible">
                    <label for="title">Title</label>
                    <input id="title" name="title" type="text"/>
                    <label for="presenter">Presenter</label>
                    <input name="presenter" id="presenter" type="text"/>
                    <fieldset data-role="controlgroup">
                        <select name="date" id="date">
                            <option value="">Any Date</option>
                            <c:forEach items="${ dates }" var="date">
                                <option value="${ date.key }">${ date.value }</option>
                            </c:forEach>
                        </select>
                        <select name="level" id="level">
                            <option value="">Any Level</option>
                            <c:forEach items="${ levels }" var="level">
                                <option>${ level }</option>
                            </c:forEach>
                        </select>
                        <select name="type" id="type">
                            <option value="">Any Type</option>
                            <c:forEach items="${ types }" var="type">
                                <option>${ type }</option>
                            </c:forEach>
                        </select>
                        <select name="track" id="track">
                            <option value="">Any Track</option>
                            <c:forEach items="${ tracks }" var="track">
                                <option>${ track }</option>
                            </c:forEach>
                        </select>
                    </fieldset>
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
            <h3>
                <a href="javascript:;" class="add-session-link"><img src="<c:url value="/images/bookmark-unselected.png"/>"/></a>
                <a href="javascript:;" class="remove-session-link"><img src="<c:url value="/images/bookmark-selected.png"/>"/></a>
                <span class="session-title"></span>
            </h3>
            <p>When: <span class="time"/> on <span class="date"/></p>
            <p>Where: <span class="room"/></p>
            <p class="track">Track: <span class="track-name"></span></p>
            <p class="level">Level: <span class="level-name"></span></p>
            <br/>
            <p class="details"></p>
            <br/>
            
            <h3 class="presenters">Presenters</h3>
            <ul class="presenter-list">
            </ul>
            
        </div>
    </div>
</div>
