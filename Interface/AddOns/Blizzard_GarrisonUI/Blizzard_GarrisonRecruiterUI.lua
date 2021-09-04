
StaticPopupDialogs["CONFIRM_RECRUIT_FOLLOWER"] = {
	text = GARRISON_CONFIRM_RECRUIT_FOLLOWER,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		C_Garrison.RecruitFollower(self.data);
	end,
	timeout = 0,
	hideOnEscape = 1
};

----------------------------------
--- GarrisonRecruiterFrame ---
----------------------------------

function GarrisonRecruiterFrame_OnLoad(self)
	self.Pick.Radio1.Text:SetText(GARRISON_RECRUIT_ABILITY);
	self.Pick.Radio2.Text:SetText(GARRISON_RECRUIT_TRAIT);
	
	GarrisonRecruiterFrame.Pick.Radio1:SetChecked(true);
	self.Pick.entries = {};
	
	self.onCloseCallback = GarrisonRecruiterFrame_OnClickClose;
	self.Pick.categories ={};
	self.categoriesTable = C_Garrison.GetRecruiterAbilityCategories();
	for index, category in pairs(self.categoriesTable)do
		self.Pick.categories[category] = {
			name = category,
			entries = {}
		};
	end
end

function GarrisonRecruiterFrame_OnEvent(self, event, ...)
	if( event == "GARRISON_RECRUITMENT_NPC_CLOSED" ) then
		HideUIPanel(self);
	elseif( event == "GARRISON_RECRUITMENT_READY" ) then
		GarrisonRecruiterFrame_OnShow(self);
	end
end

