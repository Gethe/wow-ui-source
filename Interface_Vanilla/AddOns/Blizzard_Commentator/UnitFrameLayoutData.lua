
-- [[ All valid unit frame component names that can be controlled via the layout data below ]] --
local UNIT_FRAME_COMPONENT_NAMES = {
	"UnitFrame", -- special case that refers to the base unit frame

	"FrameTexture",
	"FlagIcon",
	"FlagIconHighlight",

	"HealthBar",
	"PowerBar",
	"CastingBar",

	"ClassIcon",
	"Name",
	
	"CCIcon",
	"CCIconGlow",
	"CCText",

	"DeathIcon",
	"FeignIcon",
	"DeadText",

	"CCOverlay",
	"DeathOverlay",

	"FrameUnderlay",
}

local function MergeTables(from, to)
	for k, v in pairs(from) do
		if type(v) == "table" then
			to[k] = MergeTables(v, type(to[k]) == "table" and to[k] or {});
		else
			to[k] = v;
		end
	end
	return to;
end

local function CreateLayoutTableThatInheritsFrom(...)
	local layoutTable = {};
	for i = 1, select("#", ...) do
		layoutTable = MergeTables(select(i, ...), layoutTable);
	end

	return layoutTable;
end

local function CreatePoint(point, relComponent, relPoint, offsetX, offsetY)
	return { point = point, relComponent = relComponent, relPoint = relPoint, offsetX = offsetX, offsetY = offsetY };
end

local BASE_LAYOUT = {
	UnitFrame = {
		width = 210,
		height = 115,
	},

	Name = {
		fontObject = "GameFontNormalLarge",
		justifyH = "LEFT",

		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 76, -26),
			CreatePoint("BOTTOMRIGHT", "UnitFrame", "BOTTOMRIGHT", -6, 60),
		},
	},

	HealthBar = {
		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 71, -58),
			CreatePoint("BOTTOMRIGHT", "UnitFrame", "BOTTOMRIGHT", -1, 22),
		},
	},

	DeadText = {
		justifyH = "CENTER",

		points = {
			CreatePoint("TOPLEFT", "HealthBar", "TOPLEFT", 6, 0),
			CreatePoint("BOTTOMRIGHT", "HealthBar", "BOTTOMRIGHT", -42, 0),
		},
	},

	PowerBar = {
		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 71, -95),
			CreatePoint("BOTTOMRIGHT", "UnitFrame", "BOTTOMRIGHT", -1, 4),
		},
		enabled = false,
	},

	FrameTexture = {
		atlas = "UnitFrame-NoMana",

		width = 256,
		height = 128,
		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 0, 0),
		},
	},

	ClassIcon = {
		width = 52,
		height = 52,
		keepTexCoords = true,
		points = {
			CreatePoint("CENTER", "UnitFrame", "TOPLEFT", 42, -41),
		},
	},

	FrameUnderlay = {
		points = {
			CreatePoint("TOPLEFT", "HealthBar", "TOPLEFT", 0, 0),
			CreatePoint("BOTTOMRIGHT", "HealthBar", "BOTTOMRIGHT", 0, 0),
		},
	},

	FlagIcon = {
		width = 128,
		height = 64,
	},

	FlagIconHighlight = {
		setAllPoints = "FlagIcon",
	},

	RoleIcon = {
		width = 64,
		height = 64,

		points = {
			CreatePoint("CENTER", "UnitFrame", "TOPLEFT", 70, -15),
		},
	},

	CCIcon = {
		width = 62,
		height = 62,
		points = {
			CreatePoint("LEFT", "UnitFrame", "RIGHT", 0, -2),
		},
	},

	CCIconGlow = {
		width = 128,
		height = 128,
		points = {
			CreatePoint("TOPLEFT", "CCIcon", "TOPLEFT", -12, 12),
		},
	},

	CCOverlay = {
		atlas = "UnitFrame_CCOverlay-NoMana",
		setAllPoints = "FrameTexture",
	},

	DeathOverlay = {
		atlas = "UnitFrame_DeathOverlay-NoMana",
		setAllPoints = "FrameTexture",
	},

	CCText = {
		points = {
			CreatePoint("CENTER", "CCIcon", "CENTER", 0, 0),
		},
	},

	FeignIcon = {
		setAllPoints = "CCIcon",
	},

	DeathIcon = {
		mirrorFileV = true,
		width = 64,
		height = 128,

		points = {
			CreatePoint("RIGHT", "UnitFrame", "BOTTOMRIGHT", 14, 2),
		},
	},

	CastingBar = {
		width = 150,
		height = 30,

		points = {
			CreatePoint("LEFT", "HealthBar", "RIGHT", 52, -2),
		},
		enabled = true,
	},
}

