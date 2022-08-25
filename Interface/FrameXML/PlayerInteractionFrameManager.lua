--[[
frame = [REQUIRED][FRAME] - The frame that is intended to open
showFunc = [OPTIONAL][FUNCTION] - This will happen when we recieve the event with this type.. If none is specified ShowUIPanel will be called by default.
hideFunc = [OPTIONAL][FUNCTION] - This happens on PLAYER_INTERACTION_FRAME_HIDE. If nothing is specified, HideUIPanel will be called. 
loadFunc = [OPTIONAL][FUNCTION] - Only need to specify if the frame requires to be loaded before used. 
]]
local InteractionManagerFrameInfo = {
	[Enum.PlayerInteractionType.Merchant] = 
	{ 
		frame = "MerchantFrame",
		showFunc = MerchantFrame_MerchantShow,
		hideFunc = MerchantFrame_MerchantClosed
	}, 
	[Enum.PlayerInteractionType.Banker] = 
	{ 
		frame = "BankFrame",
		showFunc = BankFrame_Open,
	}, 
	[Enum.PlayerInteractionType.Trainer] = 
	{ 
		frame = "ClassTrainerFrame",
		showFunc = ClassTrainerFrame_Show,
		hideFunc = ClassTrainerFrame_Hide,
		loadFunc = ClassTrainerFrame_LoadUI
	},
	[Enum.PlayerInteractionType.AlliedRaceDetailsGiver] = 
	{
		frame = "AlliedRacesFrame",
		loadFunc = AlliedRaces_LoadUI,
		showFunc = nop; 
	},
	[Enum.PlayerInteractionType.GuildBanker] = 
	{
		frame = "GuildBankFrame",
		loadFunc = GuildBankFrame_LoadUI,
	}, 
	[Enum.PlayerInteractionType.Registrar] = 
	{
		frame = "GuildRegistrarFrame"
	}, 
	[Enum.PlayerInteractionType.TabardVendor] = 
	{ 
		frame = "TabardFrame", 
		showFunc = TabardFrame_Open 
	},
	[Enum.PlayerInteractionType.MailInfo] = 
	{
		frame = "MailFrame", 
		showFunc = MailFrame_Show,
		hideFunc = MailFrame_Hide
	},
	[Enum.PlayerInteractionType.Auctioneer] = 
	{
		frame = "AuctionHouseFrame",
		showFunc = function() 
			if ( GameLimitedMode_IsActive() ) then
				UIErrorsFrame:AddExternalErrorMessage(ERR_FEATURE_RESTRICTED_TRIAL);
				C_AuctionHouse.CloseAuctionHouse(); 
			else 
				ShowUIPanel(AuctionHouseFrame); 
			end
		end;
	},
	[Enum.PlayerInteractionType.Transmogrifier] = 
	{ 
		frame = "WardrobeFrame",
		loadFunc = CollectionsJournal_LoadUI 
	},
	[Enum.PlayerInteractionType.VoidStorageBanker] = {
		frame = "VoidStorageFrame",
		loadFunc = VoidStorage_LoadUI
	},
	[Enum.PlayerInteractionType.BlackMarketAuctioneer] = {
		frame = "BlackMarketFrame",
		showFunc = BlackMarketFrame_Show, 
		hideFunc = BlackMarketFrame_Hide, 
		loadFunc = BlackMarket_LoadUI, 
	},
	[Enum.PlayerInteractionType.WorldMap] = {
		frame = "WorldMapFrame",
		showFunc = nop; 
	},
	[Enum.PlayerInteractionType.GarrArchitect] = {
		frame = "GarrisonBuildingFrame",
		loadFunc = Garrison_LoadUI, 
	},
	[Enum.PlayerInteractionType.Trophy] = {
		frame = "GarrisonMonumentFrame",
		showFunc = C_Trophy and C_Trophy.MonumentLoadList or nil;
		loadFunc = Garrison_LoadUI
	},
	[Enum.PlayerInteractionType.ObliterumForge] = {
		frame = "ObliterumForgeFrame",
		loadFunc = ObliterumForgeFrame_LoadUI
	},
	[Enum.PlayerInteractionType.ScrappingMachine] = {
		frame = "ScrappingMachineFrame", 
		loadFunc = ScrappingMachineFrame_LoadUI, 
	},
	[Enum.PlayerInteractionType.ContributionCollector] = {
		frame = "ContributionCollectionFrame",
		loadFunc = function() UIParentLoadAddOn("Blizzard_Contribution") end; 
	},
	[Enum.PlayerInteractionType.AzeriteRespec] = {
		frame = "AzeriteRespecFrame",
		loadFunc = AzeriteRespecFrame_LoadUI
	},
	[Enum.PlayerInteractionType.IslandQueue] = {
		frame = "IslandsQueueFrame", 
		loadFunc = IslandsQueue_LoadUI
	},
	[Enum.PlayerInteractionType.ItemInteraction] = {
		frame = "ItemInteractionFrame", 
		loadFunc = ItemInteraction_LoadUI
	},
	[Enum.PlayerInteractionType.ChromieTime] = {
		frame = "ChromieTimeFrame", 
		loadFunc = ChromieTimeFrame_LoadUI
	},
	[Enum.PlayerInteractionType.WeeklyRewards] = {
		frame = "WeeklyRewardsFrame", 
		loadFunc = WeeklyRewards_LoadUI,
		forceShow = true
	},
	[Enum.PlayerInteractionType.Soulbind] = {
		frame = "SoulbindViewer",
		loadFunc = function() LoadAddOn("Blizzard_Soulbinds"); end; 
		showFunc = function() SoulbindViewer:Open(); end; 
	},
	[Enum.PlayerInteractionType.CovenantSanctum] = {
		frame = "CovenantSanctumFrame", 
		loadFunc = CovenantSanctum_LoadUI, 
		showFunc = function() CovenantSanctumFrame:InteractionStarted(); end; 
	}, 
	[Enum.PlayerInteractionType.Renown] = {
		frame = "CovenantRenownFrame", 
		loadFunc = CovenantRenown_LoadUI
	},
	[Enum.PlayerInteractionType.ItemUpgrade] = {
		frame = "ItemUpgradeFrame", 
		loadFunc = ItemUpgrade_LoadUI,
		showFunc = ItemUpgradeFrame_Show, 
		hideFunc = ItemUpgradeFrame_Hide
	},
	[Enum.PlayerInteractionType.AzeriteForge] = {
		frame = "AzeriteEssenceUI",
		loadFunc = function() UIParentLoadAddOn("Blizzard_AzeriteEssenceUI"); end; 
		showFunc = function() if AzeriteEssenceUI:TryShow() and AzeriteEssenceUI:ShouldOpenBagsOnShow() then OpenAllBags(AzeriteEssenceUI); end; end; 
	},
	[Enum.PlayerInteractionType.AdventureJournal] = { 
		frame = "EncounterJournal",
		loadFunc = EncounterJournal_LoadUI,
		showFunc = function () if (C_AdventureJournal.CanBeShown()) then ShowUIPanel(EncounterJournal); EJSuggestFrame_OpenFrame(); end; end; 
	},
	[Enum.PlayerInteractionType.MajorFactionRenown] = {
		frame = "MajorFactionRenownFrame",
		loadFunc = MajorFactions_LoadUI,
		-- Todo: Pull this into a "Major Factions" function so it can be reused
		showFunc = function() 
						local majorFactionID = C_MajorFactions.GetRenownNPCFactionID();
						HideUIPanel(MajorFactionRenownFrame);
						if majorFactionID > 0 then
							EventRegistry:TriggerEvent("MajorFactionRenownMixin.MajorFactionRenownRequest", majorFactionID);
							ShowUIPanel(MajorFactionRenownFrame);
						end
					end;
	}
};