function GarrisonRecruiterFrame_OnShow(self)
	self:RegisterEvent("GARRISON_RECRUITMENT_NPC_CLOSED");
	self:RegisterEvent("GARRISON_RECRUITMENT_READY");
	SetPortraitTexture(self.PortraitTexture, "npc");
	GarrisonRecruiterFrame.Pick:Hide();
	GarrisonRecruiterFrame.Random:Hide();
	GarrisonRecruiterFrame.UnavailableFrame:Hide();
	local followers = C_Garrison.GetAvailableRecruits();
	if( #followers > 0 )then
		-- display selection screen if we've already generated followers
		self.keepRecruitmentNPCOpen = true;
		HideUIPanel(self);
		GarrisonRecruitSelectFrame_UpdateRecruits(false);
		ShowUIPanel(GarrisonRecruitSelectFrame);
	else
		self.keepRecruitmentNPCOpen = nil;
		GarrisonRecruiterFrame_Show( C_Garrison.CanGenerateRecruits(), C_Garrison.CanSetRecruitmentPreference() );
	end
end

function GarrisonRecruiterFrame_Show( canRecruit, prefAvailable )
	if( canRecruit ) then
		if( prefAvailable )then
			local frame = GarrisonRecruiterFrame.Pick;
			local ability, name, desc, icon, id = C_Garrison.GetRecruitmentPreferences()
			if( name ) then
				if( ability ) then
					frame.Radio1:SetChecked(true);
					frame.Radio2:SetChecked(false);
					GarrisonRecruiterFrame_UpdateAbilityEntries(false);
					frame.Title2:SetText(GARRISON_CHOOSE_THREAT);
				else
					frame.Radio1:SetChecked(false);
					frame.Radio2:SetChecked(true);
					GarrisonRecruiterFrame_UpdateAbilityEntries(true);
					frame.Title2:SetText(GARRISON_CHOOSE_TRAIT);
				end
				GarrisonRecruiterFrame_SetAbilityPreference ({id=id, name=name, description=desc, icon=icon});
			else
				GarrisonRecruiterFrame_UpdateAbilityEntries(frame.Radio2:GetChecked());
				GarrisonRecruiterFrame_SetAbilityPreference (frame.entries[1]);
			end
			frame:Show();
		else
			GarrisonRecruiterFrame.Random:Show();
		end
	else
		GarrisonRecruiterFrame_ShowUnavailableFrame();
	end
end

function GarrisonRecruiterFrame_ShowUnavailableFrame()
	GarrisonRecruiterFrame.UnavailableFrame.Title:SetText(GARRISON_RECRUIT_NEXT_WEEK);	
	GarrisonRecruiterFrame.UnavailableFrame:Show();
end

function GarrisonRecruiterFrame_OnClickClose(self)
	HideUIPanel(GarrisonRecruiterFrame);
end

function GarrisonRecruiterFrame_OnHide(self)
	if( C_Garrison.CanSetRecruitmentPreference() ) then	
		local frame = GarrisonRecruiterFrame.Pick;
		local arg1 = (frame.Radio1:GetChecked() and frame.dropDownValue) or 0;
		local arg2 = (frame.Radio2:GetChecked() and frame.dropDownValue) or 0;
		C_Garrison.SetRecruitmentPreferences(arg1, arg2);
	end
	self:UnregisterEvent("GARRISON_RECRUITMENT_NPC_CLOSED");
	self:UnregisterEvent("GARRISON_RECRUITMENT_READY");
	
	if ( not self.keepRecruitmentNPCOpen ) then
		C_Garrison.CloseRecruitmentNPC();
	else
		self.keepRecruitmentNPCOpen = nil;
	end
end

function GarrisonRecruiterType_OnClick( self )
	CloseDropDownMenus();
	local frame = GarrisonRecruiterFrame.Pick;
	if( self:GetID() == 1 ) then
		frame.Radio1:SetChecked(true);
		frame.Radio2:SetChecked(false);
		GarrisonRecruiterFrame_UpdateAbilityEntries(false);
		frame.Title2:SetText(GARRISON_CHOOSE_THREAT);
	else
		frame.Radio1:SetChecked(false);
		frame.Radio2:SetChecked(true);
		GarrisonRecruiterFrame_UpdateAbilityEntries(true);
		frame.Title2:SetText(GARRISON_CHOOSE_TRAIT);
	end
end

function GarrisonRecruiterFrame_Init(self, level)
	local frame = GarrisonRecruiterFrame.Pick;
	if( level == 1 ) then
		local info = UIDropDownMenu_CreateInfo();
		info.isTitle = nil;
		info.disabled = nil;
		info.tooltipWhileDisabled = nil;
		info.tooltipOnButton = nil;
		info.tooltipTitle = nil;
		info.tooltipText = nil;
		info.hasArrow = true;
		info.notCheckable = true;
		info.func = function() CloseDropDownMenus() end;
		for i, category in pairs(GarrisonRecruiterFrame.categoriesTable) do
			local entry = frame.categories[category];
			if( #entry.entries > 0 ) then
				entry.id = category;
				GarrisonRecruiterFrame_AddEntryToDropdown(entry, info);
			end
		end
		
		info.hasArrow = false;
		info.notCheckable = false;
		info.func = function(self, arg1)
			GarrisonRecruiterFrame_SetAbilityPreference (arg1);
			CloseDropDownMenus();
		end
		for _, entry in pairs(frame.entries) do
			info.arg1 = entry;
			info.tooltipOnButton = 1;
			info.tooltipTitle = entry.name;
			info.tooltipText = entry.description;
			GarrisonRecruiterFrame_AddEntryToDropdown(entry, info);
		end
	
		UIDropDownMenu_SetText(frame.ThreatDropDown, frame.dropDownName);
	else
		local category = frame.categories[UIDROPDOWNMENU_MENU_VALUE];
		if(category)then
			local info = UIDropDownMenu_CreateInfo();
			info.isTitle = nil;
			info.disabled = nil;
			info.tooltipWhileDisabled = nil;
			info.tooltipOnButton = nil;
			info.tooltipTitle = nil;
			info.tooltipText = nil;
			info.func = function(self, arg1)
				GarrisonRecruiterFrame_SetAbilityPreference (arg1);
				CloseDropDownMenus();
			end
			for _, entry in pairs(category.entries) do
				info.arg1 = entry;
				info.tooltipOnButton = 1;
				info.tooltipTitle = entry.name;
				info.tooltipText = entry.description;
				GarrisonRecruiterFrame_AddEntryToDropdown(entry, info, level);
			end
		end
	end
end

function GarrisonRecruiterFrame_GenerateRecruits(ability, trait)
	C_Garrison.GenerateRecruits(ability, trait);
	GarrisonRecruiterFrame.keepRecruitmentNPCOpen = true;
	HideUIPanel(GarrisonRecruiterFrame);
	
	GarrisonRecruitSelectFrame_UpdateRecruits(true);
	ShowUIPanel(GarrisonRecruitSelectFrame);
end

function GarrisonRecruiterFrame_ChooseRecruits()
	local frame = GarrisonRecruiterFrame.Pick;
	local ability = (frame.Radio1:GetChecked() and frame.dropDownValue) or 0;
	local trait = (frame.Radio2:GetChecked() and frame.dropDownValue) or 0;
	GarrisonRecruiterFrame_GenerateRecruits(ability, trait);
end

function GarrisonRecruiterFrame_ChooseRandomRecruits()
	GarrisonRecruiterFrame_GenerateRecruits(0, 0);
end

-- Fetch ability or trait data from client
function GarrisonRecruiterFrame_UpdateAbilityEntries( isTrait )
	local frame = GarrisonRecruiterFrame.Pick;
	C_Garrison.GetRecruiterAbilityList(isTrait, frame.entries);
	for _, category in pairs( frame.categories ) do
		category.entries = {};
	end
	if( isTrait ) then
		-- sort abilities into categories
		local categoryless = {};
		local firstEntry = nil;
		for _, entry in pairs( frame.entries ) do
			if( not firstEntry ) then
				firstEntry = entry;
			end
				
			local category = entry.category;
			if( category and frame.categories[category]) then
				table.insert(frame.categories[category].entries, entry);
			else
				table.insert(categoryless, entry);
			end
		end
		frame.entries = categoryless;
		
		GarrisonRecruiterFrame_SetAbilityPreference(firstEntry)
	else
		GarrisonRecruiterFrame_SetAbilityPreference(frame.entries[1])
	end
end

-- called when setting recruiter ability/trait, but up to the client
function GarrisonRecruiterFrame_SetAbilityPreference(data)
	if( data ) then
		local frame = GarrisonRecruiterFrame.Pick;
		frame.dropDownValue = data.id;
		frame.dropDownName = data.name;
		
		frame.Counter.Title:SetText(data.name);
		frame.Counter.Description:SetText(data.description);
		frame.Counter.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
		frame.Counter.Icon:SetTexture(data.icon);
		
		UIDropDownMenu_SetText(frame.ThreatDropDown, data.name);
	end
end

----------------------------------
--- GarrisonRecruitSelectFrame ---
----------------------------------
function GarrisonRecruitSelectFrame_OnLoad(self)
	self.FollowerList:Initialize(Enum.GarrisonFollowerType.FollowerType_6_0);
	self:RegisterEvent("GARRISON_RECRUIT_FOLLOWER_RESULT");
	self:RegisterEvent("GARRISON_RECRUITMENT_FOLLOWERS_GENERATED");
end

function GarrisonRecruitSelectFrame_OnEvent(self, event, ...)
	self.FollowerList:OnEvent(event, ...);
	if(event == "GARRISON_RECRUIT_FOLLOWER_RESULT")then
		-- post event for recruiting follower
		HideUIPanel(GarrisonRecruitSelectFrame);
	elseif(event == "GARRISON_RECRUITMENT_FOLLOWERS_GENERATED")then
		GarrisonRecruitSelectFrame_UpdateRecruits( false )
	elseif(event == "GARRISON_RECRUITMENT_NPC_CLOSED")then
		HideUIPanel(GarrisonRecruitSelectFrame);
	end
end

function GarrisonRecruitSelectFrame_OnShow(self)
	self:RegisterEvent("GARRISON_RECRUITMENT_NPC_CLOSED");
end

function GarrisonRecruitSelectFrame_UpdateRecruits( waiting )
	local recruitFrame = GarrisonRecruitSelectFrame.FollowerSelection;
	if( waiting ) then
		recruitFrame.Line1:Hide();
		recruitFrame.Line2:Hide();
		recruitFrame.WaitText:Show();
		return;
	else
		recruitFrame.Line1:Show();
		recruitFrame.Line2:Show();
		recruitFrame.WaitText:Hide();
	end
	-- display possible recruits
	local prefAbility, prefName, _, prefIcon = C_Garrison.GetRecruitmentPreferences();
	local RECRUIT_HEIGHT_MULTUPLER = 0.6;
	local RECRUIT_SCALE_MULTIPLIER = 1.3;
	local followers = C_Garrison.GetAvailableRecruits();
	for i=1, 3 do
		local follower = followers[i];
		local frame = recruitFrame["Recruit"..i];
		if(follower)then
			frame:Show();
			frame.Name:SetText(follower.name);
			frame.PortraitFrame:SetupPortrait(follower);
			local displayInfo = follower.displayIDs and follower.displayIDs[1];
			GarrisonMission_SetFollowerModel(frame.Model, follower.followerID, displayInfo and displayInfo.id, displayInfo and displayInfo.showWeapon);
			frame.Model:SetHeightFactor(follower.displayHeight or 0.5);
			frame.Model:InitializeCamera((follower.displayScale or 1) * (displayInfo and displayInfo.followerPageScale or 1));
			frame.Model:Show();
			frame.Class:SetAtlas(follower.classAtlas);
			
			local color = FOLLOWER_QUALITY_COLORS[follower.quality];
			frame.Name:SetVertexColor(color.r, color.g, color.b);
			frame.PortraitFrame:SetQuality(follower.quality);

			local abilities = C_Garrison.GetRecruitAbilities(i);
			local abilityIndex = 0;
			local traitIndex = 0;
			frame.Counter:Hide();
			for _, ability in pairs(abilities) do
				local uiEntry;
				if( ability.isTrait ) then
					traitIndex = traitIndex + 1;
					uiEntry = GarrisonRecruitSelectFrame_GetAbilityUIEntry(frame.Traits, traitIndex);
				else
					abilityIndex = abilityIndex + 1;
					uiEntry = GarrisonRecruitSelectFrame_GetAbilityUIEntry(frame.Abilities, abilityIndex);
					-- display counter icon if this recruit has an ability that matches our preference
					if( prefAbility ) then
						local traitID, counterName = C_Garrison.GetFollowerAbilityCounterMechanicInfo(ability.id);
						if( prefName == counterName )then
							frame.Counter:Show();
							frame.Counter.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
							frame.Counter.Icon:SetTexture(prefIcon);
						end
					end
				end
				
				if(uiEntry)then
					uiEntry.abilityID = ability.id;
					uiEntry:Show();
					uiEntry.Icon:SetTexture(ability.icon);
					uiEntry.Name:SetText(ability.name);
				end
			end

			if( abilityIndex > 0 ) then
				frame.Abilities:Show();
				frame.Abilities:SetHeight(16 + abilityIndex*28);
			else
				frame.Abilities:Hide();
			end

			if( traitIndex > 0 ) then
				frame.Traits:Show();
				if(abilityIndex > 0)then
					frame.Traits:SetPoint("TOPLEFT", frame.Abilities, "BOTTOMLEFT", 0 , 0);
				else
					frame.Traits:SetPoint("TOPLEFT", frame.PortraitFrame, "BOTTOMLEFT", 8, -8);
				end
				frame.Traits:SetHeight(16 + traitIndex*28);
			else
				frame.Traits:Hide();
			end

			if( frame.Traits.Entries ) then
				for index=traitIndex+1, #frame.Traits.Entries do
					frame.Traits.Entries[index]:Hide();
				end
			end
			if( frame.Abilities.Entries ) then
				for index=abilityIndex+1, #frame.Abilities.Entries do
					frame.Abilities.Entries[index]:Hide();
				end
			end
		else
			frame:Hide();
			frame.Model:ClearModel();
			frame.Model:Hide();
		end
	end
end

function GarrisonRecruitSelectFrame_OnHide(self)
	self:UnregisterEvent("GARRISON_RECRUITMENT_NPC_CLOSED");
	C_Garrison.CloseRecruitmentNPC();
	StaticPopup_Hide("CONFIRM_RECRUIT_FOLLOWER");
	StaticPopup_Hide("DEACTIVATE_FOLLOWER");
	StaticPopup_Hide("ACTIVATE_FOLLOWER");
end

function GarrisonRecruiterFrame_HireRecruit(self)
	local followerIndex = self:GetParent():GetID();
	local followers = C_Garrison.GetAvailableRecruits();
	local followerName = followers[followerIndex].name;
	local color = FOLLOWER_QUALITY_COLORS[followers[followerIndex].quality].hex;
	StaticPopup_Show("CONFIRM_RECRUIT_FOLLOWER", color..followerName..FONT_COLOR_CODE_CLOSE, nil, followerIndex);
end

-- add abilty/trait to recruiter drop down
function GarrisonRecruiterFrame_AddEntryToDropdown( entry, info, level )
	info.text = entry.name;
	info.value = entry.id;
	info.checked = (GarrisonRecruiterFrame.Pick.dropDownValue == info.value);	
	UIDropDownMenu_AddButton(info, level);
end

-- create or retrieve recruit ability/trait entry
function GarrisonRecruitSelectFrame_GetAbilityUIEntry( frame, index )
	if( not frame.Entries ) then
		frame.Entries = {};
	end
	local entry = frame.Entries[index];
	if( not entry )then
		entry = CreateFrame("Frame", nil, frame, "GarrisonRecruitAbilityTemplate");
		if( index > 1 ) then
			entry:SetPoint("TOPLEFT", frame.Entries[index-1], "BOTTOMLEFT");
		else
			entry:SetPoint("TOPLEFT", frame.Title, "BOTTOMLEFT", 0, 0);
		end
	end
	return entry;
end