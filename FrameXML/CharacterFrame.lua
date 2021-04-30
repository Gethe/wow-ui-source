CHARACTERFRAME_SUBFRAMES = { "PaperDollFrame", "PetPaperDollFrame", "ReputationFrame", "SkillFrame", "PVPFrame" };

local NUM_CHARACTERFRAME_TABS = 5;
function ToggleCharacter(tab, onlyShow)
	if ( tab == "PetPaperDollFrame" and not HasPetUI() and not PetPaperDollFrame:IsVisible() ) then
		return;
	end
	local subFrame = _G[tab];
	if ( subFrame ) then
		if (not subFrame.hidden) then
			PanelTemplates_SetTab(CharacterFrame, subFrame:GetID());
			if ( CharacterFrame:IsShown() ) then
				if ( subFrame:IsShown() ) then
					if ( not onlyShow ) then
						HideUIPanel(CharacterFrame);
					end
				else
					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
					CharacterFrame_ShowSubFrame(tab);
				end
			else
				CharacterFrame_ShowSubFrame(tab);
				ShowUIPanel(CharacterFrame);
			end
		end
	end
end

function CharacterFrame_ShowSubFrame(frameName)
	for index, value in pairs(CHARACTERFRAME_SUBFRAMES) do
		if ( value ~= frameName ) then
			_G[value]:Hide();
		end	
	end 
	for index, value in pairs(CHARACTERFRAME_SUBFRAMES) do
		if ( value == frameName ) then
			_G[value]:Show();
		end	
	end 
end

function CharacterFrameTab_OnClick(self, button)
	local name = self:GetName();
	if ( name == "CharacterFrameTab1" ) then
		ToggleCharacter("PaperDollFrame");
	elseif ( name == "CharacterFrameTab2" ) then
		ToggleCharacter("PetPaperDollFrame");
	elseif ( name == "CharacterFrameTab3" ) then
		ToggleCharacter("ReputationFrame");
	elseif ( name == "CharacterFrameTab4" ) then
		ToggleCharacter("SkillFrame");
	elseif ( name == "CharacterFrameTab5" ) then
		ToggleCharacter("PVPFrame");
	end

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function CharacterFrame_OnLoad (self)
	PortraitFrameTemplateMixin.OnLoad(self);

	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PLAYER_PVP_RANK_CHANGED");

	SetTextStatusBarTextPrefix(PlayerFrameHealthBar, HEALTH);
	SetTextStatusBarTextPrefix(PlayerFrameManaBar, MANA);
	SetTextStatusBarTextPrefix(MainMenuExpBar, XP);
	ExpBar_UpdateTextString();

	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, NUM_CHARACTERFRAME_TABS);
	PanelTemplates_SetTab(self, 1);
end

function CharacterFrame_OnEvent(self, event, ...)
	if ( not self:IsShown() ) then
		return;
	end
	
	local arg1 = ...;
	if ( event == "UNIT_PORTRAIT_UPDATE" ) then
		if ( arg1 == "player" ) then
			SetPortraitTexture(CharacterFramePortrait, arg1);
		end
		return;
	elseif ( event == "UNIT_NAME_UPDATE" ) then
		if ( arg1 == "player" ) then
			CharacterNameText:SetText(UnitPVPName("player"));
		end
		return;
	elseif ( event == "PLAYER_PVP_RANK_CHANGED" ) then
		CharacterNameText:SetText(UnitPVPName("player"));
	end
end

function CharacterFrame_OnShow(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	SetPortraitTexture(CharacterFramePortrait, "player");
	CharacterNameText:SetText(UnitPVPName("player"));
	UpdateMicroButtons();
	PlayerFrameHealthBar.showNumeric = true;
	PlayerFrameManaBar.showNumeric = true;
	PetFrameHealthBar.showNumeric = true;
	PetFrameManaBar.showNumeric = true;
	ShowTextStatusBarText(PlayerFrameHealthBar);
	ShowTextStatusBarText(PlayerFrameManaBar);
	ShowTextStatusBarText(PetFrameHealthBar);
	ShowTextStatusBarText(PetFrameManaBar);

	-- This condition mimics the behavior in Classic.
	if ( UnitLevel("player") == GetMaxPlayerLevel() ) then
		ShowWatchBarText(ReputationWatchBar);
	end
	
	MicroButtonPulseStop(CharacterMicroButton);	--Stop the button pulse
end

function CharacterFrame_OnHide(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();
	PlayerFrameHealthBar.showNumeric = nil;
	PlayerFrameManaBar.showNumeric = nil;
	PetFrameHealthBar.showNumeric = nil;
	PetFrameManaBar.showNumeric = nil;
	HideTextStatusBarText(PlayerFrameHealthBar);
	HideTextStatusBarText(PlayerFrameManaBar);
	HideTextStatusBarText(PetFrameHealthBar);
	HideTextStatusBarText(PetFrameManaBar);
	PaperDollFrame.currentSideBar = nil;
end

local function CompareFrameSize(frame1, frame2)
	return frame1:GetWidth() > frame2:GetWidth();
end
local CharTabtable = {}; 
function CharacterFrame_TabBoundsCheck(self)
	if ( string.sub(self:GetName(), 1, 17) ~= "CharacterFrameTab" ) then
		return;
	end
	
	for i=1, NUM_CHARACTERFRAME_TABS do
		_G["CharacterFrameTab"..i.."Text"]:SetWidth(0);
		PanelTemplates_TabResize(_G["CharacterFrameTab"..i], 0, nil);
	end
	
	local diff = _G["CharacterFrameTab"..NUM_CHARACTERFRAME_TABS]:GetRight() - CharacterFrameCloseButton:GetRight();
	if ( diff > 0 and CharacterFrameTab3:IsShown() ) then
		--Find the biggest tab
		for i=1, NUM_CHARACTERFRAME_TABS do
			CharTabtable[i]=_G["CharacterFrameTab"..i];
		end
		table.sort(CharTabtable, CompareFrameSize);
		
		local i=1;
		while ( diff > 0 and i <= NUM_CHARACTERFRAME_TABS) do
			local tabText = _G[CharTabtable[i]:GetName().."Text"]
			local change = min(10, diff);
			diff = diff - change;
			tabText:SetWidth(0);
			PanelTemplates_TabResize(CharTabtable[i], -change, nil, 36-change, 88);
			i = i+1;
		end
	end
end
