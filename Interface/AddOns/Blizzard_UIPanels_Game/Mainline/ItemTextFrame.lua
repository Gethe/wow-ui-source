function ItemTextFrame_OnLoad(self)
	self:RegisterEvent("ITEM_TEXT_BEGIN");
	self:RegisterEvent("ITEM_TEXT_TRANSLATION");
	self:RegisterEvent("ITEM_TEXT_READY");
	self:RegisterEvent("ITEM_TEXT_CLOSED");
	ButtonFrameTemplate_HideButtonBar(self);
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

function ItemTextFrame_OnEvent(self, event, ...)
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
		if QuestUtil.QuestTextContrastUseLightText() then
			textColor, titleTextColor = GetMaterialTextColors("Stone");
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
		local page = ItemTextGetPage();
		local hasNext = ItemTextHasNextPage();

		if ( material == "Parchment" ) then
			ItemTextMaterialTopLeft:Hide();
			ItemTextMaterialTopRight:Hide();
			ItemTextMaterialBotLeft:Hide();
			ItemTextMaterialBotRight:Hide();
			ItemTextFramePageBg:Show();
			ItemTextFramePageBg:SetAtlas(QuestUtil.GetDefaultQuestBackgroundTexture());
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
		if ( (page > 1) or hasNext ) then
			ItemTextCurrentPage:SetText(page);
			ItemTextCurrentPage:Show();
			if ( page > 1 ) then
				ItemTextPrevPageButton:Show();
			else
				ItemTextPrevPageButton:Hide();
			end
			if ( hasNext ) then
				ItemTextNextPageButton:Show();
			else
				ItemTextNextPageButton:Hide();
			end
		end
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

function ItemTextFrame_OnUpdate(self, elapsed)
	if ( ItemTextStatusBar:IsShown() ) then
		elapsed = self.translationElapsed + elapsed;
		ItemTextStatusBar:SetValue(elapsed);
		self.translationElapsed = elapsed;
	end
end
