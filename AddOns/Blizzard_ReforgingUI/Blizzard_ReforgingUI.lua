
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

	ReforgingFrameTopTileStreaks:Hide();
	ReforgingFrameTitleBg:SetDrawLayer("BACKGROUND", -1);
	ReforgingFrameTitleText:SetText(REFORGE);	
	ReforgingFrameBg:Hide();
	ReforgingFrameRestoreMessage:SetShadowOffset(0, 0);
	
	MoneyFrame_SetMaxDisplayWidth(ReforgingFrameMoneyFrame, 168);
	MoneyFrame_SetType(ReforgingFrameMoneyFrame, "REFORGE");
end


function ReforgingFrame_OnShow(self)
	PlaySound("UI_EtherealWindow_Open");
	ReforgingFrame_Update(self);
end


function ReforgingFrame_OnHide(self)
	PlaySound("UI_EtherealWindow_Close");
	CloseReforge();
end


function ReforgingFrame_OnEvent(self, event, ...)
	if event == "FORGE_MASTER_SET_ITEM" then
		ReforgingFrame.srcStat = nil;
		ReforgingFrame.srcValue = nil;
		ReforgingFrame.destStat = nil;
		ReforgingFrame.destValue = nil;
		ReforgeFrame_OldStat_Initialize();
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
			self.glow.reforgeAnim:Play();
		end
	end
end


function ReforgingFrame_OnFinishedAnim(self)
	ReforgingFrame.srcStat = nil;
	ReforgingFrame.srcValue = nil;
	ReforgingFrame.destStat = nil;
	ReforgingFrame.destValue = nil;
	ReforgeFrame_OldStat_Initialize();
	ReforgingFrame_Update(self);
end


function ReforgingFrame_Update(self)
	CloseDropDownMenus();
	ReforgingFrameRestoreButton:Disable();
	ReforgingFrameReforgeButton:Disable();
	ReforgingFrameReceiptBG:Hide();
	ReforgingFrameRestoreMessage:Hide();
	ReforgingFrameLines:Show();
	
	local currentReforge, icon, name, quality, bound, cost = GetReforgeItemInfo();
	if icon then
		ReforgingFrameItemButtonIconTexture:SetTexture(icon);
		ReforgingFrameItemButtonIconTexture:SetTexCoord( 0, 1, 0, 1);
		local _, _, _, hex = GetItemQualityColor(quality);
		ReforgingFrameItemButton.name:SetText("|c"..hex..name.."|r");
		ReforgingFrameItemButton.boundStatus:SetText(bound);
		ReforgingFrameItemButton.missingText:Hide();
		ReforgingFrame.missingDescription:Hide();
		ReforgingFrameMissingFadeOut:Hide();
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
		
		if restoreMode then
			ReforgingFrameReceiptBG:Show();
			ReforgingFrameRestoreMessage:Show();
			ReforgingFrameLines:Hide();
			MoneyFrame_Update(ReforgingFrameMoneyFrame, 0);
			ReforgingFrameRestoreButton:Enable();
			ReforgingFrameTitleTextRight:SetText(REFORGE_RESTORE);
			HideStats();
			
			local index = 1;
			for i=1,#stats,3 do
				leftStat , rightStat = ReforgingFrame_GetStatRow(index, true);
				if not leftStat then
					break;
				end
				
				rightStat:Show();
				leftStat:Show();
				rightStat.button:Hide();
				leftStat.button:Hide();
				local name, statID, statValue = stats[i], stats[i+1], stats[i+2];
				if statID == ReforgingFrame.srcStat then --this stat will be restored
					rightStat.text:SetText(GREEN_FONT_COLOR_CODE.."+"..statValue.." ".. name);
					leftStat.text:SetText(RED_FONT_COLOR_CODE.."+"..(statValue-ReforgingFrame.srcValue).." "..name.." ("..statValue..")");
				else
					rightStat.text:SetText("+"..statValue.." ".. name);
					leftStat.text:SetText("+"..statValue.." "..name);
				end
				index = index+1;
			end
			
			leftStat , _ = ReforgingFrame_GetStatRow(bonusStatIndex, true);
			if leftStat then
				leftStat:Show();
				leftStat.button:Hide();
				leftStat.text:SetText(GREEN_FONT_COLOR_CODE.."+"..ReforgingFrame.destValue.." ".. ReforgingFrame.destName);
			end
			
		else --no current reforge 
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
				--_ , rightStat = ReforgingFrame_GetStatRow(bonusStatIndex, true);
				--if rightStat then	
				--	rightStat:Show();
				--end
			end
		end
		
	else  -- There is no item so hide elements
		ReforgingFrameItemButtonIconTexture:SetTexture("Interface\\BUTTONS\\UI-Slot-Background");
		ReforgingFrameItemButtonIconTexture:SetTexCoord( 0, 0.640625, 0, 0.640625);
		ReforgingFrameItemButton.name:SetText("");
		ReforgingFrameItemButton.boundStatus:SetText("");
		ReforgingFrameItemButton.missingText:Show();
		ReforgingFrame.missingDescription:Show();
		ReforgingFrameHorzBar:Hide();
		MoneyFrame_Update(ReforgingFrameMoneyFrame, 0);
		ReforgingFrameTitleTextLeft:Hide();
		ReforgingFrameTitleTextRight:Hide();
		ReforgingFrameMissingFadeOut:Show();
		HideStats();
	end
