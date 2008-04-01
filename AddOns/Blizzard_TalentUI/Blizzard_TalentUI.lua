

UIPanelWindows["PlayerTalentFrame"] = { area = "left", pushable = 6, whileDead = 1 };


function PlayerTalentFrame_Toggle()
	if ( PlayerTalentFrame:IsShown() ) then
		HideUIPanel(PlayerTalentFrame);
	else
		ShowUIPanel(PlayerTalentFrame);
	end
end


function PlayerTalentFrameTalent_OnClick()
	if ( IsModifiedClick("CHATLINK") ) then
		local link = GetTalentLink(PanelTemplates_GetSelectedTab(PlayerTalentFrame), this:GetID());
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	else
		LearnTalent(PanelTemplates_GetSelectedTab(PlayerTalentFrame), this:GetID());
	end
end

function PlayerTalentFrameTalent_OnEvent()
	if ( GameTooltip:IsOwned(this) ) then
		GameTooltip:SetTalent(PlayerTalentFrame.currentSelectedTab, this:GetID(), PlayerTalentFrame.inspect);
	end
end

function PlayerTalentFrameTalent_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	GameTooltip:SetTalent(PlayerTalentFrame.currentSelectedTab, this:GetID(), PlayerTalentFrame.inspect);
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
			PanelTemplates_TabResize(10, tab);
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


function PlayerTalentFrame_OnLoad()
	PanelTemplates_SetNumTabs(PlayerTalentFrame, 3);
	PanelTemplates_SetTab(PlayerTalentFrame, 1);
	this:RegisterEvent("CHARACTER_POINTS_CHANGED");
	this:RegisterEvent("SPELLS_CHANGED");
	this:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	this.unit = "player";
	this.inspect = false;
	this.updateFunction = PlayerTalentFrame_Update;

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

function  PlayerTalentFrame_OnShow()
	-- Stop buttons from flashing after skill up
	SetButtonPulse(TalentMicroButton, 0, 1);

	PlaySound("TalentScreenOpen");
	UpdateMicroButtons();

	TalentFrame_Update(PlayerTalentFrame);

	-- Set flag
	if ( TALENT_FRAME_WAS_SHOWN ~= 1 ) then
		TALENT_FRAME_WAS_SHOWN = 1;
		UIFrameFlash(PlayerTalentFrameScrollButtonOverlay, 0.5, 0.5, 60);
	end
end

function  PlayerTalentFrame_OnHide()
	UpdateMicroButtons();
	PlaySound("TalentScreenClose");
	UIFrameFlashStop(PlayerTalentFrameScrollButtonOverlay);
end

function PlayerTalentFrame_OnEvent()
	if ( (event == "CHARACTER_POINTS_CHANGED") or (event == "SPELLS_CHANGED") ) then
		TalentFrame_Update(PlayerTalentFrame);
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		if ( arg1 == "player" ) then
			SetPortraitTexture(PlayerTalentFramePortrait, "player");
		end
	end
end

function PlayerTalentFrameDownArrow_OnClick()
	local parent = this:GetParent();
	parent:SetValue(parent:GetValue() + (parent:GetHeight() / 2));
	PlaySound("UChatScrollButton");
	UIFrameFlashStop(PlayerTalentFrameScrollButtonOverlay);
end


function TalentFrameTab_OnClick()
	PanelTemplates_SetTab(PlayerTalentFrame, this:GetID());
	TalentFrame_Update(PlayerTalentFrame);
	for i=1, MAX_TALENT_TABS do
		SetButtonPulse(getglobal("PlayerTalentFrameTab"..i), 0, 0);
	end
	PlaySound("igCharacterInfoTab");
end
