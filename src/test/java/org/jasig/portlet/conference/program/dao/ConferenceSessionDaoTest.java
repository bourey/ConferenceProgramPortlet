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

import static org.junit.Assert.assertEquals;

import java.io.File;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.jasig.portlet.conference.program.model.ConferenceProgram;
import org.jasig.portlet.conference.program.model.ConferenceSession;
import org.junit.Before;
import org.junit.Test;


public class ConferenceSessionDaoTest {

    ConferenceSessionDao dao = new ConferenceSessionDao();
    List<ConferenceSession> sessions;
    
    @Before
    public void setUp() throws JsonParseException, JsonMappingException, IOException {
        ObjectMapper mapper = new ObjectMapper();
        ConferenceProgram program = mapper.readValue(new File("src/test/resources/program.json"), ConferenceProgram.class);
        dao.setProgram(program);
    }

    @Test
    public void testGetDates() {
        LinkedHashMap<String, String> dates = dao.getDates();
        assertEquals(2, dates.size());
        assertEquals("Sun June 10", dates.get("10-Jun-2012"));
        assertEquals("Mon June 11", dates.get("11-Jun-2012"));
    }
    
    @Test
    public void testGetTracks() {
        List<String> tracks = dao.getTracks();
        assertEquals(2, tracks.size());
        assertEquals("first", tracks.get(0));
        assertEquals("second", tracks.get(1));
    }
    
    @Test
    public void testGetTypes() {
        List<String> types = dao.getTypes();
        assertEquals(2, types.size());
        assertEquals("one", types.get(0));
        assertEquals("two", types.get(1));
    }
    
    @Test
    public void testGetLevels() {
        List<String> levels = dao.getLevels();
        assertEquals(2, levels.size());
        assertEquals("easy", levels.get(0));
        assertEquals("hard", levels.get(1));
    }
    
}
