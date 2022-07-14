EventButtonMixin = CreateFromMixins(CallbackRegistryMixin);

EventButtonMixin:GenerateCallbackEvents(
	{
		"OnMouseUp",
		"OnMouseDown",
		"OnClick",
		"OnEnter",
		"OnLeave",
	}
);

function EventButtonMixin:PlaySoundKit(soundKitID)
	if soundKitID and self:IsEnabled() then
		PlaySound(soundKitID, nil, SOUNDKIT_ALLOW_DUPLICATES);
	end
end

function EventButtonMixin:OnLoad_Intrinsic()
	CallbackRegistryMixin.OnLoad(self);
end

function EventButtonMixin:OnMouseUp_Intrinsic(buttonName, upInside)
	self:TriggerEvent("OnMouseUp", buttonName, upInside);
	self:PlaySoundKit(self.mouseUpSoundKitID);
end

function EventButtonMixin:OnMouseDown_Intrinsic(buttonName)
	self:TriggerEvent("OnMouseDown", buttonName);
	self:PlaySoundKit(self.mouseDownSoundKitID);
end

function EventButtonMixin:OnClick_Intrinsic(buttonName, down)
	self:TriggerEvent("OnClick", buttonName, down);
	self:PlaySoundKit(self.clickSoundKitID);
end

function EventButtonMixin:OnEnter_Intrinsic()
	self:TriggerEvent("OnEnter");
end

function EventButtonMixin:OnLeave_Intrinsic()
	self:TriggerEvent("OnLeave");
end