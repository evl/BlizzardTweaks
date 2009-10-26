local config = evl_BlizzardTweaks.config

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

if config.colorizeButtons then
	hooksecurefunc("ActionButton_UpdateHotkeys", ActionButton_UpdateHotkeysHook)
	hooksecurefunc("ActionButton_UpdateUsable", ActionButton_UpdateUsableHook)
	hooksecurefunc("ActionButton_OnUpdate", ActionButton_OnUpdateHook)
end

if config.hideHotKeyLabels or config.hideHotKeyLabels then
	hooksecurefunc("ActionButton_Update", ActionButton_UpdateHook)
end

-- Compact (most of this updated code is stolen from TidyBar)
local stackFrame = function(frame, relativeFrame, offsetY, offsetX)
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", relativeFrame, "TOPLEFT", offsetX or 0, offsetY or 0)
end

local updateFrames = function()
	if not InCombatLockdown() then
		local anchor
		local offsetY
		
		-- Bottom left
		if MultiBarBottomLeft:IsShown() then
			anchor = MultiBarBottomLeft
			offsetY = 4
		else
			anchor = ActionButton1
			offsetY = 8 + (MainMenuExpBar:IsShown() and 9 or 0) + (ReputationWatchBar:IsShown() and 9 or 0)
		end
		
		-- Bottom right
		if MultiBarBottomRight:IsShown() then
			stackFrame(MultiBarBottomRight, anchor, offsetY)
			anchor = MultiBarBottomRight
			offsetY = 4
		end
		
		-- Shapeshift
		if ShapeshiftButton1:IsShown() then
			stackFrame(ShapeshiftButton1, anchor, offsetY)
			anchor = ShapeshiftButton1
			offsetY = 4
		end
		
		-- Totem
		if MultiCastActionBarFrame:IsShown() then
			stackFrame(MultiCastActionBarFrame, anchor, offsetY)
			anchor = MultiCastActionBarFrame
			offsetY = 4
		end

		-- Pet
		stackFrame(PetActionButton1, anchor, offsetY)
		offsetY = 4

		-- Possess
		stackFrame(PossessButton1, anchor, offsetY)
		
		-- Micro menu
		CharacterMicroButton:ClearAllPoints()
		CharacterMicroButton:SetPoint("CENTER", UIParent, "CENTER", 0, -5000)		
	end
end

if config.compactBars then
	hooksecurefunc("UIParent_ManageFramePositions", updateFrames)

	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomRight"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PetActionBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["ShapeshiftBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PossessBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PossessBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiCastActionBarFrame"] = nil

	for _, frame in ipairs({MainMenuBarPageNumber, ActionBarUpButton, ActionBarDownButton, MainMenuXPBarTexture2, MainMenuXPBarTexture3, MainMenuBarTexture2, MainMenuBarTexture3, MainMenuMaxLevelBar2, MainMenuMaxLevelBar3}) do
		frame:Hide()
	end

	for _, texture in ipairs({ReputationWatchBarTexture2, ReputationWatchBarTexture3, ReputationXPBarTexture2, ReputationXPBarTexture3}) do
		texture:SetTexture(nil)
	end

	for _, frame in ipairs({MainMenuBar, MainMenuExpBar, ReputationWatchBar, MainMenuBarMaxLevelBar, ReputationWatchStatusBar}) do
		frame:SetWidth(512)
	end

	MainMenuXPBarTexture0:SetPoint("BOTTOM", "MainMenuExpBar", "BOTTOM", -128, 2)
	MainMenuXPBarTexture1:SetPoint("BOTTOM", "MainMenuExpBar", "BOTTOM", 128, 3)
	MainMenuMaxLevelBar0:SetPoint("BOTTOM", "MainMenuBarMaxLevelBar", "TOP", -128, 0)
	MainMenuBarTexture0:SetPoint("BOTTOM", "MainMenuBarArtFrame", "BOTTOM", -128, 0)
	MainMenuBarTexture1:SetPoint("BOTTOM", "MainMenuBarArtFrame", "BOTTOM", 128, 0)
	MainMenuBarLeftEndCap:SetPoint("BOTTOM", "MainMenuBarArtFrame", "BOTTOM", -290, 0)
	MainMenuBarRightEndCap:SetPoint("BOTTOM", "MainMenuBarArtFrame", "BOTTOM", 287, 0) 

	MainMenuBarBackpackButton:ClearAllPoints()
	MainMenuBarBackpackButton:SetPoint("CENTER", UIParent, "CENTER", 0, -5000)
	
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetScript("OnEvent", updateFrames)
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	frame:RegisterEvent("PLAYER_TALENT_UPDATE")
	frame:RegisterEvent("UNIT_EXITED_VEHICLE")
end

-- Auto-hide side bars
if config.autoHideSideBars then
	for _, bar in ipairs({MultiBarLeft, MultiBarRight}) do
		local show = function()
			bar:SetAlpha(1)
		end
		
		local hide = function()
			bar:SetAlpha(0)
		end
		
		for _, button in ipairs({bar:GetChildren()}) do
			button:HookScript("OnEnter", show)
			button:HookScript("OnLeave", hide)
		end
		
		hide()
	end
end

