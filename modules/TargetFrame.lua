local addonName, addon = ...
local config = addon.config

local TargetFrameHealthBar_OnEnterHook = function(self)
	self.showPercentage = false
   
	TextStatusBar_UpdateTextString(self)
end

local TargetFrameHealthBar_OnLeaveHook = function(self)
	self.showPercentage = true
   
	TextStatusBar_UpdateTextString(self)
end

if config.enhanceTargetFrame then
	TargetFrameHealthBar.showPercentage = true
	TargetFrameHealthBar.lockShow = 1
	TargetFrameHealthBar:HookScript("OnEnter", TargetFrameHealthBar_OnEnterHook)
	TargetFrameHealthBar:HookScript("OnLeave", TargetFrameHealthBar_OnLeaveHook)
	TargetFrameManaBar.showPercentage = true
end