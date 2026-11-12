local InputBindingManager = import("Blizzard_GamepadSharedUtility.InputBindingStack.InputBindingManager");

local PULSING_LAYOUT_INDEX_OFFSET = 2;	-- 1=backpack, 2=shard transfer
local PULSING_ICON_SIZE = 32;

GamepadInfoHUDMixin = {};

local function ResetPulsingButton(pool, button)
	UIFrameFlashStop(button.FlashTexture);
	Pool_HideAndClearAnchors(pool, button);
end

function GamepadInfoHUDMixin:OnLoad()
	self.pulsingButtonPool = CreateFramePool("BUTTON", self, "GamepadInfoHUDPulsingButtonTemplate", ResetPulsingButton);
	self.pulsingButtons = {};

	EditModeSystemMixin.OnSystemLoad(self);

	self.ShardTransferButton:HookScript("OnShow", GenerateClosure(self.OnShardTransferShown, self));
	self.ShardTransferButton:HookScript("OnHide", GenerateClosure(self.OnShardTransferHidden, self));

	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitGamepad, self));
end

function GamepadInfoHUDMixin:InitGamepad()
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player");

	GamepadRadial:RegisterCallback(GamepadRadial.Event.OnBeginSegmentPulse, self.RefreshPulsingIcons, self);
	GamepadRadial:RegisterCallback(GamepadRadial.Event.OnEndSegmentPulse, self.RefreshPulsingIcons, self);
	InputBindingManager:RegisterCallback(InputBindingManager.Event.CoreBindingsActiveChanged, self.OnCoreBindingsActiveChanged, self);

	self.coreBindingsActive = InputBindingManager:IsOnlyCoreBindingSetActive();

	self:RefreshPulsingIcons();
	self:RefreshInputHint();
	self:RefreshAmmoBag();
	self:RefreshBackpackCount();
	self:Show();
end

function GamepadInfoHUDMixin:UninitGamepad()
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED");

	GamepadRadial:UnregisterCallback(GamepadRadial.Event.OnBeginSegmentPulse, self);
	GamepadRadial:UnregisterCallback(GamepadRadial.Event.OnEndSegmentPulse, self);
	InputBindingManager:UnregisterCallback(InputBindingManager.Event.CoreBindingsActiveChanged, self);

	self.pulsingButtonPool:ReleaseAll();
	self.pulsingButtons = {};
	self:Hide();
end

function GamepadInfoHUDMixin:OnCoreBindingsActiveChanged(active)
	self.coreBindingsActive = active;
	self:RefreshInputHint();
end

function GamepadInfoHUDMixin:OnEvent(event, ...)
	if event == "BAG_UPDATE" then
		self:RefreshAmmoBag();
		self:RefreshBackpackCount();
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:RefreshAmmoBag();
		self:RefreshBackpackCount();
	elseif event == "UNIT_INVENTORY_CHANGED" then
		local unitToken = ...;
		if unitToken == "player" then
			self:RefreshAmmoBag();
		end
	end
end

local function GetEquippedAmmoBagInvSlotID()
	for bagIndex=Enum.BagIndex.Bag_1, Enum.BagIndex.Bag_4 do
		local invSlotID = C_Container.ContainerIDToInventoryID(bagIndex);
		local itemID = invSlotID and GetInventoryItemID("player", invSlotID);
		if itemID then
			local classID = select(6, C_Item.GetItemInfoInstant(itemID));
			if classID == Enum.ItemClass.Quiver then
				return invSlotID;
			end
		end
	end
end

