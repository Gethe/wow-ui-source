UIPanelWindows["GarrisonCapacitiveDisplayFrame"] = { area = "left", pushable = 0, };

function GarrisonCapacitiveDisplayFrame_ToggleFrame()
	if (not GarrisonCapacitiveFrame:IsShown()) then
		ShowUIPanel(GarrisonCapacitiveDisplayFrame);
	else
		HideUIPanel(GarrisonCapacitiveDisplayFrame);
	end
end

function GarrisonCapacitiveDisplayFrame_OnLoad(self)
    self:RegisterEvent("SHIPMENT_CRAFTER_OPENED");
    self:RegisterEvent("SHIPMENT_CRAFTER_CLOSED");
    self:RegisterEvent("SHIPMENT_CRAFTER_INFO");
    self:RegisterEvent("SHIPMENT_CRAFTER_REAGENT_UPDATE");
    self:RegisterEvent("SHIPMENT_UPDATE");
end

local shipmentUpdater;

function GarrisonCapacitiveDisplayFrame_TimerUpdate()
	local self = GarrisonCapacitiveDisplayFrame;
	GarrisonCapacitiveDisplayFrame_Update(self, true, self.maxShipments, self.plotID);
end

function GarrisonCapacitiveDisplayFrame_Update(self, success, maxShipments, plotID)
	if (success ~= 0) then
		self.maxShipments = maxShipments;
		self.plotID = plotID;

		local display = self.CapacitiveDisplay;

		local numPending = C_Garrison.GetNumPendingShipments();
		local display = self.CapacitiveDisplay;

		if (not numPending) then
			return;
		end

		local available = maxShipments - numPending;

		display.ShipmentIconFrame.itemId = nil;
		
		
	    local reagents = display.Reagents;

	    local hasReagents = true;

	    for i = 1, #reagents do
	    	reagents[i]:Hide();
	    end

	    for i = 1, C_Garrison.GetNumShipmentReagents() do
	    	local reagent = reagents[i];
	    	if (not reagent) then
	    		reagent = CreateFrame("Button", nil, display, "GarrisonCapacitiveItemButtonTemplate");
	    		reagent:SetID(i);
	    		reagent:SetPoint("TOP", reagents[i-1], "BOTTOM", 0, -6);
	    	end

	    	local name, texture, quality, needed, quantity, itemID = C_Garrison.GetShipmentReagentInfo(i);

	    	-- If we don't have a name here the data is not set up correctly, but this prevents lua errors later.
	    	if (not name) then
	    		break;
	    	end

			reagent.Icon:SetTexture(texture);	    	
			reagent.Name:SetText(name);
			reagent.Name:SetTextColor(ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b);
			-- Grayout items
			if ( quantity < needed ) then
				reagent.Icon:SetVertexColor(0.5, 0.5, 0.5);
				reagent.Name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				hasReagents = false;
			else
				reagent.Icon:SetVertexColor(1.0, 1.0, 1.0);
				reagent.Name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			end
			if ( quantity >= 100 ) then
				quantity = "*";
			end
			reagent.Count:SetText(quantity.." /"..needed);
			--fix text overflow when the reagent count is too high
			if (math.floor(reagent.Count:GetStringWidth()) > math.floor(reagent.Icon:GetWidth() + .5)) then 
			--round count width down because the leftmost number can overflow slightly without looking bad
			--round icon width because it should always be an int, but sometimes it's a slightly off float
				reagent.Count:SetText(quantity.."\n/"..needed);
			end
	 	   	reagent.itemId = itemID;
	 	   	reagent.currencyID = nil;
	 	   	reagent:Show();
	    end

	    local currencyID, currencyNeeded = C_Garrison.GetShipmentReagentCurrencyInfo();

	    if (currencyID and currencyNeeded) then
	    	local i = C_Garrison.GetNumShipmentReagents() + 1;

	    	local reagent = reagents[i];
	    	if (not reagent) then
	    		reagent = CreateFrame("Button", nil, display, "GarrisonCapacitiveItemButtonTemplate");
	    		reagent:SetID(i);
	    		reagent:SetPoint("TOP", reagents[i-1], "BOTTOM", 0, -6);
	    	end

	    	local name, quantity, texture, _, _, _, _, quality = GetCurrencyInfo(currencyID);

	    	-- If we don't have a name here the data is not set up correctly, but this prevents lua errors later.
	    	if (name) then
				reagent.Icon:SetTexture(texture);	    	
				reagent.Name:SetText(name);
				reagent.Name:SetTextColor(ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b);
				-- Grayout items
				if ( quantity < currencyNeeded ) then
					reagent.Icon:SetVertexColor(0.5, 0.5, 0.5);
					reagent.Name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					hasReagents = false;
				else
					reagent.Icon:SetVertexColor(1.0, 1.0, 1.0);
					reagent.Name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				end
				if ( quantity >= 100 ) then
					quantity = "*";
				end
				reagent.Count:SetText(quantity.." /"..currencyNeeded);
				--fix text overflow when the reagent count is too high
				if (math.floor(reagent.Count:GetStringWidth()) > math.floor(reagent.Icon:GetWidth() + .5)) then 
				--round count width down because the leftmost number can overflow slightly without looking bad
				--round icon width because it should always be an int, but sometimes it's a slightly off float
					reagent.Count:SetText(quantity.."\n/"..currencyNeeded);
				end
		 	   	reagent.itemId = nil;
		 	   	reagent.currencyID = currencyID;
		 	   	reagent:Show();
		 	end
	 	end

	    local name, texture, quality, itemID, duration = C_Garrison.GetShipmentItemInfo();

		if (not quality) then
			quality = LE_ITEM_QUALITY_COMMON;
		end

		if (not duration) then
			duration = 0;
		end

		local prefix, pendingText, description = C_Garrison.GetShipmentContainerInfo();

		local _, buildingName = C_Garrison.GetOwnedBuildingInfoAbbrev(self.plotID);

		self.TitleText:SetText(buildingName);
		self.StartWorkOrderButton:SetEnabled(hasReagents and available > 0);
		
		if ( UnitExists("npc") ) then
			SetPortraitTexture(self.portrait, "npc");
		else
			self.portrait:SetTexture("Interface\\QuestFrame\\UI-QuestLog-BookIcon");
		end

	    local followerName = C_Garrison.GetFollowerInfoForBuilding(self.plotID);

	    display.FollowerActive:SetShown(followerName ~= nil);

		display.Description:SetText(description);

		display.ShipmentIconFrame.ShipmentName:SetText(name);
		if (available > 0) then
			if (shipmentUpdater) then
				shipmentUpdater:Cancel();
				shipmentUpdater = nil;
			end
			display.ShipmentIconFrame.ShipmentsAvailable:SetText(CAPACITANCE_SHIPMENT_COUNT:format(available, maxShipments));
		else
			local timeRemaining = select(6,C_Garrison.GetPendingShipmentInfo(1));
			if (timeRemaining ~= 0) then
				if (not shipmentUpdater) then
					shipmentUpdater = C_Timer.NewTicker(1, GarrisonCapacitiveDisplayFrame_TimerUpdate);
				end
			end
			if (timeRemaining == 0) then
				display.ShipmentIconFrame.ShipmentsAvailable:SetText(GREEN_FONT_COLOR_CODE..CAPACITANCE_SHIPMENT_READY..FONT_COLOR_CODE_CLOSE);
			else
				display.ShipmentIconFrame.ShipmentsAvailable:SetText(RED_FONT_COLOR_CODE..CAPACITANCE_SHIPMENT_COOLDOWN:format(SecondsToTime(timeRemaining, false, true, 1))..FONT_COLOR_CODE_CLOSE);
			end
		end

		display.ShipmentIconFrame.Icon:SetTexture(texture);
		display.ShipmentIconFrame.itemId = itemID;

		ShowUIPanel(GarrisonCapacitiveDisplayFrame);
	end
