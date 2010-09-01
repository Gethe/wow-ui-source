VideoOptionsTooltip = GameTooltip;
VideoOptionsDropDownMenu_Initialize =UIDropDownMenu_Initialize;
VideoOptionsDropDownMenu_GetSelectedID = UIDropDownMenu_GetSelectedID;
VideoOptionsDropDownMenu_SetSelectedID = UIDropDownMenu_SetSelectedID;
VideoOptionsDropDownMenu_SetSelectedValue = UIDropDownMenu_SetSelectedValue;
VideoOptionsDropDownMenu_DisableDropDown = UIDropDownMenu_DisableDropDown;
VideoOptionsDropDownMenu_EnableDropDown = UIDropDownMenu_EnableDropDown;

VideoOptionsDropDownMenu_SetText = 
	function(text, frame)
		return UIDropDownMenu_SetText(frame, text);
	end
VideoOptionsDropDownMenu_SetWidth = 
	function(width, frame)
		return UIDropDownMenu_SetWidth(frame, width);
	end
VideoOptionsDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo;
VideoOptionsDropDownMenu_AddButton = UIDropDownMenu_AddButton;
function InGlue()
	return false;
end

