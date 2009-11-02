evl_BlizzardTweaks = {}
evl_BlizzardTweaks.config = {
	enhanceTargetFrame = true,
	colorizeButtons = true,
	hideHotKeyLabels = true,
	hideMacroLabels = true,
	cooldownThreshold = 10,
	compactBars = true,
	cleanBars = true,
	hideShapeShiftBar = false,
	autoHideMicroMenu = true,
	autoHideSideBars = true,
}

local noop = function() end

evl_BlizzardTweaks.hideFrame = function(object, useSetPoint, force)
	if force or not object.evl_Hidden then
		if object.SetTexture then
			object:SetTexture(nil)
		else
			if useSetPoint then
				object:ClearAllPoints()
				object:SetPoint("CENTER", UIParent, "CENTER", -5000, 0)
			else
				object:UnregisterAllEvents()
				object.Show = noop
				object:Hide()
			end
		end

		object.evl_Hidden = true
	end
end

evl_BlizzardTweaks.enableMouseOver = function(frame, includeChildren)
	local show = function()
		frame:SetAlpha(1)
	end
	
	local hide = function()
		frame:SetAlpha(0)
	end
	
	if includeChildren then
		for _, child in ipairs({frame:GetChildren()}) do
			child:HookScript("OnEnter", show)
			child:HookScript("OnLeave", hide)
		end		
	else	
		frame:HookScript("OnEnter", show)
		frame:HookScript("OnLeave", hide)
	end
	
	hide()
end