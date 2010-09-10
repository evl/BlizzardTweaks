local addonName, addon = ...
local config = addon.config
local noop = function() end

-- This is mostly stolen from nMainbar minus the stuff I didn't need
if config.compactBars then
	-- Disable up/down buttons
	for _, button in pairs({
		ActionBarUpButton,
		ActionBarDownButton
	}) do
		button:SetAlpha(0)
		button:Disable()
	end

	-- Hide texture frames
	local hiddenContainer = CreateFrame("Frame")
	hiddenContainer:Hide()

	for _, texture in pairs({
  	MainMenuBarTexture2,
  	MainMenuBarTexture3,
	  MainMenuBarPageNumber,
	  MainMenuMaxLevelBar2,
	  MainMenuMaxLevelBar3,
	  MainMenuXPBarTexture2,
	  MainMenuXPBarTexture3,

	  ReputationWatchBarTexture2,
	  ReputationWatchBarTexture3,
	  ReputationXPBarTexture2,
	  ReputationXPBarTexture3,

	  SlidingActionBarTexture0,
	  SlidingActionBarTexture1,

	  ShapeshiftBarLeft,
	  ShapeshiftBarMiddle,
	  ShapeshiftBarRight,

	  PossessBackground1,
	  PossessBackground2,
	}) do
    texture:SetParent(hiddenContainer)
	end

	-- Adjust main menu bar width
	for _, bar in pairs({
		MainMenuBar,
		MainMenuExpBar,
		MainMenuBarMaxLevelBar,

		ReputationWatchStatusBar,
		ReputationWatchBar,
	}) do
		bar:SetWidth(512)
	end

	-- Adjust main menu texture positions
	MainMenuBarTexture0:SetPoint("BOTTOM", MainMenuBarArtFrame, -128, 0)
	MainMenuBarTexture1:SetPoint("BOTTOM", MainMenuBarArtFrame, 128, 0)

	MainMenuMaxLevelBar0:SetPoint("BOTTOM", MainMenuBarMaxLevelBar, "TOP", -128, 0)

	MainMenuXPBarTexture0:SetPoint("BOTTOM", MainMenuExpBar, -128, 3)
	MainMenuXPBarTexture1:SetPoint("BOTTOM", MainMenuExpBar, 128, 3)

	MainMenuBarLeftEndCap:SetPoint("BOTTOM", MainMenuBarArtFrame, -289, 0)
	MainMenuBarLeftEndCap.SetPoint = noop

	MainMenuBarRightEndCap:SetPoint("BOTTOM", MainMenuBarArtFrame, 289, 0)
	MainMenuBarRightEndCap.SetPoint = noop

	-- Stack the bottom right bar on top of the bottom left
	MultiBarBottomRight:ClearAllPoints()
	MultiBarBottomRight:SetPoint("BOTTOM", MultiBarBottomLeft, "TOP", 0, 4)
	
	-- Move bag buttons and micro menu
	MainMenuBarBackpackButton:ClearAllPoints()
	MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", -25, 40)

	KeyRingButton:Enable()
	KeyRingButton:EnableDrawLayer()
	KeyRingButton:Show()
	KeyRingButton:ClearAllPoints()
	KeyRingButton:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", 22, -1)

	hooksecurefunc("VehicleMenuBar_MoveMicroButtons", function(skinName)
		CharacterMicroButton:ClearAllPoints()

		if skinName == "Mechanical" then
			CharacterMicroButton:SetPoint("BOTTOMLEFT", VehicleMenuBar, "BOTTOMRIGHT", -340, 41)
		elseif skinName == "Natural" then
			CharacterMicroButton:SetPoint("BOTTOMLEFT", VehicleMenuBar, "BOTTOMRIGHT", -365, 41)
		else
			CharacterMicroButton:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -226, 0)
		end
	end)

	VehicleMenuBar_MoveMicroButtons()	
	
	-- We need to do this after we enter the world or UIPARENT_MANAGED_FRAME_POSITIONS will screw us over
	local frame = CreateFrame("Frame")
	frame:SetScript("OnEvent", function(self, event)
		self:UnregisterAllEvents()
		
		local getShownFrame = function(frames)
			for _, frame in pairs(frames) do
				if frame:IsShown() then
					return frame
				end
			end
		end
		
		local debugContainer = function(frame)
			frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 8})
			frame:SetBackdropColor(255, 255, 255)
		end

		-- Move pet frame
		PetActionBarFrame:SetPoint("BOTTOMLEFT", getShownFrame({MultiBarBottomRight, MultiBarBottomLeft, MainMenuBar}), "TOPLEFT", 0, 0)
		PetActionBarFrame.SetPoint = noop
		
		for i = 2, NUM_PET_ACTION_SLOTS do
			_G["PetActionButton" .. i]:SetPoint("LEFT", _G["PetActionButton" .. (i - 1)], "RIGHT", 3, 0)
		end

		ShapeshiftBarFrame:SetPoint("BOTTOMLEFT", getShownFrame({PetActionBarFrame, MultiBarBottomRight, MultiBarBottomLeft, MainMenuBar}), "TOPLEFT", 0, 0)
		ShapeshiftBarFrame.SetPoint = noop

		for i = 2, NUM_SHAPESHIFT_SLOTS do
			_G["ShapeshiftButton" .. i]:SetPoint("LEFT", _G["ShapeshiftButton" .. (i - 1)], "RIGHT", 0, 0)
		end

		-- Move multicast bar
		MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", getShownFrame({ShapeshiftBarFrame, PetActionBarFrame, MultiBarBottomRight, MultiBarBottomLeft, MainMenuBar}), "TOPLEFT", 0, 0)
		MultiCastActionBarFrame.SetPoint = noop
	end)

	if InCombatLockdown() then
		frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
