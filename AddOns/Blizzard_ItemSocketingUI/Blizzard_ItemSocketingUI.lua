UIPanelWindows["ItemSocketingFrame"] =	{ area = "left",	pushable = 0,	xoffset = -16,	yoffset = 12,	bottomClampOverride = 140+12,	width = 338,	height = 424};

local primaryGemTexture = "Interface\\ItemSocketingFrame\\UI-ItemSockets";

GEM_TYPE_INFO = {};
GEM_TYPE_INFO["Yellow"] = {tex=primaryGemTexture, w=43, h=43, left=0, right=0.16796875, top=0.640625, bottom=0.80859375, r=0.97, g=0.82, b=0.29, CBx=53, CBy=53, CBLeft=0.5546875, CBRight=0.7578125, CBTop=0, CBBottom=0.20703125, OBx=61, OBy=57, OBLeft=0.7578125, OBRight=0.9921875, OBTop=0, OBBottom=0.22265625};
GEM_TYPE_INFO["Red"] = {tex=primaryGemTexture, w=43, h=43, left=0.1796875, right=0.34375, top=0.640625, bottom=0.80859375, r=1, g=0.47, b=0.47, CBx=53, CBy=53, CBLeft=0.5546875, CBRight=0.7578125, CBTop=0.4765625, CBBottom=0.68359375, OBx=61, OBy=57, OBLeft=0.7578125, OBRight=0.9921875, OBTop=0.4765625, OBBottom=0.69921875};
GEM_TYPE_INFO["Blue"] = {tex=primaryGemTexture, w=43, h=43, left=0.3515625, right=0.51953125, top=0.640625, bottom=0.80859375, r=0.47, g=0.67, b=1, CBx=53, CBy=53, CBLeft=0.5546875, CBRight=0.7578125, CBTop=0.23828125, CBBottom=0.4453125, OBx=61, OBy=57, OBLeft=0.7578125, OBRight=0.9921875, OBTop=0.23828125, OBBottom=0.4609375};
GEM_TYPE_INFO["Meta"] = {tex=primaryGemTexture, w=57, h=52, left=0.171875, right=0.3984375, top=0.40234375, bottom=0.609375, r=1, g=1, b=1, CBLeft=0.5546875, CBx=53, CBy=53, CBRight=0.7578125, CBTop=0, CBBottom=0.20703125, OBLeft=0.7578125, OBx=61, OBy=57, OBRight=0.9921875, OBTop=0, OBBottom=0.22265625};

ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH = 240;

function ItemSocketingFrame_OnLoad(self)
	self:RegisterEvent("SOCKET_INFO_UPDATE");
	self:RegisterEvent("SOCKET_INFO_CLOSE");
	self:RegisterEvent("SOCKET_INFO_REFUNDABLE_CONFIRM");
	self:RegisterEvent("SOCKET_INFO_ACCEPT");
	self:RegisterEvent("SOCKET_INFO_SUCCESS");
	self:RegisterEvent("SOCKET_INFO_FAILURE");
	ItemSocketingScrollFrameScrollBarScrollUpButton:SetPoint("BOTTOM", ItemSocketingScrollFrameScrollBar, "TOP", 0, 1);
	ItemSocketingScrollFrameScrollBarScrollDownButton:SetPoint("TOP", ItemSocketingScrollFrameScrollBar, "BOTTOM", 0, -3);
	ItemSocketingScrollFrameTop:SetPoint("TOP", ItemSocketingScrollFrameScrollBarScrollUpButton, "TOP", -2, 3);
	ItemSocketingScrollFrameScrollBar:SetPoint("TOPLEFT", ItemSocketingScrollFrame, "TOPRIGHT", 7.9999995231628, -18);
	ItemSocketingScrollFrameScrollBar:SetHeight(221);
	ItemSocketingDescription:SetMinimumWidth(ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH, true);
end

function ItemSocketingFrame_OnEvent(self, event, ...)
	if ( event == "SOCKET_INFO_UPDATE" ) then
		ItemSocketingFrame_Update();
		ItemSocketingFrame_LoadUI();
		if ( not ItemSocketingFrame:IsShown() ) then
			ShowUIPanel(ItemSocketingFrame);
		end
	elseif ( event == "SOCKET_INFO_CLOSE" ) then
		HideUIPanel(ItemSocketingFrame);
	elseif ( event == "SOCKET_INFO_REFUNDABLE_CONFIRM" ) then
		StaticPopup_Show("REFUNDABLE_SOCKET");
	elseif ( event == "SOCKET_INFO_ACCEPT" ) then
		self.isSocketing = true;
		ItemSocketingSocketButton_Disable();
		ItemSocketingFrame_DisableSockets();
	elseif ( event == "SOCKET_INFO_SUCCESS" ) then
		self.isSocketing = nil;
		ItemSocketingFrame_EnableSockets();
	elseif ( event == "SOCKET_INFO_FAILURE" ) then
		self.isSocketing = nil;
		ItemSocketingFrame_EnableSockets();
	end
