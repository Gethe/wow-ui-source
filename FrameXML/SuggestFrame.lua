function ToggleSuggestFrame()
	if ( SuggestFrame:IsVisible() ) then
		HideUIPanel(SuggestFrame);
	else
		ShowSuggestFrame("");
	end
end
function ShowSuggestFrame(msg, type) 
	if ( type == "bug" ) then
		SuggestFrameSendBugButton:Enable();
		SuggestFrameSendSuggestButton:Disable();
	elseif ( type == "suggest" ) then
		SuggestFrameSendBugButton:Disable();
		SuggestFrameSendSuggestButton:Enable();
	else
		SuggestFrameSendBugButton:Enable();
		SuggestFrameSendSuggestButton:Enable();
	end
	UIDropDownMenu_SetSelectedID(SuggestFrameCategoryDropDown, 1);
	UIDropDownMenu_SetText(BUG_CATEGORY_CHOOSE, SuggestFrameCategoryDropDown);	
	ShowUIPanel(SuggestFrame);
	SuggestFrameText:SetText(msg);
end
function SuggestFrameCategoryDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, SuggestFrameCategoryDropDown_Initialize);
	UIDropDownMenu_SetWidth(210);
end

function SuggestFrameCategoryDropDown_Initialize()
	local info;
	local count = 1;
	local category = BUG_CATEGORY1;
	info = {};
	info.text = BUG_CATEGORY_CHOOSE;
	UIDropDownMenu_AddButton(info);
	while (category and category ~= "") do
		info = {};
		info.text = category;
		info.func = SuggestFrameCategoryDropDown_OnClick;
		UIDropDownMenu_AddButton(info);

		count = count + 1;
		category = getglobal("BUG_CATEGORY"..count);
	end
end

function SuggestFrameCategoryDropDown_OnClick()
	UIDropDownMenu_SetSelectedName(SuggestFrameCategoryDropDown, this:GetText())
end