end


function HideStats()
	local index = 1;
	local leftStat , rightStat = ReforgingFrame_GetStatRow(index);
	while leftStat and rightStat do -- this should always be syncd
		leftStat:Hide();
		rightStat:Hide();
		index  = index + 1;
		leftStat , rightStat = ReforgingFrame_GetStatRow(index);
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
		leftStat = CreateFrame("CHECKBUTTON", "ReforgingFrameLeftStat"..index, ReforgingFrame, "ReforgingStatTemplate");
		leftStat:SetPoint("TOP",  _G["ReforgingFrameLeftStat"..(index-1)], "BOTTOM", 0, -1);
		rightStat = CreateFrame("CHECKBUTTON", "ReforgingFrameRightStat"..index, ReforgingFrame, "ReforgingStatTemplate");
		rightStat:SetPoint("TOP",  _G["ReforgingFrameRightStat"..(index-1)], "BOTTOM", 0, -1);
		if mod(index, 2) == 0 then
			leftStat.Bg:Show();
			rightStat.Bg:Show();
		end
		leftStat:Hide();
		rightStat:Hide();
	end
	return leftStat, rightStat;
end

-----------------------------------------------------------
------------- Stat Changing Goodness ----------------------
-----------------------------------------------------------
function Stat_SetButtonChecked(self, checked)
	self:SetChecked(checked);
	if ( self:IsEnabled() ) then
		if (checked) then
			self.button.disableTex:Hide();
			self.button.normalTex:Show();
			self.button.checkedTex:Show();
		else
			self.button.disableTex:Hide();
			self.button.normalTex:Show();
			self.button.checkedTex:Hide();
		end
	end
end

function Stat_OnClick(self)
	if (not self.button:IsShown()) then
		Stat_SetButtonChecked(self, false);
		return;
	end

	if (self.isOld) then -- current stat was selected
		local name, stat, value, currValue = self.info[1], self.info[2], self.info[3], self.info[4];
		
		if (not self:GetChecked()) then
			ReforgingFrame.srcStat = nil;
			ReforgingFrame.srcValue = nil;
			self.text:SetText("+"..currValue.." "..name);
			ReforgeFrame_NewStat_Initialize(true, stat, value);
			ReforgingFrame_Update(ReforgingFrame);
			return;
		end
			
		ReforgingFrame.srcStat = stat;
		ReforgingFrame.srcValue = value;
		ReforgingFrame.destStat = nil;
		ReforgingFrame.destValue = nil;
		
		local index = 1;
		local leftStat, rightStat = ReforgingFrame_GetStatRow(index, false);
		local rightSelected = nil;
		while (leftStat and rightStat) do
			if (leftStat:IsShown()) then 
				local lname, lstat, lcurrValue = leftStat.info[1], leftStat.info[2], leftStat.info[4]
				if  (lstat ~= stat) then
					Stat_SetButtonChecked(leftStat, false);
					leftStat.text:SetText("+"..lcurrValue.." "..lname);
				end
			end
			if (rightStat:IsShown() and rightStat:GetChecked()) then
				rightSelected = rightStat;
			end
			index = index + 1;
			leftStat, rightStat = ReforgingFrame_GetStatRow(index, false);
		end
		
		self.text:SetText(RED_FONT_COLOR_CODE.."+"..(currValue-value).." "..name.." ("..currValue..")");
		
		ReforgeFrame_NewStat_Initialize()
		-- if they already had a reforge stat selected, keep it selected
		if (rightSelected) then
			Stat_SetButtonChecked(rightSelected, true);
			rightSelected:Click();
		end
	else -- reforge stat was selected
		
		if (not ReforgingFrame.srcStat) then
			Stat_SetButtonChecked(self, false);
			return;
		end
	
		local name, stat, value, reforgeID = self.info[1], self.info[2], self.info[3], self.info[4];
		
		if (not self:GetChecked()) then
			ReforgingFrame.destStat = nil;
			ReforgingFrame.destValue = nil;
			ReforgingFrame.destName = nil;
			ReforgingFrame.reforgeID = nil;
			self.text:SetText("+"..value.." "..name);
			ReforgingFrame_Update(ReforgingFrame);
			return;
		end
		
		ReforgingFrame.destStat = stat;
		ReforgingFrame.destValue = value;
		ReforgingFrame.destName = name;
		ReforgingFrame.reforgeID = reforgeID;
		
		local index = 1;
		local _, rightStat = ReforgingFrame_GetStatRow(index, false);
		while (rightStat and rightStat:IsShown()) do
			local rname, rstat, rvalue = rightStat.info[1], rightStat.info[2], rightStat.info[3]
			if  (rstat ~= stat) then
				Stat_SetButtonChecked(rightStat, false);
				rightStat.text:SetText("+"..rvalue.." "..rname);
			end
			index = index + 1;
			_, rightStat = ReforgingFrame_GetStatRow(index, false);
		end
		
		self.text:SetText(GREEN_FONT_COLOR_CODE.."+"..value.." "..name);
	end
	ReforgingFrame_Update(ReforgingFrame);
