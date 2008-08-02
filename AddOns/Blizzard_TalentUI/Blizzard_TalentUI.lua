

UIPanelWindows["PlayerTalentFrame"] = { area = "left", pushable = 6, whileDead = 1 };


function PlayerTalentFrame_Toggle()
	if ( PlayerTalentFrame:IsShown() ) then
		HideUIPanel(PlayerTalentFrame);
	else
		ShowUIPanel(PlayerTalentFrame);
	end
end


function PlayerTalentFrameTalent_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local link = GetTalentLink(PanelTemplates_GetSelectedTab(PlayerTalentFrame), self:GetID(), PlayerTalentFrame.inspect, PlayerTalentFrame.pet);
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	else
		LearnTalent(PanelTemplates_GetSelectedTab(PlayerTalentFrame), self:GetID(), PlayerTalentFrame.pet);
	end
end

function PlayerTalentFrameTalent_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetTalent(PlayerTalentFrame.currentSelectedTab, self:GetID(), PlayerTalentFrame.inspect, PlayerTalentFrame.pet);
	end
end

function PlayerTalentFrameTalent_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetTalent(PlayerTalentFrame.currentSelectedTab, self:GetID(), PlayerTalentFrame.inspect, PlayerTalentFrame.pet);
end

function PlayerTalentFrame_Update()
	-- Setup Tabs
	local hasUI, isHunterPet = HasPetUI();
	if ( isHunterPet ) then
		PlayerTalentFrameType1:Show()
		PlayerTalentFrameType2:Show()
	else
		PlayerTalentFrameType1:Hide()
		PlayerTalentFrameType2:Hide()
	end
		
	local numTabs = GetNumTalentTabs(PlayerTalentFrame.inspect, PlayerTalentFrame.pet);
	for i=1, MAX_TALENT_TABS do
		tab = getglobal("PlayerTalentFrameTab"..i);
		if ( i <= numTabs ) then
			local name, iconTexture, pointsSpent = GetTalentTabInfo(i, PlayerTalentFrame.inspect, PlayerTalentFrame.pet);
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
	SetPortraitTexture(PlayerTalentFrameType1:GetNormalTexture(),"player");
	SetPortraitTexture(PlayerTalentFrameType2:GetNormalTexture(),"pet");

	PlayerTalentFrame.currentSelectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
end


function PlayerTalentFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(PlayerTalentFrame, 3);
	PanelTemplates_SetTab(PlayerTalentFrame, 1);
	self:RegisterEvent("CHARACTER_POINTS_CHANGED");
	self:RegisterEvent("PET_TALENT_POINTS_CHANGED");
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("UNIT_PET");
	self.unit = "player";
	self.inspect = false;
	self.pet = false;
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
	
	PlayerTalentFrameType1.tooltip = PLAYER;
	PlayerTalentFrameType2.tooltip = PET;
	--PlayerTalentFrameType1:SetNormalTexture("Interface\\Icons\\Ability_Hunter_BeastWithin");
	--PlayerTalentFrameType2:SetNormalTexture("Interface\\Icons\\Ability_Druid_FerociousBite");
	SetPortraitTexture(PlayerTalentFrameType1:GetNormalTexture(),"player");
	SetPortraitTexture(PlayerTalentFrameType2:GetNormalTexture(),"pet");
	PlayerTalentFrameType1:SetChecked(true);
	
	PlayerTalentFrame.playertab = 1;
	
	
end

function  PlayerTalentFrame_OnShow()
	if ( MISTER_SPARKLE and MISTER_SPARKLE ~= 0 ) then
		PlayerTalentFrame:Hide();
		return;
	end
	-- Stop buttons from flashing after skill up
	SetButtonPulse(TalentMicroButton, 0, 1);

	PlaySound("TalentScreenOpen");
	UpdateMicroButtons();

	TalentFrame_Update(PlayerTalentFrame);

	-- Set flag
	if ( not GetCVarBool("talentFrameShown") ) then
		SetCVar("talentFrameShown", 1);
		UIFrameFlash(PlayerTalentFrameScrollButtonOverlay, 0.5, 0.5, 60);
	end
end

function  PlayerTalentFrame_OnHide()
	UpdateMicroButtons();
	PlaySound("TalentScreenClose");
	UIFrameFlashStop(PlayerTalentFrameScrollButtonOverlay);
end

function PlayerTalentFrame_OnEvent(self, event, ...)
	if ( (event == "CHARACTER_POINTS_CHANGED") or (event == "SPELLS_CHANGED") or (event == "PET_TALENT_POINTS_CHANGED")) then
		TalentFrame_Update(PlayerTalentFrame);
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local arg1 = ...;
		if ( arg1 == "player" ) then
			SetPortraitTexture(PlayerTalentFramePortrait, "player");
			SetPortraitTexture(PlayerTalentFrameType1:GetNormalTexture(),"player");
		elseif ( arg1 == "pet" ) then
			SetPortraitTexture(PlayerTalentFrameType2:GetNormalTexture(),"pet");
		end
	elseif ( event == "UNIT_PET" ) then
		local arg1 = ...;
		if ( arg1 == "player" ) then
			PlayerTalentFrameType_OnClick(PlayerTalentFrameType1);
			PlayerTalentFrame_Update();
			TalentFrame_Update(self);
		end
	end
end

function PlayerTalentFrameDownArrow_OnClick(self, button)
	local parent = self:GetParent();
	parent:SetValue(parent:GetValue() + (parent:GetHeight() / 2));
	PlaySound("UChatScrollButton");
	UIFrameFlashStop(PlayerTalentFrameScrollButtonOverlay);
end


function TalentFrameTab_OnClick(self)
	PanelTemplates_SetTab(PlayerTalentFrame, self:GetID());
	TalentFrame_Update(PlayerTalentFrame);
	for i=1, MAX_TALENT_TABS do
		SetButtonPulse(getglobal("PlayerTalentFrameTab"..i), 0, 0);
	end
	PlaySound("igCharacterInfoTab");
end

function PlayerTalentFrameType_OnClick(self)
	local name=self:GetName()
	PlayerTalentFrameType1:SetChecked(false)
	PlayerTalentFrameType2:SetChecked(false)
	self:SetChecked(1)
	if ( name == "PlayerTalentFrameType1" ) then
		PlayerTalentFrame.pet = false;
		PlayerTalentFrame.unit = "player";
		PanelTemplates_SetTab(PlayerTalentFrame,PlayerTalentFrame.playertab)
	elseif ( name == "PlayerTalentFrameType2" ) then
		PlayerTalentFrame.pet = true;
		PlayerTalentFrame.unit = "pet";
		PlayerTalentFrame.playertab = PanelTemplates_GetSelectedTab(PlayerTalentFrame)
		PanelTemplates_SetTab(PlayerTalentFrame, 1)
	end
	
	PlayerTalentFrame_Update()
	TalentFrame_Update(self:GetParent())
end