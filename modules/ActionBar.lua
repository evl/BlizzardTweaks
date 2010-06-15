local addonName, addon = ...
local config = addon.config

-- Hide labels and macros on actionbuttons and color out of range
local ActionButton_UpdateHotkeysHook = function(self, actionButtonType)
	if not self.elements then
		local name = self:GetName()
		
		self.elements = {
			icon = _G[name .. "Icon"],
			normalTexture = _G[name .. "NormalTexture"],
			hotKey = _G[name .. "HotKey"],
			macroName = _G[name .. "Name"],
			colorized = false,
			inRange = nil
		}
	end
end

local ActionButton_UpdateHook = function(self)
	if self.elements then
		if config.hideHotKeyLabels then
			self.elements.hotKey:Hide()
		end
		
		if config.hideMacroLabels then
			self.elements.macroName:Hide()
		end
	end
end

-- Most of this is stolen from RedRange
local ActionButton_UpdateUsableHook = function(self)
	if self.elements then
		local id = self.action
		local isUsable, notEnoughMana = IsUsableAction(id)
		local icon = self.elements.icon
		local normalTexture = self.elements.normalTexture
	
		if isUsable then
			if ActionHasRange(id) and IsActionInRange(id) == 0 then
	      icon:SetVertexColor(0.8, 0.1, 0.1)
	      normalTexture:SetVertexColor(0.8, 0.1, 0.1)
				self.elements.colorized = true
			elseif self.elements.colorized then
      	icon:SetVertexColor(1.0, 1.0, 1.0)
      	normalTexture:SetVertexColor(1.0, 1.0, 1.0)
				self.elements.colorized = false
			end
		elseif notEnoughMana then
	    icon:SetVertexColor(0.1, 0.3, 1.0)
	    normalTexture:SetVertexColor(0.1, 0.3, 1.0)
		end
	end
end

local ActionButton_OnUpdateHook = function(self, elapsed)
	if self.elements then
		local id = self.action
		local newRange = ActionHasRange(id) and IsActionInRange(id) == 0
		
		if self.elements.inRange ~= newRange then
			self.elements.inRange = newRange

			ActionButton_UpdateUsableHook(self)
		end
	end
end

local timeleft
local ActionButton_OnUpdateCooldownHook = function(self, elapsed)
	if self.cooldown and self.cooldown.active then
		timeLeft = ceil(self.cooldown.start + self.cooldown.duration - GetTime())
		
		if self.cooldown.enable > 0 and timeLeft > 0 then
			if timeLeft <= config.cooldownThreshold then
				self.cooldown.count:SetText(format("%d", timeLeft))
			end
		else
			self.cooldown.count:SetText("")
			self.cooldown.active = false
		end			
	end
end

local CooldownFrame_SetTimerHook = function(self, start, duration, enable)
	local button = self:GetParent()

	if start > 0 and duration > 3 and enable > 0 then
		if not button.cooldown then
			local name = button:GetName() .. "Counter"
			
	    local frame = CreateFrame("Frame", name, self)
	    frame:SetWidth(32)
	    frame:SetHeight(32)
	    frame:SetPoint("CENTER", button, "CENTER")

	    local count = frame:CreateFontString(nil, "ARTWORK")
			count:SetFont(unpack({STANDARD_TEXT_FONT, 20}))
			count:SetShadowOffset(0.7, -0.7)
	    count:SetAllPoints(frame)
	    count:SetJustifyH("CENTER")

	    button.cooldown = {
	      count = count
	    }
		else
			button.cooldown.count:SetText("")
		end
		
		button.cooldown.active = true
		button.cooldown.start = start
		button.cooldown.duration = duration
		button.cooldown.enable = enable

		ActionButton_OnUpdateCooldownHook(self, 1)
	end
end

if config.colorizeButtons then
	hooksecurefunc("ActionButton_UpdateHotkeys", ActionButton_UpdateHotkeysHook)
	hooksecurefunc("ActionButton_UpdateUsable", ActionButton_UpdateUsableHook)
	hooksecurefunc("ActionButton_OnUpdate", ActionButton_OnUpdateHook)
end

if config.cooldownThreshold > 0 then
	hooksecurefunc("ActionButton_OnUpdate", ActionButton_OnUpdateCooldownHook)
	hooksecurefunc("CooldownFrame_SetTimer", CooldownFrame_SetTimerHook)
end

if config.hideHotKeyLabels or config.hideMacroLabels then
	hooksecurefunc("ActionButton_Update", ActionButton_UpdateHook)
end