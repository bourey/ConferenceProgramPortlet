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

package org.jasig.portlet.conference.program.mvc.portlet;

import java.io.IOException;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.portlet.PortletPreferences;
import javax.portlet.PortletRequest;
import javax.portlet.ReadOnlyException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.ValidatorException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jasig.portlet.conference.program.dao.ConferenceSessionDao;
import org.jasig.portlet.conference.program.mvc.IViewSelector;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.portlet.ModelAndView;
import org.springframework.web.portlet.bind.annotation.ActionMapping;
import org.springframework.web.portlet.bind.annotation.RenderMapping;
import org.springframework.web.portlet.bind.annotation.ResourceMapping;

/**
 * Main portlet view.
 */
@Controller
@RequestMapping("VIEW")
public class MainController {

    protected final Log logger = LogFactory.getLog(getClass());
    
    private IViewSelector viewSelector;
    
    @Autowired(required = true)
    public void setViewSelector(IViewSelector viewSelector) {
        this.viewSelector = viewSelector;
    }
    
    private ConferenceSessionDao dao;
    
    @Autowired(required = true)
    public void setConferenceSessionDao(ConferenceSessionDao dao) {
        this.dao = dao;
    }
    
    @RenderMapping
    public ModelAndView showMainView(
            final RenderRequest request, final RenderResponse response) {

        // determine if the request represents a mobile browser and set the
        // view name accordingly
        final boolean isMobile = viewSelector.isMobile(request);
        final String viewName = isMobile ? "main-jQM" : "main";
        final ModelAndView mav = new ModelAndView(viewName);
        
        if(logger.isDebugEnabled()) {
            logger.debug("Using view name " + viewName + " for main view");
        }
        
        final Map<String,String> dates = dao.getDates();
        
        
        mav.addObject("dates", dates);
        mav.addObject("tracks", dao.getTracks());
        mav.addObject("types", dao.getTypes());
        mav.addObject("levels", dao.getLevels());

        PortletPreferences preferences = request.getPreferences();
        mav.addObject("mysessions", preferences.getValues("mysessions", new String[]{}));
        mav.addObject("hash", dao.getProgram().hashCode());

        if(logger.isDebugEnabled()) {
            logger.debug("Rendering main view");
        }

        return mav;

    }
    
    @ResourceMapping
    public ModelAndView updateSessions(PortletRequest request, @RequestParam String title, @RequestParam boolean add)  throws ReadOnlyException, ValidatorException, IOException {
        PortletPreferences preferences = request.getPreferences();
        String[] sessions = preferences.getValues("mysessions", new String[]{});
        
        Set<String> mine = new HashSet<String>();
        for (String session : sessions) {
            mine.add(session);
        }
        if (add) {
            mine.add(title);
        } else {
            mine.remove(title);
        }
        preferences.setValues("mysessions", mine.toArray(new String[]{}));
        
        preferences.store();
        
        return new ModelAndView("json");
    }
    
    @ActionMapping
    public void doAction() {
        // no-op action mapping to prevent accidental calls to this URL from
        // crashing the portlet
    }

}
