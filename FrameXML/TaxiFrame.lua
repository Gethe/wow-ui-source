
TAXI_MAP_WIDTH = 280;
TAXI_MAP_HEIGHT = 280;
TAXI_BUTTONS = 64;

TaxiButtonTypes = { };
TaxiButtonTypes["CURRENT"] = {
	file = "Interface\\TaxiFrame\\UI-Taxi-Icon-Green"
}
TaxiButtonTypes["REACHABLE"] = {
	file = "Interface\\TaxiFrame\\UI-Taxi-Icon-Yellow"
}
TaxiButtonTypes["DISTANT"] = {
	file = "Interface\\TaxiFrame\\UI-Taxi-Icon-Yellow"
}


function TaxiFrame_OnLoad()
	this:RegisterEvent("TAXIMAP_OPENED");
	this:RegisterEvent("TAXIMAP_CLOSED");
end

function TaxiFrame_OnEvent(event)
	if ( event == "TAXIMAP_OPENED" ) then
		-- Show the merchant we're dealing with
		TaxiMerchant:SetText(UnitName("npc"));
		SetPortraitTexture(TaxiPortrait, "npc");

		-- Set the texture coords on the map
		TaxiMap:SetTexCoord(0,1,0,1);
		SetTaxiMap(TaxiMap);

		-- Show the taxi node map and buttons
		local last_button = 1;
		local num_nodes = NumTaxiNodes();
		if ( num_nodes > TAXI_BUTTONS ) then
			message("Warning: Not enough taxi node buttons ("..num_nodes..")");
			num_nodes = TAXI_BUTTONS;
		end

		for index = last_button, num_nodes, 1 do
			local type = TaxiNodeGetType(index);
			local button = getglobal("TaxiButton"..index);
			if ( type ~= "NONE" ) then
				local x, y = TaxiNodePosition(button:GetID());
				button:ClearAllPoints();
				button:SetPoint("CENTER", "TaxiMap", "BOTTOMLEFT", x*TAXI_MAP_WIDTH, y*TAXI_MAP_HEIGHT);
				button:SetNormalTexture(TaxiButtonTypes[type].file);
				button:Show();
				last_button = index+1;
			else
				button:Hide();
			end
		end
		for index = last_button, TAXI_BUTTONS, 1 do
			local button = getglobal("TaxiButton"..index);
			button:Hide();
		end

		-- All set...
		ShowUIPanel(this);
		if ( not this:IsVisible() ) then
			CloseTaxiMap();
		end
		return;
	end
	if ( event == "TAXIMAP_CLOSED" ) then
		HideUIPanel(this);
		return;
	end
end

function TaxiNodeOnButtonEnter(button) 
	local index = this:GetID();
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
	GameTooltip:AddLine(TaxiNodeName(index), "", 1.0, 1.0, 1.0);
	
	local type = TaxiNodeGetType(index);
	if ( type == "REACHABLE" ) then
		SetTooltipMoney(GameTooltip, TaxiNodeCost(this:GetID()));
	elseif ( type == "CURRENT" ) then
		GameTooltip:AddLine(TEXT(TAXINODEYOUAREHERE), "", 0.5, 1.0, 0.5);
	end
	GameTooltip:Show();
end