local POWER_LAYOUT = {
	FrameTexture = {
		atlas = "UnitFrame-NoTrinket",

		width = 256,
		height = 128,
		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 0, 0),
		},
	},

	PowerBar = {
		enabled = true,
	},

	FrameUnderlay = {
		points = {
			CreatePoint("TOPLEFT", "HealthBar", "TOPLEFT", 0, 0),
			CreatePoint("BOTTOMRIGHT", "PowerBar", "BOTTOMRIGHT", 0, 0),
		},
	},

	CCIcon = {
		width = 62,
		height = 62,
		points = {
			CreatePoint("LEFT", "UnitFrame", "RIGHT", 0, -12),
		},
	},

	CCOverlay = {
		atlas = "UnitFrame_CCOverlay",
	},

	DeathOverlay = {
		atlas = "UnitFrame_DeathOverlay",
	},
};

local RIGHT_LAYOUT = {
	FrameTexture = {
		mirrorFileV = true,
		mirrorPointsV = true,
	},

	ClassIcon = {
		mirrorPointsV = true,
	},

	Name = {
		justifyH = "RIGHT",
		mirrorPointsV = true,
	},

	HealthBar = {
		mirrorPointsV = true,
	},

	PowerBar = {
		mirrorPointsV = true,
	},

	FlagIcon = {
		mirrorFileV = true,
	},

	FlagIconHighlight = {
		mirrorFileV = true,
	},

	CCIcon = {
		mirrorPointsV = true,
	},

	CCOverlay = {
		mirrorFileV = true,
	},

	DeathOverlay = {
		mirrorFileV = true,
	},

	DeadText = {
		mirrorPointsV = true,
		justifyH = "CENTER",
	},

	DeathIcon = {
		mirrorFileV = false,
		mirrorPointsV = true,
	},

	CastingBar = {
		points = {
			CreatePoint("RIGHT", "HealthBar", "LEFT", -13, -2),
		},
	},
};

local COMPACT_LAYOUT = {
	CastingBar = {
		enabled = false,
	},
};

local VERY_COMPACT_LAYOUT = {
	UnitFrame = {
		width = 158,
		height = 86,
	},
	FrameTexture = {
		atlas = "UnitFrame-NoMana",
		width = 192,
		height = 96,
	},
	ClassIcon = {
		width = 39,
		height = 39,
		points = {
			CreatePoint("CENTER", "UnitFrame", "TOPLEFT", 32, -31),
		},
	},
	Name = {
		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 57, -20),
			CreatePoint("BOTTOMRIGHT", "UnitFrame", "BOTTOMRIGHT", -4, 45),
		},
	},
	FlagIcon = {
		width = 96,
		height = 48,
	},
	CCIcon = {
		width = 47,
		height = 47,
		points = {
			CreatePoint("LEFT", "UnitFrame", "RIGHT", 0, -2),
		},
	},
	CCIconGlow = {
		width = 96,
		height = 96,
		points = {
			CreatePoint("TOPLEFT", "CCIcon", "TOPLEFT", -9, 9),
		},
	},
	DeathIcon = {
		mirrorFileV = true,
		width = 48,
		height = 96,

		points = {
			CreatePoint("RIGHT", "UnitFrame", "BOTTOMRIGHT", 14, 2),
		},
	},
};

local EXTREMELY_COMPACT_LAYOUT = {
	UnitFrame = {
		width = 147,
		height = 80,
	},
	FrameTexture = {
		atlas = "UnitFrame-NoMana",

		width = 179,
		height = 90,
		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 0, 0),
		},
	},
	ClassIcon = {
		width = 36,
		height = 36,
		points = {
			CreatePoint("CENTER", "UnitFrame", "TOPLEFT", 29, -29),
		},
	},
	FlagIcon = {
		width = 89,
		height = 44,
	},
	CCIcon = {
		width = 44,
		height = 44,
		points = {
			CreatePoint("LEFT", "UnitFrame", "RIGHT", 0, -2),
		},
	},
	CCIconGlow = {
		width = 89,
		height = 89,
		points = {
			CreatePoint("TOPLEFT", "CCIcon", "TOPLEFT", -9, 8),
		},
	},
	DeathIcon = {
		mirrorFileV = true,
		width = 44,
		height = 89,

		points = {
			CreatePoint("RIGHT", "UnitFrame", "BOTTOMRIGHT", 14, 2),
		},
	},
};

