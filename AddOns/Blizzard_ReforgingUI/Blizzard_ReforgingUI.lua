
REFORGE_MAX_STATS_SHOWN = 8;

UIPanelWindows["ReforgingFrame"] = { area = "left", pushable = 0};




function ReforgingFrame_Show()
	ShowUIPanel(ReforgingFrame);
	if ( not ReforgingFrame:IsShown() ) then
		CloseReforge();
	end
end

function ReforgingFrame_Hide()
	HideUIPanel(ReforgingFrame);
end


function ReforgingFrame_OnLoad(self)
	self:RegisterEvent("FORGE_MASTER_SET_ITEM");
	self:RegisterEvent("FORGE_MASTER_ITEM_CHANGED");
	SetPortraitToTexture(ReforgingFramePortrait, "Interface\\Reforging\\Reforge-Portrait");
	UIDropDownMenu_SetWidth(ReforgingFrameFilterOldStat, 135);
	UIDropDownMenu_SetWidth(ReforgingFrameFilterNewStat, 135);
	UIDropDownMenu_JustifyText(ReforgingFrameFilterOldStat, "LEFT");
	UIDropDownMenu_JustifyText(ReforgingFrameFilterNewStat, "LEFT");
	ReforgingFrameInset:SetPoint("BOTTOMRIGHT", ReforgingFrameBottomInset, "TOPRIGHT", 0, 4);
	
	ReforgingFrameTitleText:SetText(REFORGE);	
	
	UIDropDownMenu_Initialize(ReforgingFrameFilterOldStat, ReforgeFrame_FilterOldStat_Initialize);
	UIDropDownMenu_Initialize(ReforgingFrameFilterNewStat, ReforgeFrame_FilterNewStat_Initialize);
	MoneyFrame_SetMaxDisplayWidth(ReforgingFrameMoneyFrame, 168);
	MoneyFrame_SetType(ReforgingFrameMoneyFrame, "REFORGE");
end


function ReforgingFrame_OnShow(self)
	ReforgingFrame_Update(self);
end


function ReforgingFrame_OnHide(self)
	CloseReforge();
end


function ReforgingFrame_OnEvent(self, event, ...)
	if event == "FORGE_MASTER_SET_ITEM" then
		UIDropDownMenu_SetText(ReforgingFrameFilterOldStat, REFORGE_OLD_FILTER_TEXT);
		UIDropDownMenu_SetText(ReforgingFrameFilterNewStat, GRAY_FONT_COLOR_CODE..REFORGE_NEW_FILTER_TEXT);
		UIDropDownMenu_DisableDropDown(ReforgingFrameFilterNewStat);
		ReforgingFrameBottomRedText:SetText("");
		ReforgingFrameBottomGreenText:SetText("");
		ReforgingFrame.srcStat = nil;
		ReforgingFrame.srcValue = nil;
		ReforgingFrame.destStat = nil;
		ReforgingFrame.destValue = nil;
		ReforgingFrameBottomGreenBg:Hide();
		ReforgingFrameBottomRedBg:Hide();
		
		ReforgingFrame_Update(self);
	elseif event == "FORGE_MASTER_ITEM_CHANGED" then
		-- this event can trigger from other item changes, like
		-- a temporary enchant expiring
		local reforged = GetReforgeItemInfo();
		if ( reforged ==  ReforgingFrame.reforgeEvent ) then
			ReforgingFrame.reforgeEvent = nil;
			if ( reforged == 0 ) then
				PlaySoundKitID(23292);
			else
				PlaySoundKitID(23291);
			end
			self.topInset.invisButton.glow.reforgeAnim:Play();
		end
	end
end


