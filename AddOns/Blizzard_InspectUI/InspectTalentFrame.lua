
local talentSpecInfoCache = {};

function InspectTalentFrameSpentPoints_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:AddLine(TALENT_POINTS);
	for index, info in ipairs(talentSpecInfoCache) do
		if ( info.name ) then
			local pointsColor;
			if ( talentSpecInfoCache.primaryTabIndex == index ) then
				pointsColor = GREEN_FONT_COLOR;
			else
				pointsColor = HIGHLIGHT_FONT_COLOR;
			end
			GameTooltip:AddDoubleLine(
				info.name,
				info.pointsSpent,
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
				pointsColor.r, pointsColor.g, pointsColor.b,
				1
			);
		end
	end
	
	GameTooltip:Show();
end

function InspectTalentFrameTalent_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetTalent(InspectTalentFrame.selectedTab, self:GetID(), InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup);
	end
end

function InspectTalentFrameTalent_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetTalent(InspectTalentFrame.selectedTab, self:GetID(), InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup);
end

function InspectTalentFrame_SetupTabs()
	local numTabs = GetNumTalentTabs(InspectTalentFrame.inspect, InspectTalentFrame.pet);
	local selectedTab = PanelTemplates_GetSelectedTab(InspectTalentFrame);
	for i = 1, MAX_TALENT_TABS do
		tab = _G["InspectTalentFrameTab"..i];
		if ( tab ) then
			talentSpecInfoCache[i] = talentSpecInfoCache[i] or { };
			if ( i <= numTabs ) then
				local name, icon, pointsSpent, background, previewPointsSpent = GetTalentTabInfo(i, InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup);
				if ( i == selectedTab ) then
					-- If tab is the selected tab set the points spent info
					local displayPointsSpent = pointsSpent + previewPointsSpent;
					InspectTalentFrameSpentPointsText:SetFormattedText(MASTERY_POINTS_SPENT, name, HIGHLIGHT_FONT_COLOR_CODE..displayPointsSpent..FONT_COLOR_CODE_CLOSE);
					InspectTalentFrame.pointsSpent = pointsSpent;
					InspectTalentFrame.previewPointsSpent = previewPointsSpent;
				end
				tab:SetText(name);
				PanelTemplates_TabResize(tab, -10);
				tab:Show();
			else
				tab:Hide();
				talentSpecInfoCache[i].name = nil;
			end
		end
	end
	TalentFrame_UpdateSpecInfoCache(talentSpecInfoCache, InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup);
end

function InspectTalentFrame_Update()
	InspectTalentFrame_SetupTabs();
	PanelTemplates_UpdateTabs(InspectFrame);
	InspectTalentFrame.selectedTab = PanelTemplates_GetSelectedTab(InspectTalentFrame)
end

function InspectTalentFrame_Refresh()
	InspectTalentFrame.talentGroup = GetActiveTalentGroup(InspectTalentFrame.inspect);
	InspectTalentFrame.unit = InspectFrame.unit;
	TalentFrame_Update(InspectTalentFrame);
end

function InspectTalentFrame_OnLoad(self)
	self.updateFunction = InspectTalentFrame_Update;
	self.inspect = true;
	self.pet = false;
	self.talentGroup = 1;

	TalentFrame_Load(InspectTalentFrame);

	for i = 1, MAX_NUM_TALENTS do
		button = _G["InspectTalentFrameTalent"..i];
		if ( button ) then
			button:SetScript("OnEvent", InspectTalentFrameTalent_OnEvent);
			button:SetScript("OnEnter", InspectTalentFrameTalent_OnEnter);
		end
	end
	PanelTemplates_SetNumTabs(self, 3);
	PanelTemplates_SetTab(InspectTalentFrame, 1);
	PanelTemplates_UpdateTabs(self);
	InspectTalentFrame:SetScript("OnEvent", InspectTalentFrame_OnEvent);
end

function  InspectTalentFrame_OnShow()
	InspectTalentFrame:RegisterEvent("INSPECT_TALENT_READY");
	InspectTalentFrame_Refresh();
end

function  InspectTalentFrame_OnHide()
	InspectTalentFrame:UnregisterEvent("INSPECT_TALENT_READY");
	wipe(talentSpecInfoCache);
end

function InspectTalentFrame_OnEvent(self, event, ...)
	if ( event == "INSPECT_TALENT_READY" ) then
		InspectTalentFrame_Refresh();
	end
end

function InspectTalentFrameDownArrow_OnClick(self)
	local parent = self:GetParent();
	parent:SetValue(parent:GetValue() + (parent:GetHeight() / 2));
	PlaySound("UChatScrollButton");
	UIFrameFlashStop(InspectTalentFrameScrollButtonOverlay);
end


