
function GuildRegistrar_OnLoad(self)
	self:RegisterEvent("GUILD_REGISTRAR_SHOW");
	self:RegisterEvent("GUILD_REGISTRAR_CLOSED");
end

function GuildRegistrar_OnEvent(self, event)
	if ( event == "GUILD_REGISTRAR_SHOW" ) then
		ShowUIPanel(GuildRegistrarFrame);
		if ( not GuildRegistrarFrame:IsShown() ) then
			ClosePetitionRegistrar();
		end
	elseif ( event == "GUILD_REGISTRAR_CLOSED" ) then
		HideUIPanel(GuildRegistrarFrame);
	end
end

function GuildRegistrar_OnShow(self)
	GuildRegistrarGreetingFrame:Show();
	GuildRegistrarPurchaseFrame:Hide();
	SetPortraitTexture(GuildRegistrarFramePortrait, "NPC");
	GuildRegistrarFrameNpcNameText:SetText(UnitName("NPC"));
	PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
end

function GuildRegistrar_OnHide(self)
	PlaySound(SOUNDKIT.IG_QUEST_LIST_CLOSE);
	StaticPopup_Hide("CONFIRM_GUILD_CHARTER_PURCHASE");
	ClosePetitionRegistrar();
end

function GuildRegistrar_ShowPurchaseFrame()
	GuildRegistrarPurchaseFrame:Show();
	GuildRegistrarGreetingFrame:Hide();
	MoneyFrame_Update("GuildRegistrarMoneyFrame", GetGuildCharterCost());
end

function GuildRegistrar_PurchaseCharter(hasConfirmed)
	BuyGuildCharter(GuildRegistrarFrameEditBox:GetText());
	HideUIPanel(GuildRegistrarFrame);
	ChatEdit_FocusActiveWindow();
end