local COMPACT_POWER_LAYOUT = {
	FrameTexture = {
		atlas = "UnitFrame-NoTrinket",
	},
}

local VERY_COMPACT_POWER_LAYOUT = {
	FrameTexture = {
		atlas = "UnitFrame-NoMana",
		width = 192,
		height = 96,
	},
	HealthBar = {
		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 53, -44),
			CreatePoint("BOTTOMRIGHT", "UnitFrame", "BOTTOMRIGHT", -1, 24),
		},
	},
	PowerBar = {
		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 53, -64),
			CreatePoint("BOTTOMRIGHT", "UnitFrame", "BOTTOMRIGHT", -1, 13),
		},
	},
	CCIcon = {
		width = 47,
		height = 47,
		points = {
			CreatePoint("LEFT", "UnitFrame", "RIGHT", 0, -2),
		},
	},
	CCOverlay = {
		atlas = "UnitFrame_CCOverlay-NoMana",
		setAllPoints = "FrameTexture",
	},
	DeathOverlay = {
		atlas = "UnitFrame_DeathOverlay-NoMana",
		setAllPoints = "FrameTexture",
	},
};

local EXTREMELY_COMPACT_POWER_LAYOUT = {
	FrameTexture = {
		atlas = "UnitFrame-NoMana",

		width = 179,
		height = 90,
	},
	HealthBar = {
		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 50, -41),
			CreatePoint("BOTTOMRIGHT", "UnitFrame", "BOTTOMRIGHT", -1, 24),
		},
	},
	PowerBar = {
		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 49, -58),
			CreatePoint("BOTTOMRIGHT", "UnitFrame", "BOTTOMRIGHT", -1, 13),
		},
	},
	CCIcon = {
		width = 44,
		height = 44,
		points = {
			CreatePoint("LEFT", "UnitFrame", "RIGHT", 0, -2),
		},
	},
};

local FOCUSED_LAYOUT = {
	Name = {
		fontObject = "GameFontNormalHuge3",

		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 89, -29),
			CreatePoint("BOTTOMRIGHT", "UnitFrame", "BOTTOMRIGHT", 107, 53),
		},
	},

	HealthBar = {
		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 84, -66),
			CreatePoint("BOTTOMRIGHT", "UnitFrame", "BOTTOMRIGHT", 117, 2),
		},
	},

	PowerBar = {
		points = {
			CreatePoint("TOPLEFT", "UnitFrame", "TOPLEFT", 84, -115),
			CreatePoint("BOTTOMRIGHT", "UnitFrame", "BOTTOMRIGHT", 117, -21),
		},
	},

	FrameTexture = {
		atlas = "UnitFrame_CurrentPlayer-NoTrinket",

		width = 512,
		height = 256,
	},

	ClassIcon = {
		width = 66,
		height = 66,
		points = {
			CreatePoint("CENTER", "UnitFrame", "TOPLEFT", 49, -45),
		},
	},

	CCIcon = {
		points = {
			CreatePoint("LEFT", "UnitFrame", "RIGHT", 121, -18),
		},
	},

	CCOverlay = {
		atlas = "UnitFrame_CurrentPlayer_CCOverlay",
	},

	DeathOverlay = {
		atlas = "UnitFrame_CurrentPlayer_DeathOverlay",
	},

	DeathIcon = {
		width = 80,
		height = 160,

		points = {
			CreatePoint("RIGHT", "UnitFrame", "BOTTOMRIGHT", 144, -20),
		},
	},

	CastingBar = {
		points = {
			CreatePoint("LEFT", "HealthBar", "RIGHT", 54, -2),
		},
	},
};

