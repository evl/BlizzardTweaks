local config = evl_BlizzardTweaks.config
local hideFrame = evl_BlizzardTweaks.hideFrame

if config.compactBars then
	local frame = CreateFrame("Frame", nil, UIParent)

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
				hideFrame(MainMenuBarBackpackButton, true, true)
				hideFrame(CharacterMicroButton, true, true)
			end
		end
	end
		
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
	
	if config.cleanBars then
		UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomLeft"].baseY = 11
		
		hideFrame(MainMenuBarTexture0)
		hideFrame(MainMenuBarTexture1)
		hideFrame(MainMenuBarLeftEndCap)
		hideFrame(MainMenuBarRightEndCap)
		hideFrame(MainMenuXPBarTexture0)
		hideFrame(MainMenuXPBarTexture1)
		hideFrame(MainMenuMaxLevelBar0)
		hideFrame(MainMenuMaxLevelBar1)

		hideFrame(BonusActionBarTexture0)
		hideFrame(BonusActionBarTexture1)
	else
		MainMenuXPBarTexture0:SetPoint("BOTTOM", "MainMenuExpBar", "BOTTOM", -128, 2)
		MainMenuXPBarTexture1:SetPoint("BOTTOM", "MainMenuExpBar", "BOTTOM", 128, 3)
		MainMenuMaxLevelBar0:SetPoint("BOTTOM", "MainMenuBarMaxLevelBar", "TOP", -128, 0)
		MainMenuBarTexture0:SetPoint("BOTTOM", "MainMenuBarArtFrame", "BOTTOM", -128, 0)
		MainMenuBarTexture1:SetPoint("BOTTOM", "MainMenuBarArtFrame", "BOTTOM", 128, 0)
		MainMenuBarLeftEndCap:SetPoint("BOTTOM", "MainMenuBarArtFrame", "BOTTOM", -290, 0)
		MainMenuBarRightEndCap:SetPoint("BOTTOM", "MainMenuBarArtFrame", "BOTTOM", 287, 0)
	end
	
	if config.autoHideMicroMenu then
		ContainerFrame1:HookScript("OnShow", updateFrames)
		ContainerFrame1:HookScript("OnHide", updateFrames)
	end

	local onEvent = function(self, event)
		updateFrames()
	end
	
	frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	frame:SetScript("OnEvent", onEvent)
end

if config.hideShapeShiftBar then
	hideFrame(ShapeshiftBarFrame)	
end

-- Auto-hide side bars
if config.autoHideSideBars then
	evl_BlizzardTweaks.enableMouseOver(MultiBarLeft, true)
	evl_BlizzardTweaks.enableMouseOver(MultiBarRight, true)
end
