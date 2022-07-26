AddonCompartmentMixin = { };

function AddonCompartmentMixin:OnLoad()
	self.registeredAddons = { };
	self:UpdateDisplay();
end

function AddonCompartmentMixin:OnClick()
	ToggleDropDownMenu(1, nil, self.DropDown, self, 0, 0);
end

-- Custom registration, insert your own UIDropDownMenu Info!
function AddonCompartmentMixin:RegisterAddon(info)
	table.insert(self.registeredAddons, info);
	self:UpdateDisplay();
end

function AddonCompartmentMixin:UpdateDisplay()
	local addonCount = #self.registeredAddons;
	self.Text:SetText(addonCount);
	self:SetShown(addonCount > 0);
end

function AddonCompartmentDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, AddonCompartmentDropDown_Initialize, "MENU");
end

function AddonCompartmentDropDown_Initialize(self, level)
	local addonCompartment = AddonCompartmentFrame;
	for _, info in ipairs(addonCompartment.registeredAddons or {}) do
		UIDropDownMenu_AddButton(info, level);
	end
end
