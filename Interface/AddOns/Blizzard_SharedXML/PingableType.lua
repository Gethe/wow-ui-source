-- Mixins used for frames that are pingable, and associated behavior used up to the point of sending a ping.

-- Base mixin, do not use directly. If adding a new mixin or PingableTypeMixin function here, be sure to mirror it in Classic's Stubs.lua/xml files if classic has similar UI.
PingableTypeMixin = {};

-- Check if attributes like "ping-receiver" should be set or not on this frame.
function PingableTypeMixin:UpdatePingAttributes()
end

-- Certain UI may only sometimes be valid ping targets (action buttons are pingable depending on the type of action etc.)
function PingableTypeMixin:GetIsPingable()
	return true;
end

-- Is radial wheel pinging supported on this frame. If false, only contextual pings are allowed.
function PingableTypeMixin:GetAllowRadialWheel()
	return true;
end

-- Various pieces of target information for a UI ping.
function PingableTypeMixin:GetTargetInfo()
	local info = {
		-- guid - the guid of the target the ping should be located over, if any.
		-- spellID - the spellID of a pinged action button, if a spell.
		-- itemID - the itemID of a pinged action button, if an item.
	};

	return info;
end


PingableType_UnitFrameMixin = CreateFromMixins(PingableTypeMixin);

function PingableType_UnitFrameMixin:GetTargetInfo()
	local targetInfo = {
		guid = UnitGUID(self.unit or self:GetAttribute("unit"))
	};

	return targetInfo;
end


PingableType_PlayerUnitFrameMixin = CreateFromMixins(PingableType_UnitFrameMixin);

function PingableType_PlayerUnitFrameMixin:GetAllowRadialWheel()
	-- Do not allow the radial wheel when over player resources.
	return self.unit ~= "player" or self.PlayerFrameContainer.PlayerPortrait:IsMouseOver();
end

function PingableType_PlayerUnitFrameMixin:GetTargetInfo()
	local targetInfo = {
		guid = UnitGUID("player")
	};

	targetInfo.isPlayerResource = self.unit == "player" and not self.PlayerFrameContainer.PlayerPortrait:IsMouseOver();

	return targetInfo;
end


PingableType_ActionButtonMixin = CreateFromMixins(PingableTypeMixin);

function PingableType_ActionButtonMixin:UpdatePingAttributes()
	-- Empty action bar buttons should let pings pass through them.
	if self:HasAction() then
		self:SetAttribute("ping-receiver", true);
	else
		self:ClearAttribute("ping-receiver");
	end
end

function PingableType_ActionButtonMixin:GetIsPingable()
	-- Only certain kinds of actions are pingable. This only checks high level types, the client will determine if a specific spell or item etc. is valid later.
	local isPingable = false;

	local actionButtonInfo = self:GetActionButtonInfo();
	if actionButtonInfo and actionButtonInfo.id then
		if actionButtonInfo.actionType then
			-- Only allow spells and items to be pinged if this action button allows different types of actions.
			if actionButtonInfo.actionType == "spell" or actionButtonInfo.actionType == "item" then
				isPingable = actionButtonInfo.isUsable;
			end
		else
			-- Otherwise, assume this action is a spell, which should be pingable.
			isPingable = true;
		end
	end

	return isPingable;
end

function PingableType_ActionButtonMixin:GetAllowRadialWheel()
	return false;
end

function PingableType_ActionButtonMixin:GetTargetInfo()
	local targetInfo = {};

	local actionButtonInfo = self:GetActionButtonInfo();
	if actionButtonInfo and actionButtonInfo.id then
		if actionButtonInfo.actionType and actionButtonInfo.actionType == "item" then
			targetInfo.itemID = actionButtonInfo.id;
		else
			targetInfo.spellID = actionButtonInfo.id;
		end
	end

	return targetInfo;
end


PingableType_CooldownViewerItemMixin = CreateFromMixins(PingableTypeMixin);

function PingableType_CooldownViewerItemMixin:GetAllowRadialWheel()
	return false;
end

function PingableType_CooldownViewerItemMixin:GetTargetInfo()
	local targetInfo = {};

	local spellID = self:GetSpellID();
	if spellID then
		targetInfo.spellID = spellID;
	end

	return targetInfo;
end
