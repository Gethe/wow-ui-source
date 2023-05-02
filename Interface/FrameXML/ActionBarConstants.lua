MAIN_MENU_BAR_NUM_BUTTONS = 12; 
MAIN_MENU_BAR_ADD_BUTTONS_TO_RIGHT = true; 
MULTI_BAR_BOTTOM_LEFT_NUM_BUTTONS = 12; 
MULTI_BAR_BOTTOM_RIGHT_NUM_BUTTONS = 12; 
ACTION_BARS_USE_DEFAULT_ANCHORS = false; 

function IsMultibarVisible(index) 
	if(index == 1) then 
		return Settings.GetValue("PROXY_SHOW_ACTIONBAR_2"); 
	elseif(index == 2) then 
		return Settings.GetValue("PROXY_SHOW_ACTIONBAR_3"); 
	elseif(index == 3) then 
		return Settings.GetValue("PROXY_SHOW_ACTIONBAR_4"); 
	elseif(index == 4) then 
		return Settings.GetValue("PROXY_SHOW_ACTIONBAR_5"); 
	elseif(index == 5) then 
		return Settings.GetValue("PROXY_SHOW_ACTIONBAR_6"); 
	elseif(index == 6) then 
		return Settings.GetValue("PROXY_SHOW_ACTIONBAR_7"); 
	elseif(index == 7) then 
		return Settings.GetValue("PROXY_SHOW_ACTIONBAR_8"); 
	end		
end		

DISABLE_MAP_ZOOM = false; 

