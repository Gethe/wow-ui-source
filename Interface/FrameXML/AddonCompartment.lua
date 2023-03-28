local forceinsecure = forceinsecure;

AddonCompartmentMixin = { };

function AddonCompartmentMixin:OnLoad()
	self.registeredAddons = { };

	local addonCount = GetNumAddOns();
	for addon = 1, addonCount do
		local addonEnabled = GetAddOnEnableState(nil, addon) > 0;
		local addonCompartmentFunc = C_AddOns.GetAddOnMetadata(addon, "AddonCompartmentFunc");
		local name, title, notes, loadable, reason, security = GetAddOnInfo(addon);
		if addonEnabled and addonCompartmentFunc and (loadable or reason == "DEMAND_LOADED") then
			local info = UIDropDownMenu_CreateInfo();
			info.text = title;
			info.icon = C_AddOns.GetAddOnMetadata(addon, "IconTexture") or C_AddOns.GetAddOnMetadata(addon, "IconAtlas");
			info.notCheckable = true;
			info.registerForRightClick = true;

			local function CallAddonGlobalFunc(addonCompartmentFunc, addonName, ...)
				forceinsecure();
				if reason == "DEMAND_LOADED" and not IsAddOnLoaded(addonName) then
					LoadAddOn(addonName);
				end
				_G[addonCompartmentFunc](addonName, ...);
			end

			info.func = function(btn, arg1, arg2, checked, mouseButton)
				CallAddonGlobalFunc(addonCompartmentFunc, name, mouseButton);
			end;

			local onEnterGlobal = C_AddOns.GetAddOnMetadata(addon, "AddonCompartmentFuncOnEnter");
			if onEnterGlobal then
				info.funcOnEnter = function()
					CallAddonGlobalFunc(onEnterGlobal, name);
				end
			end

			local onLeaveGlobal = C_AddOns.GetAddOnMetadata(addon, "AddonCompartmentFuncOnLeave");
			if onLeaveGlobal then
				info.funcOnLeave = function()
					CallAddonGlobalFunc(onLeaveGlobal, name);
				end
			end

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
