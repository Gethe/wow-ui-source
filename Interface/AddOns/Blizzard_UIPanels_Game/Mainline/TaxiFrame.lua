
TAXI_MAP_WIDTH = 580;
TAXI_MAP_HEIGHT = 580;
NUM_TAXI_BUTTONS = 0;
NUM_TAXI_ROUTES = 0;
TAXIROUTE_LINEFACTOR = 32/30; -- Multiplying factor for texture coordinates

TaxiButtonTypes = { };
TaxiButtonTypes["CURRENT"] = {
	file = "Interface\\TaxiFrame\\UI-Taxi-Icon-Green",
	highlightBrightness = 0

}
TaxiButtonTypes["REACHABLE"] = {
	file = "Interface\\TaxiFrame\\UI-Taxi-Icon-White",
	highlightBrightness = 1
}
TaxiButtonTypes["DISTANT"] = {
	file = "Interface\\TaxiFrame\\UI-Taxi-Icon-Nub",
	highlightBrightness = 0
}
TaxiButtonTypes["UNREACHABLE"] = {
	file = "Interface\\TaxiFrame\\UI-Taxi-Icon-White",
	hoverFile = "Interface\\TaxiFrame\\UI-Taxi-Icon-Red",
	highlightBrightness = 0
}

local taxiNodePositions = {};

TAXI_BUTTON_MIN_DIST = 18;

function TaxiFrame_OnLoad(self)
	self:RegisterEvent("TAXIMAP_CLOSED");
	self.InsetBg:SetHorizTile(false);
	self.InsetBg:SetVertTile(false);
end

