SoulbindSelectGroupMixin = CreateFromMixins(CallbackRegistryMixin);

SoulbindSelectGroupMixin:GenerateCallbackEvents(
	{
		"OnSoulbindSelected",
	}
);

function SoulbindSelectGroupMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	local resetterCb = function(pool, frame)
		frame:Reset();
		FramePool_HideAndClearAnchors(pool, frame);
	end;

	self.pool = CreateFramePool("BUTTON", self, "SoulbindsSelectButtonTemplate", resetterCb);

	self.buttonGroup = CreateRadioButtonGroup();
end

function SoulbindSelectGroupMixin:OnHide()
	self.buttonGroup:Reset();
end

function SoulbindSelectGroupMixin:Init(covenantData, initialSelectSoulbindID)
	self.pool:ReleaseAll();

	local soulbindIDs = covenantData.soulbindIDs;
	local parent = nil;
	local buttons = {};
	for index = 1, #soulbindIDs do
		local button = self.pool:Acquire();
		table.insert(buttons, button);
		if parent then
			button:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 5);
		else
			button:SetPoint("TOPLEFT");
		end
		parent = button;
		button:Show();
	end

	-- Required prior to initializing the buttons so that their model scene frames have a valid size.
	self:Layout();

	for index, button in ipairs(buttons) do
		local soulbindData = C_Soulbinds.GetSoulbindData(soulbindIDs[index]);
		button:Init(soulbindData);
	end

	self.buttonGroup:Reset();
	self.buttonGroup:AddButtons(buttons);
	self.buttonGroup:SelectAtIndex(tIndexOf(soulbindIDs, initialSelectSoulbindID) or 1);
	self.buttonGroup:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.OnSoulbindSelected, self, soulbindIDs);

	self:UpdateActivations();
end

function SoulbindSelectGroupMixin:OnSoulbindSelected(soulbindIDs, button, buttonIndex)
	self:TriggerEvent(SoulbindSelectGroupMixin.Event.OnSoulbindSelected, soulbindIDs, button, buttonIndex);
end

function SoulbindSelectGroupMixin:OnSoulbindActivated(soulbindID)
	local button = self.buttonGroup:FindButtonByPredicate(
		function(button)
			return soulbindID == button:GetSoulbindID();
		end
	);
	button:OnActivated();

	self:UpdateActivations();
end

function SoulbindSelectGroupMixin:UpdateActivations()
	self:SetActiveMarkers(Soulbinds.GetSoulbindAppearingActive());
end

function SoulbindSelectGroupMixin:SetActiveMarkers(soulbindID)
	for buttonIndex, button in ipairs(self.buttonGroup:GetButtons()) do
		button:SetActivated(soulbindID == button:GetSoulbindID());
	end
end
