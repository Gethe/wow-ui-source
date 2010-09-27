function GuildRegistrar_OnShow()
	GuildRegistrarGreetingFrame:Show();
	GuildRegistrarPurchaseFrame:Hide();
	SetPortraitTexture(GuildRegistrarFramePortrait, "NPC");
	GuildRegistrarFrameNpcNameText:SetText(UnitName("NPC"));
end

function GuildRegistrar_ShowPurchaseFrame()
	GuildRegistrarPurchaseFrame:Show();
	GuildRegistrarGreetingFrame:Hide();
	MoneyFrame_Update("GuildRegistrarMoneyFrame", GetGuildCharterCost());
end

function GuildRegistrar_PurchaseCharter(hasConfirmed)
	local name, description, standingID, barMin, barMax, barValue = GetGuildFactionInfo();
	if ( not hasConfirmed and ( standingID > 4 or barValue > 0 ) ) then
		StaticPopup_Show("CONFIRM_GUILD_CHARTER_PURCHASE");
	else
		BuyGuildCharter(GuildRegistrarFrameEditBox:GetText());
		HideUIPanel(GuildRegistrarFrame);
		ChatEdit_FocusActiveWindow();
	end
end