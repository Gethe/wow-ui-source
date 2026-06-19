VisualAlertBaseMixin = CreateFromMixins(VisualAlertMixin);

function VisualAlertBaseMixin:OnLoad()
	self:ApplyVertexColor();
end

function VisualAlertBaseMixin:OnShow()
	AnimateWhileShownMixin.PlayAnims(self);
	self.playTime = 0;
end

function VisualAlertBaseMixin:ClearAlertTarget()
	VisualAlertMixin.ClearAlertTarget(self);

	self:SetManualRelease(false);
end

-- When manual release is enabled the OnUpdate script is removed, preventing the alert from auto-releasing
-- after its duration. The caller is then responsible for releasing the alert via VisualAlertsManager:ReleaseAlert.
-- Passing false re-enables auto-release, which is done automatically when the alert target is cleared.
function VisualAlertBaseMixin:SetManualRelease(manualRelease)
	self:SetScript("OnUpdate", not manualRelease and self.OnUpdate or nil);
end

function VisualAlertBaseMixin:OnUpdate(elapsed)
	self.playTime = self.playTime + elapsed;
	if self.playTime >= self.durationSeconds then
		self.alertManager:ReleaseAlert(self);
	end
end

function VisualAlertBaseMixin:GetVertexColor()
	return self.vertexColor;
end

function VisualAlertBaseMixin:ApplyVertexColor()
	local color = self:GetVertexColor();
	if color then
		self:ApplyVertexColorToRegions(color, self:GetVertexColoredRegions());
	end
end

function VisualAlertBaseMixin:ApplyVertexColorToRegions(color, ...)
	for i = 1, select("#", ...) do
		local region = select(i, ...);
		region:SetVertexColor(color:GetRGBA());
	end
end

VisualAlertMarchingAntsBaseMixin = {};

function VisualAlertMarchingAntsBaseMixin:GetVertexColoredRegions()
	return self.Flipbook;
end

function VisualAlertMarchingAntsBaseMixin:GetAnchors()
	local topLeft = CreateAnchor("TOPLEFT", nil, "TOPLEFT", -8, 8);
	local bottomRight = CreateAnchor("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 9, -9);
	return topLeft, bottomRight;
end

VisualAlertFlashBaseMixin = {};

function VisualAlertFlashBaseMixin:GetVertexColoredRegions()
	return self.Glow;
end

function VisualAlertFlashBaseMixin:GetAnchors()
	local topLeft = CreateAnchor("TOPLEFT", nil, "TOPLEFT", -8, 8);
	local bottomRight = CreateAnchor("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 9, -9);
	return topLeft, bottomRight;
end

local VisualAlertData = {
	{ enum = Enum.VisualAlertType.MarchingAnts, animTemplate = "VisualAlertMarchingAntsBaseTemplate", text = CDMVIS_MARCHING_ANTS },
	{ enum = Enum.VisualAlertType.MarchingAntsCyan, animTemplate = "VisualAlertMarchingAntsCyanTemplate", text = CDMVIS_MARCHING_ANTS_CYAN },
	{ enum = Enum.VisualAlertType.MarchingAntsRed, animTemplate = "VisualAlertMarchingAntsRedTemplate", text = CDMVIS_MARCHING_ANTS_RED },
	{ enum = Enum.VisualAlertType.MarchingAntsGreen, animTemplate = "VisualAlertMarchingAntsGreenTemplate", text = CDMVIS_MARCHING_ANTS_GREEN },
	{ enum = Enum.VisualAlertType.MarchingAntsBlue, animTemplate = "VisualAlertMarchingAntsBlueTemplate", text = CDMVIS_MARCHING_ANTS_BLUE },
	{ enum = Enum.VisualAlertType.Flash, animTemplate = "VisualAlertFlashBaseTemplate", text = CDMVIS_FLASH },
	{ enum = Enum.VisualAlertType.FlashCyan, animTemplate = "VisualAlertFlashCyanTemplate", text = CDMVIS_FLASH_CYAN },
	{ enum = Enum.VisualAlertType.FlashRed, animTemplate = "VisualAlertFlashRedTemplate", text = CDMVIS_FLASH_RED },
	{ enum = Enum.VisualAlertType.FlashGreen, animTemplate = "VisualAlertFlashGreenTemplate", text = CDMVIS_FLASH_GREEN },
	{ enum = Enum.VisualAlertType.FlashBlue, animTemplate = "VisualAlertFlashBlueTemplate", text = CDMVIS_FLASH_BLUE },
};

local visualAlertTypeToText;
local visualAlertTypeToTemplate;

local function CheckCreateVisualAlertLookups()
	if not visualAlertTypeToText then
		visualAlertTypeToText = {};
		visualAlertTypeToTemplate = {};
		for _, visualData in ipairs(VisualAlertData) do
			visualAlertTypeToText[visualData.enum] = visualData.text;
			visualAlertTypeToTemplate[visualData.enum] = visualData.animTemplate;
		end
	end
end

function VisualAlert_GetTypeText(visualAlertType)
	CheckCreateVisualAlertLookups();
	return visualAlertTypeToText[visualAlertType];
end

function VisualAlert_GetTypeTemplate(visualAlertType)
	CheckCreateVisualAlertLookups();
	return visualAlertTypeToTemplate[visualAlertType];
end

function VisualAlertData_ForEach(callback)
	for _, visualData in ipairs(VisualAlertData) do
		callback(visualData);
	end
end

function VisualAlerts_RegisterAll(manager)
	VisualAlertData_ForEach(function(visualData)
		manager:RegisterAlert(visualData.enum, visualData.animTemplate);
	end);
end
