function NewMountAlertFrameMixin:GetMountItemQuality()
	-- Mounts don't have an inherent concept of quality, but the items do. We want to make it white to be consistent with the journal.
	return Enum.ItemQuality.Common;
end
