
UIPanelWindows["TaxiFrame"] = { area = "left", pushable = 0, width = 605, height = 580, showFailedFunc = CloseTaxiMap };

function ShowTaxiMapFrame()
	ShowUIPanel(TaxiFrame);
end

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

local SOFT_CURSOR_SELECT_DISTANCE_SQ = 30 * 30;

TaxiFrameMixin = {};

function TaxiFrameMixin:OnLoad()
	self:RegisterEvent("TAXIMAP_CLOSED");
	self.MapTexture:SetHorizTile(false);
	self.MapTexture:SetVertTile(false);
end

function TaxiFrameMixin:SetupGamepad()
	local function CanSelect()
		return self.gamepadSelection and TaxiNodeGetType(self.gamepadSelection:GetID()) == "REACHABLE";
	end

	local function SelectNode()
		if self.gamepadSelection then
			self.gamepadSelection:Click();
		end
	end

	local selectBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, SelectNode, ACTION_LABEL_SELECT);
	selectBinding:AddCondition(CanSelect);

	local moveCursorBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_LEFT, nil, FRAME_ACTION_NAVIGATE);

	self.gamepadFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self);
	self.gamepadFooter:AddPromptedBinding(moveCursorBinding);
	self.gamepadFooter:AddPromptedBinding(selectBinding);
	self.gamepadFooter:AddStandardBackPrompt();
	self.gamepadFooter:Finalize();
end

function TaxiFrameMixin:FocusGamepad()
	SoftCursor:SetBounds(function()
		local width, height = self.MapTexture:GetSize();
		local centerX, centerY = self.MapTexture:GetCenter();
		return SoftCursor_CreateRectBounds(centerX, centerY, width, height);
	end);

	SoftCursor:SetInputStick("Left");
	SoftCursor:SetMaxSpeed(GetCVarNumberOrDefault("GamepadMapScrollSpeed"));
	SoftCursor:SetLinesEnabled(true, self);
	SoftCursor:RegisterCallback(SoftCursor.Event.OnMove, self.OnSoftCursorMoved, self);
	SoftCursor:Show();

	if self.gamepadSelection then
		SoftCursor:SetPosition(self.gamepadSelection:GetCenter());
	end

	self.gamepadFooter:ShowAndActivateBindings();
end

function TaxiFrameMixin:UnfocusGamepad()
	SoftCursor:UnregisterCallback(SoftCursor.Event.OnMove, self);
	SoftCursor:Hide();
	self.gamepadFooter:HideAndDeactivateBindings();
end

function TaxiFrameMixin:OnSoftCursorMoved(x, y)
	local bestButton = nil;
	local bestButtonDistSq = math.huge;

	for i=1, NUM_TAXI_BUTTONS do
		local nodeButton = _G["TaxiButton"..i];
		local buttonX, buttonY = nodeButton:GetCenter();
		local deltaX = x - buttonX;
		local deltaY = y - buttonY;
		local buttonDistSq = (deltaX * deltaX) + (deltaY * deltaY);

		if buttonDistSq <= SOFT_CURSOR_SELECT_DISTANCE_SQ and buttonDistSq < bestButtonDistSq then
			bestButton = nodeButton;
			bestButtonDistSq = buttonDistSq;
		end
	end

	if bestButton and bestButton ~= self.gamepadSelection then
		self:SetGamepadSelection(bestButton);
	end
end

function TaxiFrameMixin:SetGamepadSelection(newButton)
	if newButton == self.gamepadSelection or not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	if self.gamepadSelection then
		self.gamepadSelection:FocusExit();
		self.gamepadSelection:UnlockHighlight();
	end

	self.gamepadSelection = newButton;

	if newButton then
		newButton:FocusEnter();
		newButton:LockHighlight();
	end

	self.gamepadFooter:Refresh();
end

function TaxiFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);

	self.NineSlice.Text:SetText(FLIGHT_MAP);

	SetTaxiMap(self.MapTexture);

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
	local mapWidth = self.MapTexture:GetWidth();
	local mapHeight = self.MapTexture:GetHeight();
	local numValidFlightNodes = 0;
	local currentNode;
	for index = 1, num_nodes do
		local type = TaxiNodeGetType(index);
		local button = _G["TaxiButton"..index];
		taxiNodePositions[index] = {};
		if ( type ~= "NONE" ) then
			numValidFlightNodes = numValidFlightNodes + 1;
			local x, y = TaxiNodePosition(button:GetID());
			local currX = x * mapWidth;
			local currY = (1.0 - y) * mapHeight;
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
			button:SetPoint("CENTER", self.MapTexture, "BOTTOMLEFT", floor(taxiNodePositions[index].x+.5), floor(taxiNodePositions[index].y+.5));
			button:SetNormalTexture(TaxiButtonTypes[type].file);
			local texture = button:GetHighlightTexture();
			texture:SetAlpha(TaxiButtonTypes[type].highlightBrightness);
			if ( type == "DISTANT" ) then
				button:Hide(); -- We'll only show them when a path is going through them (or directly connected to current location)
			else
				if type == "CURRENT" then
					currentNode = button;
				end
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

	if InputUtil.IsGamepadUIEnabled() and currentNode then
		SoftCursor:SetPosition(currentNode:GetCenter());
	end
end

function TaxiFrameMixin:OnHide()
	CloseTaxiMap();
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);

	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end

function TaxiFrameMixin:OnEvent(event, ...)
	if ( event == "TAXIMAP_CLOSED" ) then
		HideUIPanel(self);
		return;
	end
end

TaxiButtonMixin = {};

function TaxiButtonMixin:OnEnter()
	TaxiFrame:SetGamepadSelection(self);

	local index = self:GetID();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:AddLine(TaxiNodeName(index), nil, nil, nil, true);

	-- Setup variables
	local numNodes = NumTaxiNodes();
	local numRoutes = GetNumRoutes(index);
	local line;
	local sX, sY, dX, dY;
	local type = TaxiNodeGetType(index);

	-- if not on a distant node...
	if ( type ~= "DISTANT" ) then
		-- ...start off with all distant nodes hidden
		for i=1, numNodes  do
			local currType = TaxiNodeGetType(i);
			if ( currType == "DISTANT" ) then
				local taxiButton = _G["TaxiButton"..i];
				taxiButton:Hide();
			end
		end
	end

	if ( type == "REACHABLE" ) then
		GameTooltip_AddMoneyLine(GameTooltip, TaxiNodeCost(self:GetID()));

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

				local dstType = TaxiNodeGetType(dstSlot);
				if ( dstType == "DISTANT" ) then
					local taxiButton = _G["TaxiButton"..dstSlot];
					taxiButton:Show();
				end
			else
				line:Hide();
			end
		end
	elseif ( type == "UNREACHABLE" ) then
		-- Show error state when unreachable node is hovered over
		self:SetNormalTexture(TaxiButtonTypes[type].hoverFile);
		local texture = self:GetHighlightTexture();
		texture:SetAlpha(TaxiButtonTypes[type].highlightBrightness);
		for i=1, NUM_TAXI_ROUTES do
			line = _G["TaxiRoute"..i];
			line:Hide();
		end
	elseif ( type == "CURRENT" ) then
		GameTooltip:AddLine(TAXINODEYOUAREHERE, 1.0, 1.0, 1.0, true);
		DrawOneHopLines(self.parent);
	end

	GameTooltip:Show();
end

function TaxiButtonMixin:OnLeave()
	GameTooltip:Hide();

	local index = self:GetID();
	local type = TaxiNodeGetType(index);
	if TaxiButtonTypes[type] then
		-- Don't leave it with the hover icon (if it had one)
		self:SetNormalTexture(TaxiButtonTypes[type].file);
	end
end

function TaxiButtonMixin:OnClick()
	TakeTaxiNode(self:GetID());
end

-- Draw all flightpaths within one hop of current location
function DrawOneHopLines(self)
	local line;
	local sX, sY, dX, dY;
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
