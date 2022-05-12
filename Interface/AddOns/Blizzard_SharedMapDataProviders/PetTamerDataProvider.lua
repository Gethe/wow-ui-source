PetTamerDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function PetTamerDataProviderMixin:OnShow()
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("CVAR_UPDATE");
end

function PetTamerDataProviderMixin:OnHide()
	self:UnregisterEvent("SPELLS_CHANGED");
	self:UnregisterEvent("CVAR_UPDATE");
end

function PetTamerDataProviderMixin:OnEvent(event, ...)
	if event == "SPELLS_CHANGED" then
		self:RefreshAllData();
	elseif event == "CVAR_UPDATE" then
		local eventName, value = ...;
		if eventName == "SHOW_TAMERS" then
			self:RefreshAllData();
		end
	end
end

function PetTamerDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("PetTamerPinTemplate");
end

function PetTamerDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	if not CanTrackBattlePets() or not GetCVarBool("showTamers") then
		return;
	end

	local mapID = self:GetMap():GetMapID();
	local petTamers = C_PetInfo.GetPetTamersForMap(mapID);
	for i, petTamerInfo in ipairs(petTamers) do
		self:GetMap():AcquirePin("PetTamerPinTemplate", petTamerInfo);
	end
end

--[[ Pin ]]--
PetTamerPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_PET_TAMER");