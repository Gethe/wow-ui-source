function ItemTextFrame_OnLoad()
	this:RegisterEvent("ITEM_TEXT_BEGIN");
	this:RegisterEvent("ITEM_TEXT_TRANSLATION");
	this:RegisterEvent("ITEM_TEXT_READY");
	this:RegisterEvent("ITEM_TEXT_CLOSED");
	ItemTextScrollFrame.scrollBarHideable = 1;
	ItemTextScrollFrameScrollBar:Hide();
end

function ItemTextFrame_OnEvent(event)
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
		local textColor = MATERIAL_TEXT_COLOR_TABLE[material];
		ItemTextPageText:SetTextColor(textColor[1], textColor[2], textColor[3]);
		return;
	end
	if ( event == "ITEM_TEXT_TRANSLATION" ) then
		ItemTextPrevPageButton:Hide();
		ItemTextNextPageButton:Hide();
		this.translationElapsed = 0;
		ItemTextStatusBar:SetMinMaxValues(0, arg1);
		ItemTextStatusBar:Show();
		ShowUIPanel(this);
		if ( not this:IsVisible() ) then
			CloseItemText();
		end
		return;
	end
	if ( event == "ITEM_TEXT_READY" ) then
		local creator = ItemTextGetCreator();
		if ( creator ) then
			creator = "\n\n"..ITEM_TEXT_FROM.."\n"..creator.."\n\n";
			ItemTextPageText:SetText("\n"..ItemTextGetText()..creator);
		else
			ItemTextPageText:SetText("\n"..ItemTextGetText().."\n");
		end
		
		ItemTextScrollFrame:UpdateScrollChildRect();
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
		ShowUIPanel(this);
		if ( not this:IsVisible() ) then
			CloseItemText();
		end
		return;
	end
	if ( event == "ITEM_TEXT_CLOSED" ) then
		HideUIPanel(this);
		return;
	end
end

function ItemTextFrame_OnUpdate(elapsed)
	if ( ItemTextStatusBar:IsVisible() ) then
		elapsed = this.translationElapsed + elapsed;
		ItemTextStatusBar:SetValue(elapsed);
		this.translationElapsed = elapsed;
	end
end
