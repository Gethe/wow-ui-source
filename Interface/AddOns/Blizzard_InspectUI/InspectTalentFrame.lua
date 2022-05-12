local tabInfo = {};

function InspectTalentFrameSpentPoints_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:AddLine(TALENT_POINTS, 1, 1, 1);
	for _, entry in ipairs(tabInfo) do
		GameTooltip:AddDoubleLine(entry[1], entry[3], nil, nil, nil, 1, 1, 1);
	end
	
	GameTooltip:Show();
end

function InspectTalentFrameTalent_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetTalent(InspectTalentFrame.currentSelectedTab, self:GetID(), InspectTalentFrame.inspect);
	end
end

function InspectTalentFrameTalent_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetTalent(InspectTalentFrame.currentSelectedTab, self:GetID(), InspectTalentFrame.inspect);
	self.UpdateTooltip = InspectTalentFrameTalent_OnEnter;
end

function InspectTalentFrame_SetupTabs()
	local numTabs = GetNumTalentTabs(InspectTalentFrame.inspect);
	for i=#tabInfo, 1, -1 do
		tremove(tabInfo, i);
	end
	for i=1, MAX_TALENT_TABS do
		tab = getglobal("InspectTalentFrameTab"..(i));
		if ( tab ) then
			if ( i <= numTabs ) then
				--GetTalentTabInfo return values: 1 - Tree name, 2 - Tree icon, 3 - Points Spent, 4 - Long Tree name
				tabInfo[i] = {GetTalentTabInfo(i, InspectTalentFrame.inspect)};
				if ( (i) == PanelTemplates_GetSelectedTab(InspectTalentFrame) ) then
					-- If tab is the selected tab set the points spent info
					getglobal("InspectTalentFrameSpentPoints"):SetText(format(MASTERY_POINTS_SPENT, tabInfo[i][1]).." "..HIGHLIGHT_FONT_COLOR_CODE..tabInfo[i][3]..FONT_COLOR_CODE_CLOSE);
					InspectTalentFrame.pointsSpent = tabInfo[i][3];
				end
				tab:SetText(tabInfo[i][1]);
				PanelTemplates_TabResize(tab, -10);
				tab:Show();
			else
				tab:Hide();
			end
		end
	end
end

function InspectTalentFrame_Update(self)
	InspectTalentFrame_SetupTabs();
	PanelTemplates_UpdateTabs(InspectFrame);
	InspectTalentFrame.currentSelectedTab = PanelTemplates_GetSelectedTab(InspectTalentFrame)
end

function InspectTalentFrame_Refresh(self)
	InspectTalentFrame.unit = InspectFrame.unit;
	TalentFrame_Update(InspectTalentFrame);
end

function InspectTalentFrame_OnLoad(self)
	self.updateFunction = InspectTalentFrame_Update;
	self.inspect = true;

	TalentFrame_Load(InspectTalentFrame);

	for i=1, MAX_NUM_TALENTS do
		button = getglobal("InspectTalentFrameTalent"..i);
		if ( button ) then
			button.talentButton_OnEvent = InspectTalentFrameTalent_OnEvent;
			button.talentButton_OnClick = InspectTalentFrameTalent_OnClick;
			button.talentButton_OnEnter = InspectTalentFrameTalent_OnEnter;
		end
	end
	PanelTemplates_SetNumTabs(self, 3);
	InspectTalentFrame.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
	InspectTalentFrame:SetScript("OnEvent", function(...) InspectTalentFrame_OnEvent(...) end);
end

function  InspectTalentFrame_OnShow(self)
	InspectTalentFrame:RegisterEvent("INSPECT_READY");
	InspectTalentFrame_Refresh();
end

function  InspectTalentFrame_OnHide(self)
	InspectTalentFrame:UnregisterEvent("INSPECT_READY");
end

function InspectTalentFrame_OnEvent(self, event, ...)
	if ( event == "INSPECT_READY" ) then
		InspectTalentFrame_Refresh();
	end
end

function InspectTalentFrameDownArrow_OnClick(self)
	local parent = self:GetParent();
	parent:SetValue(parent:GetValue() + (parent:GetHeight() / 2));
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	UIFrameFlashStop(InspectTalentFrameScrollButtonOverlay);
end


