/**
 * Licensed to Jasig under one or more contributor license
 * agreements. See the NOTICE file distributed with this work
 * for additional information regarding copyright ownership.
 * Jasig licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a
 * copy of the License at:
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.jasig.portlet.conference.program.model;

import java.io.Serializable;
import java.util.List;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.joda.time.LocalDate;
import org.joda.time.LocalTime;
import org.joda.time.format.DateTimeFormatter;
import org.joda.time.format.DateTimeFormatterBuilder;

public class ConferenceSession implements Serializable {

    final static DateTimeFormatter providedDF = new DateTimeFormatterBuilder().appendPattern("dd-MMM-yyyy").toFormatter();
    final static DateTimeFormatter displayDF = new DateTimeFormatterBuilder().appendPattern("EEE MMMM d").toFormatter();
    
    final static DateTimeFormatter providedTF = new DateTimeFormatterBuilder().appendPattern("h:mm a").toFormatter();
    final static DateTimeFormatter timestampTR = new DateTimeFormatterBuilder().appendPattern("yyyyMMddHHmm").toFormatter();

    private String title;
    private LocalDate date;
    private LocalTime time;
    private String room;
    private String track;
    private String level;
    private String type;
    private List<String> presenters;
    private String details;
    
    public void setTime(String time) {
        this.time = providedTF.parseDateTime(time).toLocalTime();
    }
    
    public void setDate(String date) {
        this.date = providedDF.parseDateTime(date).toLocalDate();
    }
    
    public String getTimestamp() {
        return timestampTR.print(this.date.toLocalDateTime(time));
    }
    
    public String getDate() {
        return providedDF.print(this.date);
    }
    
    public String getDisplayDate() {
        return displayDF.print(this.date);
    }
    
    public String getTime() {
        return providedTF.print(this.time);
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getRoom() {
        return room;
    }

    public void setRoom(String room) {
        this.room = room;
    }

    public String getTrack() {
        return track;
    }

    public void setTrack(String track) {
        this.track = track;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public List<String> getPresenters() {
        return presenters;
    }

    public void setPresenters(List<String> presenters) {
        this.presenters = presenters;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    @Override
    public boolean equals(Object o) {
        
        if (!(o instanceof ConferenceSession)) {
            return false;
        }
        
        final ConferenceSession session = (ConferenceSession) o;
        
        return new EqualsBuilder()
            .append(this.title, session.getTitle())
            .append(this.date, session.getDate())
            .append(this.time, session.getTime())
            .append(this.room, session.getRoom())
            .append(this.track, session.getTrack())
            .append(this.level, session.getLevel())
            .append(this.type, session.getType())
            .append(this.presenters, session.getPresenters())
            .append(this.details, session.getDetails())
            .isEquals();
    }

    @Override
    public int hashCode() {
        return new HashCodeBuilder()
            .append(this.title)
            .append(this.date)
            .append(this.time)
            .append(this.room)
            .append(this.track)
            .append(this.level)
            .append(this.type)
            .append(this.presenters)
            .append(this.details)
            .toHashCode();
    }
    
}
