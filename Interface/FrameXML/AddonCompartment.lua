local forceinsecure = forceinsecure;

AddonCompartmentMixin = { };

function AddonCompartmentMixin:OnLoad()
	self.registeredAddons = { };

	local addonCount = GetNumAddOns();
	for addon = 1, addonCount do
		local addonCompartmentFunc = GetAddOnEnableState(nil, addon) > 0 and GetAddOnMetadata(addon, "AddonCompartmentFunc");
		if addonCompartmentFunc then
			local name, title, notes, loadable, reason, security = GetAddOnInfo(addon);

			local info = UIDropDownMenu_CreateInfo();
			info.text = title;
			info.icon = GetAddOnMetadata(addon, "IconTexture") or GetAddOnMetadata(addon, "IconAtlas");
			info.notCheckable = true;
			info.func = function()
				forceinsecure();
				_G[addonCompartmentFunc](name);
			end;
			table.insert(self.registeredAddons, info);
		end
	end

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
	local addonCompartment = self:GetParent();

	if addonCompartment.registeredAddons then
		table.sort(addonCompartment.registeredAddons, function(infoA, infoB) return strcmputf8i(StripHyperlinks(infoA.text), StripHyperlinks(infoB.text)) < 0; end);

		for _, info in ipairs(addonCompartment.registeredAddons) do
			UIDropDownMenu_AddButton(info, level);
		end
	end
end
