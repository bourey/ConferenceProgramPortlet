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
<script type="text/javascript" src="<c:url value="/js/conference-program.js"/>"></script>

<script type="text/javascript"><rs:compressJs>
var ${n} = ${n} || {};
${n}.jQuery = up.jQuery;
if (!conference.initialized) conference.init(${n}.jQuery);
${n}.conference = conference;

${n}.jQuery(document).ready(function () { 

    var $ = ${n}.jQuery;
    
    var preferences = {
        programUrl: '<c:url value="/service/program/${hash}.json"/>',
        updateUrl: '<portlet:resourceURL/>',
        mysessions: [],
        selectedImg: '<c:url value="/images/bookmark-selected.png"/>',
        unselectedImg: '<c:url value="/images/bookmark-unselected.png"/>',
        authenticated: ${ authenticated }
    };
    <c:forEach items="${ mysessions }" var="session">
        preferences.mysessions.push('<spring:escapeBody javaScriptEscape="true">${session}</spring:escapeBody>');
    </c:forEach>    
        
    conference.program($("#${n}"), preferences);
    
});
</rs:compressJs></script>

<style type="text/css">
.header-template {
    font-weight: bold;
    list-style: none;
    margin-left: -2em;
}
</style>

<div id="${n}" class="fl-widget portlet" role="section">

    <ul class="list-template" data-role="listview" style="display:none">
        <li data-role="list-divider" class="header-template">Header</li>
        <li class="link-item-template">
            <a href="javascript:;"><h3>Title</h3></a>
            <p>Desc</p>
        </li>
        <li class="item-template">Item</li>
    </ul>

    <!-- session list by date -->
    <div class="browse-sessions">
        <div data-role="header" class="fl-widget-titlebar titlebar portlet-titlebar" role="sectionhead">
            <h2 class="title">
                <a class="program-date-back-link" href="javascript:;">&lt;</a>
                <span class="date-name"></span>
                <a class="program-date-forward-link" href="javascript:;">&gt;</a>
            </h2>
            <div class="toolbar">
                <ul>                        
                    <li><a href="javascript:;" class="ui-btn-left my-sessions-button" data-icon="star" data-iconpos="notext">
                        <span>My Sessions</span>
                    </a></li>
                    <li><a href="javascript:;" class="ui-btn-right program-search-button" data-icon="search" data-iconpos="notext">
                        <span>Search</span>
                    </a></li>
                </ul>
            </div>
        </div>
        <div data-role="content" class="portlet-content">
            <ul data-role="listview" class="session-list"></ul>
        </div>
    </div>

    <div class="my-sessions" style="display: none;">
        <div data-role="header" class="fl-widget-titlebar titlebar portlet-titlebar">
            <h2 class="title">
                <a data-role="button" data-icon="arrow-l" data-iconpos="notext" data-inline="true" class="program-date-back-link" href="javascript:;">&lt;</a>
                <span class="date-name"></span>
                <a data-role="button" data-icon="arrow-r" data-iconpos="notext" data-inline="true" class="program-date-forward-link" href="javascript:;">&gt;</a>
            </h2>
            <div class="toolbar">
                <ul>
                    <li><a href="javascript:;" class="ui-btn-left browse-sessions-button" data-icon="home" data-iconpos="notext">
                        <span>All Sessions</span>
                    </a></li>
                    <li><a href="javascript:;" class="ui-btn-right program-search-button" data-icon="search" data-iconpos="notext">
                        <span>Search</span>
                    </a></li>
                </ul>
            </div>
        </div>
        <div data-role="content" class="portlet-content">
            <ul data-role="listview" class="session-list"></ul>
        </div>
    </div>

    <!-- session search results -->
    <div class="search-results" style="display:none">
        <div data-role="header" class="fl-widget-titlebar titlebar portlet-titlebar">
            <a href="javascript:;" class="matches-back-button">Back</a>
            <h2 class="title">Search</h2>
        </div>
        <div data-role="content" class="portlet-content">
            <ul data-role="listview" class="session-list"></ul>
        </div>
    </div>

    <!-- session search form -->
    <div class="session-search-form" style="display:none">
        <div data-role="header" class="fl-widget-titlebar titlebar portlet-titlebar">
            <a href="javascript:;" class="search-back-button">Back</a>
            <h2 class="title">Search</h2>
        </div>
        <div data-role="content" class="portlet-content">
            <form class="session-search-form">
                <div data-role="fieldcontain" class="ui-hidden-accessible">
                    <p><label for="title">Title</label>
                    <input id="title" name="title" type="text"/>
                    </p>
                    <p>
                    <label for="presenter">Presenter</label>
                    <input name="presenter" id="presenter" type="text"/>
                    </p>
                    <p>
                        <select name="date" id="date">
                            <option value="">Any Date</option>
                            <c:forEach items="${ dates }" var="date">
                                <option value="${ date.key }">${ date.value }</option>
                            </c:forEach>
                        </select>
                    </p>
                    <p>
                        <select name="level" id="level">
                            <option value="">Any Level</option>
                            <c:forEach items="${ levels }" var="level">
                                <option>${ level }</option>
                            </c:forEach>
                        </select>
                    </p>
                    <p>
                        <select name="type" id="type">
                            <option value="">Any Type</option>
                            <c:forEach items="${ types }" var="type">
                                <option>${ type }</option>
                            </c:forEach>
                        </select>
                    </p>
                    <p>
                        <select name="track" id="track">
                            <option value="">Any Track</option>
                            <c:forEach items="${ tracks }" var="track">
                                <option>${ track }</option>
                            </c:forEach>
                        </select>
                    </p>
                </div>
                <div data-role="fieldcontain">
                    <input type="submit" value="Search"/>
                </div>
            </form>
        </div>
    </div>
        
    <div class="session-details" style="display:none">
        <div data-role="header" class="fl-widget-titlebar titlebar portlet-titlebar">
            <a data-role="button" data-icon="back" data-inline="true" href="javascript:;" class="details-back-button">Back</a>
            <h2 class="title">Details</h2>
        </div>
        <div data-role="content" class="portlet-content">
            <h3>
                <c:if test="${ authenticated }">
                    <a href="javascript:;" class="add-session-link"><img src="<c:url value="/images/bookmark-unselected.png"/>"/></a>
                    <a href="javascript:;" class="remove-session-link"><img src="<c:url value="/images/bookmark-selected.png"/>"/></a>
                </c:if>
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
