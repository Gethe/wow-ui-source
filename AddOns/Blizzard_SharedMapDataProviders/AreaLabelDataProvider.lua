
AreaLabelDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function AreaLabelDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	if not self.Label then
		self.Label = CreateFrame("FRAME", nil, self:GetMap():GetCanvasContainer(), "AreaLabelFrameTemplate");

		self.setAreaLabelCallback = function(event, ...) self.Label:SetLabel(...); end;
		self.clearAreaLabelCallback = function(event, ...) self.Label:ClearLabel(...); end;
	else
		self.Label:SetParent(self:GetMap():GetCanvasContainer());
	end

	self.Label:SetPoint("TOP", self:GetMap():GetCanvasContainer(), 0, self:GetOffsetY());
	self.Label.dataProvider = self;

	self:GetMap():RegisterCallback("SetAreaLabel", self.setAreaLabelCallback, self);
	self:GetMap():RegisterCallback("ClearAreaLabel", self.clearAreaLabelCallback, self);	

	self.Label:Show();
end

function AreaLabelDataProviderMixin:OnRemoved(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	self:GetMap():UnregisterCallback("SetAreaLabel", self);
	self:GetMap():UnregisterCallback("ClearAreaLabel", self);
	
	self.Label.dataProvider = nil;
	self.Label:ClearAllPoints();
	self.Label:Hide();
end

function AreaLabelDataProviderMixin:GetOffsetY()
	return self.offsetY or -10;
end

function AreaLabelDataProviderMixin:SetOffsetY(offsetY)
	self.offsetY = offsetY;
	if self.Label then
		self.Label:SetPoint("TOP", self:GetMap(), 0, self.offsetY);
	end
end

function AreaLabelDataProviderMixin:RemoveAllData()
	self.Label:ClearAllLabels();
end

MAP_AREA_LABEL_TYPE = {
	-- Where their value is the priority (lower numbers are trumped by larger)
	INVASION = 1,
	AREA_POI_BANNER = 2,
	AREA_NAME = 3,
	POI = 4,
};

AreaLabelFrameMixin = { };

function AreaLabelFrameMixin:OnLoad()
	self.labelInfoByType = { };
end

function AreaLabelFrameMixin:OnUpdate()
	self:ClearLabel(MAP_AREA_LABEL_TYPE.AREA_NAME);
	local map = self.dataProvider:GetMap();
	if map:IsCanvasMouseFocus() then
		local name, description;
		local mapID = map:GetMapID();
		local normalizedCursorX, normalizedCursorY = map:GetNormalizedCursorPosition();
		local positionMapInfo = C_Map.GetMapInfoAtPosition(mapID, normalizedCursorX, normalizedCursorY);		
		if positionMapInfo and positionMapInfo.mapID ~= mapID then
			name = positionMapInfo.name;
			local playerMinLevel, playerMaxLevel, petMinLevel, petMaxLevel = C_Map.GetMapLevels(positionMapInfo.mapID);
			if name and playerMinLevel and playerMaxLevel and playerMinLevel > 0 and playerMaxLevel > 0 then
				local playerLevel = UnitLevel("player");
				local color;
				if playerLevel < playerMinLevel then
					color = GetQuestDifficultyColor(playerMinLevel);
				elseif playerLevel > playerMaxLevel then
					--subtract 2 from the maxLevel so zones entirely below the player's level won't be yellow
					color = GetQuestDifficultyColor(playerMaxLevel - 2);
				else
					color = QuestDifficultyColors["difficult"];
				end
				color = ConvertRGBtoColorString(color);
				if playerMinLevel ~= playerMaxLevel then
					name = name..color.." ("..playerMinLevel.."-"..playerMaxLevel..")"..FONT_COLOR_CODE_CLOSE;
				else
					name = name..color.." ("..playerMaxLevel..")"..FONT_COLOR_CODE_CLOSE;
				end
			end

--[[
			local _, _, _, _, locked = C_PetJournal.GetPetLoadOutInfo(1);
			if not locked and GetCVarBool("showTamers") then --don't show pet levels for people who haven't unlocked battle petting
				if petMinLevel and petMaxLevel and petMinLevel > 0 and petMaxLevel > 0 then
					local teamLevel = C_PetJournal.GetPetTeamAverageLevel();
					local color;
					if teamLevel then
						if teamLevel < petMinLevel then
							--add 2 to the min level because it's really hard to fight higher level pets
							color = GetRelativeDifficultyColor(teamLevel, petMinLevel + 2);
						elseif teamLevel > petMaxLevel then
							color = GetRelativeDifficultyColor(teamLevel, petMaxLevel);
						else
							--if your team is in the level range, no need to call the function, just make it yellow
							color = QuestDifficultyColors["difficult"];
						end
					else
						--If you unlocked pet battles but have no team, level ranges are meaningless so make them grey
						color = QuestDifficultyColors["header"];
					end
					color = ConvertRGBtoColorString(color);
					if petMinLevel ~= petMaxLevel then
						description = WORLD_MAP_WILDBATTLEPET_LEVEL..color.."("..petMinLevel.."-"..petMaxLevel..")"..FONT_COLOR_CODE_CLOSE;
					else
						description = WORLD_MAP_WILDBATTLEPET_LEVEL..color.."("..petMaxLevel..")"..FONT_COLOR_CODE_CLOSE;
					end
				end
			end
]]
		else
			name = MapUtil.FindBestAreaNameAtMouse(mapID, normalizedCursorX, normalizedCursorY);
		end
		if name then
			self:SetLabel(MAP_AREA_LABEL_TYPE.AREA_NAME, name, description);
		end
	end
	self:EvaluateLabels();
end

function AreaLabelFrameMixin:SetLabel(areaLabelType, name, description, nameColor, descriptionColor, textureInfo)
	if not self.labelInfoByType[areaLabelType] then
		self.labelInfoByType[areaLabelType] = { };
	end

	local areaLabelInfo = self.labelInfoByType[areaLabelType];
	if areaLabelInfo.name ~= name or areaLabelInfo.description ~= description or not AreColorsEqual(areaLabelInfo.nameColor, nameColor) or not AreColorsEqual(areaLabelInfo.descriptionColor, descriptionColor) or areaLabelInfo.callback ~= callback then
		areaLabelInfo.name = name;
		areaLabelInfo.description = description;
		areaLabelInfo.nameColor = nameColor;
		areaLabelInfo.descriptionColor = descriptionColor;
		areaLabelInfo.textureInfo = textureInfo;

		self.dirty = true;
	end
end

function AreaLabelFrameMixin:ClearLabel(areaLabelType)
	if self.labelInfoByType[areaLabelType] then
		self:SetLabel(areaLabelType, nil);
	end
end

function AreaLabelFrameMixin:ClearAllLabels()
	table.wipe(self.labelInfoByType);
	self.dirty = true;
end

function AreaLabelFrameMixin:EvaluateLabels()
	if not self.dirty then
		return;
	end
	self.dirty = false;

	local highestPriorityAreaLabelType;

	for areaLabelName, areaLabelType in pairs(MAP_AREA_LABEL_TYPE) do
		local areaLabelInfo = self.labelInfoByType[areaLabelType];
		if areaLabelInfo and areaLabelInfo.name then
			if not highestPriorityAreaLabelType or areaLabelType > highestPriorityAreaLabelType then
				highestPriorityAreaLabelType = areaLabelType;
			end
		end
	end

	if highestPriorityAreaLabelType then
		local areaLabelInfo = self.labelInfoByType[highestPriorityAreaLabelType];
		self.Name:SetText(areaLabelInfo.name);
		self.Description:SetText(areaLabelInfo.description);

		if areaLabelInfo.nameColor then
			self.Name:SetVertexColor(areaLabelInfo.nameColor:GetRGB());
		else
			self.Name:SetVertexColor(AREA_NAME_FONT_COLOR:GetRGB());
		end

		if areaLabelInfo.descriptionColor then
			self.Description:SetVertexColor(areaLabelInfo.descriptionColor:GetRGB());
		else
			self.Description:SetVertexColor(AREA_DESCRIPTION_FONT_COLOR:GetRGB());
		end
		
		if areaLabelInfo.textureInfo then
			self.Texture:SetAtlas(areaLabelInfo.textureInfo.atlas);
			self.Texture:SetAtlas(areaLabelInfo.textureInfo.atlas);
			self.Texture:SetSize(areaLabelInfo.textureInfo.width, areaLabelInfo.textureInfo.height);
			self.Texture:Show();
		else
			self.Texture:Hide();
		end
	else
		self.Name:SetText("");
		self.Description:SetText("");
		self.Texture:Hide();
	end
end