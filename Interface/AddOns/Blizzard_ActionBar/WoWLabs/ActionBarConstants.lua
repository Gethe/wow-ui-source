MAIN_MENU_BAR_NUM_BUTTONS = 2; 
MAIN_MENU_BAR_ADD_BUTTONS_TO_LEFT = true; 
MAIN_MENU_BAR_HIDE_END_CAPS = true; 
ACTION_BARS_USE_DEFAULT_ANCHORS = true; 

MULTI_BAR_BOTTOM_LEFT_NUM_BUTTONS = 2; 
MULTI_BAR_BOTTOM_RIGHT_NUM_BUTTONS = 2; 

function IsMultibarVisible(index) 
	if(index == 1) then 
		return true;
	elseif(index == 2) then 
		return true;
	elseif(index == 3) then 
		return false; 
	elseif(index == 4) then 
		return false; 
	elseif(index == 5) then 
		return false; 
	elseif(index == 6) then 
		return false; 
	elseif(index == 7) then 
		return false;
	end		
end	

DISABLE_MAP_ZOOM = false; 