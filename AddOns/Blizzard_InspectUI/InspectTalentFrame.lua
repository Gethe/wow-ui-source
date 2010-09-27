
local talentSpecInfoCache = {};

function InspectTalentFrameTalent_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local link = GetTalentLink(PanelTemplates_GetSelectedTab(InspectTalentFrame), self:GetID(),
			InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup);
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	end
end

function InspectTalentFrameTalent_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetTalent(PanelTemplates_GetSelectedTab(InspectTalentFrame), self:GetID(),
			InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup);
	end
end

function InspectTalentFrameTalent_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetTalent(PanelTemplates_GetSelectedTab(InspectTalentFrame), self:GetID(),
		InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup);
end

function InspectTalentFrame_UpdateTabs()
	local numTabs = GetNumTalentTabs(InspectTalentFrame.inspect, InspectTalentFrame.pet);
	local selectedTab = PanelTemplates_GetSelectedTab(InspectTalentFrame);
	local tab;
	for i = 1, MAX_TALENT_TABS do
		tab = _G["InspectTalentFrameTab"..i];
		if ( tab ) then
			talentSpecInfoCache[i] = talentSpecInfoCache[i] or { };
			if ( i <= numTabs ) then
				local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(i, InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup);
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
end

function InspectTalentFrame_Update()

	InspectTalentFrame.talentGroup = GetActiveTalentGroup(InspectTalentFrame.inspect);
	InspectTalentFrame.unit = InspectFrame.unit;

	-- update spec info first
	TalentFrame_UpdateSpecInfoCache(talentSpecInfoCache, InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup);

	-- update tabs

	-- select a tab if one is not already selected
	if ( not PanelTemplates_GetSelectedTab(InspectTalentFrame) ) then
		-- if there is a primary tab then we'll prefer that one
		if ( talentSpecInfoCache.primaryTabIndex > 0 ) then
			PanelTemplates_SetTab(InspectTalentFrame, talentSpecInfoCache.primaryTabIndex);
		else
			PanelTemplates_SetTab(InspectTalentFrame, DEFAULT_TALENT_TAB);
		end
	end
	InspectTalentFrame_UpdateTabs();

	-- update parent tabs
	PanelTemplates_UpdateTabs(InspectFrame);
	
	-- Update talents
	TalentFrame_Update(InspectTalentFrame);
	
	-- Update unspent talent point text
	local unspentTalentPoints = TalentFrame_GetUnspentTalentPoints(InspectTalentFrame);
	InspectTalentFrameTalentPointsText:SetFormattedText(UNSPENT_TALENT_POINTS, HIGHLIGHT_FONT_COLOR_CODE..unspentTalentPoints..FONT_COLOR_CODE_CLOSE);
end

function InspectTalentFrame_OnLoad(self)
	self.inspect = true;
	self.pet = false;
	self.talentButtonSize = 30;
	self.initialOffsetX = 62;
	self.initialOffsetY = 12;
	self.buttonSpacingX = 56;
	self.buttonSpacingY = 46;
	self.arrowInsetX = 2;
	self.arrowInsetY = 2;
	
	TalentFrame_Load(self);

	local button;
	for i = 1, MAX_NUM_TALENTS do
		button = _G["InspectTalentFrameTalent"..i];
		if ( button ) then
			button:SetScript("OnClick",	InspectTalentFrameTalent_OnClick);
			button:SetScript("OnEvent", InspectTalentFrameTalent_OnEvent);
			button:SetScript("OnEnter", InspectTalentFrameTalent_OnEnter);
		end
	end
	
	InspectTalentFrameScrollFrame.scrollBarHideable = 1;
	-- setup tabs
	PanelTemplates_SetNumTabs(self, MAX_TALENT_TABS);
	PanelTemplates_UpdateTabs(self);
end

function InspectTalentFrame_OnShow()
	InspectTalentFrame:RegisterEvent("INSPECT_READY");
	ButtonFrameTemplate_ShowButtonBar(InspectFrame);
	InspectTalentFrame_Update();
end

function InspectTalentFrame_OnHide()
	InspectTalentFrame:UnregisterEvent("INSPECT_READY");
	wipe(talentSpecInfoCache);
end

function InspectTalentFrame_OnEvent(self, event, ...)
	if ( event == "INSPECT_READY" ) then
		InspectTalentFrame_Update();
	end
end

function InspectTalentFrameDownArrow_OnClick(self)
	local parent = self:GetParent();
	parent:SetValue(parent:GetValue() + (parent:GetHeight() / 2));
	PlaySound("UChatScrollButton");
	UIFrameFlashStop(InspectTalentFrameScrollButtonOverlay);
end

function InspectTalentFramePointsBar_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:AddLine(TALENT_POINTS);
	local pointsColor;
	for index, info in ipairs(talentSpecInfoCache) do
		if ( info.name ) then
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

