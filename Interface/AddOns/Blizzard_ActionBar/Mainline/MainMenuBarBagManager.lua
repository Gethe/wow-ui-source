MainMenuBarBagManager = {};

function MainMenuBarBagManager:Init()
	self.allBagButtons = {};
	self:SetExpandBar(true); -- Default, this will change to being initialized by an actual cvar

	EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", function()
		self:SetExpandBar(GetCVarBool("expandBagBar"));

		EventRegistry:UnregisterFrameEventAndCallback("VARIABLES_LOADED", self);
	end, self);

	EventRegistry:RegisterFrameEventAndCallback("EXPAND_BAG_BAR_CHANGED", function(owner, expandBar) self:SetExpandBar(expandBar); end, self);
	EventRegistry:RegisterFrameEventAndCallback("CURSOR_CHANGED", self.OnCursorChanged, self);
end

function MainMenuBarBagManager:RegisterBagButton(bagButton)
	if not tContains(self.allBagButtons, bagButton) then
		table.insert(self.allBagButtons, bagButton);
	end
end

function MainMenuBarBagManager:EnumerateBagButtons()
	return ipairs(self.allBagButtons);
end

function MainMenuBarBagManager:ToggleExpandBar()
	SetCVar("expandBagBar", not GetCVarBool("expandBagBar"));
end

function MainMenuBarBagManager:SetExpandBar(expand)
	local wasExpand = self.expandBar;
	self.expandBar = expand;
	if wasExpand ~= expand then
		self:OnExpandBarChanged();
	end
end

function MainMenuBarBagManager:SetExpandBarAuto(expand)
	local wasExpand = self.expandBarAuto;
	self.expandBarAuto = expand;
	if wasExpand ~= expand then
		self:OnExpandBarChanged();
	end
end

function MainMenuBarBagManager:ShouldBarExpand()
	return self.expandBar or self.expandBarAuto;
end

function MainMenuBarBagManager:IsBarUserExpanded()
	return self.expandBar;
end

do
	local relevantCursorTypes =
	{
		[Enum.UICursorType.Item] = true,
		[Enum.UICursorType.Merchant] = true,
		[Enum.UICursorType.GuildBank] = true,
		[Enum.UICursorType.VoidItem] = true,
	};

	function MainMenuBarBagManager:OnCursorChanged(isDefault, newCursorType, oldCursorType, oldCursorVirtualID)
		self:SetExpandBarAuto(relevantCursorTypes[newCursorType] ~= nil);
	end
end

function MainMenuBarBagManager:OnExpandBarChanged()
	local isExpanded = self:ShouldBarExpand();
	for i, bagButton in self:EnumerateBagButtons() do
		bagButton:SetBarExpanded(isExpanded);
	end

	EventRegistry:TriggerEvent("MainMenuBarManager.OnExpandChanged", self);
end

MainMenuBarBagManager:Init();