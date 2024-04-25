
local PersonalTabardItemID = 210469;


function TabardFrame_OnLoad(self)
	self:RegisterEvent("TABARD_CANSAVE_CHANGED");
	self:RegisterEvent("TABARD_SAVE_PENDING");
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");

	local backgroundAlpha = 0.40;
	TabardFrameEmblemTopRight:SetAlpha(backgroundAlpha);
	TabardFrameEmblemTopLeft:SetAlpha(backgroundAlpha);
	TabardFrameEmblemBottomRight:SetAlpha(backgroundAlpha);
	TabardFrameEmblemBottomLeft:SetAlpha(backgroundAlpha);
	
	MoneyFrame_SetMaxDisplayWidth(TabardFrameMoneyFrame, 160);
end

function TabardFrame_Open()
	SetPortraitTexture(TabardFramePortrait,"npc");
	TabardFrameNameText:SetText(UnitName("npc"));
	TabardModel:InitializeTabardColors();
	TabardFrame_UpdateTextures();
	TabardFrame_UpdateButtons();
	ShowUIPanel(TabardFrame);

	if ( TabardModel:IsGuildTabard() ) then
		MoneyFrame_Update("TabardFrameCostMoneyFrame", GetTabardCreationCost());
		TabardFrameCostFrame:Show();

		TabardFrameMoneyInset:Show();
		TabardFrameMoneyBg:Show();
		TabardFrameMoneyFrame:Show();
	else
		TabardFrameCostFrame:Hide();

		TabardFrameMoneyInset:Hide();
		TabardFrameMoneyBg:Hide();
		TabardFrameMoneyFrame:Hide();
	end

	if ( not TabardFrame:IsShown() ) then
		CloseTabardCreation();
	end
end

function TabardFrame_OnEvent(self, event, ...)
	if ( event == "TABARD_CANSAVE_CHANGED" or event == "TABARD_SAVE_PENDING" ) then
		TabardFrame_UpdateButtons();
	elseif ( event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" or event == "UNIT_MODEL_CHANGED" ) then
		-- This will happen even on initial open.
		TabardModel:SetUnit("player");
	end
end

function TabardCustomization_Left(id)
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
	TabardModel:CycleVariation(id,-1);
	TabardFrame_UpdateTextures();
end

function TabardCustomization_Right(id)
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
	TabardModel:CycleVariation(id,1);
	TabardFrame_UpdateTextures();
end

function TabardFrame_UpdateTextures()
	TabardModel:GetUpperEmblemTexture(TabardFrameEmblemTopLeft);
	TabardModel:GetUpperEmblemTexture(TabardFrameEmblemTopRight);
	TabardModel:GetLowerEmblemTexture(TabardFrameEmblemBottomLeft);
	TabardModel:GetLowerEmblemTexture(TabardFrameEmblemBottomRight);
end

function TabardFrame_UpdateButtons()
	local guildName, rankName, rank = GetGuildInfo("player");
	if ( TabardModel:IsGuildTabard() and (guildName == nil or rankName == nil or ( rank > 0 )) ) then
		TabardFrameGreetingText:SetText(TABARDVENDORNOGUILDGREETING);
		TabardFrameAcceptButton:Disable();
	else
		if (TabardModel:IsGuildTabard()) then
			TabardFrameGreetingText:SetText(TABARDVENDORGREETING);
		else
			local includeBank = true;
			local ownedItemCount = C_Item.GetItemCount(PersonalTabardItemID, includeBank);
			if ownedItemCount == 0 then
				TabardFrameGreetingText:SetText(PERSONALTABARDVENDORUNOWNEDGREETING);
			else
				TabardFrameGreetingText:SetText(PERSONALTABARDVENDORGREETING);
			end
		end

		if( TabardModel:CanSaveTabardNow() ) then
			TabardFrameAcceptButton:Enable();
		else
			TabardFrameAcceptButton:Disable();
		end
	end
end