local FOCUSED_COMPACT_LAYOUT = {
	CastingBar = {
		enabled = true,
		points = {
			CreatePoint("LEFT", "HealthBar", "RIGHT", 52, -2),
		},
	},

	FrameTexture = {
		atlas = "UnitFrame_CurrentPlayer-NoMana",
	},

	CCIcon = {
		points = {
			CreatePoint("LEFT", "UnitFrame", "RIGHT", 121, -12),
		},
	},

	CCOverlay = {
		atlas = "UnitFrame_CurrentPlayer_CCOverlay-NoMana",
	},

	DeathOverlay = {
		atlas = "UnitFrame_CurrentPlayer_DeathOverlay-NoMana",
	},
};

local FOCUSED_COMPACT_POWER_LAYOUT = {
	FrameTexture = {
		atlas = "UnitFrame_CurrentPlayer-NoTrinket",

		width = 512,
		height = 256,
	},

	CCOverlay = {
		atlas = "UnitFrame_CurrentPlayer_CCOverlay",
	},

	DeathOverlay = {
		atlas = "UnitFrame_CurrentPlayer_DeathOverlay",
	},
}

local FOCUSED_COMPACT_RIGHT_LAYOUT = {
	CastingBar = {
		points = {
			CreatePoint("RIGHT", "HealthBar", "LEFT", -13, -2),
		},
	},
}

local LAYOUT_DATA = {
	team_left = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT),
	team_right = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, RIGHT_LAYOUT),

	team_left_power = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, POWER_LAYOUT),
	team_right_power = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, RIGHT_LAYOUT, POWER_LAYOUT),

	team_left_compact = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, COMPACT_LAYOUT),
	team_right_compact = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, RIGHT_LAYOUT, COMPACT_LAYOUT),

	team_left_compact_power = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, COMPACT_LAYOUT, POWER_LAYOUT, COMPACT_POWER_LAYOUT),
	team_right_compact_power = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, RIGHT_LAYOUT, COMPACT_LAYOUT, POWER_LAYOUT, COMPACT_POWER_LAYOUT),

	team_left_veryCompact = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, COMPACT_LAYOUT, VERY_COMPACT_LAYOUT),
	team_right_veryCompact = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, RIGHT_LAYOUT, COMPACT_LAYOUT, VERY_COMPACT_LAYOUT),

	team_left_veryCompact_power = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, COMPACT_LAYOUT, VERY_COMPACT_LAYOUT, POWER_LAYOUT, COMPACT_POWER_LAYOUT, VERY_COMPACT_POWER_LAYOUT),
	team_right_veryCompact_power = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, RIGHT_LAYOUT, COMPACT_LAYOUT, VERY_COMPACT_LAYOUT, POWER_LAYOUT, COMPACT_POWER_LAYOUT, VERY_COMPACT_POWER_LAYOUT),

	team_left_extremelyCompact = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, COMPACT_LAYOUT, VERY_COMPACT_LAYOUT, EXTREMELY_COMPACT_LAYOUT),
	team_right_extremelyCompact = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, RIGHT_LAYOUT, COMPACT_LAYOUT, VERY_COMPACT_LAYOUT, EXTREMELY_COMPACT_LAYOUT),

	team_left_extremelyCompact_power = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, COMPACT_LAYOUT, VERY_COMPACT_LAYOUT, EXTREMELY_COMPACT_LAYOUT, POWER_LAYOUT, COMPACT_POWER_LAYOUT, VERY_COMPACT_POWER_LAYOUT, EXTREMELY_COMPACT_POWER_LAYOUT),
	team_right_extremelyCompact_power = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, RIGHT_LAYOUT, COMPACT_LAYOUT, VERY_COMPACT_LAYOUT, EXTREMELY_COMPACT_LAYOUT, POWER_LAYOUT, COMPACT_POWER_LAYOUT, VERY_COMPACT_POWER_LAYOUT, EXTREMELY_COMPACT_POWER_LAYOUT),

	team_left_focus = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, FOCUSED_LAYOUT),
	team_right_focus = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, RIGHT_LAYOUT, FOCUSED_LAYOUT),

	team_left_focus_power = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, POWER_LAYOUT, FOCUSED_LAYOUT),
	team_right_focus_power = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, RIGHT_LAYOUT, POWER_LAYOUT, FOCUSED_LAYOUT),

	team_left_focus_compact = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, FOCUSED_LAYOUT, COMPACT_LAYOUT, FOCUSED_COMPACT_LAYOUT),
	team_right_focus_compact = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, RIGHT_LAYOUT, FOCUSED_LAYOUT, COMPACT_LAYOUT, FOCUSED_COMPACT_LAYOUT, FOCUSED_COMPACT_RIGHT_LAYOUT),

	team_left_focus_compact_power = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, POWER_LAYOUT, FOCUSED_LAYOUT, COMPACT_LAYOUT, FOCUSED_COMPACT_LAYOUT, FOCUSED_COMPACT_POWER_LAYOUT),
	team_right_focus_compact_power = CreateLayoutTableThatInheritsFrom(BASE_LAYOUT, RIGHT_LAYOUT, POWER_LAYOUT, FOCUSED_LAYOUT, COMPACT_LAYOUT, POWER_LAYOUT, FOCUSED_COMPACT_LAYOUT, FOCUSED_COMPACT_POWER_LAYOUT, FOCUSED_COMPACT_RIGHT_LAYOUT),
};

