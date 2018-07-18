function GarrisonMonuntmentFrame_OnLoad(self)
	self:RegisterEvent("GARRISON_MONUMENT_SHOW_UI");
	self:RegisterEvent("GARRISON_MONUMENT_CLOSE_UI");
	self:RegisterEvent("GARRISON_MONUMENT_LIST_LOADED");
	self:RegisterEvent("GARRISON_MONUMENT_SELECTED_TROPHY_ID_LOADED");
	self:RegisterEvent("GARRISON_MONUMENT_REPLACED");
end

function GarrisonMonuntmentFrame_OnEvent(self, event, ...)
	if(event == "GARRISON_MONUMENT_SHOW_UI")then
		C_Trophy.MonumentLoadList();
	elseif(event == "GARRISON_MONUMENT_CLOSE_UI")then
		HideUIPanel(GarrisonMonumentFrame);
	elseif(event == "GARRISON_MONUMENT_LIST_LOADED")then
		C_Trophy.MonumentLoadSelectedTrophyID();
	elseif(event == "GARRISON_MONUMENT_SELECTED_TROPHY_ID_LOADED")then
		local currentID = C_Trophy.MonumentGetSelectedTrophyID();
		local count = C_Trophy.MonumentGetCount();
		self.monumentID = 0;
		for i=1, count do
			local trophy_id = C_Trophy.MonumentGetTrophyInfoByIndex(i);
			if( trophy_id == currentID ) then
				self.monumentID = i;
				break;
			end
		end
		ShowUIPanel(GarrisonMonumentFrame);
		GarrisonMonuntmentFrame_UpdateDisplay();
	elseif(event == "GARRISON_MONUMENT_REPLACED")then
		self.monumentID = C_Trophy.MonumentGetSelectedTrophyID();
		GarrisonMonuntmentFrame_UpdateDisplay();
	end
end

function GarrisonMonuntmentFrame_SaveSelection()
	if( not GarrisonMonumentFrame.monumentID ) then
		C_Trophy.MonumentRevertAppearanceToSaved();
		return;
	end
	local trophy_id, lock_code = C_Trophy.MonumentGetTrophyInfoByIndex(GarrisonMonumentFrame.monumentID);
	if(lock_code == MATCH_CONDITION_SUCCESS) then
		C_Trophy.MonumentSaveSelection(trophy_id);
	else
		C_Trophy.MonumentRevertAppearanceToSaved();
	end
end

function GarrisonMonuntmentFrame_OnShow(self)
	PlaySound(SOUNDKIT.UI_GARRISON_MONUMENTS_OPEN);
end

function GarrisonMonuntmentFrame_OnHide(self)
	GarrisonMonuntmentFrame_SaveSelection();
	PlaySound(SOUNDKIT.UI_GARRISON_MONUMENTS_CLOSE);
end

function GarrisonMonuntmentLeftBtn_OnMouseDown(self)
	PlaySound(SOUNDKIT.UI_GARRISON_MONUMENTS_NAV);
	GarrisonMonumentFrame.LeftBtn.Texture:SetAtlas("Monuments-LeftButton-Down");
	GarrisonMonuntmentFrame_UpdateSelectedTrophyID( -1 );
end

function GarrisonMonuntmentLeftBtn_OnMouseUp(self)
	GarrisonMonumentFrame.LeftBtn.Texture:SetAtlas("Monuments-LeftButton-Up");
end

function GarrisonMonuntmentRightBtn_OnMouseDown(self)
	PlaySound(SOUNDKIT.UI_GARRISON_MONUMENTS_NAV);
	GarrisonMonumentFrame.RightBtn.Texture:SetAtlas("Monuments-RightButton-Down");
	GarrisonMonuntmentFrame_UpdateSelectedTrophyID( 1 );
end

function GarrisonMonuntmentRightBtn_OnMouseUp(self)
	GarrisonMonumentFrame.RightBtn.Texture:SetAtlas("Monuments-RightButton-Up");
end

function GarrisonMonuntmentFrame_UpdateSelectedTrophyID( delta )
	local frame = GarrisonMonumentFrame;
	local id = frame.monumentID + delta;
	-- constrain id range to 1 to MonumentGetCount();
	local count = C_Trophy.MonumentGetCount();
	if( id > count ) then
		id = 0;
	elseif(id < 0 )then
		id = count;
	end
	frame.monumentID = id;
	
	local trophy_id, lock_code, _, trophy_name = C_Trophy.MonumentGetTrophyInfoByIndex(id);
	C_Trophy.MonumentChangeAppearanceToTrophyID(trophy_id);
	GarrisonMonuntmentFrame_UpdateDisplay(trophy_id, trophy_name, lock_code);
end

function GarrisonMonuntmentFrame_UpdateDisplay(trophy_id, trophy_name, lock_code)
	local frame = GarrisonMonumentFrame;
	if( not trophy_id ) then
		local _;
		trophy_id, lock_code,_, trophy_name = C_Trophy.MonumentGetTrophyInfoByIndex(frame.monumentID);
	end
	frame.Text:SetText( trophy_name or EMPTY ) -- set trophy name;
	if(lock_code == MATCH_CONDITION_SUCCESS)then
		frame.Body.Lock:Hide();
	else
		frame.Body.Lock:Show();
	end
end

function GarrisonMonuntmentLock_OnEnter(self)
	local trophy_id, lock_code, lock_reason, trophy_name = C_Trophy.MonumentGetTrophyInfoByIndex(GarrisonMonumentFrame.monumentID);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(trophy_name or EMPTY, 1, 1, 1, true);
	if( lock_code == MATCH_CONDITION_WRONG_ACHIEVEMENT ) then
		local _, ach_name, _, _, _, _, _, desc = GetAchievementInfo(lock_reason);
		GameTooltip:AddLine(GARRISON_TROPHY_LOCKED_SUBTEXT.."\n\n"..ach_name, 1, .82, 0, true);
		GameTooltip:AddLine(desc, 1, 1, 1, true);
	end
	GameTooltip:Show();
end