PlayerLocation = {};
PlayerLocationMixin = {};

--[[static]] function PlayerLocation:CreateFromGUID(guid)
	local playerLocation = CreateFromMixins(PlayerLocationMixin);
	playerLocation:SetGUID(guid);
	return playerLocation;
end

--[[static]] function PlayerLocation:CreateFromUnit(unit)
	local playerLocation = CreateFromMixins(PlayerLocationMixin);
	playerLocation:SetUnit(unit);
	return playerLocation;
end

--[[static]] function PlayerLocation:CreateFromChatLineID(lineID)
	local playerLocation = CreateFromMixins(PlayerLocationMixin);
	playerLocation:SetChatLineID(lineID);
	return playerLocation;
end

--[[static]] function PlayerLocation:CreateFromBattlefieldScoreIndex(battlefieldScoreIndex)
	local playerLocation = CreateFromMixins(PlayerLocationMixin);
	playerLocation:SetBattlefieldScoreIndex(battlefieldScoreIndex);
	return playerLocation;
end

--[[static]] function PlayerLocation:CreateFromVoiceID(memberID, channelID)
	local playerLocation = CreateFromMixins(PlayerLocationMixin);
	playerLocation:SetVoiceID(memberID, channelID);
	return playerLocation;
end

--[[public api]]
function PlayerLocationMixin:SetGUID(guid)
	self:ClearAndSetField("guid", guid);
end

function PlayerLocationMixin:IsGUID()
	return self.guid ~= nil;
end

function PlayerLocationMixin:GetGUID()
	return self.guid;
end

function PlayerLocationMixin:SetUnit(unit)
	self:ClearAndSetField("unit", unit);
end

function PlayerLocationMixin:IsUnit()
	return self.unit ~= nil;
end

function PlayerLocationMixin:GetUnit()
	return self.unit;
end

function PlayerLocationMixin:SetChatLineID(lineID)
	self:ClearAndSetField("chatLineID", lineID);
end

function PlayerLocationMixin:IsChatLineID()
	return self.chatLineID ~= nil;
end

function PlayerLocationMixin:GetChatLineID()
	return self.chatLineID;
end

function PlayerLocationMixin:SetBattlefieldScoreIndex(index)
	self:ClearAndSetField("battlefieldScoreIndex", index);
end

function PlayerLocationMixin:IsBattlefieldScoreIndex()
	return self.battlefieldScoreIndex ~= nil;
end

function PlayerLocationMixin:GetBattlefieldScoreIndex()
	return self.battlefieldScoreIndex;
end

function PlayerLocationMixin:SetVoiceID(memberID, channelID)
	self:Clear();
	self.voiceMemberID = memberID;
	self.voiceChannelID = channelID;
end

function PlayerLocationMixin:IsVoiceID()
	return self.voiceMemberID ~= nil and self.voiceChannelID ~= nil;
end

function PlayerLocationMixin:GetVoiceID()
	return self.voiceMemberID, self.voiceChannelID;
end

--[[private api]]
function PlayerLocationMixin:Clear()
	self.guid = nil;
	self.unit = nil;
	self.chatLineID = nil;
	self.battlefieldScoreIndex = nil;
	self.voiceMemberID = nil;
	self.voiceChannelID = nil;
end

function PlayerLocationMixin:ClearAndSetField(fieldName, field)
	self:Clear();
	self[fieldName] = field;
end