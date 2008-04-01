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