function ReforgingFrame_OnFinishedAnim(self)
	UIDropDownMenu_SetText(ReforgingFrameFilterOldStat, REFORGE_OLD_FILTER_TEXT);
	UIDropDownMenu_SetText(ReforgingFrameFilterNewStat, GRAY_FONT_COLOR_CODE..REFORGE_NEW_FILTER_TEXT);
	UIDropDownMenu_DisableDropDown(ReforgingFrameFilterNewStat);
	ReforgingFrameBottomRedText:SetText("");
	ReforgingFrameBottomGreenText:SetText("");
	ReforgingFrame.srcStat = nil;
	ReforgingFrame.srcValue = nil;
	ReforgingFrame.destStat = nil;
	ReforgingFrame.destValue = nil;
	ReforgingFrameBottomGreenBg:Hide();
	ReforgingFrameBottomRedBg:Hide();
		
	ReforgingFrame_Update(self);
end


function ReforgingFrame_Update(self)
	CloseDropDownMenus();
	ReforgingFrameRestoreButton:Disable();
	ReforgingFrameReforgeButton:Disable();
	local leftStat = _G["ReforgingFrameLeftStat1"];
	local rightStat = _G["ReforgingFrameRightStat1"];
	local index = 1;
	while leftStat and rightStat do -- this should alwasy be syncd
		leftStat:Hide();
		rightStat:Hide();
		index  = index+1
		leftStat , rightStat = ReforgingFrame_GetStatRow(index);
	end
	ReforgingFrameStatHelpText:Hide();
	
	local currentReforge, icon, name, quality, bound, cost = GetReforgeItemInfo();
	if icon then
		ReforgingFrameItemButtonIconTexture:SetTexture(icon);
		ReforgingFrameItemButtonIconTexture:SetTexCoord( 0, 1, 0, 1);
		local _, _, _, hex = GetItemQualityColor(quality);
		ReforgingFrameItemButton.name:SetText(hex..name);
		ReforgingFrameItemButton.boundStatus:SetText(bound);
		ReforgingFrameItemButton.missingText:Hide();
		ReforgingFrame.missingDescription:Hide();
		ReforgingFrameHorzBar:Show();
		ReforgingFrameTitleTextLeft:Show();
		ReforgingFrameTitleTextRight:Show();
		local stats = {GetReforgeItemStats()};
		local bonusStatIndex = #stats/3 + 1;
		local rightStat, leftStat;
		local restoreMode = false;
		
		if currentReforge ~= 0 then --has a current reforge 
			restoreMode = true;
			ReforgingFrame.srcName, ReforgingFrame.srcStat, ReforgingFrame.srcValue, ReforgingFrame.destName, 
			ReforgingFrame.destStat, ReforgingFrame.destValue = GetReforgeOptionInfo(currentReforge);
		end

		local srcTextColor = NORMAL_FONT_COLOR_CODE;
		local destTextColor = RED_FONT_COLOR_CODE;
		local index = 1;
		for i=1,#stats,3 do
			leftStat , rightStat = ReforgingFrame_GetStatRow(index, true);
			if not leftStat then
				break;
			end
			if restoreMode then
				leftStat , rightStat = rightStat, leftStat;
				srcTextColor = GREEN_FONT_COLOR_CODE;
				destTextColor = GREEN_FONT_COLOR_CODE;
			end
			
			leftStat:Show();
			local name, statID, statValue = stats[i], stats[i+1], stats[i+2];
			if statID == ReforgingFrame.srcStat then
				leftStat.text:SetText(srcTextColor.."+"..statValue.." ".. name);
			else
				leftStat.text:SetText("+"..statValue.." ".. name);
			end
			
			if ReforgingFrame.destStat then
				rightStat:Show();
				if statID == ReforgingFrame.srcStat then
					rightStat.text:SetText(destTextColor.."+"..(statValue-ReforgingFrame.srcValue).." ".. name);
				else
					rightStat.text:SetText("+"..statValue.." ".. name);
				end
			end
			index = index+1;
		end	
		
		if restoreMode then
			ReforgingFrameInset:SetPoint("TOPLEFT", ReforgingFrameTopInset, "BOTTOMLEFT", 0, -3);
			ReforgingFrameFilterOldStat:Hide();
			ReforgingFrameFilterNewStat:Hide();
			MoneyFrame_Update(ReforgingFrameMoneyFrame, 0);
			ReforgingFrameRestoreButton:Enable();
			ReforgingFrameTitleTextRight:SetText(REFORGE_RESTORE);
			leftStat , _ = ReforgingFrame_GetStatRow(bonusStatIndex, true);
			if leftStat then
				leftStat:Show();
				leftStat.text:SetText(RED_FONT_COLOR_CODE.."+"..ReforgingFrame.destValue.." ".. ReforgingFrame.destName);
			end
			ReforgingFrameBottomGreenText:SetText("+"..ReforgingFrame.srcValue.." "..ReforgingFrame.srcName);
			ReforgingFrameBottomRedText:SetText("-"..ReforgingFrame.destValue.." "..ReforgingFrame.destName);
			ReforgingFrameBottomRedBg:Show();
			ReforgingFrameBottomGreenBg:Show();
		else --no current reforge 
			ReforgingFrameInset:SetPoint("TOPLEFT", ReforgingFrameTopInset, "BOTTOMLEFT", 0, -45);
			ReforgingFrameFilterOldStat:Show();
			ReforgingFrameFilterNewStat:Show();
			MoneyFrame_Update(ReforgingFrameMoneyFrame, cost);
			local enoughMoney = GetMoney() >=  cost;
			if enoughMoney then
				SetMoneyFrameColor("ReforgingFrameMoneyFrame", "white");
			else
				SetMoneyFrameColor("ReforgingFrameMoneyFrame", "red");
			end
			ReforgingFrameTitleTextRight:SetText(REFORGE);
			if ReforgingFrame.srcStat and ReforgingFrame.destStat then
				if enoughMoney then
					ReforgingFrameReforgeButton:Enable();
				end
				_ , rightStat = ReforgingFrame_GetStatRow(bonusStatIndex, true);
				if rightStat then	
					rightStat:Show();
					rightStat.text:SetText(GREEN_FONT_COLOR_CODE.."+"..ReforgingFrame.destValue.." ".. ReforgingFrame.destName);
				end
			elseif not ReforgingFrame.destStat then
				ReforgingFrameBottomGreenText:SetText("");
				ReforgingFrameStatHelpText:Show();
			end
		end
		
	else  -- There is no items so hide elements
		ReforgingFrameInset:SetPoint("TOPLEFT", ReforgingFrameTopInset, "BOTTOMLEFT", 0, -3);
		ReforgingFrameItemButtonIconTexture:SetTexture("Interface\\BUTTONS\\UI-Slot-Background");
		ReforgingFrameItemButtonIconTexture:SetTexCoord( 0, 0.640625, 0, 0.640625);
		ReforgingFrameItemButton.name:SetText("");
		ReforgingFrameItemButton.boundStatus:SetText("");
		ReforgingFrameItemButton.missingText:Show();
		ReforgingFrame.missingDescription:Show();
		ReforgingFrameHorzBar:Hide();
		ReforgingFrameFilterOldStat:Hide();
		ReforgingFrameFilterNewStat:Hide();
		MoneyFrame_Update(ReforgingFrameMoneyFrame, 0);
		ReforgingFrameBottomGreenText:SetText("");
		ReforgingFrameBottomRedText:SetText("");
		ReforgingFrameBottomGreenBg:Hide();
		ReforgingFrameBottomRedBg:Hide();
		ReforgingFrameTitleTextLeft:Hide();
		ReforgingFrameTitleTextRight:Hide();
	end
