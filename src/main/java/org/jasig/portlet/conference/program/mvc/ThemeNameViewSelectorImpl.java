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

package org.jasig.portlet.conference.program.mvc;

import javax.portlet.PortletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class ThemeNameViewSelectorImpl implements IViewSelector {
    
    protected static final String THEME_NAME_PROPERTY = "themeName";
    protected static final String MOBILE_THEMES_KEY = "mobileThemes";
    protected static final String[] MOBILE_THEMES_DEFAULT = new String[]{ "UniversalityMobile" };

    protected final Log logger = LogFactory.getLog(getClass());
    
    public boolean isMobile(PortletRequest request) {
        
        String[] mobileThemes = request.getPreferences().getValues(MOBILE_THEMES_KEY, MOBILE_THEMES_DEFAULT);
        String themeName = request.getProperty(THEME_NAME_PROPERTY);
        
        // if no theme name can be found, just assume the request is for a 
        // desktop client
        if (themeName == null) {
            logger.debug("No theme name found, assuming desktop environment");
            return false;
        }

        // otherwise, determine if the theme name matches one of the known 
        // mobile themes
        for (String theme : mobileThemes) {
            if (themeName.equals(theme)) {
                logger.debug("Theme name " + themeName + " matches configured list of mobile themes");
                return true;
            }
        }
        
        logger.debug("No match found for theme name " + themeName + ", assuming desktop environment");
        return false;
    }

}
