function ItemTextFrame_OnLoad(self)
	self:RegisterEvent("ITEM_TEXT_BEGIN");
	self:RegisterEvent("ITEM_TEXT_TRANSLATION");
	self:RegisterEvent("ITEM_TEXT_READY");
	self:RegisterEvent("ITEM_TEXT_CLOSED");
	ItemTextScrollFrame.scrollBarHideable = 1;
	ItemTextScrollFrameScrollBar:Hide();
end

function ItemTextFrame_OnEvent(self, event, ...)
	if ( event == "ITEM_TEXT_BEGIN" ) then
		ItemTextTitleText:SetText(ItemTextGetItem());
		ItemTextScrollFrame:Hide();
		ItemTextCurrentPage:Hide();
		ItemTextStatusBar:Hide();
		ItemTextPrevPageButton:Hide();
		ItemTextNextPageButton:Hide();
		local material = ItemTextGetMaterial(); 
		if ( not material ) then
			material = "Parchment";
		end
		local textColor = GetMaterialTextColors(material);
		ItemTextPageText:SetTextColor(textColor[1], textColor[2], textColor[3]);
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
		local creator = ItemTextGetCreator();
		if ( creator ) then
			creator = "\n\n"..ITEM_TEXT_FROM.."\n"..creator.."\n\n\n";
			ItemTextPageText:SetText("\n"..ItemTextGetText()..creator);
		else
			ItemTextPageText:SetText("\n"..ItemTextGetText().."\n\n");
		end
		
		ItemTextScrollFrameScrollBar:SetValue(0);
		ItemTextScrollFrame:Show();	
		local page = ItemTextGetPage();
		local next = ItemTextHasNextPage();
		local material = ItemTextGetMaterial(); 
		if ( not material ) then
			material = "Parchment";
		end
		if ( material == "Parchment" ) then
			ItemTextMaterialTopLeft:Hide();
			ItemTextMaterialTopRight:Hide();
			ItemTextMaterialBotLeft:Hide();
			ItemTextMaterialBotRight:Hide();
		else
			ItemTextMaterialTopLeft:Show();
			ItemTextMaterialTopRight:Show();
			ItemTextMaterialBotLeft:Show();
			ItemTextMaterialBotRight:Show();
			ItemTextMaterialTopLeft:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-TopLeft");
			ItemTextMaterialTopRight:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-TopRight");
			ItemTextMaterialBotLeft:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-BotLeft");
			ItemTextMaterialBotRight:SetTexture("Interface\\ItemTextFrame\\ItemText-"..material.."-BotRight");
		end
		if ( (page > 1) or next ) then
			ItemTextCurrentPage:SetText(page);
			ItemTextCurrentPage:Show();
			if ( page > 1 ) then
				ItemTextPrevPageButton:Show();
			else
				ItemTextPrevPageButton:Hide();
			end
			if ( next ) then
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