end



function ReforgeFrame_OldStat_Initialize()
	
	HideStats();
	local stats = {GetReforgeItemStats()};
	local reforgeStats = {GetSourceReforgeStats()};
	local index = 1;
	local leftStat;
	local newStatsSet = false;
	local numReforgable = 0;
	local lastStat = nil;
	
	for i=1,#stats,3 do
		leftStat, _ = ReforgingFrame_GetStatRow(index, true);
		local name, stat, value = stats[i], stats[i+1], stats[i+2];
		local currValue = value;
		local reforgable;
		for j=1, #reforgeStats, 3 do
			local rname, rstat, rvalue = reforgeStats[j], reforgeStats[j+1], reforgeStats[j+2];
			if (rstat == stat) then
				reforgable = true;
				value = rvalue;
				numReforgable = numReforgable + 1;
				lastStat = leftStat;
			end
		end
		
		if (reforgable) then
			leftStat.button:Show();
			if (not newStatsSet) then
				ReforgeFrame_NewStat_Initialize(true, stat, value);
				newStatsSet = true;
			end
		else
			leftStat.button:Hide();
		end

		leftStat.reforgable = reforgable;
		leftStat.text:SetText("+"..currValue.." "..name);
		leftStat.info = {name, stat, value, currValue};
		leftStat.isOld = true;
		leftStat:Show();
		
		index = index + 1;
	end
	
	-- if there is only one reforgable stat, select it automatically
	if (numReforgable == 1) then
		lastStat:Click();
	end
end 


--[[
Reset the possible reforge stats
noneSelected flag is true if a stat to reduce hasn't been selected yet, meaning 
we want to show the reforge stat names, but not the value you could add
]]
function ReforgeFrame_NewStat_Initialize(noneSelected, stat, value)

	if not noneSelected and (not ReforgingFrame.srcStat or not ReforgingFrame.srcValue) then
		return
	end
	
	local stats;
	if (noneSelected) then
		stats = {GetDestinationReforgeStats(stat, value)};
	else
		stats = {GetDestinationReforgeStats(ReforgingFrame.srcStat, ReforgingFrame.srcValue)};
	end
	
	ReforgingFrame.destStat = nil;
	ReforgingFrame.destValue = nil;
	ReforgingFrame.destName = nil;
	ReforgingFrame.reforgeID = nil;
	local index = 1;
	local rightStat;
	
	for i=1,#stats,4 do
		_, rightStat = ReforgingFrame_GetStatRow(index, true);
		local name, stat, value, reforgeID = stats[i], stats[i+1], stats[i+2], stats[i+3];
		if (noneSelected) then
			rightStat.text:SetText(GRAY_FONT_COLOR_CODE.."+0"..FONT_COLOR_CODE_CLOSE.." "..name);
			rightStat:Disable();
			rightStat.button:SetAlpha(.5)
		else
			rightStat.text:SetText("+"..ReforgingFrame.srcValue.." "..name);
			rightStat:Enable();
			rightStat.button:SetAlpha(1)
		end
		rightStat.info = {name, stat, value, reforgeID};
		rightStat.button:Show();
		Stat_SetButtonChecked(rightStat, false);
		rightStat:Show();
		
		index = index + 1;
	end
end 