end

function ItemSocketingFrame_Update()
	ItemSocketingFrame.destroyingGem = nil;
	ItemSocketingFrame.itemIsRefundable = nil;
	ItemSocketingFrame.itemIsBoundTradeable = nil;
	if(GetSocketItemRefundable()) then
		ItemSocketingFrame.itemIsRefundable = true;
	elseif(GetSocketItemBoundTradeable() or HasBoundGemProposed()) then
		ItemSocketingFrame.itemIsBoundTradeable = true;
	end

	local numSockets = GetNumSockets();
	local name, icon, quality, gemMatchesSocket; 
	local socket, socketName;
	local numNewGems = numSockets;
	local closedBracket, openBracket;
	local bracketsOpen, gemColor, gemBorder, gemColorText, gemInfo;
	local numMatches = 0;
	for i=1, MAX_NUM_SOCKETS do
		socket = _G["ItemSocketingSocket"..i];
		socketName = "ItemSocketingSocket"..i;
		closedBracket = _G[socketName.."BracketFrameClosedBracket"];
		openBracket = _G[socketName.."BracketFrameOpenBracket"];
		if ( i <= numSockets ) then
			-- See if there's a replacement gem and if not see if there's an existing gem
			name, icon, gemMatchesSocket = GetNewSocketInfo(i);
			bracketsOpen = 1;
			if ( not name ) then
				name, icon, gemMatchesSocket = GetExistingSocketInfo(i);
				if ( icon ) then
					bracketsOpen = nil;
				end
				
				-- Count down new gems if there's no name
				numNewGems = numNewGems - 1;
			elseif ( GetExistingSocketInfo(i) ) then
				ItemSocketingFrame.destroyingGem = 1;
			end
			--Handle one color only right now
			gemColor = GetSocketTypes(i);
			if ( gemMatchesSocket ) then
				local color = GEM_TYPE_INFO[gemColor];
				AnimatedShine_Start(socket, color.r, color.g, color.b);
				numMatches = numMatches + 1;
			else
				AnimatedShine_Stop(socket);
			end
			if ( bracketsOpen ) then
				-- Show open brackets
				closedBracket:Hide();
				openBracket:Show();
			else
				-- Show closed brackets
				closedBracket:Show();
				openBracket:Hide();
			end
			
			if ( gemColor ~= "" ) then
				gemInfo = GEM_TYPE_INFO[gemColor];
				gemBorder = _G[socketName.."Background"]
				gemBorder:SetTexture(gemInfo.tex);
				gemBorder:SetWidth(gemInfo.w);
				gemBorder:SetHeight(gemInfo.h);
				gemBorder:SetTexCoord(gemInfo.left, gemInfo.right, gemInfo.top, gemInfo.bottom);
				gemBorder:Show();
				if ( gemColor == "Meta" ) then
					-- Special stuff for meta gem sockets
					SetDesaturation(openBracket, true);
					SetDesaturation(closedBracket, true);
				else
					SetDesaturation(openBracket, false);
					SetDesaturation(closedBracket, false);
				end
				openBracket:SetSize(gemInfo.OBx, gemInfo.OBy);
				openBracket:SetTexture(gemInfo.tex);
				openBracket:SetTexCoord(gemInfo.OBLeft, gemInfo.OBRight, gemInfo.OBTop, gemInfo.OBBottom);
				closedBracket:SetSize(gemInfo.CBx, gemInfo.CBy)
				closedBracket:SetTexture(gemInfo.tex);
				closedBracket:SetTexCoord(gemInfo.CBLeft, gemInfo.CBRight, gemInfo.CBTop, gemInfo.CBBottom);
				if ( ENABLE_COLORBLIND_MODE == "1" ) then
					gemColorText = _G[socketName.."Color"];
					gemColorText:SetText(_G[strupper(gemColor) .. "_GEM"]);
					gemColorText:Show();
				else
					_G[socketName.."Color"]:Hide();
				end
			else
				gemBorder:Hide();
			end

			SetItemButtonTexture(socket, icon);
			socket:Show();
		else
			socket:Hide();
		end
	end

	-- Position the sockets and show/hide the border graphics
	if ( numSockets == 3 ) then
		ItemSocketingSocket1Right:Hide();
		ItemSocketingSocket2Left:Show();
		ItemSocketingSocket2Right:Hide();
		ItemSocketingSocket3Left:Show();
		ItemSocketingSocket3Right:Show();
		ItemSocketingSocket1:SetPoint("BOTTOM", ItemSocketingFrame, "BOTTOM", -75, 62);
	elseif ( numSockets == 2 ) then
		ItemSocketingSocket1Right:Hide();
		ItemSocketingSocket2Left:Show();
		ItemSocketingSocket2Right:Show();
		ItemSocketingSocket1:SetPoint("BOTTOM", ItemSocketingFrame, "BOTTOM", -35, 62);
	else
		ItemSocketingSocket1:SetPoint("BOTTOM", ItemSocketingFrame, "BOTTOM", 0, 62);
		ItemSocketingSocket1Right:Show();
	end

	-- Set portrait
	name, icon, quality = GetSocketItemInfo();
	SetPortraitToTexture("ItemSocketingFramePortrait", icon);

	-- see if has a scrollbar and resize accordingly
	local scrollBarOffset = 28;
	if ( ItemSocketingScrollFrame:GetVerticalScrollRange() ~= 0 ) then
		scrollBarOffset = 0;
	end
	ItemSocketingScrollFrame:SetWidth(269+scrollBarOffset);
	ItemSocketingDescription:SetMinimumWidth(ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH+scrollBarOffset, true);
	-- Owner needs to be set everytime since it is cleared everytime the tooltip is hidden
	ItemSocketingDescription:SetOwner(ItemSocketingScrollChild, "ANCHOR_PRESERVE");
	ItemSocketingDescription:SetSocketedItem();

	-- Update socket button
	if ( numNewGems == 0 ) then
		ItemSocketingSocketButton_Disable();
	elseif ( not ItemSocketingFrame.isSocketing ) then
		ItemSocketingSocketButton_Enable();
	end
