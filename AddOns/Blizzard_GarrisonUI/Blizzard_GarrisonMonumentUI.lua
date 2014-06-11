-- stubs --
GARRISON_TROPHY_NAME = "Badass Statue ";
-- stubs --

function GarrisonMountmentFrame_OnLoad(self)
	self:RegisterEvent("GARRISON_MONUMENT_SHOW_UI");
	self:RegisterEvent("GARRISON_MONUMENT_CLOSE_UI");
	self:RegisterEvent("GARRISON_MONUMENT_LIST_LOADED");
	self:RegisterEvent("GARRISON_MONUMENT_SELECTED_TROPHY_ID_LOADED");
	self:RegisterEvent("GARRISON_MONUMENT_REPLACED");
end

function GarrisonMountmentFrame_OnEvent(self, event, ...)
	if(event == "GARRISON_MONUMENT_SHOW_UI")then
		MonumentLoadList();
	elseif(event == "GARRISON_MONUMENT_CLOSE_UI")then
		HideUIPanel(GarrisonMonumentFrame);
	elseif(event == "GARRISON_MONUMENT_LIST_LOADED")then
		ShowUIPanel(GarrisonMonumentFrame);
	elseif(event == "GARRISON_MONUMENT_SELECTED_TROPHY_ID_LOADED")then
		self.monumentID = MonumentGetSelectedTrophyID();
		GarrisonMountmentFrame_UpdateDisplay();
	elseif(event == "GARRISON_MONUMENT_REPLACED")then
		self.monumentID = MonumentGetSelectedTrophyID();
		GarrisonMountmentFrame_UpdateDisplay();
	end
end

function GarrisonMountmentFrame_SaveSelection()
	local trophy_id, lock_code = MonumentGetTrophyInfoByIndex(GarrisonMonumentFrame.monumentID);
	if(lock_code == MATCH_CONDITION_SUCCESS) then
		MonumentSaveSelection(trophy_id);
	else
		MonumentRevertAppearanceToSaved();
	end
end

function GarrisonMountmentFrame_OnShow(self)
	self.monumentID = MonumentGetSelectedTrophyID();
	GarrisonMountmentFrame_UpdateDisplay();
	PlaySound("igCharacterInfoOpen");
end

function GarrisonMountmentFrame_OnHide(self)
	GarrisonMountmentFrame_SaveSelection();
end

function GarrisonMountmentLeftBtn_OnMouseDown(self)
	PlaySound("igCharacterInfoOpen");
	GarrisonMonumentFrame.LeftBtn.Texture:SetAtlas("Monuments-LeftButton-Down");
	GarrisonMountmentFrame_UpdateSelectedTrophyID( -1 );
end

function GarrisonMountmentLeftBtn_OnMouseUp(self)
	GarrisonMonumentFrame.LeftBtn.Texture:SetAtlas("Monuments-LeftButton-Up");
end

function GarrisonMountmentRightBtn_OnMouseDown(self)
	PlaySound("igCharacterInfoOpen");
	GarrisonMonumentFrame.RightBtn.Texture:SetAtlas("Monuments-RightButton-Down");
	GarrisonMountmentFrame_UpdateSelectedTrophyID( 1 );
end

function GarrisonMountmentRightBtn_OnMouseUp(self)
	GarrisonMonumentFrame.RightBtn.Texture:SetAtlas("Monuments-RightButton-Up");
end

function GarrisonMountmentFrame_UpdateSelectedTrophyID( delta )
	local frame = GarrisonMonumentFrame;
	local id = frame.monumentID + delta;
	-- constrain id range to 1 to MonumentGetCount();
	local count = MonumentGetCount();
	if( id > count ) then
		id = 0;
	elseif(id < 0 )then
		id = count;
	end
	frame.monumentID = id;
	
	local trophy_id, lock_code, _, trophy_name = MonumentGetTrophyInfoByIndex(id);
	MonumentChangeAppearanceToTrophyID(trophy_id);
	GarrisonMountmentFrame_UpdateDisplay(trophy_id, trophy_name, lock_code);
end

function GarrisonMountmentFrame_UpdateDisplay(trophy_id, trophy_name, lock_code)
	local frame = GarrisonMonumentFrame;
	if( not trophy_id ) then
		trophy_id, lock_code,_, trophy_name = MonumentGetTrophyInfoByIndex(frame.monumentID);
	end
	frame.Text:SetText( trophy_name or EMPTY ) -- set trophy name;
	if(lock_code == MATCH_CONDITION_SUCCESS)then
		frame.Body.Lock:Hide();
	else
		frame.Body.Lock:Show();
	end
end

function GarrisonMountmentLock_OnEnter(self)
	local trophy_id, lock_code, lock_reason, trophy_name = MonumentGetTrophyInfoByIndex(GarrisonMonumentFrame.monumentID);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(trophy_name or EMPTY, 1, 1, 1, true);
	if( lock_code == MATCH_CONDITION_WRONG_ACHIEVEMENT ) then
		local _, ach_name, _, _, _, _, _, desc = GetAchievementInfo(lock_reason);
		GameTooltip:AddLine(GARRISON_TROPHY_LOCKED_SUBTEXT.."\n\n"..ach_name, 1, .82, 0, true);
		GameTooltip:AddLine(desc, 1, 1, 1, true);
	end
	GameTooltip:Show();
end