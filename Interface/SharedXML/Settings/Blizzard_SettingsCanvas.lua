SettingsCanvasMixin = {};

function SettingsCanvasMixin:OnCommit()
	print("SettingsCanvasMixin OnCommit")
end

function SettingsCanvasMixin:OnCancel()
	print("SettingsCanvasMixin OnCancel")
end

function SettingsCanvasMixin:OnDefault()
	print("SettingsCanvasMixin OnDefault")
end

function SettingsCanvasMixin:OnRefresh()
	print("SettingsCanvasMixin OnRefresh")
end