local function GetComponent(UnitFrame, componentName)
	if componentName == "UnitFrame" then
		return UnitFrame;
	end
	if not UnitFrame[componentName] then
		error(("Component %q missing from %q"):format(tostring(componentName), tostring(UnitFrame:GetName())));
	end
	return UnitFrame[componentName];
end

local function GetMirroredVPoint(point)
	if point == "TOPLEFT" then
		return "TOPRIGHT";
	elseif point == "TOPRIGHT" then
		return "TOPLEFT";
	elseif point == "BOTTOMLEFT" then
		return "BOTTOMRIGHT";
	elseif point == "BOTTOMRIGHT" then
		return "BOTTOMLEFT";
	elseif point == "LEFT" then
		return "RIGHT";
	elseif point == "RIGHT" then
		return "LEFT";
	end

	return point;
end

local function ApplyLayout(UnitFrame, component, layoutData)
	if component and layoutData then
		if layoutData.width then
			component:SetWidth(layoutData.width);
		end
		if layoutData.height then
			component:SetHeight(layoutData.height);
		end

		if layoutData.points then
			for i, point in ipairs(layoutData.points) do
				if layoutData.mirrorPointsV then
					component:SetPoint(GetMirroredVPoint(point.point), GetComponent(UnitFrame, point.relComponent), GetMirroredVPoint(point.relPoint), -point.offsetX, point.offsetY);
				else
					component:SetPoint(point.point, GetComponent(UnitFrame, point.relComponent), point.relPoint, point.offsetX, point.offsetY);
				end
			end
		end

		if layoutData.setAllPoints then
			component:SetAllPoints(GetComponent(UnitFrame, layoutData.setAllPoints));
		end

		if layoutData.atlas then
			component:SetAtlas(layoutData.atlas);
		end

		if component.SetTexCoord and not layoutData.keepTexCoords then
			if layoutData.mirrorFileV then
				component:SetTexCoord(1, 0, 0, 1);
			else
				component:SetTexCoord(0, 1, 0, 1);
			end
		end

		if layoutData.fontObject then
			component:SetFontObject(layoutData.fontObject);
		end

		if layoutData.justifyH then
			component:SetJustifyH(layoutData.justifyH);
		end

		if layoutData.justifyV then
			component:SetJustifyV(layoutData.justifyV);
		end

		if layoutData.keyValues then
			for k, v in pairs(layoutData.keyValues) do
				component[k] = v;
			end
		end

		component.enabled = layoutData.enabled;
	end
end

function CommentatorUnitFrameLayout_GetLayout(layoutName)
	return LAYOUT_DATA[layoutName];
end

function CommentatorUnitFrameMixin:ApplyLayout(layoutName)
	local layoutTable = CommentatorUnitFrameLayout_GetLayout(layoutName);

	for i, componentName in ipairs(UNIT_FRAME_COMPONENT_NAMES) do
		local layoutData = layoutTable[componentName];
		if layoutData and (layoutData.points or layoutData.setAllPoints) then
			local component = GetComponent(self, componentName);
			if component then
				component:ClearAllPoints();
			end
		end
	end

	for i, componentName in ipairs(UNIT_FRAME_COMPONENT_NAMES) do
		local component = GetComponent(self, componentName);
		if component then
			ApplyLayout(self, component, layoutTable[componentName]);
		end
	end

	self:OnLayoutApplied();
end