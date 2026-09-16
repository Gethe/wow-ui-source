ItemTextFrameMixin = {};

function ItemTextFrameMixin:OnLoad()
	self:RegisterEvent("ITEM_TEXT_BEGIN");
	self:RegisterEvent("ITEM_TEXT_TRANSLATION");
	self:RegisterEvent("ITEM_TEXT_READY");
	self:RegisterEvent("ITEM_TEXT_CLOSED");
	ButtonFrameTemplate_HideButtonBar(self);
	self:RegisterForTransitions();
end

DEFAULT_ITEM_TEXT_FRAME_WIDTH = 338;
DEFAULT_ITEM_TEXT_FRAME_HEIGHT = 424;

EXPANDED_ITEM_TEXT_FRAME_WIDTH = 520;
EXPANDED_ITEM_TEXT_FRAME_HEIGHT = 560;

ITEM_TEXT_FONTS = {
	["ParchmentLarge"] = {
		["P"]  = QuestFont,
		["H1"] = Fancy48Font,
		["H2"] = Game20Font,
		["H3"] = Fancy32Font
	},
	["default"] = {
		["P"]  = QuestFont,
		["H1"] = QuestFont,
		["H2"] = QuestFont,
		["H3"] = QuestFont
	}
};

function ItemTextFrameMixin:OnEvent(event, ...)
	if ( event == "ITEM_TEXT_BEGIN" ) then
		self:SetTitle(ItemTextGetItem());
		ItemTextScrollFrame:Hide();
		ItemTextCurrentPage:Hide();
		ItemTextStatusBar:Hide();
		ItemTextPrevPageButton:Hide();
		ItemTextNextPageButton:Hide();
		local material = ItemTextGetMaterial();
		if ( not material ) then
			material = "Parchment";
		end

		-- Set up fonts
		local fontTable = ITEM_TEXT_FONTS[material];
		if(fontTable == nil) then
			fontTable = ITEM_TEXT_FONTS["default"];
		end
		for tag, font in pairs(fontTable) do
			ItemTextPageText:SetFontObject(tag, font);
		end

		-- Set up text colors
		local textColor, titleColor = GetMaterialTextColors(material);
		if QuestTextContrast.UseLightText() then
			textColor, titleColor = GetMaterialTextColors("Stone");
		end
		if(material == "ParchmentLarge") then
			ItemTextPageText:SetTextColor("P", textColor[1], textColor[2], textColor[3]);
			ItemTextPageText:SetTextColor("H1", titleColor[1], titleColor[2], titleColor[3]);
			ItemTextPageText:SetTextColor("H2", titleColor[1], titleColor[2], titleColor[3]);
			ItemTextPageText:SetTextColor("H3", titleColor[1], titleColor[2], titleColor[3]);
		else
			-- Legacy behavior - ignore the title color
			ItemTextPageText:SetTextColor("P", textColor[1], textColor[2], textColor[3]);
			ItemTextPageText:SetTextColor("H1", textColor[1], textColor[2], textColor[3]);
			ItemTextPageText:SetTextColor("H2", textColor[1], textColor[2], textColor[3]);
			ItemTextPageText:SetTextColor("H3", textColor[1], textColor[2], textColor[3]);
		end

		return;
	elseif ( event == "ITEM_TEXT_TRANSLATION" ) then
		local arg1 = ...;
		ItemTextPrevPageButton:Hide();
		ItemTextNextPageButton:Hide();
		self.translationElapsed = 0;
		ItemTextStatusBar:SetMinMaxValues(0, arg1);
		ItemTextStatusBar:Show();
		ShowUIPanel(self);
		if ( not self:IsShown() ) then
			CloseItemText();
		end
		return;
	elseif ( event == "ITEM_TEXT_READY" ) then

		local material = ItemTextGetMaterial();
		if ( not material ) then
			material = "Parchment";
		end

		if (material == "ParchmentLarge") then
			self:SetWidth(EXPANDED_ITEM_TEXT_FRAME_WIDTH);
			self:SetHeight(EXPANDED_ITEM_TEXT_FRAME_HEIGHT);
			ItemTextScrollFrame:SetPoint("TOPRIGHT", self, "TOPRIGHT", -27, -89);
			ItemTextScrollFrame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 6, 6);
			ItemTextPageText:SetPoint("TOPLEFT", 34, -15);
			ItemTextPageText:SetWidth(412);
			ItemTextPageText:SetHeight(440);
		else
			self:SetWidth(DEFAULT_ITEM_TEXT_FRAME_WIDTH);
			self:SetHeight(DEFAULT_ITEM_TEXT_FRAME_HEIGHT);
			if (ItemTextIsFullPage()) then
				ItemTextScrollFrame:SetPoint("TOPRIGHT", self, "TOPRIGHT", -31, -63);
				ItemTextScrollFrame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 6, 6);
				ItemTextPageText:SetPoint("TOPLEFT", 0, 0);
				ItemTextPageText:SetWidth(301);
				ItemTextPageText:SetHeight(355);
			else
				ItemTextScrollFrame:SetPoint("TOPRIGHT", self, "TOPRIGHT", -31, -63);
				ItemTextScrollFrame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 6, 6);
				ItemTextPageText:SetPoint("TOPLEFT", 18, -15);
				ItemTextPageText:SetWidth(270);
				ItemTextPageText:SetHeight(304);
			end
		end

		local creator = ItemTextGetCreator();
		if ( creator ) then
			creator = "\n\n"..ITEM_TEXT_FROM.."\n"..creator.."\n";
			ItemTextPageText:SetText(ItemTextGetText()..creator);
		else
			ItemTextPageText:SetText(ItemTextGetText());
		end

		-- Add some padding at the bottom if the bar can scroll appreciably
		ItemTextScrollFrame:GetScrollChild():SetHeight(1);
		ItemTextScrollFrame:UpdateScrollChildRect();
		if(floor(ItemTextScrollFrame:GetVerticalScrollRange()) > 0) then
			ItemTextScrollFrame:GetScrollChild():SetHeight(ItemTextScrollFrame:GetHeight() + ItemTextScrollFrame:GetVerticalScrollRange() + 30);
		end

		ItemTextScrollFrame.ScrollBar:ScrollToBegin();
		ItemTextScrollFrame:Show();

		if ( material == "Parchment" ) then
			ItemTextMaterialTopLeft:Hide();
			ItemTextMaterialTopRight:Hide();
			ItemTextMaterialBotLeft:Hide();
			ItemTextMaterialBotRight:Hide();
			ItemTextFramePageBg:Show();
			ItemTextFramePageBg:SetAtlas(QuestTextContrast.GetDefaultBackgroundAtlas());
			ItemTextFramePageBg:SetWidth(299);
			ItemTextFramePageBg:SetHeight(357);
		elseif ( material == "ParchmentLarge" ) then
			ItemTextMaterialTopLeft:Hide();
			ItemTextMaterialTopRight:Hide();
			ItemTextMaterialBotLeft:Hide();
			ItemTextMaterialBotRight:Hide();
			ItemTextFramePageBg:Show();
			ItemTextFramePageBg:SetAtlas("Book-bg", true);
		else
			ItemTextFramePageBg:Hide();
			ItemTextMaterialTopLeft:Show();
			ItemTextMaterialTopRight:Show();
			ItemTextMaterialBotLeft:Show();
			ItemTextMaterialBotRight:Show();
			ItemTextMaterialTopLeft:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-TopLeft");
			ItemTextMaterialTopRight:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-TopRight");
			ItemTextMaterialBotLeft:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-BotLeft");
			ItemTextMaterialBotRight:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-BotRight");
		end
		self:HandlePagingDisplay();
		ItemTextStatusBar:Hide();
		ShowUIPanel(self);
		if ( not self:IsShown() ) then
			CloseItemText();
		end
		return;
	elseif ( event == "ITEM_TEXT_CLOSED" ) then
		HideUIPanel(self);
		return;
	end
