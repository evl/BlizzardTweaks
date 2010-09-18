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

if config.cooldownThreshold > 0 then
	local floor = math.floor
	local round = function(value) return floor(value + 0.5) end
	
	-- The core of this is from tullaCC, I just don't want all those formatting options
	local stopTimer = function(self)
		self.enabled = nil
		self:Hide()
	end
	
	local updateTimer = function(self, elapsed)
		if self.nextUpdate > 0 then
			self.nextUpdate = self.nextUpdate - elapsed
		else
			local remain = self.duration - (GetTime() - self.start)
			local seconds = floor(remain + 0.5)

			if seconds > 0 then
				local show = seconds <= config.cooldownThreshold
				
				self.text:SetText(show and seconds or "")
				self.nextUpdate = show and (remain - seconds - 0.51) or 1
			else
				stopTimer(self)
			end
		end
	end

	local createTimer = function(frame)
		local timer = CreateFrame("Frame", nil, frame)
		timer:Hide()
		timer:SetAllPoints(frame)
		timer:SetScript("OnUpdate", updateTimer)

		local text = timer:CreateFontString(nil, "OVERLAY")
		text:SetFont(STANDARD_TEXT_FONT, 24, "OUTLINE")
		text:SetShadowColor(0, 0, 0, 0.8)
		text:SetShadowOffset(1, -1)
		text:SetPoint("CENTER", 0, 0)

		timer.text = text
		frame.timer = timer
		
		return timer
	end
	
	hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, "SetCooldown", function(frame, start, duration)
		local timer

		if start > 0 and duration > 3 and (frame:GetWidth() >= 36 * 0.8) then
			timer = frame.timer or createTimer(frame)
			timer.start = start
			timer.duration = duration
			timer.enabled = true
			timer.nextUpdate = 0
			timer:Show()
		else
			timer = frame.timer

			if timer then
				stopTimer(timer)
			end
		end
	end)
end
