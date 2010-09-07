local addonName, addon = ...
local config = addon.config
local noop = function() end

-- This is mostly stolen from nMainbar minus the stuff I didn"t need
if config.compactBars then
	MultiBarBottomRight:ClearAllPoints()
	MultiBarBottomRight:SetPoint("BOTTOM", MultiBarBottomLeft, "TOP", 0, 4)
	MultiBarBottomRight.SetPoint = noop

	-- Stop managing frame positions
	for _, frame in pairs({
		"MultiBarBottomRight",
		"PetActionBarFrame",
		"ShapeshiftBarFrame",
		"PossessBarFrame",
		"MultiCastActionBarFrame",
	}) do
		UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
	end

	for _, button in pairs({
		ActionBarUpButton,
		ActionBarDownButton
	}) do
		button:SetAlpha(0)
		button:EnableMouse(false)
	end
	
	local container = CreateFrame("Frame")
	container:Hide()
	
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
    texture:SetParent(container)
	end
	
	for _, bar in pairs({
		MainMenuBar,
		MainMenuExpBar,
		MainMenuBarMaxLevelBar,

		ReputationWatchStatusBar,
		ReputationWatchBar,
	}) do
		bar:SetWidth(512)
	end

	MainMenuBarTexture0:SetPoint("BOTTOM", MainMenuBarArtFrame, -128, 0)
	MainMenuBarTexture1:SetPoint("BOTTOM", MainMenuBarArtFrame, 128, 0)

	MainMenuMaxLevelBar0:SetPoint("BOTTOM", MainMenuBarMaxLevelBar, "TOP", -128, 0)

	MainMenuXPBarTexture0:SetPoint("BOTTOM", MainMenuExpBar, -128, 3)
	MainMenuXPBarTexture1:SetPoint("BOTTOM", MainMenuExpBar, 128, 3)

	MainMenuBarLeftEndCap:SetPoint("BOTTOM", MainMenuBarArtFrame, -289, 0)
	MainMenuBarLeftEndCap.SetPoint = noop

	MainMenuBarRightEndCap:SetPoint("BOTTOM", MainMenuBarArtFrame, 289, 0)
	MainMenuBarRightEndCap.SetPoint = noop
	
	local anchorToShownFrame = function(button, frames, offsetX, offsetY)
		for _, anchor in pairs(frames) do
			if anchor:IsShown() then
				button:ClearAllPoints()
				button:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", (anchor == MainMenuBar and PETACTIONBAR_XPOS or 0) + (offsetX or 0), offsetY or 0)
				break
			end
		end
	end

	-- Maybe use OnLoad instead
	-- Pet bar
	PetActionBarFrame:HookScript("OnEvent", function()
		anchorToShownFrame(PetActionButton1, {MultiBarBottomRight, MultiBarBottomLeft, MainMenuBar}, 0, 4)
	end)

	-- Shapeshift bar
	ShapeshiftBarFrame:HookScript("OnEvent", function()
		anchorToShownFrame(ShapeshiftButton1, {PetActionButton1, MultiBarBottomRight, MultiBarBottomLeft, MainMenuBar}, -2, 2)
	end)

	-- Multicast bar
	MultiCastActionBarFrame:HookScript("OnShow", function()
		anchorToShownFrame(MultiCastSlotButton1, {ShapeshiftButton1, PetActionButton1, MultiBarBottomRight, MultiBarBottomLeft, MainMenuBar})
	end)

	--- Tighten spacing since we don't have any art
	for i = 2, NUM_PET_ACTION_SLOTS do
		_G["PetActionButton" .. i]:SetPoint("LEFT", _G["PetActionButton" .. (i - 1)], "RIGHT", 3, 0)
		_G["ShapeshiftButton" .. i]:SetPoint("LEFT", _G["ShapeshiftButton" .. (i - 1)], "RIGHT", 0, 0)
	end	
end

-- Auto-hide side bars
if config.autoHideSideBars then
	local enableBarMouseOver = function(frame, includeChildren)
		local show = function()
			frame:SetAlpha(1)
		end

		local hide = function()
			frame:SetAlpha(0)
		end

		if includeChildren then
			for _, child in pairs({frame:GetChildren()}) do
				child:HookScript("OnEnter", show)
				child:HookScript("OnLeave", hide)
			end
		end

		frame:EnableMouse(true)
		frame:HookScript("OnEnter", show)
		frame:HookScript("OnLeave", hide)

		hide()
	end

	enableBarMouseOver(MultiBarLeft, true)
	enableBarMouseOver(MultiBarRight, true)
end

-- Auto-hide micro menu and bag buttons
if config.autoHideMicroMenu then
  CharacterMicroButton:ClearAllPoints()
  CharacterMicroButton:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -226, 0)
	
	MainMenuBarBackpackButton:ClearAllPoints()
	MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", -25, 40)

	KeyRingButton:Enable()
	KeyRingButton:EnableDrawLayer()
	KeyRingButton:Show()
	KeyRingButton:ClearAllPoints()
	KeyRingButton:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", 22, -1)

	local enableMicroMenuMouseOver = function(children, showInVehicle)
		local container = CreateFrame("Frame", nil, UIParent)

		local show = function()
			for _, child in pairs(children) do
				child:SetAlpha(1)
			end
		end

		local hide = function()
			if not showInVehicle or not UnitHasVehicleUI("player") then
				for _, child in pairs(children) do
					child:SetAlpha(0)
				end
			end
		end

		for _, child in pairs(children) do
			child:HookScript("OnEnter", show)
			child:HookScript("OnLeave", hide)
		end

		container:EnableMouse(true)
		container:HookScript("OnEnter", show)
		container:HookScript("OnLeave", hide)
		
		hide()
		
		return container
	end

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
	
	local menuContainer = enableMicroMenuMouseOver(menuButtons, true)
	menuContainer:SetPoint("TOPLEFT", CharacterMicroButton, "TOPLEFT", 0, -20)
	menuContainer:SetPoint("BOTTOMRIGHT", HelpMicroButton, "BOTTOMRIGHT", 0, 0)
	
	local bagButtons = {
		MainMenuBarBackpackButton,
		CharacterBag0Slot,
		CharacterBag1Slot,
		CharacterBag2Slot,
		CharacterBag3Slot,
		KeyRingButton
	}
	
	local bagContainer = enableMicroMenuMouseOver(bagButtons)
	bagContainer:SetPoint("TOPLEFT", CharacterBag3Slot, "TOPLEFT", -4, 8)
	bagContainer:SetPoint("BOTTOMRIGHT", KeyRingButton, "BOTTOMRIGHT", 4, -4)
end

-- Shape shift
if config.hideShapeShiftBar then
	ShapeshiftBarFrame:UnregisterAllEvents()
	ShapeshiftBarFrame:Hide()
	ShapeshiftBarFrame.Show = noop
end