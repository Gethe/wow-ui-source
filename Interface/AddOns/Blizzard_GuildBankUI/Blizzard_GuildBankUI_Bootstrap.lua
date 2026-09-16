local AddonName = ...;

function GuildBankFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowGuildBankFrame()
	if GuildBankFrame_LoadUI() then
		ShowUIPanel(GuildBankFrame);
		if ( not GuildBankFrame:IsVisible() ) then
			CloseGuildBankFrame();
		end
	end
end

function HideGuildBankFrame()
	if C_AddOns.IsAddOnLoaded(AddonName) then
		HideUIPanel(GuildBankFrame);
	end
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "GuildBankFrame",
		loadFunc = GuildBankFrame_LoadUI,
		showFunc = ShowGuildBankFrame,
		hideFunc = HideGuildBankFrame,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.GuildBanker, frameInfo);
end

RegisterWithPlayerInteractionManager();
