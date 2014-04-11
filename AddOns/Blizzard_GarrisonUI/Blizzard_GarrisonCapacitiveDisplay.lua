local CAPACITIVE_MAX_SHIPMENTS = 7;
local TIME_TO_UPDATE = 1; -- Every 1 second

UIPanelWindows["GarrisonCapacitiveDisplayFrame"] = { area = "left", pushable = 0, };

function GarrisonCapacitiveDisplayFrame_ToggleFrame()
	if (not GarrisonCapacitiveFrame:IsShown()) then
		ShowUIPanel(GarrisonCapacitiveDisplayFrame);
	else
		HideUIPanel(GarrisonCapacitiveDisplayFrame);
	end
end

function GarrisonCapacitiveDisplayFrame_OnLoad(self)
	ButtonFrameTemplate_HidePortrait(self);
    ButtonFrameTemplate_HideAttic(self);

    self:RegisterEvent("SHIPMENT_CRAFTER_OPENED");
    self:RegisterEvent("SHIPMENT_CRAFTER_CLOSED");
    self:RegisterEvent("SHIPMENT_CRAFTER_INFO");
    self:RegisterEvent("SHIPMENT_UPDATE");
end

local shipmentUpdater;

function GarrisonCapacitiveDisplayFrame_Update(self, success, maxShipments, plotID)
	if (success) then
		self.maxShipments = maxShipments;
		self.plotID = plotID;

		local display = self.CapacitiveDisplay;

		local numPending = C_Garrison.GetNumPendingShipments();
		local display = self.CapacitiveDisplay;
		local workOrders = display.WorkOrders;


		display.StatusLabel:Hide();
		display.TimeLeftLabel:Hide();
		display.Timer:Hide();

		display.ShipmentIconFrame.itemId = nil;

		for i = 1, CAPACITIVE_MAX_SHIPMENTS do
			local workOrder = workOrders[i];

			if (not workOrder) then
				workOrder = CreateFrame("Frame", nil, display, "GarrisonCapacitiveWorkOrderTemplate");
				workOrder:SetPoint("LEFT", workOrders[i-1], "RIGHT", 8, 0);
				workOrder:SetID(i);
			end

			workOrder.Lock:Hide();
			workOrder.CompletedOverlay:Hide();
			workOrder.QueuedOverlay:Hide();
			workOrder.Checkmark:Hide();
			workOrder.Icon:Hide();
			workOrder.Active:Hide();
			workOrder.Border:Hide();
			workOrder.Arrow:Hide();

			local firstActiveFound = false;

			if (i <= numPending) then
				local _, texture, _, _, totalTime, timeRemaining = C_Garrison.GetPendingShipmentInfo(i);

				workOrder.Icon:SetTexture(texture);
					workOrder.Icon:Show();   				
				workOrder.Border:Show();

				workOrder.complete = false;

				if (timeRemaining == 0) then
					workOrder.Border:SetAlpha(1);
					workOrder.CompletedOverlay:Show();
					workOrder.Checkmark:Show();
					workOrder.Active:Show();
					workOrder.complete = true;
				elseif (not firstActiveFound) then
					if (not shipmentUpdater) then
						shipmentUpdater = C_Timer.NewTicker(1, function() GarrisonCapacitiveDisplayFrame_Update(self, success, maxShipments, plotID) end);
					end
					workOrder.Arrow:Show();
					workOrder.Border:SetAlpha(1);
					display.StatusLabel:Show();
					display.TimeLeftLabel:Show();
					display.TimeLeftLabel:SetText(SecondsToTime(timeRemaining, false, true, 1));
					display.Timer:Show();
					display.Timer.Fill:SetMinMaxValues(0, totalTime);
					display.Timer.Fill:SetValue(totalTime - timeRemaining);
					firstActiveFound = true;
				else
					workOrder.QueuedOverlay:Show();
					workOrder.Border:SetAlpha(0.4);
				end
			elseif (i > self.maxShipments) then
				workOrder.Lock:Show();
			end

			workOrder:Show();
	    end

	    if (numPending == 0) then
			if (shipmentUpdater) then
				shipmentUpdater:Cancel();
			end
			shipmentUpdater = nil;
		end
		
	    local reagents = display.Reagents;

	    for i = 1, #reagents do
	    	reagents[i]:Hide();
	    end

	    for i = 1, C_Garrison.GetNumShipmentReagents() do
	    	local reagent = reagents[i];
	    	if (not reagent) then
	    		reagent = CreateFrame("Frame", nil, self, "GarrisonCapacitiveItemButtonTemplate");
	    		reagent:SetID(i);
	    		reagent:SetPoint("TOP", reagents[i-1], "BOTTOM", 0, -6);
	    	end

	    	local name, texture, quality, needed, quantity, itemID = C_Garrison.GetShipmentReagentInfo(i);

	    	-- If we don't have a name here the data is not set up correctly, but this prevents lua errors later.
	    	if (not name) then
	    		break;
	    	end
	    	
	    	SetItemButtonTexture(reagent, texture);
			reagent.Name:SetText(name);
			reagent.Name:SetTextColor(ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b);
	 	   	reagent.Count:SetText(quantity .. "/" .. needed);
	 	   	reagent.itemId = itemID;

	 	   	reagent:Show();
	    end

	    local name, texture, quality, itemID, duration = C_Garrison.GetShipmentItemInfo();

		-- If we don't have a name here the data is not set up correctly, but this prevents lua errors later.
		if (not quality) then
			quality = ITEM_QUALITY_COMMON;
		end

		local prefix, pendingText = C_Garrison.GetShipmentContainerInfo();

		if (not prefix or prefix == "") then
			prefix = "Capacitance-Blacksmithing";
		end

		display.StatusLabel:SetText(pendingText);

		GarrisonCapacitiveDisplayFrame_UpdateFollower(self);

		local _, name = C_Garrison.GetOwnedBuildingInfo(self.plotID);

		self.TitleText:SetText(name);

		self.CapacitiveInset.BG:SetAtlas(prefix.."-BG", true);

		display.IconBG:SetAtlas(prefix.."-IconBG", true);
		display.ShipmentIconFrame.IconBorder:SetAtlas(prefix.."-IconBorder", true);

		display.Timer.BG:SetAtlas(prefix.."-TimerBG", true);
		display.Timer.TimerFrame:SetAtlas(prefix.."-TimerFrame", true);
		display.Timer.Fill:SetStatusBarAtlas(prefix.."-TimerFill");

		display.ShipmentIconFrame.ShipmentName:SetText(name);
		display.ShipmentIconFrame.ShipmentName:SetTextColor(ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b);
		display.ShipmentIconFrame.ShipmentDuration:SetText(SecondsToTime(duration, false, true, 1));
		display.ShipmentIconFrame.Icon:SetTexture(texture);
		display.ShipmentIconFrame.itemId = itemID;

		self:Show();
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

		self:Hide();
	elseif (event == "SHIPMENT_UPDATE") then
		C_Garrison.RequestShipmentInfo();
	end
