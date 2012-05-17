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
package org.jasig.portlet.conference.program.dao;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.codehaus.jackson.map.ObjectMapper;
import org.jasig.portlet.conference.program.model.ConferenceProgram;
import org.jasig.portlet.conference.program.model.ConferenceSession;
import org.joda.time.DateMidnight;
import org.joda.time.format.DateTimeFormatter;
import org.joda.time.format.DateTimeFormatterBuilder;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.core.io.ClassPathResource;

public class ConferenceSessionDao implements InitializingBean {
    
    private ConferenceProgram program;

    public ConferenceProgram getProgram() {
        return this.program;
    }
    
    public void setProgram(ConferenceProgram program) {
        this.program = program;
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        this.program = mapper.readValue(new ClassPathResource("/program.json").getInputStream(), ConferenceProgram.class);
    }
    
    public List<String> getTracks() {
        final List<String> tracks = new ArrayList<String>();
        for (final ConferenceSession session : this.program.getSessions()) {
            final String value = session.getTrack();
            if (shouldAddToList(value, tracks)) {
                tracks.add(session.getTrack());
            }
        }
        Collections.sort(tracks);
        return tracks;
    }
    
    public List<String> getTypes() {
        final List<String> types = new ArrayList<String>();
        for (final ConferenceSession session : this.program.getSessions()) {
            final String value = session.getType();
            if (shouldAddToList(value, types)) {
                types.add(session.getType());
            }
        }
        Collections.sort(types);
        return types;
    }
    
    public List<String> getLevels() {
        final List<String> levels = new ArrayList<String>();
        for (final ConferenceSession session : this.program.getSessions()) {
            final String value = session.getLevel();
            if (shouldAddToList(value, levels)) {
                levels.add(session.getLevel());
            }
        }
        Collections.sort(levels);
        return levels;
    }
    
    public LinkedHashMap<String, String> getDates() {
        final List<DateMidnight> dates = new ArrayList<DateMidnight>();
        
        final DateTimeFormatter providedDF = new DateTimeFormatterBuilder().appendPattern("dd-MMM-yyyy").toFormatter();
        final DateTimeFormatter displayDF = new DateTimeFormatterBuilder().appendPattern("EEE MMMM d").toFormatter();
        
        for (ConferenceSession session : this.program.getSessions()) {
            final String value = session.getDate();
            final DateMidnight date = providedDF.parseDateTime(value).toDateMidnight();
            if (!dates.contains(date)) {
                dates.add(date);
            }
        }
        Collections.sort(dates);
        
        LinkedHashMap<String, String> dateMap = new LinkedHashMap<String, String>();
        for (DateMidnight date : dates) {
            dateMap.put(providedDF.print(date), displayDF.print(date));
        }
        
        return dateMap;
    }
    
    protected boolean shouldAddToList(final String value, final List<String> list) {
        return (!list.contains(value) && !StringUtils.isBlank(value) && !"Unknown".equals(value));
    }
    
}