end

function ItemTextFrameMixin:HandlePagingDisplay()
	local page = ItemTextGetPage();
	local hasNext = ItemTextHasNextPage();

	ItemTextCurrentPage:SetText(page);
	ItemTextCurrentPage:SetShown(hasNext or (page > 1))

	-- Update Gamepad specific nav buttons
	if InputUtil.IsGamepadUIEnabled() then
		GamepadItemTextPrevPageButton:UpdateEnabledState();
		GamepadItemTextNextPageButton:UpdateEnabledState();
		return;
	end

	ItemTextPrevPageButton:SetShown(page > 1);
	ItemTextNextPageButton:SetShown(hasNext);
end

function ItemTextFrameMixin:OnUpdate(elapsed)
	if ( ItemTextStatusBar:IsShown() ) then
		elapsed = self.translationElapsed + elapsed;
		ItemTextStatusBar:SetValue(elapsed);
		self.translationElapsed = elapsed;
	end
end

function ItemTextFrame_NextPageOnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	ItemTextNextPage();

	ItemTextFrame:RefreshBindingVisibility();
end

function ItemTextFrame_PrevPageOnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	ItemTextPrevPage();

	ItemTextFrame:RefreshBindingVisibility();
end

function ItemTextFrameMixin:RefreshBindingVisibility()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	-- Refresh binding visibility state if in gamepad mode
	self.itemTextFrameFooter:Refresh();