end

local enableMouseOver = function(frame, children, reparent)
	local show = function()
		frame:SetAlpha(1)
	end

	local hide = function()
		frame:SetAlpha(0)
	end

	for _, child in pairs(children) do
		if reparent then
			child:SetParent(frame)
		end

		child:HookScript("OnEnter", show)
		child:HookScript("OnLeave", hide)
	end

	frame.show = show
	frame.hide = hide
	frame:EnableMouse(true)
	frame:HookScript("OnEnter", show)
	frame:HookScript("OnLeave", hide)

	hide()
end

-- Auto-hide side bars
if config.autoHideSideBars then
	enableMouseOver(MultiBarLeft, {MultiBarLeft:GetChildren()})
	enableMouseOver(MultiBarRight, {MultiBarRight:GetChildren()})
end

-- Auto-hide micro menu and bag buttons
if config.autoHideMicroMenu then
	--AchievementMicroButton:UnregisterAllEvents()
	--TalentMicroButton:UnregisterAllEvents()

	local menuButtons = {
		CharacterMicroButton,
		SpellbookMicroButton,
		TalentMicroButton,
		AchievementMicroButton,
		QuestLogMicroButton,
		SocialsMicroButton,
		PVPMicroButton,
		LFDMicroButton,
		MainMenuMicroButton,
		HelpMicroButton
	}

	local bagButtons = {
		MainMenuBarBackpackButton,
		CharacterBag0Slot,
		CharacterBag1Slot,
		CharacterBag2Slot,
		CharacterBag3Slot,
		KeyRingButton
	}

	local menuContainer = CreateFrame("Frame", nil, UIParent)
	menuContainer:SetPoint("TOPLEFT", CharacterMicroButton, "TOPLEFT", 0, -20)
	menuContainer:SetPoint("BOTTOMRIGHT", HelpMicroButton, "BOTTOMRIGHT", 0, 0)

	local bagContainer =  CreateFrame("Frame", nil, UIParent)
	bagContainer:SetPoint("TOPLEFT", CharacterBag3Slot, "TOPLEFT", -4, 8)
	bagContainer:SetPoint("BOTTOMRIGHT", KeyRingButton, "BOTTOMRIGHT", 4, -4)

	enableMouseOver(bagContainer, bagButtons, true)
	enableMouseOver(menuContainer, menuButtons, true)
end

-- Shape shift
if config.hideShapeShiftBar then
	ShapeshiftBarFrame:UnregisterAllEvents()
	ShapeshiftBarFrame:Hide()
	ShapeshiftBarFrame.Show = noop
end