function GamepadInfoHUDMixin:RefreshPulsingIcons()
	local prevButtons = self.pulsingButtons;
	local pulsingSegments = GamepadRadial:GetPulsingSegments();
	self.pulsingButtons = table.create(#pulsingSegments);

	for i, segment in ipairs(pulsingSegments) do
		local button = prevButtons[segment];

		if button then
			prevButtons[segment] = nil;
		else
			local icon = segment.icons and segment.icons.up or segment.icon;
			button = self.pulsingButtonPool:Acquire();
			button:SetScript("OnClick", GenerateClosure(segment.Trigger, segment));
			segment:SetIconForFrame(icon, button.Icon, PULSING_ICON_SIZE, PULSING_ICON_SIZE);
			UIFrameFlash(button.FlashTexture, 1, 1, -1, true, 0, 0, "microbutton");
			button:Show();
		end

		local layoutIndex = i + PULSING_LAYOUT_INDEX_OFFSET;
		button.layoutIndex = layoutIndex;

		self.pulsingButtons[segment] = button;
	end

	for _, button in pairs(prevButtons) do
		self.pulsingButtonPool:Release(button);
	end

	self:RefreshInputHint();
	self:MarkDirty();
end

function GamepadInfoHUDMixin:RefreshInputHint()
	local hasPulsingButton = next(self.pulsingButtons) ~= nil;
	local shouldShowHint = hasPulsingButton or self.ShardTransferButton:IsShown();
	self.ButtonHint:SetShown(self.coreBindingsActive and shouldShowHint);
	self:MarkDirty();
end

function GamepadInfoHUDMixin:RefreshAmmoBag()
	local ammoBagInvSlotID = GetEquippedAmmoBagInvSlotID();
	local hasAmmoBag = ammoBagInvSlotID ~= nil;
	local wasVisible = self.AmmoButton:IsShown();

	if ammoBagInvSlotID  then
		local ammoItemID = GetInventoryItemID("player", INVSLOT_AMMO);
		local ammoBagTexture = GetInventoryItemTexture("player", ammoBagInvSlotID);
		local ammoCount = ammoItemID and C_Item.GetItemCount(ammoItemID) or 0;
		local ammoCountLabel = ammoCount < 1000 and tostring(ammoCount) or "*";
		self.AmmoButton.Icon:SetTexture(ammoBagTexture);
		self.AmmoButton.Count:SetText(ammoCountLabel);
	end

	if hasAmmoBag ~= wasVisible then
		self.AmmoButton:SetShown(hasAmmoBag);
		self:MarkDirty();
	end
end

function GamepadInfoHUDMixin:RefreshBackpackCount()
	local freeSlots = C_Container.CalculateTotalNumberOfFreeBagSlots();
	self.BackpackButton.Count:SetText(("(%d)"):format(freeSlots or 0));
end

function GamepadInfoHUDMixin:GetPadding()
	return 0, 0, 0, 0;
end

function GamepadInfoHUDMixin:OnShardTransferShown()
	self:RefreshInputHint();
end

function GamepadInfoHUDMixin:OnShardTransferHidden()
	self:RefreshInputHint();
end

GamepadInfoHUDShardTransferButtonMixin = {};

function GamepadInfoHUDShardTransferButtonMixin:OnLoad()
	self.timeFormatter = CreateAndInitFromMixin(SecondsFormatterMixin, 0, SecondsFormatter.Abbreviation.OneLetter);
	self.timeFormatter:SetDesiredUnitCount(1);

	-- The icon art isn't necessarily square
	local iconAtlas = "gamepad-radial-icon-fullmap-up";
	local iconSize = 43;
	local iconAtlasInfo = C_Texture.GetAtlasInfo(iconAtlas);
	self.Icon:ClearAllPoints();
	self.Icon:SetPoint("CENTER");
	self.Icon:SetAtlas(iconAtlas);
	self.Icon:SetScale(math.min(iconSize / iconAtlasInfo.width, iconSize / iconAtlasInfo.height));
	self.Icon:SetSize(iconAtlasInfo.width, iconAtlasInfo.height);

	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitGamepad, self));
end

function GamepadInfoHUDShardTransferButtonMixin:InitGamepad()
	self:RegisterEvent("SHARD_TRANSFER_IMMINENT");
	self:RegisterEvent("SHARD_TRANSFER_CANCELLED");
	self:RegisterEvent("SHARD_TRANSFER");

	EventRegistry:RegisterCallback("Gamepad.ShowMainMenu", self.OnMainMenuOpened, self);
	EventRegistry:RegisterCallback("Gamepad.HideMainMenu", self.OnMainMenuClosed, self);

	-- Defer refresh in case this is called at load time, since the shard transfer frame is loaded after this
	RunNextFrame(GenerateClosure(self.RefreshVisibility, self));
end

function GamepadInfoHUDShardTransferButtonMixin:UninitGamepad()
	self:UnregisterEvent("SHARD_TRANSFER_IMMINENT");
	self:UnregisterEvent("SHARD_TRANSFER_CANCELLED");
	self:UnregisterEvent("SHARD_TRANSFER");

	EventRegistry:UnregisterCallback("Gamepad.ShowMainMenu", self);
	EventRegistry:UnregisterCallback("Gamepad.HideMainMenu", self);
