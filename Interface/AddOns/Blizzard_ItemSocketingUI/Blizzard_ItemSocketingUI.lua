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
							Fragrance = {textureKit="hydraulic", r=1, g=1, b=1},
							SingingThunder = {textureKit="yellow", r=0.97, g=0.82, b=0.29},
							SingingSea = {textureKit="blue",r=0.47, g=0.67, b=1},
							SingingWind = {textureKit="red", r=1, g=0.47, b=0.47},
							Fiber = {textureKit="hydraulic", r=1, g=1, b=1}
						};

ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH = 240;

function ItemSocketingFrame_OnLoad(self)
	self:RegisterEvent("SOCKET_INFO_UPDATE");
	self:RegisterEvent("SOCKET_INFO_CLOSE");
	ItemSocketingDescription:SetMinimumWidth(ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH, true);
	ButtonFrameTemplate_HideButtonBar(self);

	self.ScrollFrame:RegisterCallback("OnScrollRangeChanged", function(scrollFrame, xrange, yrange)
		ItemSocketingSocketButton_OnScrollRangeChanged(scrollFrame);
	end);

	self.SocketingContainer.ApplySocketsButton:ClearAllPoints();
	self.SocketingContainer.ApplySocketsButton:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -5, 4);
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
	end
end

function ItemSocketingFrame_Update()
	ItemSocketingFrame.SocketingContainer:Update();

	-- Set portrait
	local icon = select(2, C_ItemSocketInfo.GetSocketItemInfo());
	ItemSocketingFrame:SetPortraitToAsset(icon);

	ItemSocketingDescription:SetMinimumWidth(ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH, true);
	-- Owner needs to be set everytime since it is cleared everytime the tooltip is hidden
	ItemSocketingDescription:SetOwner(ItemSocketingScrollChild, "ANCHOR_PRESERVE");
	ItemSocketingDescription:SetSocketedItem();
end

function ItemSocketingSocketButton_OnScrollRangeChanged()
	ItemSocketingDescription:SetSocketedItem();
end

GenericSocketButtonMixin = {};

function GenericSocketButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self:RegisterEvent("SOCKET_INFO_UPDATE");
end

function GenericSocketButtonMixin:ClickSocketButton()
	StaticPopup_Hide("DELETE_ITEM");
	StaticPopup_Hide("DELETE_QUEST_ITEM");
	StaticPopup_Hide("DELETE_GOOD_ITEM");
	StaticPopup_Hide("DELETE_GOOD_QUEST_ITEM");
	C_ItemSocketInfo.ClickSocketButton(self:GetID());
end

function GenericSocketButtonMixin:OnClick()
	if ( IsModifiedClick() ) then
		local link = C_ItemSocketInfo.GetNewSocketLink(self:GetID()) or
		C_ItemSocketInfo.GetExistingSocketLink(self:GetID());
		HandleModifiedItemClick(link);
	else
		self:ClickSocketButton();
	end
end

function GenericSocketButtonMixin:OnReceiveDrag()
	self:ClickSocketButton();
end

function GenericSocketButtonMixin:OnDragStart()
	self:ClickSocketButton();
end

function GenericSocketButtonMixin:OnEnter()
	local newSocket = C_ItemSocketInfo.GetNewSocketInfo(self:GetID());
	local existingSocket = C_ItemSocketInfo.GetExistingSocketInfo(self:GetID());

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

function GenericSocketButtonMixin:OnLeave()
	GameTooltip:Hide();
	ShoppingTooltip1:Hide();
end

function GenericSocketButtonMixin:OnEvent(event, ...)
	if ( event == "SOCKET_INFO_UPDATE" ) then
		if ( GameTooltip:IsOwned(self) ) then
			self:OnEnter();
		end
	end
end

local GENERIC_ITEM_SOCKETING_FRAME_EVENTS = {
	"SOCKET_INFO_BIND_CONFIRM",
	"SOCKET_INFO_REFUNDABLE_CONFIRM",
	"SOCKET_INFO_ACCEPT",
	"SOCKET_INFO_SUCCESS",
	"SOCKET_INFO_FAILURE",
};

GenericItemSocketingFrameMixin = {};

function GenericItemSocketingFrameMixin:OnLoad()
	self.socketUIType = Enum.ItemSocketInfoUIType.RemixArtifactUI;

	local function ApplySocketButtonOnClick()
		if ( self:GetParent().itemIsBoundTradeable ) then
			local dialog = StaticPopup_Show("END_BOUND_TRADEABLE", nil, nil, "gem");
		elseif ( self:GetParent().destroyingGem ) then
			StaticPopup_Show("CONFIRM_ACCEPT_SOCKETS");
		else
			C_ItemSocketInfo.AcceptSockets();
			PlaySound(SOUNDKIT.JEWEL_CRAFTING_FINALIZE);
		end
	end

	self.ApplySocketsButton.onClickHandler = ApplySocketButtonOnClick;

	-- We always want this event registered
	self:RegisterEvent("SOCKET_INFO_UI_EVENT_REGISTRATION_UPDATE");
end

function GenericItemSocketingFrameMixin:OnShow()
	self:RegisterEvents();
end