end

function GarrisonCapacitiveDisplayFrame_OnHide(self)
	C_Garrison.CloseTradeskillCrafter();
end

function GarrisonCapacitiveDisplayFrame_UpdateFollower(self)
	local display = self.CapacitiveDisplay;

    local follower = display.Follower;

    local data = C_Garrison.GetFollowerInfoForBuilding(self.plotID);

    follower.EmptyFollower:SetShown(not data);

    follower.FollowerBorder:SetShown(data ~= nil);
    follower.LevelBorder:SetShown(data ~= nil);
    follower.LevelText:SetShown(data ~= nil);

    if (data) then
    	local color = ITEM_QUALITY_COLORS[data.quality];
	
    	follower.LevelBorder:SetVertexColor(color.r, color.g, color.b);
    	follower.LevelText:SetText(data.level);
    	follower.FollowerBonus:SetText(CAPACITANCE_INCREASED_YIELD);
    	follower.FollowerBonus:SetTextColor(0.12, 1, 0);
    else
    	follower.FollowerBonus:SetText(NONE);
    	follower.FollowerBonus:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
    end
end

function GarrisonCapacitiveWorkOrder_OnEnter(self)
	if (self.complete) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, -100);
		GameTooltip:SetText(CAPACITANCE_WORK_COMPLETE_TOOLTIP_TITLE, 1, 1, 1);
		GameTooltip:AddLine(CAPACITANCE_WORK_COMPLETE_TOOLTIP, nil, nil, nil, true);
		GameTooltip:Show();
	elseif (self:GetID() > GarrisonCapacitiveDisplayFrame.maxShipments) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 2, -80);
		GameTooltip:SetText(CAPACITANCE_INCREASED_CAPACITY_TOOLTIP_TITLE, 1, 1, 1);
		GameTooltip:AddLine(CAPACITANCE_INCREASED_CAPACITY_TOOLTIP, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

function GarrisonCapacitiveWorkOrder_OnLeave(self)
	GameTooltip:Hide();
end

function GarrisonCapacitiveStartWorkOrder_OnClick(self)
	C_Garrison.RequestShipmentCreation();
end