end




function ReforgingFrame_RestoreClick(self)
	ReforgingFrame.reforgeEvent = 0;
	ReforgeItem(0);	
end


function ReforgingFrame_ReforgeClick(self)
	ReforgingFrame.reforgeEvent = ReforgingFrame.reforgeID;
	ReforgeItem(ReforgingFrame.reforgeID);
end


function ReforgingFrame_AddItemClick(self, button)
	SetReforgeFromCursorItem();
	GameTooltip:Hide();
end


function ReforgingFrame_GetStatRow(index, tryAdd)
	local leftStat, rightStat;
	leftStat = _G["ReforgingFrameLeftStat"..index];
	rightStat = _G["ReforgingFrameRightStat"..index];
	if tryAdd and not leftStat then
		if index > REFORGE_MAX_STATS_SHOWN  then
			return;
		end
		leftStat = CreateFrame("FRAME", "ReforgingFrameLeftStat"..index, ReforgingFrame, "ReforgingStatTemplate");
		leftStat:SetPoint("TOP",  _G["ReforgingFrameLeftStat"..(index-1)], "BOTTOM", 0, -1);
		rightStat = CreateFrame("FRAME", "ReforgingFrameRightStat"..index, ReforgingFrame, "ReforgingStatTemplate");
		rightStat:SetPoint("TOP",  _G["ReforgingFrameRightStat"..(index-1)], "BOTTOM", 0, -1);
		if mod(index, 2) == 0 then
			leftStat.Bg:Hide();
			rightStat.Bg:Hide();
		end
		leftStat:Hide();
		rightStat:Hide();
	end
	return leftStat, rightStat;