end

function GarrisonCapacitiveDisplayFrame_OnEvent(self, event, ...)
	if (event == "SHIPMENT_CRAFTER_OPENED") then
		self.containerID = ...;

		C_Garrison.RequestShipmentInfo();
	elseif (event == "SHIPMENT_CRAFTER_INFO") then
		local success, _, maxShipments, plotID = ...;

		GarrisonCapacitiveDisplayFrame_Update(self, success, maxShipments, plotID);		
	elseif (event == "SHIPMENT_CRAFTER_CLOSED") then
		self.containerID = nil;

		if (shipmentUpdater) then
			shipmentUpdater:Cancel();
		end
		shipmentUpdater = nil;

		HideUIPanel(GarrisonCapacitiveDisplayFrame);
	elseif (event == "SHIPMENT_CRAFTER_REAGENT_UPDATE") then
		if (self.plotID and self.maxShipments) then
			GarrisonCapacitiveDisplayFrame_Update(self, true, self.maxShipments, self.plotID);
		end
	elseif (event == "SHIPMENT_UPDATE") then
		local shipmentStarted = ...;
		if (shipmentStarted) then
			self.FinishedGlow.FinishedAnim:Play();
		end
		C_Garrison.RequestShipmentInfo();
	end
end

function GarrisonCapacitiveDisplayFrame_OnShow(self)
	PlaySound("UI_Garrison_Shipments_Window_Open");
end

function GarrisonCapacitiveDisplayFrame_OnHide(self)
	if (shipmentUpdater) then
		shipmentUpdater:Cancel();
		shipmentUpdater = nil;
	end
	C_Garrison.CloseTradeskillCrafter();
	PlaySound("UI_Garrison_Shipments_Window_Close");
end

function GarrisonCapacitiveStartWorkOrder_OnClick(self)
	C_Garrison.RequestShipmentCreation();
	PlaySound("UI_Garrison_Start_Work_Order");
end