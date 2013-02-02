
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
	ReforgingFrame.RestoreMessage:SetShadowOffset(0, 0);
	
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
			self.FinishedGlow.ReforgeAnim:Play();
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
	ReforgingFrame.ReceiptBG:Hide();
	ReforgingFrame.RestoreMessage:Hide();
	ReforgingFrame.Lines:Show();
	
	local currentReforge, icon, name, quality, bound, cost = GetReforgeItemInfo();
	if icon then
		ReforgingFrame.ItemButton.IconTexture:SetTexture(icon);
		ReforgingFrame.ItemButton.IconTexture:SetTexCoord( 0, 1, 0, 1);
		local _, _, _, hex = GetItemQualityColor(quality);
		ReforgingFrame.ItemButton.ItemName:SetText("|c"..hex..name.."|r");
		ReforgingFrame.ItemButton.BoundStatus:SetText(bound);
		ReforgingFrame.ItemButton.MissingText:Hide();
		ReforgingFrame.MissingDescription:Hide();
		ReforgingFrame.MissingFadeOut:Hide();
		ReforgingFrame.HorzBar:Show();
		ReforgingFrame.TitleTextLeft:Show();
		ReforgingFrame.TitleTextRight:Show();
		
		
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
			ReforgingFrame.ReceiptBG:Show();
			ReforgingFrame.RestoreMessage:Show();
			ReforgingFrame.Lines:Hide();
			MoneyFrame_Update(ReforgingFrameMoneyFrame, 0);
			ReforgingFrameRestoreButton:Enable();
			ReforgingFrame.TitleTextRight:SetText(REFORGE_RESTORE);
			HideStats();
			
			local index = 1;
			for i=1,#stats,3 do
				leftStat , rightStat = ReforgingFrame_GetStatRow(index, true);
				if not leftStat then
					break;
				end
				
				rightStat:Show();
				leftStat:Show();
				rightStat.Button:Hide();
				leftStat.Button:Hide();
				local name, statID, statValue = stats[i], stats[i+1], stats[i+2];
				if statID == ReforgingFrame.srcStat then --this stat will be restored
					rightStat.Text:SetText(GREEN_FONT_COLOR_CODE.."+"..statValue.." ".. name);
					leftStat.Text:SetText(RED_FONT_COLOR_CODE.."+"..(statValue-ReforgingFrame.srcValue).." "..name.." ("..statValue..")");
				else
					rightStat.Text:SetText("+"..statValue.." ".. name);
					leftStat.Text:SetText("+"..statValue.." "..name);
				end
				index = index+1;
			end
			
			leftStat , _ = ReforgingFrame_GetStatRow(bonusStatIndex, true);
			if leftStat then
				leftStat:Show();
				leftStat.Button:Hide();
				leftStat.Text:SetText(GREEN_FONT_COLOR_CODE.."+"..ReforgingFrame.destValue.." ".. ReforgingFrame.destName);
			end
			
		else --no current reforge 
			MoneyFrame_Update(ReforgingFrameMoneyFrame, cost);
			local enoughMoney = GetMoney() >=  cost;
			if enoughMoney then
				SetMoneyFrameColor("ReforgingFrameMoneyFrame", "white");
			else
				SetMoneyFrameColor("ReforgingFrameMoneyFrame", "red");
			end
			ReforgingFrame.TitleTextRight:SetText(REFORGE);
			
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
		ReforgingFrame.ItemButton.IconTexture:SetTexture("Interface\\BUTTONS\\UI-Slot-Background");
		ReforgingFrame.ItemButton.IconTexture:SetTexCoord( 0, 0.640625, 0, 0.640625);
		ReforgingFrame.ItemButton.ItemName:SetText("");
		ReforgingFrame.ItemButton.BoundStatus:SetText("");
		ReforgingFrame.ItemButton.MissingText:Show();
		ReforgingFrame.MissingDescription:Show();
		ReforgingFrame.HorzBar:Hide();
		MoneyFrame_Update(ReforgingFrameMoneyFrame, 0);
		ReforgingFrame.TitleTextLeft:Hide();
		ReforgingFrame.TitleTextRight:Hide();
		ReforgingFrame.MissingFadeOut:Show();
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
	leftStat = ReforgingFrame.LeftStat[index];
	rightStat = ReforgingFrame.RightStat[index];
	if tryAdd and not leftStat then
		if index > REFORGE_MAX_STATS_SHOWN  then
			return;
		end
		leftStat = CreateFrame("CHECKBUTTON", nil, ReforgingFrame, "ReforgingStatTemplate");
		leftStat:SetPoint("TOP",  ReforgingFrame.LeftStat[index-1], "BOTTOM", 0, -1);
		rightStat = CreateFrame("CHECKBUTTON", nil, ReforgingFrame, "ReforgingStatTemplate");
		rightStat:SetPoint("TOP",  ReforgingFrame.RightStat[index-1], "BOTTOM", 0, -1);
		if mod(index, 2) == 0 then
			leftStat.BG:Show();
			rightStat.BG:Show();
		end
		leftStat:Hide();
		rightStat:Hide();
		ReforgingFrame.LeftStat[index] = leftStat;
		ReforgingFrame.RightStat[index] = rightStat;
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
			self.Button.DisableTex:Hide();
			self.Button.NormalTex:Show();
			self.Button.CheckedTex:Show();
		else
			self.Button.DisableTex:Hide();
			self.Button.NormalTex:Show();
			self.Button.CheckedTex:Hide();
		end
	end