end

function ItemTextFrameMixin:FocusGamepad()
	SmartNavigation:SetScrollFrameForFrame(self, ItemTextScrollFrame);
	GamepadScrollBarHint:SetOwner(ItemTextScrollFrame.ScrollBar.Track.Thumb, "CENTER");
	GamepadScrollBarHint:Show();

	self.itemTextFrameFooter:ShowAndActivateBindings();
end

function ItemTextFrameMixin:UnfocusGamepad()
	self.itemTextFrameFooter:HideAndDeactivateBindings();
end

function ItemTextFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadSetup(self, GenerateFlatClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateFlatClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateFlatClosure(self.UninitializeGamepad, self));
end

function ItemTextFrameMixin:SetupGamepad()
	-- Condition visibility of dpad binding
	local itemTextFramePrevious = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_DPAD_LEFT, ItemTextFrame_PrevPageOnClick, PREV);
	itemTextFramePrevious:AddCondition(function()
		return ItemTextGetPage() > 1;
	end);
	itemTextFramePrevious:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	local itemTextFrameNext = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_DPAD_RIGHT, ItemTextFrame_NextPageOnClick, NEXT);
	itemTextFrameNext:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	itemTextFrameNext:AddCondition(ItemTextHasNextPage);

	-- Mirror binding behavior to gamepad nav buttons
	GamepadItemTextPrevPageButton:SetOnClick(ItemTextFrame_PrevPageOnClick);
	GamepadItemTextNextPageButton:SetOnClick(ItemTextFrame_NextPageOnClick);
	GamepadItemTextPrevPageButton:SetEnabledCondition(function()
		return itemTextFramePrevious:AreConditionsMet();
	end);
	GamepadItemTextNextPageButton:SetEnabledCondition(function()
		return itemTextFrameNext:AreConditionsMet();
	end);

	-- Create binding footer
	self.itemTextFrameFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "ItemTextFrameFooter");
	self.itemTextFrameFooter:AddPromptedBinding(itemTextFramePrevious);
	self.itemTextFrameFooter:AddPromptedBinding(itemTextFrameNext);
	self.itemTextFrameFooter:AddStandardBackPrompt();
	self.itemTextFrameFooter:Finalize();
end

function ItemTextFrameMixin:InitializeGamepad()
	self.CloseButton:Hide();
	ItemTextPrevPageButton:Hide();
	ItemTextNextPageButton:Hide();
	GamepadItemTextPrevPageButton:Show();
	GamepadItemTextNextPageButton:Show();
end

function ItemTextFrameMixin:UninitializeGamepad()
	self.CloseButton:Show();
	ItemTextPrevPageButton:Show();
	ItemTextNextPageButton:Show();
	GamepadItemTextPrevPageButton:Hide();
	GamepadItemTextNextPageButton:Hide();
end
