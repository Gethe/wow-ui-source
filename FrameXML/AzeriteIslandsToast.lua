AzeriteIslandsToastMixin = { }; 

function AzeriteIslandsToastMixin:OnLoad()
	self:RegisterEvent("ISLAND_AZERITE_GAIN"); 
end

function AzeriteIslandsToastMixin:ShowWidgetGlow(isHorde)
	for widgetID, widgetFrame in UIWidgetManager:EnumerateWidgetsByWidgetTag("azeriteBar") do	
		widgetFrame:PlayBarGlow(isHorde); 
	end
end

function AzeriteIslandsToastMixin:SetupTextFrame(frame, amount) 
	frame.Text:SetFormattedText(AZERITE_ISLAND_POWER_GAIN_SHORT, amount); 
	frame:Show(); 
	frame.ShowAnim:Play();
end

function AzeriteIslandsToastMixin:OnEvent(event, ...)
	if ( event == "ISLAND_AZERITE_GAIN" ) then 
		local amount, isPlayer, factionIndex = ...; 
		local frame;
		
		local factionGroup = PLAYER_FACTION_GROUP[factionIndex];
		
		if ( isPlayer ) then 
			frame = CreateFrame("FRAME", "AzeriteIslandsToast", self, "AzeriteIslandsPlayerToastTextTemplate"); 
		else 
			frame = CreateFrame("FRAME", "AzeriteIslandsToast", self, "AzeriteIslandsPartyToastTextTemplate");
		end
		
		self:ShowWidgetGlow(factionGroup == "Horde"); 
		self:SetupTextFrame(frame, amount); 
	end
end