local arenaFrames;

function InspectPVPFrame_OnLoad(self)
	self:RegisterEvent("INSPECT_HONOR_UPDATE");
	self.inspect = true;
	arenaFrames = {InspectPVPFrame.Arena2v2, InspectPVPFrame.Arena3v3};
end

function InspectPVPFrame_OnEvent(self, event, ...)
	if ( event == "INSPECT_HONOR_UPDATE" ) then
		InspectPVPFrame_Update();
	end
end

function InspectPVPFrame_OnShow()
	ButtonFrameTemplate_HideButtonBar(InspectFrame);
	InspectPVPFrame_Update();
	if ( not HasInspectHonorData() ) then
		RequestInspectHonorData();
	else
		InspectPVPFrame_Update();
	end
end

function InspectPVPFrame_OnHide(self)
	local parent = self:GetParent();
	self.PortraitBackground:Hide();
	parent.portrait:SetSize(61, 61);
	parent.portrait:ClearAllPoints();
	parent.portrait:SetPoint("TOPLEFT", -6, 8);
	SetPortraitTexture(InspectFramePortrait, INSPECTED_UNIT);
end

function InspectPVPFrame_Update()
	local parent = InspectPVPFrame:GetParent();
	local factionGroup = UnitFactionGroup(INSPECTED_UNIT);
	local prestigeLevel = UnitPrestige(INSPECTED_UNIT);
	local _, _, _, _, lifetimeHKs, _ = GetInspectHonorData();
	local level = UnitLevel(INSPECTED_UNIT);

	InspectPVPFrame.HKs:SetFormattedText(INSPECT_HONORABLE_KILLS, lifetimeHKs);

	if (level < MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_LEVEL_CURRENT]) then
		InspectPVPFrame.SmallWreath:Hide();
		InspectPVPFrame.HonorLevel:Hide();
		InspectPVPFrame.RatedBG:Hide();
		for i = 1, MAX_ARENA_TEAMS do
			arenaFrames[i]:Hide();
		end
		InspectPVPFrame.Talents:Hide();
	else
		if (prestigeLevel > 0) then
			InspectPVPFrame.PortraitBackground:SetAtlas("honorsystem-prestige-laurel-bg-"..factionGroup, false);
			InspectPVPFrame.PortraitBackground:Show();
			parent.portrait:SetSize(57,57);
			parent.portrait:ClearAllPoints();
			parent.portrait:SetPoint("CENTER", InspectPVPFrame.PortraitBackground, "CENTER", 0, 0);
			parent.portrait:SetTexture(GetPrestigeInfo(UnitPrestige(INSPECTED_UNIT)));
		end
		InspectPVPFrame.SmallWreath:SetShown(prestigeLevel > 0);

		InspectPVPFrame.HonorLevel:SetFormattedText(HONOR_LEVEL_LABEL, UnitHonorLevel(INSPECTED_UNIT));
		InspectPVPFrame.HonorLevel:Show();
		local rating, played, won = GetInspectRatedBGData();
		InspectPVPFrame.RatedBG.Rating:SetText(rating);
		InspectPVPFrame.RatedBG.Record:SetFormattedText(PVP_RECORD_DESCRIPTION, won, (played - won));
		InspectPVPFrame.RatedBG:Show();
		for i=1, MAX_ARENA_TEAMS do
			local arenarating, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon = GetInspectArenaData(i);
			local frame = arenaFrames[i];
			frame.Rating:SetText(arenarating);
			frame.Record:SetFormattedText(PVP_RECORD_DESCRIPTION, seasonWon, (seasonPlayed - seasonWon));
			frame:Show();
		end
		InspectPVPFrame.talentGroup = GetActiveSpecGroup(true);
		PVPTalentFrame_Update(InspectPVPFrame, INSPECTED_UNIT);
		InspectPVPFrame.Talents:Show();
	end
end

function InspectPVPFramePortraitMouseOverFrame_OnEnter(self)
	local prestige = UnitPrestige(INSPECTED_UNIT);
	if (prestige > 0) then
		GameTooltip:ClearAllPoints();
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(select(2, GetPrestigeInfo(prestige)), 1, 1, 1, nil, true);
		GameTooltip:AddLine(" ");
		for i = 1, GetMaxPrestigeLevel() do
			local color;
			if (prestige == i) then
				color = GREEN_FONT_COLOR;
			else
				color = NORMAL_FONT_COLOR;
			end
            local texture, name = GetPrestigeInfo(i);
			GameTooltip:AddLine(PRESTIGE_RANK_TOOLTIP_LINE:format(texture, name), color.r, color.g, color.b);
		end
		GameTooltip:Show();
	end
end

function InspectPvPTalentFrameTalent_OnEnter(self)
	local classDisplayName, class, classID = UnitClass(INSPECTED_UNIT);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");	
	GameTooltip:SetPvpTalent(self.pvpTalentID ,true, self.talentGroup, INSPECTED_UNIT, classID);
end

function InspectPvPTalentFrameTalent_OnClick(self)
	if ( IsModifiedClick("CHATLINK") ) then
		local link = GetPvpTalentLink(self.pvpTalentID);
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	end
end
