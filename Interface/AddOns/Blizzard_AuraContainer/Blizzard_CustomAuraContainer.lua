local _addonName, addonTbl = ...;

local CustomAuraContainerPrivateMixin = CreateFromMixins(addonTbl.AuraContainerPrivateMixin);
addonTbl.CustomAuraContainerPrivateMixin = CustomAuraContainerPrivateMixin;

function CustomAuraContainerPrivateMixin:OnLoad_Intrinsic()
	addonTbl.AuraContainerPrivateMixin.OnLoad_Intrinsic(self);

	self.auraFrames = {};
	self.auraFilters = {};
end

--[[override]] function CustomAuraContainerPrivateMixin:OnUnitAuraUpdate(unitAuraUpdateInfo)
	local aurasChanged = false;
	if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate then
		self:ParseAllAuras();
		aurasChanged = true;
	else
		if unitAuraUpdateInfo.addedAuras ~= nil then
			for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
				aurasChanged = self:AddAura(aura) or aurasChanged;
			end
		end

		if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
				aurasChanged = self:UpdateAura(auraInstanceID) or aurasChanged;
			end
		end

		if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
				aurasChanged = self:RemoveAura(auraInstanceID) or aurasChanged;
			end
		end
	end

	if aurasChanged then
		self:RefreshAuraFrames();
	end
end

--[[override]] function CustomAuraContainerPrivateMixin:UpdateAllAuras()
	self:ParseAllAuras();
	self:RefreshAuraFrames();
end

function CustomAuraContainerPrivateMixin:AddAura(auraData)
	local aurasChanged = false;

	for _index, auraFilter in ipairs(self.auraFilters) do
		local auraInstanceID = auraData.auraInstanceID;

		if not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unitToken, auraInstanceID, auraFilter.filterString) then
			local auraList = auraFilter.auras;
			auraData.requiresFullUpdate = true;
			auraList[auraInstanceID] = auraData;
			aurasChanged = true;
		end
	end

	return aurasChanged;
end

function CustomAuraContainerPrivateMixin:UpdateAura(auraInstanceID)
	local aurasChanged = false;
	local newAuraData;

	for _index, auraFilter in ipairs(self.auraFilters) do
		local auraList = auraFilter.auras;
		if auraList[auraInstanceID] ~= nil then
			newAuraData = newAuraData or C_UnitAuras.GetAuraDataByAuraInstanceID(self.unitToken, auraInstanceID);
			auraList[auraInstanceID] = newAuraData;
			aurasChanged = true;
		end
	end

	return aurasChanged;
end

function CustomAuraContainerPrivateMixin:RemoveAura(auraInstanceID)
	local aurasChanged = false;

	for _index, auraFilter in ipairs(self.auraFilters) do
		local auraList = auraFilter.auras;
		if auraList[auraInstanceID] ~= nil then
			auraList[auraInstanceID] = nil;
			aurasChanged = true;
		end
	end

	return aurasChanged;
end

function CustomAuraContainerPrivateMixin:ParseAllAuras()
	for _index, auraFilter in ipairs(self.auraFilters) do
		local auraList = auraFilter.auras;
		auraList:Clear();

		for _auraIndex, auraData in ipairs(C_UnitAuras.GetUnitAuras(self.unitToken, auraFilter.filterString)) do
			local auraInstanceID = auraData.auraInstanceID;
			auraData.requiresFullUpdate = true;
			auraList[auraInstanceID] = auraData;
		end
	end
end

function CustomAuraContainerPrivateMixin:AddAuraFrameInternal(auraFrame)
	auraFrame:SetAuraContainer(self);
	table.insert(self.auraFrames, auraFrame);
end

function CustomAuraContainerPrivateMixin:RemoveAuraFrameInternal(index)
	local auraFrame = table.remove(self.auraFrames, index);
	auraFrame:ClearAuraContainer();
end