end

function ItemSocketingFrame_DisableSockets()
	for i = 1, MAX_NUM_SOCKETS do
		local socket = _G["ItemSocketingSocket"..i];
		socket:Disable();
		socket.icon:SetDesaturated(true);
	end
end

function ItemSocketingFrame_EnableSockets()
	for i = 1, MAX_NUM_SOCKETS do
		local socket = _G["ItemSocketingSocket"..i];
		socket:Enable();
		socket.icon:SetDesaturated(false);
	end
end

function ItemSocketingSocketButton_OnScrollRangeChanged()

	-- see if has a scrollbar and resize accordingly
	local scrollBarOffset = 28;
	if ( ItemSocketingScrollFrame:GetVerticalScrollRange() ~= 0 ) then
		scrollBarOffset = 0;
	end
	ItemSocketingScrollFrame:SetWidth(269+scrollBarOffset);
	ItemSocketingDescription:SetMinimumWidth(ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH+scrollBarOffset, true);

	ItemSocketingDescription:SetSocketedItem();
end

function ItemSocketingSocketButton_OnEnter(self)
	local newSocket = GetNewSocketInfo(self:GetID());
	local existingSocket = GetExistingSocketInfo(self:GetID());
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( newSocket ) then
		GameTooltip:SetSocketGem(self:GetID());
	else
		GameTooltip:SetExistingSocketGem(self:GetID());
	end
	if ( newSocket and existingSocket ) then
		ShoppingTooltip1:SetOwner(GameTooltip, "ANCHOR_NONE");
		ShoppingTooltip1:ClearAllPoints();
		ShoppingTooltip1:SetPoint("TOPLEFT", "GameTooltip", "TOPRIGHT", 0, -10);
		ShoppingTooltip1:SetExistingSocketGem(self:GetID(), true);
		ShoppingTooltip1:Show();
	end
end

function ItemSocketingSocketButton_OnEvent(self, event, ...)
	if ( event == "SOCKET_INFO_UPDATE" ) then
		if ( GameTooltip:IsOwned(self) ) then
			ItemSocketingSocketButton_OnEnter(self);
		end
	end
end

function ItemSocketingSocketButton_Disable()
	ItemSocketingSocketButton:Disable();
	ItemSocketingSocketButton.Left:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled");
	ItemSocketingSocketButton.Middle:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled");
	ItemSocketingSocketButton.Right:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled");
end

function ItemSocketingSocketButton_Enable()
	ItemSocketingSocketButton:Enable();
	ItemSocketingSocketButton.Left:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
	ItemSocketingSocketButton.Middle:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
	ItemSocketingSocketButton.Right:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");	
end