function GenericItemSocketingFrameMixin:OnHide()
	self:UnregisterEvents();

	if self.isSocketing then
		self:EnableSockets();
		self.isSocketing = nil;
	end
	StaticPopup_Hide("CONFIRM_ACCEPT_SOCKETS");
	C_ItemSocketInfo.CloseSocketInfo();
end

function GenericItemSocketingFrameMixin:RegisterEvents()
	if not self.registeredForEvents then
		FrameUtil.RegisterFrameForEvents(self, GENERIC_ITEM_SOCKETING_FRAME_EVENTS);
		self.registeredForEvents = true;
	end
end

function GenericItemSocketingFrameMixin:UnregisterEvents()
	if self.registeredForEvents then
		FrameUtil.UnregisterFrameForEvents(self, GENERIC_ITEM_SOCKETING_FRAME_EVENTS);
		self.registeredForEvents = false;
	end
end

function GenericItemSocketingFrameMixin:OnEvent(event, ...)
	if event == "SOCKET_INFO_UI_EVENT_REGISTRATION_UPDATE" then
		local socketUIType = ...;
		if socketUIType == self.socketUIType then
			self:RegisterEvents();
		else
			self:UnregisterEvents();
		end
	elseif event == "SOCKET_INFO_BIND_CONFIRM" then
		StaticPopup_Show("BIND_SOCKET");
	elseif event == "SOCKET_INFO_REFUNDABLE_CONFIRM" then
		StaticPopup_Show("REFUNDABLE_SOCKET");
	elseif event == "SOCKET_INFO_ACCEPT" then
		self.isSocketing = true;
		self.ApplySocketsButton:Disable();
		self:DisableSockets();
	elseif event == "SOCKET_INFO_SUCCESS" then
		self.isSocketing = nil;
		self:EnableSockets();
	elseif event == "SOCKET_INFO_FAILURE" then
		self.isSocketing = nil;
		self:EnableSockets();
	end
end

function GenericItemSocketingFrameMixin:Update()
	self.destroyingGem = nil;
	self.itemIsRefundable = nil;
	self.itemIsBoundTradeable = nil;

	if C_ItemSocketInfo.GetSocketItemRefundable() then
		self.itemIsRefundable = true;
	elseif C_ItemSocketInfo.GetSocketItemBoundTradeable() and C_ItemSocketInfo.HasBoundGemProposed() then -- Only gems flagged "Soulbound" on their enchantments will remove item tradability when socketed
		self.itemIsBoundTradeable = true;
	end

	local numSockets = C_ItemSocketInfo.GetNumSockets();
	local name, icon, quality, gemMatchesSocket;
	local numNewGems = numSockets;
	local bracketsOpen;
	local numMatches = 0;
	for i, socket in ipairs(self.SocketFrames) do
		if ( i <= numSockets ) then
			local gemBorder = socket.Background;
			local closedBracket = socket.BracketFrame.ClosedBracket;
			local openBracket = socket.BracketFrame.OpenBracket;
			local gemColorText = socket.BracketFrame.ColorText;

			-- See if there's a replacement gem and if not see if there's an existing gem
			name, icon, gemMatchesSocket = C_ItemSocketInfo.GetNewSocketInfo(i);
			bracketsOpen = 1;
			if ( not name ) then
				name, icon, gemMatchesSocket = C_ItemSocketInfo.GetExistingSocketInfo(i);
				if ( icon ) then
					bracketsOpen = nil;
				end

				-- Count down new gems if there's no name
				numNewGems = numNewGems - 1;
			elseif ( C_ItemSocketInfo.GetExistingSocketInfo(i) ) then
				self.destroyingGem = 1;
			end
			--Handle one color only right now
			local gemColor = C_ItemSocketInfo.GetSocketTypes(i);
			if ( gemMatchesSocket ) then
				local color = GEM_TYPE_INFO[gemColor];
				socket.Shine:Start(color.r, color.g, color.b);
				numMatches = numMatches + 1;
			else
				socket.Shine:Stop();
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
		self.Socket1:SetPoint("BOTTOM", self, "BOTTOM", -75, 33);
	elseif ( numSockets == 2 ) then
		self.Socket1:SetPoint("BOTTOM", self, "BOTTOM", -35, 33);
	else
		self.Socket1:SetPoint("BOTTOM", self, "BOTTOM", 0, 33);
	end

	self.Socket1.RightFiligree:SetShown(numSockets == 1);
	self.Socket2.RightFiligree:SetShown(numSockets == 2);
	self.Socket3.RightFiligree:SetShown(numSockets == 3);

	self.Socket1.LeftFiligree:SetShown(true);
	self.Socket2.LeftFiligree:SetShown(numSockets > 1);
	self.Socket3.LeftFiligree:SetShown(numSockets > 2);

	-- Update socket button
	if ( numNewGems == 0 ) then
		self.ApplySocketsButton:Disable();
	elseif ( not self.isSocketing ) then
		self.ApplySocketsButton:Enable();
	end
end

function GenericItemSocketingFrameMixin:DisableSockets()
	for i, socket in ipairs(self.SocketFrames) do
		socket:Disable();
		socket.Icon:SetDesaturated(true);
	end
end

function GenericItemSocketingFrameMixin:EnableSockets()
	for i, socket in ipairs(self.SocketFrames) do
		socket:Enable();
		socket.Icon:SetDesaturated(false);
	end
end
