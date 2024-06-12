
GlueMenuFrameUtil = {};

GlueMenuFrameUtil.GlueMenuContextKey = "GlueMenuFrame";

function GlueMenuFrameUtil.ShowMenu()
	GlueMenuFrame:Show();
end

function GlueMenuFrameUtil.HideMenu()
	PlaySound(SOUNDKIT.IG_MAINMENU_CONTINUE);
	GlueMenuFrame:Hide();
end

function GlueMenuFrameUtil.ToggleMenu()
	if GlueMenuFrame:IsShown() then
		GlueMenuFrameUtil.HideMenu();
	else
		GlueMenuFrameUtil.ShowMenu();
	end
end


GlueMenuFrameMixin = {};

function GlueMenuFrameMixin:OnShow()
	BaseLayoutMixin.OnShow(self);

	GlueParent_AddModalFrame(self);
	self:InitButtons();
end

function GlueMenuFrameMixin:OnHide()
	GlueParent_RemoveModalFrame(self);
end

function GlueMenuFrameMixin:InitButtons()
	if GlueParent_GetCurrentScreen() == "charselect" then
		self:InitCharacterSelectButtons();
	else
		self:InitAccountLoginButtons();
	end
end

function GlueMenuFrameMixin:GenerateMenuCallback(callback)
	return function()
		self:Hide();
		callback();
	end;
end

function GlueMenuFrameMixin:InitAccountLoginButtons()
	self:Reset();

	self:AddButton(GAMEMENU_OPTIONS, self:GenerateMenuCallback(GenerateFlatClosure(GlueParent_ShowOptionsScreen, GlueMenuFrameUtil.GlueMenuContextKey)));

	self:AddSection();

	self:AddButton(CREDITS, self:GenerateMenuCallback(GenerateFlatClosure(GlueParent_ShowCreditsScreen, GlueMenuFrameUtil.GlueMenuContextKey)));
	self:AddButton(CINEMATICS, self:GenerateMenuCallback(GenerateFlatClosure(GlueParent_ShowCinematicsScreen, GlueMenuFrameUtil.GlueMenuContextKey)));
	self:AddButton(MANAGE_ACCOUNT, self:GenerateMenuCallback(GenerateFlatClosure(AccountLogin_ManageAccount, GlueMenuFrameUtil.GlueMenuContextKey)));
	self:AddButton(COMMUNITY_SITE, self:GenerateMenuCallback(GenerateFlatClosure(AccountLogin_LaunchCommunitySite, GlueMenuFrameUtil.GlueMenuContextKey)));
	self:AddButton(EXIT_GAME, GenerateFlatClosure(QuitGame));

	self:AddCloseButton();
end

function GlueMenuFrameMixin:InitCharacterSelectButtons()
	self:Reset();

	self:AddButton(GAMEMENU_OPTIONS, self:GenerateMenuCallback(GenerateFlatClosure(GlueParent_ShowOptionsScreen, GlueMenuFrameUtil.GlueMenuContextKey)));

	local isStoreDisabled = not CharacterSelectUtil.ShouldStoreBeEnabled();
	self:AddButton(BLIZZARD_STORE, self:GenerateMenuCallback(GenerateFlatClosure(ToggleStoreUI, GlueMenuFrameUtil.GlueMenuContextKey)), isStoreDisabled);

	self:AddSection();

	if C_AddOns.GetNumAddOns() > 0 then
		local function ShowAddOnList()
			self:Hide();
			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS);
			AddonList:Show();
		end

		self:AddButton(ADDONS, ShowAddOnList);
	end

	self:AddButton(CREDITS, self:GenerateMenuCallback(GenerateFlatClosure(GlueParent_ShowCreditsScreen, GlueMenuFrameUtil.GlueMenuContextKey)));
	self:AddButton(CINEMATICS, self:GenerateMenuCallback(GenerateFlatClosure(GlueParent_ShowCinematicsScreen, GlueMenuFrameUtil.GlueMenuContextKey)));
	self:AddButton(EXIT_GAME, GenerateFlatClosure(QuitGame));

	self:AddCloseButton();
end
