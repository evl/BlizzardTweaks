local addonName, addon = ...
local config = addon.config

-- Hide labels and macros
if config.hideHotKeyLabels then
	hooksecurefunc("ActionButton_UpdateHotkeys", function(self)
		_G[self:GetName() .. "HotKey"]:SetAlpha(0.85)
	end)
end

if config.hideMacroLabels then
	hooksecurefunc("ActionButton_Update", function(self)
		_G[self:GetName() .. "Name"]:SetAlpha(0)
	end)
end