end


-----------------------------------------------------------
-- Dropdown menu action ----------------------------------
-----------------------------------------------------------

function ReforgeFrame_FilterOldStat_Set(self, arg1)
	local name, stat, value = arg1[1], arg1[2], arg1[3];
	
	ReforgingFrame.srcStat = stat;
	ReforgingFrame.srcValue = value;
	UIDropDownMenu_EnableDropDown(ReforgingFrameFilterNewStat);
	UIDropDownMenu_SetText(ReforgingFrameFilterOldStat, name.."(-"..value..")");
	ReforgingFrame.destStat = nil;
	ReforgingFrame.destValue = nil;
	UIDropDownMenu_SetText(ReforgingFrameFilterNewStat, REFORGE_NEW_FILTER_TEXT);
	ReforgingFrameBottomRedText:SetText("-"..value.." "..name);
	ReforgingFrameBottomRedBg:Show();
	ReforgingFrame_Update(ReforgingFrame);
end



function ReforgeFrame_FilterNewStat_Set(self, arg1)
	local name, stat, value, reforgeID = arg1[1], arg1[2], arg1[3], arg1[4];
												
	ReforgingFrame.destStat = stat;
	ReforgingFrame.destValue = value;
	ReforgingFrame.destName = name;
	ReforgingFrame.reforgeID = reforgeID;
	UIDropDownMenu_SetText(ReforgingFrameFilterNewStat, name.."(+"..value..")");
	ReforgingFrameBottomGreenText:SetText("+"..value.." "..name);		
	ReforgingFrameBottomGreenBg:Show();
	ReforgingFrame_Update(ReforgingFrame);
end



function ReforgeFrame_FilterOldStat_Initialize()

	local stats = {GetSourceReforgeStats()};
	local info = UIDropDownMenu_CreateInfo();
	for i=1,#stats,3 do
		local name, stat, value = stats[i], stats[i+1], stats[i+2];
		info.text = name.."("..value..")";
		info.arg1 = {name, stat, value};
		info.checked = (stat == ReforgingFrame.srcStat);
		info.func = ReforgeFrame_FilterOldStat_Set;
		UIDropDownMenu_AddButton(info);
	end
end 



function ReforgeFrame_FilterNewStat_Initialize()

	if not ReforgingFrame.srcStat or not ReforgingFrame.srcValue then
		return
	end
	
	local stats = {GetDestinationReforgeStats(ReforgingFrame.srcStat, ReforgingFrame.srcValue)};	
	local info = UIDropDownMenu_CreateInfo();
	for i=1,#stats,4 do
		local name, stat, value, reforgeID = stats[i], stats[i+1], stats[i+2], stats[i+3];
		info.text = name.."("..value..")";
		info.arg1 = {name, stat, value, reforgeID};
		info.checked = (stat == ReforgingFrame.destStat);
		info.func = 	ReforgeFrame_FilterNewStat_Set;
		UIDropDownMenu_AddButton(info);
	end
end 

