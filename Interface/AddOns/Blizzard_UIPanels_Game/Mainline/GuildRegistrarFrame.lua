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
	local guildFactionData = C_Reputation.GetGuildFactionData();
	if ( not hasConfirmed and guildFactionData and ( guildFactionData.reaction > 4 or guildFactionData.currentStanding > 0 ) ) then
		StaticPopup_Show("CONFIRM_GUILD_CHARTER_PURCHASE");
	else
		BuyGuildCharter(GuildRegistrarFrameEditBox:GetText());
		HideUIPanel(GuildRegistrarFrame);
		ChatEdit_FocusActiveWindow();
		GuildRegistrarFrameEditBox:SetText("");
	end
end