function PlayerTalentFrameTalent_OnClick(self, mouseButton)
	if ( mouseButton == "LeftButton" ) then
		if ( IsModifiedClick("CHATLINK") ) then
			local link = GetTalentLink(PanelTemplates_GetSelectedTab(PlayerTalentFrame), self:GetID());
			if ( link ) then
				ChatEdit_InsertLink(link);
			end
		else
			LearnTalent(PanelTemplates_GetSelectedTab(PlayerTalentFrame), self:GetID());
		end
	end
end

function PlayerTalentFrameTalent_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetTalent(PlayerTalentFrame.currentSelectedTab, self:GetID(), PlayerTalentFrame.inspect);
	end
end

function PlayerTalentFrameTalent_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetTalent(PlayerTalentFrame.currentSelectedTab, self:GetID(), PlayerTalentFrame.inspect);
	self.UpdateTooltip = PlayerTalentFrameTalent_OnEnter;
end

function PlayerTalentFrame_Update()
	-- Setup Tabs
	local numTabs = GetNumTalentTabs(PlayerTalentFrame.inspect);
	for i=1, MAX_TALENT_TABS do
		tab = getglobal("PlayerTalentFrameTab"..i);
		if ( i <= numTabs ) then
			local name, iconTexture, pointsSpent = GetTalentTabInfo(i, PlayerTalentFrame.inspect);
			if ( i == PanelTemplates_GetSelectedTab(PlayerTalentFrame) ) then
				-- If tab is the selected tab set the points spent info
				getglobal("PlayerTalentFrameSpentPoints"):SetText(format(MASTERY_POINTS_SPENT, name).." "..HIGHLIGHT_FONT_COLOR_CODE..pointsSpent..FONT_COLOR_CODE_CLOSE);
				PlayerTalentFrame.pointsSpent = pointsSpent;
			end
			tab:SetText(name);
			PanelTemplates_TabResize(tab, 10);
			tab:Show();
		else
			tab:Hide();
		end
	end

	PanelTemplates_SetNumTabs(PlayerTalentFrame, numTabs);
	PanelTemplates_UpdateTabs(PlayerTalentFrame);

	SetPortraitTexture(PlayerTalentFramePortrait, PlayerTalentFrame.unit);

	PlayerTalentFrame.currentSelectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
end


function PlayerTalentFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(PlayerTalentFrame, 3);
	PanelTemplates_SetTab(PlayerTalentFrame, 1);
	self:RegisterEvent("CHARACTER_POINTS_CHANGED");
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self.unit = "player";
	self.inspect = false;
	self.updateFunction = PlayerTalentFrame_Update;

	TalentFrame_Load(PlayerTalentFrame);

	for i=1, MAX_NUM_TALENTS do
		button = getglobal("PlayerTalentFrameTalent"..i);
		if ( button ) then
			button.talentButton_OnEvent = PlayerTalentFrameTalent_OnEvent;
			button.talentButton_OnClick = PlayerTalentFrameTalent_OnClick;
			button.talentButton_OnEnter = PlayerTalentFrameTalent_OnEnter;
		end
	end
end

function  PlayerTalentFrame_OnShow(self)
	-- Stop buttons from flashing after skill up
	SetButtonPulse(TalentMicroButton, 0, 1);

	PlaySound(SOUNDKIT.TALENT_SCREEN_OPEN);
	UpdateMicroButtons();

	TalentFrame_Update(PlayerTalentFrame);
end

function  PlayerTalentFrame_OnHide(self)
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.TALENT_SCREEN_CLOSE);
end

function PlayerTalentFrame_OnEvent(self, event, ...)
	if ( (event == "CHARACTER_POINTS_CHANGED") or (event == "SPELLS_CHANGED") ) then
		TalentFrame_Update(PlayerTalentFrame);
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		if ( select(1, ...) == "player" ) then
			SetPortraitTexture(PlayerTalentFramePortrait, "player");
		end
	end
end

function PlayerTalentFrameDownArrow_OnClick(self)
	local parent = self:GetParent();
	parent:SetValue(parent:GetValue() + (parent:GetHeight() / 2));
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end


function TalentFrameTab_OnClick(self)
	PanelTemplates_SetTab(PlayerTalentFrame, self:GetID());
	TalentFrame_Update(PlayerTalentFrame);
	for i=1, MAX_TALENT_TABS do
		SetButtonPulse(getglobal("PlayerTalentFrameTab"..i), 0, 0);
	end
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end