end

function Stat_OnClick(self)
	if (not self.Button:IsShown()) then
		Stat_SetButtonChecked(self, false);
		return;
	end

	if (self.isOld) then -- current stat was selected
		local name, stat, value, currValue = self.info[1], self.info[2], self.info[3], self.info[4];
		
		if (not self:GetChecked()) then
			ReforgingFrame.srcStat = nil;
			ReforgingFrame.srcValue = nil;
			self.Text:SetText("+"..currValue.." "..name);
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
					leftStat.Text:SetText("+"..lcurrValue.." "..lname);
				end
			end
			if (rightStat:IsShown() and rightStat:GetChecked()) then
				rightSelected = rightStat;
			end
			index = index + 1;
			leftStat, rightStat = ReforgingFrame_GetStatRow(index, false);
		end
		
		self.Text:SetText(RED_FONT_COLOR_CODE.."+"..(currValue-value).." "..name.." ("..currValue..")");
		
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
			self.Text:SetText("+"..value.." "..name);
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
				rightStat.Text:SetText("+"..rvalue.." "..rname);
			end
			index = index + 1;
			_, rightStat = ReforgingFrame_GetStatRow(index, false);
		end
		
		self.Text:SetText(GREEN_FONT_COLOR_CODE.."+"..value.." "..name);
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
		leftStat = ReforgingFrame_GetStatRow(index, true);
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
			leftStat.Button:Show();
			if (not newStatsSet) then
				ReforgeFrame_NewStat_Initialize(true, stat, value);
				newStatsSet = true;
			end
		else
			leftStat.Button:Hide();
		end

		leftStat.reforgable = reforgable;
		leftStat.Text:SetText("+"..currValue.." "..name);
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
	local _, rightStat;
	
	for i=1,#stats,4 do
		_, rightStat = ReforgingFrame_GetStatRow(index, true);
		local name, stat, value, reforgeID = stats[i], stats[i+1], stats[i+2], stats[i+3];
		if (noneSelected) then
			rightStat.Text:SetText(GRAY_FONT_COLOR_CODE.."+0"..FONT_COLOR_CODE_CLOSE.." "..name);
			rightStat:Disable();
			rightStat.Button:SetAlpha(.5)
		else
			rightStat.Text:SetText("+"..ReforgingFrame.srcValue.." "..name);
			rightStat:Enable();
			rightStat.Button:SetAlpha(1)
		end
		rightStat.info = {name, stat, value, reforgeID};
		rightStat.Button:Show();
		Stat_SetButtonChecked(rightStat, false);
		rightStat:Show();
		
		index = index + 1;
	end
end 

