local addonName, addon = ...
local config = addon.config

if config.compactBars then
	-- Compact (most of this updated code is stolen from TidyBar. Thanks to Maul for helping me discover RegisterStateDriver)
	local stackFrame = function(frame, relativeFrame, offsetY, offsetX)
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", relativeFrame, "TOPLEFT", offsetX or 0, offsetY or 0)
	end

	local updateFrames = function()
		if not InCombatLockdown() then
			local anchor = ActionButton1
			local offsetY = 4

			-- Experience
			if MainMenuExpBar:IsShown() then
				stackFrame(MainMenuExpBar, anchor, offsetY)
				
				MainMenuExpBar:SetWidth(500)

				anchor = MainMenuExpBar
				offsetY = 2
			else
				offsetY = 4
			end
			
			-- Reputation
			if ReputationWatchBar:IsShown() then
				stackFrame(ReputationWatchBar, anchor, offsetY)

				ReputationWatchBar:SetWidth(500)
				ReputationWatchBar:SetHeight(8)
				ReputationWatchStatusBar:SetWidth(500)
				ReputationWatchStatusBar:SetHeight(8)

				anchor = ReputationWatchBar
				offsetY = 5
			else
				offsetY = 4
			end

			-- Bottom left
			if MultiBarBottomLeft:IsShown() then
				stackFrame(MultiBarBottomLeft, anchor, offsetY)
				
				anchor = MultiBarBottomLeft
				offsetY = 4
			else
				offsetY = 8 + (MainMenuExpBar:IsShown() and 9 or 0) + (ReputationWatchBar:IsShown() and 9 or 0)
			end
			
			-- Bottom right
			if MultiBarBottomRight:IsShown() then
				stackFrame(MultiBarBottomRight, anchor, offsetY)

				anchor = MultiBarBottomRight
				offsetY = 4
			end

			-- Shapeshift
			if config.hideShapeShiftBar then
				ShapeshiftBarFrame:UnregisterAllEvents()
				ShapeshiftBarFrame:Hide()

				RegisterStateDriver(ShapeshiftBarFrame, "visibility", "hide")
			elseif ShapeshiftBarFrame:IsShown() then
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

			-- Pet & Vehicle
			PetActionBarFrame:ClearAllPoints()
			PetActionBarFrame:SetPoint("BOTTOM", anchor, "TOP", 0, offsetY)
			
			if not MultiBarBottomLeft:IsShown() and MultiBarBottomRight:IsShown() then
				SlidingActionBarTexture0:Hide()
				SlidingActionBarTexture1:Hide()
			end
			
			stackFrame(MainMenuBarVehicleLeaveButton, anchor, offsetY)
			offsetY = 4

			-- Possess
			stackFrame(PossessButton1, anchor, offsetY)
			
			-- Micro menu
			if config.autoHideMicroMenu and ContainerFrame1:IsShown() then
				MainMenuBarBackpackButton:ClearAllPoints()
				MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 48)

				CharacterMicroButton:ClearAllPoints()
				
				if UnitInVehicle("player") then
					CharacterMicroButton:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -108, 45)
				else
					CharacterMicroButton:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -233, 8)
				end
			else
				MainMenuBarBackpackButton:ClearAllPoints()
				MainMenuBarBackpackButton:SetPoint("TOP", UIParent, "BOTTOM")
				
				CharacterMicroButton:ClearAllPoints()
				CharacterMicroButton:SetPoint("TOP", UIParent, "BOTTOM")
			end
		end
	end

	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomLeft"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomRight"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PetActionBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["ShapeshiftBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PossessBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiCastActionBarFrame"] = nil
 	
	hooksecurefunc("UIParent_ManageFramePositions", updateFrames)
	hooksecurefunc("ReputationWatchBar_Update", updateFrames)
	
	for _, frame in ipairs({MainMenuBarPageNumber, ActionBarUpButton, ActionBarDownButton, MainMenuXPBarTexture2, MainMenuXPBarTexture3, MainMenuBarTexture2, MainMenuBarTexture3, MainMenuMaxLevelBar2, MainMenuMaxLevelBar3}) do
		frame:Hide()
	end

	for _, texture in ipairs({ReputationWatchBarTexture2, ReputationWatchBarTexture3, ReputationXPBarTexture2, ReputationXPBarTexture3}) do
		texture:SetTexture(nil)
	end

	for _, frame in ipairs({MainMenuBar, MainMenuExpBar, ReputationWatchBar, MainMenuBarMaxLevelBar, ReputationWatchStatusBar}) do
		frame:SetWidth(512)
	end
	
	if config.cleanBars then
		for _, texture in ipairs({MainMenuBarTexture0, MainMenuBarTexture1, ReputationWatchBarTexture0, ReputationWatchBarTexture1, ReputationXPBarTexture0, ReputationXPBarTexture1, MainMenuBarLeftEndCap, MainMenuBarRightEndCap, MainMenuXPBarTexture0, MainMenuXPBarTexture1, MainMenuMaxLevelBar0, MainMenuMaxLevelBar1, BonusActionBarTexture0, BonusActionBarTexture1, PossessBackground1, PossessBackground2}) do
			texture:SetTexture(nil)
		end
	else
		MainMenuXPBarTexture0:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", -128, 2)
		MainMenuXPBarTexture1:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", 128, 3)
		MainMenuMaxLevelBar0:SetPoint("BOTTOM", MainMenuBarMaxLevelBar, "TOP", -128, 0)
		MainMenuBarTexture0:SetPoint("BOTTOM", MainMenuBarArtFrame, "BOTTOM", -128, 0)
		MainMenuBarTexture1:SetPoint("BOTTOM", MainMenuBarArtFrame, "BOTTOM", 128, 0)
		MainMenuBarLeftEndCap:SetPoint("BOTTOM", MainMenuBarArtFrame, "BOTTOM", -290, 0)
		MainMenuBarRightEndCap:SetPoint("BOTTOM", MainMenuBarArtFrame, "BOTTOM", 287, 0)
	end
	
	if config.autoHideMicroMenu then
		ContainerFrame1:HookScript("OnShow", updateFrames)
		ContainerFrame1:HookScript("OnHide", updateFrames)
	else
		ContainerFrame1:ClearAllPoints()
		ContainerFrame1:SetPoint("TOP", UIParent, "BOTTOM")
	end

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetScript("OnEvent", UIParent_ManageFramePositions)
	frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
end

-- Auto-hide side bars
if config.autoHideSideBars then
	local enableMouseOver = function(frame, includeChildren)
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
		end
		
		frame:EnableMouse(true)
		frame:HookScript("OnEnter", show)
		frame:HookScript("OnLeave", hide)

		hide()
	end	
	
	enableMouseOver(MultiBarLeft, true)
	enableMouseOver(MultiBarRight, true)
end
