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
		local hotKey = self.elements.hotKey
		local macroName = self.elements.macroName
		
		hotKey:Hide()
		macroName:Hide()
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

hooksecurefunc("ActionButton_UpdateHotkeys", ActionButton_UpdateHotkeysHook)
hooksecurefunc("ActionButton_Update", ActionButton_UpdateHook)
hooksecurefunc("ActionButton_UpdateUsable", ActionButton_UpdateUsableHook)
hooksecurefunc("ActionButton_OnUpdate", ActionButton_OnUpdateHook)

-- Compact (most of this updated code is stolen from TidyBar)
local stackFrame = function(frame, relativeFrame, offsetY, offsetX)
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", relativeFrame, "TOPLEFT", offsetX or 0, offsetY or 0)
end

local UIParent_ManageFramePositionsHook = function()
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
		if MultiCastActionBarFrame:IsShown() then	-- Totem bar
			stackFrame(MultiCastActionBarFrame, anchor, offsetY)
			anchor = MultiCastActionBarFrame
			offsetY = 4
		end

		-- Pet
		stackFrame(PetActionButton1, anchor, offsetY)
		offsetY = 4

		-- Possess
		stackFrame(PossessButton1, anchor, offsetY)
	end
end

hooksecurefunc("UIParent_ManageFramePositions", UIParent_ManageFramePositionsHook)

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

MainMenuBarTexture0:SetPoint("BOTTOM", MainMenuBar, "BOTTOM", -128, 0)
MainMenuBarTexture1:SetPoint("BOTTOM", MainMenuBar, "BOTTOM", 128, 0)
MainMenuMaxLevelBar0:SetPoint("BOTTOM", "MainMenuBarMaxLevelBar", "TOP", -128, 0)
MainMenuBarLeftEndCap:SetPoint("BOTTOM", MainMenuBar, "BOTTOM", -290, 0)
MainMenuBarRightEndCap:SetPoint("BOTTOM", MainMenuBar, "BOTTOM", 290, 0)

-- Hide character micro buttons
local VehicleMenuBar_MoveMicroButtonsHook = function()
	if not InCombatLockdown() then
		CharacterMicroButton:ClearAllPoints()
		CharacterMicroButton:SetPoint("CENTER", UIParent, "CENTER", 0, -5000)
	end
end

hooksecurefunc("VehicleMenuBar_MoveMicroButtons", VehicleMenuBar_MoveMicroButtonsHook)
VehicleMenuBar_MoveMicroButtonsHook()

MainMenuBarBackpackButton:ClearAllPoints()
MainMenuBarBackpackButton:SetPoint("CENTER", UIParent, "CENTER", 0, -5000)

-- Auto-hide side bar
local showBar = function()
	MultiBarRight:SetAlpha(1)
end

local hideBar = function()
	MultiBarRight:SetAlpha(0)
end

for _, button in ipairs({MultiBarRight:GetChildren()}) do
	button:HookScript("OnEnter", showBar)
	button:HookScript("OnLeave", hideBar)
end

hideBar()