end

function GamepadInfoHUDShardTransferButtonMixin:OnShow()
	UIFrameFlash(self.FlashTexture, 1, 1, -1, true, 0, 0, "microbutton");
end

function GamepadInfoHUDShardTransferButtonMixin:OnHide()
	UIFrameFlashStop(self.FlashTexture);
end

function GamepadInfoHUDShardTransferButtonMixin:OnEvent(event, ...)
	if event == "SHARD_TRANSFER_IMMINENT"
		or event == "SHARD_TRANSFER_CANCELLED"
		or event == "SHARD_TRANSFER"
	then
		self:RefreshVisibility();
	end
end

function GamepadInfoHUDShardTransferButtonMixin:OnUpdate()
	local remaining = GetEvictionTimeRemaining();

	if remaining and remaining > 0 then
		local timeLeft = self.timeFormatter:Format(remaining);
		self.Countdown:SetText(timeLeft);
	else
		local dots = string.rep(".", (GetTime() % 3) + 1);
		self.Countdown:SetText(dots);
	end
end

function GamepadInfoHUDShardTransferButtonMixin:RefreshVisibility()
	self:SetShown(GetEvictionTimeRemaining() ~= nil);
	GamepadShardTransferFrame:SetShown(self:IsShown() and self.isMainMenuOpen);
end

function GamepadInfoHUDShardTransferButtonMixin:OnMainMenuOpened()
	self.isMainMenuOpen = true;
	GamepadShardTransferFrame:SetShown(self:IsShown());
end

function GamepadInfoHUDShardTransferButtonMixin:OnMainMenuClosed()
	self.isMainMenuOpen = false;
	GamepadShardTransferFrame:Hide();
end

GamepadShardTransferMixin = {};

function GamepadShardTransferMixin:OnLoad()
	self.isActive = false;

	local function AcceptRefresh()
		C_PlayerInteractionManager.ShardTransferConfirm();
	end

	local holdTime = 1;
	local acceptRefresh = GamepadSharedUtility.CreateTapOrHoldPromptedBinding(GAMEPAD_FACE_LEFT, holdTime, nil, AcceptRefresh);
	local acceptRefreshBinding = acceptRefresh:AddCustomPromptBinding({ frame = self.AcceptPrompt });
	acceptRefresh:AddCustomPromptHoldFunction(acceptRefreshBinding, { holdTime = holdTime });
	acceptRefresh:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.NEVER);

	self.footer = GamepadSharedUtility.CreatePromptedBindingFooter(self, "GamepadShardTransferFooter");
	self.footer:AddPromptedBinding(acceptRefresh);
	self.footer:Finalize();

	self.CloseButton:Hide();
end

function GamepadShardTransferMixin:OnShow()
	self:OnUpdate();
end

function GamepadShardTransferMixin:OnHide()
	if self.isActive then
		self.footer:HideAndDeactivateBindings();
		self.isActive = false;
	end
end

function GamepadShardTransferMixin:OnUpdate()
	local timeLeft = GetEvictionTimeRemaining();
	local isActive = timeLeft and timeLeft > 0;

	if isActive ~= self.isActive then
		self.isActive = isActive;
		self.PromptText:SetShown(isActive);

		if isActive then
			self.footer:ShowAndActivateBindings();
		else
			self.footer:HideAndDeactivateBindings();
		end
	end

	if isActive then
		local timeUnit = SECONDS;
		if timeLeft >= 60 then
			timeLeft = math.floor(timeLeft / 60);
			timeUnit = MINUTES;
		end

		self.Text:SetText(SHARD_TRANSFER_COUNTDOWN_STATIC_POPUP_MESSAGE:format(timeLeft, timeUnit));
		self:SetHeight(self:GetTop() - self.AcceptPrompt:GetBottom() + 14);
	else
		self.Text:SetText(SHARD_TRANSFER_ANYTIME);
		self:SetHeight(self:GetTop() - self.Text:GetBottom() + 14);
	end
end

function GamepadShardTransferMixin:ManagesOwnOutroAnimation()
	return false;
end
