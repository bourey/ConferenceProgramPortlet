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

import net.sf.ehcache.Cache;
import net.sf.ehcache.Element;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jasig.portlet.conference.program.model.ConferenceProgram;
import org.jasig.portlet.conference.program.model.ConferenceSession;
import org.joda.time.DateMidnight;
import org.joda.time.format.DateTimeFormatter;
import org.joda.time.format.DateTimeFormatterBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Required;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.client.RestTemplate;

public class ConferenceSessionDao {
    
    protected final String PROGRAM_CACHE_KEY = "program";
    protected final String TRACK_LIST_KEY = "tracks";
    protected final String LEVEL_LIST_KEY = "levels";
    protected final String TYPE_LIST_KEY = "types";
    protected final String DATE_MAP_KEY = "dates";

    
    protected final Log log = LogFactory.getLog(getClass());
    
    private RestTemplate restTemplate;

    @Autowired(required = true)
    public void setRestTemplate(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    private Cache cache;
    
    /**
     * @param cache the cache to set
     */
    @Required
    public void setCache(Cache cache) {
        this.cache = cache;
    }
    
    private String programUrl;
    
    @Value("${programUrl:https://www.concentra-cms.com/cfp/data/json/2012-jasig-sakai/program}")
    public void setProgramUrl(String programUrl) {
        this.programUrl = programUrl;
    }
    
    protected ConferenceProgram retrieveProgram() {
        log.debug("Requesting program data from " + this.programUrl);
        final ConferenceProgram program = restTemplate.getForObject(programUrl,
                ConferenceProgram.class, Collections.<String, String> emptyMap());

        if (program != null) {
            cache.put(new Element(PROGRAM_CACHE_KEY, program));
            
            final List<String> tracks = new ArrayList<String>();
            final List<String> types = new ArrayList<String>();
            final List<String> levels = new ArrayList<String>();
            final List<DateMidnight> dates = new ArrayList<DateMidnight>();
            
            final DateTimeFormatter providedDF = new DateTimeFormatterBuilder().appendPattern("dd-MMM-yyyy").toFormatter();
            final DateTimeFormatter displayDF = new DateTimeFormatterBuilder().appendPattern("EEE MMMM d").toFormatter();
            for (final ConferenceSession session : getProgram().getSessions()) {
                final String track = session.getTrack();
                if (shouldAddToList(track, tracks)) {
                    tracks.add(track);
                }
                
                final String type = session.getType();
                if (shouldAddToList(type, types)) {
                    types.add(type);
                }
                
                final String level = session.getLevel();
                if (shouldAddToList(level, levels)) {
                    levels.add(level);
                }
                
                final String value = session.getDate();
                final DateMidnight date = providedDF.parseDateTime(value).toDateMidnight();
                if (!dates.contains(date)) {
                    dates.add(date);
                }
                
            }
            Collections.sort(tracks);
            Collections.sort(levels);
            Collections.sort(types);
            
            Collections.sort(dates);            
            LinkedHashMap<String, String> dateMap = new LinkedHashMap<String, String>();
            for (DateMidnight date : dates) {
                dateMap.put(providedDF.print(date), displayDF.print(date));
            }

            cache.put(new Element(PROGRAM_CACHE_KEY, program));
            cache.put(new Element(TRACK_LIST_KEY, tracks));
            cache.put(new Element(LEVEL_LIST_KEY, levels));
            cache.put(new Element(TYPE_LIST_KEY, types));
            cache.put(new Element(DATE_MAP_KEY, dateMap));
            
            return program;

        }
        
        return null;
        
    }

    public ConferenceProgram getProgram() {
        final Element cachedProgram = this.cache.get(PROGRAM_CACHE_KEY);
        
        if (cachedProgram != null) {
            log.debug("Retrieving program from cache");
            return (ConferenceProgram) cachedProgram.getValue();
        } 
        
        else {
            return retrieveProgram();
        }
    }
    
    public List<String> getTracks() {
        final Element cached = this.cache.get(TRACK_LIST_KEY);
        if (cached != null) {
            @SuppressWarnings("unchecked")
            final List<String> tracks = (List<String>) cached.getValue();
            return tracks;
        } else {
            return null;
        }
    }
    
    public List<String> getTypes() {
        final Element cached = this.cache.get(TYPE_LIST_KEY);
        if (cached != null) {
            @SuppressWarnings("unchecked")
            final List<String> types = (List<String>) cached.getValue();
            return types;
        } else {
            return null;
        }
    }
    
    public List<String> getLevels() {
        final Element cached = this.cache.get(LEVEL_LIST_KEY);
        if (cached != null) {
            @SuppressWarnings("unchecked")
            final List<String> levels = (List<String>) cached.getValue();
            return levels;
        } else {
            return null;
        }
    }
    
    public LinkedHashMap<String, String> getDates() {
        final Element cached = this.cache.get(DATE_MAP_KEY);
        if (cached != null) {
            @SuppressWarnings("unchecked")
            final LinkedHashMap<String, String> dates = (LinkedHashMap<String, String>) cached.getValue();
            return dates;
        } else {
            return null;
        }
    }
    
    protected boolean shouldAddToList(final String value, final List<String> list) {
        return (!list.contains(value) && !StringUtils.isBlank(value) && !"Unknown".equals(value));
    }
    
}