function CustomAuraContainerPrivateMixin:RefreshAuraFrames()
	local frameIndex = 1;
	local auraIndex = 1;

	local function RefreshAuraFrame(_auraInstanceID, auraData, auraFilter)
		local auraFrame = self.auraFrames[frameIndex];
		local stopIterating = false;

		if auraFrame ~= nil and auraIndex <= auraFilter.maxFrameCount then
			auraFrame:SetAuraInstance(self.unitToken, auraData, auraData.requiresFullUpdate);
			auraData.requiresFullUpdate = nil;
			frameIndex = frameIndex + 1;
			auraIndex = auraIndex + 1;
		else
			stopIterating = true;
		end

		return stopIterating;
	end

	for _index, auraFilter in ipairs(self.auraFilters) do
		if auraFilter.roundUpFrameIndex then
			local remainder = (frameIndex - 1) % auraFilter.roundUpFrameIndex;

			if remainder > 0 then
				for i = frameIndex, math.min((frameIndex - 1) + (auraFilter.roundUpFrameIndex - remainder), #self.auraFrames) do
					self.auraFrames[i]:ClearAuraInstance();
					frameIndex = frameIndex + 1;
				end
			end
		end

		auraFilter.auras:Iterate(RefreshAuraFrame, auraFilter);
	end

	for i = frameIndex, #self.auraFrames do
		self.auraFrames[i]:ClearAuraInstance();
	end
end

local CustomAuraContainerInboundMixin = {};
addonTbl.CustomAuraContainerInboundMixin = CustomAuraContainerInboundMixin;

function CustomAuraContainerInboundMixin:AddAuraFilter(filterString, options)
	options = securecopy(options or {});

	local isAssociative = true;
	local auraFilter = {
		auras = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, isAssociative),
		filterString = filterString,
		maxFrameCount = options and options.maxFrameCount or math.huge,
		roundUpFrameIndex = options and options.roundUpFrameIndex or nil,
	};

	table.insert(self.auraFilters, auraFilter);
	self:UpdateAllAuras();
end

function CustomAuraContainerInboundMixin:ClearAuraFilters()
	self.auraFilters = {};
	self:UpdateAllAuras();
end

function CustomAuraContainerInboundMixin:AddAuraFrame(auraFrame)
	self:AddAuraFrameInternal(GetForbiddenObjectTable(auraFrame));
	self:RefreshAuraFrames();
end

function CustomAuraContainerInboundMixin:AddAuraFramesFromTable(auraFrames)
	for _, auraFrame in ipairs(auraFrames) do
		self:AddAuraFrameInternal(GetForbiddenObjectTable(auraFrame));
	end

	self:RefreshAuraFrames();
end

function CustomAuraContainerInboundMixin:AddAuraFramesFromTemplate(templateName, count)
	local frames = {};

	for _i = 1, count do
		local auraFrame = CreateFrame("AuraButton", nil, self, templateName);
		table.insert(frames, auraFrame);
		self:AddAuraFrameInternal(GetForbiddenObjectTable(auraFrame));
	end

	self:RefreshAuraFrames();
	return frames;
end

function CustomAuraContainerInboundMixin:RemoveAuraFrame(auraFrame)
	local forbiddenAuraFrame = GetForbiddenObjectTable(auraFrame);
	local index = tIndexOf(self.auraFrames, forbiddenAuraFrame);

	if index then
		self:RemoveAuraFrameInternal(index);
		self:RefreshAuraFrames();
	end
end

function CustomAuraContainerInboundMixin:RemoveAllAuraFrames()
	for index, _auraFrame in ipairs_reverse(self.auraFrames) do
		self:RemoveAuraFrameInternal(index);
	end

	self:RefreshAuraFrames();
end

function CustomAuraContainerInboundMixin:GetAuraFrame(index)
	return self.auraFrames[index];
end

function CustomAuraContainerInboundMixin:GetAuraFrameCount()
	return #self.auraFrames;
end

ApplySecureDelegatesToTable(CustomAuraContainerInboundMixin);
