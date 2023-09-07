UIPanelWindows["ItemSocketingFrame"] =		{ area = "left",	pushable = 0 };

local bgAtlas = "socket-%s-background"
local closedBracketAtlas = "socket-%s-closed"
local openBracketAtlas = "socket-%s-open"

local GEM_TYPE_INFO =	{	Yellow = {textureKit="yellow", r=0.97, g=0.82, b=0.29},
							Red = {textureKit="red", r=1, g=0.47, b=0.47},
							Blue = {textureKit="blue", r=0.47, g=0.67, b=1},
							Hydraulic = {textureKit="hydraulic", r=1, g=1, b=1},
							Cogwheel = {textureKit="cogwheel", r=1, g=1, b=1},
							Meta = {textureKit="meta", r=1, g=1, b=1},
							Prismatic = {textureKit="prismatic", r=1, g=1, b=1},
							PunchcardRed = {textureKit="punchcard-red", r=1, g=0.47, b=0.47},
							PunchcardYellow = {textureKit="punchcard-yellow", r=0.97, g=0.82, b=0.29},
							PunchcardBlue = {textureKit="punchcard-blue", r=0.47, g=0.67, b=1},
							Domination = {textureKit="domination", r=1, g=1, b=1},
							Cypher = {textureKit="meta", r=1, g=1, b=1},
							Tinker = {textureKit="punchcard-red", r=1, g=0.47, b=0.47},
							Primordial = {textureKit="meta", r=1, g=1, b=1},
						};

ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH = 240;

function ItemSocketingFrame_OnLoad(self)
	self:RegisterEvent("SOCKET_INFO_UPDATE");
	self:RegisterEvent("SOCKET_INFO_CLOSE");
	self:RegisterEvent("SOCKET_INFO_BIND_CONFIRM");
	self:RegisterEvent("SOCKET_INFO_REFUNDABLE_CONFIRM");
	self:RegisterEvent("SOCKET_INFO_ACCEPT");
	self:RegisterEvent("SOCKET_INFO_SUCCESS");
	self:RegisterEvent("SOCKET_INFO_FAILURE");
	ItemSocketingDescription:SetMinimumWidth(ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH, true);
	ButtonFrameTemplate_HideButtonBar(self);

	self.ScrollFrame:RegisterCallback("OnScrollRangeChanged", function(scrollFrame, xrange, yrange)
		ItemSocketingSocketButton_OnScrollRangeChanged(scrollFrame);
	end);
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
	elseif ( event == "SOCKET_INFO_BIND_CONFIRM" ) then
		StaticPopup_Show("BIND_SOCKET");
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
	elseif(GetSocketItemBoundTradeable() and HasBoundGemProposed()) then -- Only gems flagged "Soulbound" on their enchantments will remove item tradability when socketed
		ItemSocketingFrame.itemIsBoundTradeable = true;
	end

	local numSockets = GetNumSockets();
	local name, icon, quality, gemMatchesSocket;
	local numNewGems = numSockets;
	local bracketsOpen;
	local numMatches = 0;
	for i, socket in ipairs(ItemSocketingFrame.Sockets) do
		if ( i <= numSockets ) then
			local gemBorder = socket.Background;
			local closedBracket = socket.BracketFrame.ClosedBracket;
			local openBracket = socket.BracketFrame.OpenBracket;
			local gemColorText = socket.BracketFrame.ColorText;

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
			local gemColor = GetSocketTypes(i);
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
				local gemInfo = GEM_TYPE_INFO[gemColor];
				SetupTextureKitOnFrame(gemInfo.textureKit, gemBorder, bgAtlas, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
				gemBorder:Show();
				if ( gemColor == "Meta" ) then
					-- Special stuff for meta gem sockets
					SetDesaturation(openBracket, true);
					SetDesaturation(closedBracket, true);
				else
					SetDesaturation(openBracket, false);
					SetDesaturation(closedBracket, false);
				end
				SetupTextureKitOnFrame(gemInfo.textureKit, openBracket, openBracketAtlas, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
				SetupTextureKitOnFrame(gemInfo.textureKit, closedBracket, closedBracketAtlas, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
				if ( CVarCallbackRegistry:GetCVarValueBool("colorblindMode") ) then
					gemColorText:SetText(_G[strupper(gemColor) .. "_GEM"]);
					gemColorText:Show();
				else
					gemColorText:Hide();
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

	-- Playsound if all sockets are matched
	if ( numMatches == numSockets ) then
		-- Will probably need a new sound
		PlaySound(SOUNDKIT.MAP_PING);
	end

	-- Position the sockets and show/hide the border graphics
	if ( numSockets == 3 ) then
		ItemSocketingSocket1Right:Hide();
		ItemSocketingSocket2Left:Show();
		ItemSocketingSocket2Right:Hide();
		ItemSocketingSocket3Left:Show();
		ItemSocketingSocket3Right:Show();
		ItemSocketingSocket1:SetPoint("BOTTOM", ItemSocketingFrame, "BOTTOM", -75, 32);
	elseif ( numSockets == 2 ) then
		ItemSocketingSocket1Right:Hide();
		ItemSocketingSocket2Left:Show();
		ItemSocketingSocket2Right:Show();
		ItemSocketingSocket1:SetPoint("BOTTOM", ItemSocketingFrame, "BOTTOM", -35, 32);
	else
		ItemSocketingSocket1:SetPoint("BOTTOM", ItemSocketingFrame, "BOTTOM", 0, 32);
		ItemSocketingSocket1Right:Show();
	end

	-- Set portrait
	name, icon, quality = GetSocketItemInfo();
	ItemSocketingFrame:SetPortraitToAsset(icon);

	ItemSocketingDescription:SetMinimumWidth(ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH, true);
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