PlayerInteractionFrameManagerMixin = { };

function PlayerInteractionFrameManagerMixin:ShowFrame(type)
	local frameInfo = InteractionManagerFrameInfo[type]; 
	if(not frameInfo) then 
		return; 
	end 

	if(frameInfo.loadFunc and not _G[frameInfo.frame]) then 
		frameInfo.loadFunc(); 
	end			

	if(frameInfo.showFunc) then 
		frameInfo.showFunc(); 
	else 
		ShowUIPanel(_G[frameInfo.frame], frameInfo.forceShow);
	end		
end		

function PlayerInteractionFrameManagerMixin:HideFrame(type)
	local frameInfo = InteractionManagerFrameInfo[type]; 
	if(not frameInfo) then 
		return; 
	end 

	-- The frame isn't loaded, so nothing to hide. 
	if(not _G[frameInfo.frame]) then 
		return;
	end

	if(frameInfo.hideFunc) then 
		frameInfo.hideFunc();
	else 
		HideUIPanel(_G[frameInfo.frame]); 
	end				
end

function PlayerInteractionFrameManagerMixin:OnLoad() 
	self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW");
	self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE");
end	

function PlayerInteractionFrameManagerMixin:OnEvent(event, ...) 
	if(event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW") then 
		local type = ...; 
		self:ShowFrame(type);
	elseif (event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE") then 
		local type = ...; 
		self:HideFrame(type);
	end		
end		