function TaxiFrame_OnShow(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);

	self.TitleText:SetText(FLIGHT_MAP);

	-- Set the texture coords on the map
	self.InsetBg:SetTexCoord(0,1,0,1);
	SetTaxiMap(self.InsetBg);

	-- Show the taxi node map and buttons
	local num_nodes = NumTaxiNodes();
	if ( num_nodes > NUM_TAXI_BUTTONS ) then
		local button;
		for i = NUM_TAXI_BUTTONS+1, num_nodes do
			button = CreateFrame("Button", "TaxiButton"..i, TaxiRouteMap, "TaxiButtonTemplate");
			button:SetID(i);
		end
	end
		
	-- Draw nodes
	local numValidFlightNodes = 0;
	for index = 1, num_nodes do
		local type = TaxiNodeGetType(index);
		local button = _G["TaxiButton"..index];
		taxiNodePositions[index] = {};
		if ( type ~= "NONE" ) then
			numValidFlightNodes = numValidFlightNodes + 1;
			local x, y = TaxiNodePosition(button:GetID());
			local currX = x*TAXI_MAP_WIDTH;
			local currY = (1.0-y)*TAXI_MAP_HEIGHT;
			taxiNodePositions[index].x = currX;
			taxiNodePositions[index].y = currY;
			-- check if we are obscuring a previous placement (eg: Ebon Hold and Light's Hope Chapel)
			if ( numValidFlightNodes > 1 ) then
				for checkNode = 1, index - 1 do
					-- Don't let distant nodes push around non-distant nodes
					if ( type == "DISTANT" or TaxiNodeGetType(checkNode) ~= "DISTANT" ) then
						local checkX = taxiNodePositions[checkNode].x;
						local checkY = taxiNodePositions[checkNode].y;
						if ( checkX ) then
							local distX = currX - checkX;
							local distY = currY - checkY;
							local distSq = distX*distX + distY*distY;
							if ( distSq < TAXI_BUTTON_MIN_DIST * TAXI_BUTTON_MIN_DIST ) then
								local scale = TAXI_BUTTON_MIN_DIST;
								if ( distSq > 0 ) then
									scale = TAXI_BUTTON_MIN_DIST / sqrt(distSq);
								end
								taxiNodePositions[index].x = checkX + distX*scale;
								taxiNodePositions[index].y = checkY + distY*scale;
							end
						end
					end
				end
			end
			-- set the button position
			button:ClearAllPoints();
			button:SetPoint("CENTER", self.InsetBg, "BOTTOMLEFT", floor(taxiNodePositions[index].x+.5), floor(taxiNodePositions[index].y+.5));
			button:SetNormalTexture(TaxiButtonTypes[type].file);
			local texture = button:GetHighlightTexture();
			texture:SetAlpha(TaxiButtonTypes[type].highlightBrightness);
			if ( type == "DISTANT" ) then
				button:Hide(); -- We'll only show them when a path is going through them (or directly connected to current location)
			else
				button:Show();
			end
		else
			button:Hide();
		end
	end
	
	-- Hide any remaining nodes
	for index = num_nodes+1, NUM_TAXI_BUTTONS, 1 do
		local button = _G["TaxiButton"..index];
		button:Hide();
	end 

	if ( num_nodes > NUM_TAXI_BUTTONS ) then
		NUM_TAXI_BUTTONS = num_nodes
	end

	DrawOneHopLines();
end

function TaxiFrame_OnEvent(self, event, ...)
	if ( event == "TAXIMAP_CLOSED" ) then
		HideUIPanel(self);
		return;
	end
end

function TaxiNodeOnButtonEnter(button) 
	local index = button:GetID();
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
	GameTooltip:AddLine(TaxiNodeName(index), nil, nil, nil, true);

	-- Setup variables
	local numNodes = NumTaxiNodes();
	local numRoutes = GetNumRoutes(index);
	local line;
	local sX, sY, dX, dY;
	local w = TAXI_MAP_WIDTH;
	local h = TAXI_MAP_HEIGHT;
	local type = TaxiNodeGetType(index);

	-- if not on a distant node...
	if ( type ~= "DISTANT" ) then
		-- ...start off with all distant nodes hidden
		for i=1, numNodes  do
			local currType = TaxiNodeGetType(i);
			if ( currType == "DISTANT" ) then
				local button = _G["TaxiButton"..i];
				button:Hide();
			end
		end
	end
	
	if ( type == "REACHABLE" ) then
		SetTooltipMoney(GameTooltip, TaxiNodeCost(button:GetID()));

		-- Show the path to this node
		if ( numRoutes > NUM_TAXI_ROUTES ) then
			for i = NUM_TAXI_ROUTES+1, numRoutes do
				line = TaxiRouteMap:CreateTexture("TaxiRoute"..i, "BACKGROUND");
				line:SetTexture("Interface\\TaxiFrame\\UI-Taxi-Line");
			end
			NUM_TAXI_ROUTES = numRoutes;
		end

		for i=1, NUM_TAXI_ROUTES do
			line = _G["TaxiRoute"..i];
			if ( i <= numRoutes ) then
				local srcSlot = TaxiGetNodeSlot(index, i, true);
				sX = taxiNodePositions[srcSlot].x;
				sY = taxiNodePositions[srcSlot].y;
				local dstSlot = TaxiGetNodeSlot(index, i, false);
				dX = taxiNodePositions[dstSlot].x;
				dY = taxiNodePositions[dstSlot].y;
				DrawLine(line, "TaxiRouteMap", sX, sY, dX, dY, 32, TAXIROUTE_LINEFACTOR);
				line:Show();

				local type = TaxiNodeGetType(dstSlot);
				if ( type == "DISTANT" ) then
					local button = _G["TaxiButton"..dstSlot];
					button:Show();
				end
			else
				line:Hide();
			end
		end
	elseif ( type == "UNREACHABLE" ) then
		-- Show error state when unreachable node is hovered over
		button:SetNormalTexture(TaxiButtonTypes[type].hoverFile);
		local texture = button:GetHighlightTexture();
		texture:SetAlpha(TaxiButtonTypes[type].highlightBrightness);
		for i=1, NUM_TAXI_ROUTES do
			line = _G["TaxiRoute"..i];
			line:Hide();
		end
	elseif ( type == "CURRENT" ) then
		GameTooltip:AddLine(TAXINODEYOUAREHERE, 1.0, 1.0, 1.0, true);
		DrawOneHopLines(button.parent);
	end

	GameTooltip:Show();
end

function TaxiNodeOnButtonLeave(button) 
	GameTooltip:Hide();

	local index = button:GetID();
	local type = TaxiNodeGetType(index);
	if TaxiButtonTypes[type] then
		-- Don't leave it with the hover icon (if it had one)
		button:SetNormalTexture(TaxiButtonTypes[type].file);
	end
end

-- Draw all flightpaths within one hop of current location
function DrawOneHopLines(self)
	local line;
	local sX, sY, dX, dY;
	local w = TAXI_MAP_WIDTH;
	local h = TAXI_MAP_HEIGHT;
	local numNodes = NumTaxiNodes();
	local numLines = 0;
	local numSingleHops = 0;
	for i=1, numNodes  do
		local type = TaxiNodeGetType(i);
		if ( (type == "REACHABLE") and TaxiIsDirectFlight(i) ) then
			numSingleHops = numSingleHops + 1;
			numLines = numLines + 1;
			if ( numLines > NUM_TAXI_ROUTES ) then
				line = TaxiRouteMap:CreateTexture("TaxiRoute"..numLines, "BACKGROUND");
				line:SetTexture("Interface\\TaxiFrame\\UI-Taxi-Line");
				NUM_TAXI_ROUTES = numLines;
			else
				line = _G["TaxiRoute"..numLines];
			end
			if ( line ) then
				local srcSlot = TaxiGetNodeSlot(i, 1, true);
				sX = taxiNodePositions[srcSlot].x;
				sY = taxiNodePositions[srcSlot].y;
				local dstSlot = TaxiGetNodeSlot(i, 1, false);
				dX = taxiNodePositions[dstSlot].x;
				dY = taxiNodePositions[dstSlot].y;
				DrawLine(line, "TaxiRouteMap", sX, sY, dX, dY, 32, TAXIROUTE_LINEFACTOR);
				line:Show();
			end
		elseif ( type == "DISTANT" ) then
			numSingleHops = numSingleHops + 1;
			local button = _G["TaxiButton"..i];
			button:Hide();
		end
	end
	for i=numLines+1, NUM_TAXI_ROUTES do
		_G["TaxiRoute"..i]:Hide();
	end
	if ( numSingleHops == 0 ) then
		UIErrorsFrame:AddMessage(ERR_TAXINOPATHS, 1.0, 0.1, 0.1, 1.0);
		HideUIPanel(TaxiFrame);
	end
end
