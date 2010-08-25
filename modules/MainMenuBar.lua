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
		"MultiBarRight",
		"MultiBarBottomRight",
		"PetActionBarFrame",
		"ShapeshiftBarFrame",
		"PossessBarFrame",
	}) do
		UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
	end

	for _, button in pairs({
		_G["ActionBarUpButton"],
		_G["ActionBarDownButton"],
	}) do
		button:SetAlpha(0)
		button:EnableMouse(false)
	end
	
	local container = CreateFrame("Frame")
	container:Hide()
	
	for i = 2, 3 do
		for _, texture in pairs({
	    _G["MainMenuBarTexture" .. i],
	    _G["MainMenuMaxLevelBar" .. i],
	    _G["MainMenuXPBarTexture" .. i],

	    _G["ReputationWatchBarTexture" .. i],
	    _G["ReputationXPBarTexture" .. i],

	    _G["MainMenuBarPageNumber"],

	    _G["SlidingActionBarTexture0"],
	    _G["SlidingActionBarTexture1"],

	    _G["ShapeshiftBarLeft"],
	    _G["ShapeshiftBarMiddle"],
	    _G["ShapeshiftBarRight"],

	    _G["PossessBackground1"],
	    _G["PossessBackground2"],
		}) do
	    texture:SetParent(container)
		end
	end
	
	for _, bar in pairs({
		_G["MainMenuBar"],
		_G["MainMenuExpBar"],
		_G["MainMenuBarMaxLevelBar"],

		_G["ReputationWatchStatusBar"],
		_G["ReputationWatchBar"],
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
	
	SocialsMicroButton:ClearAllPoints()
	SocialsMicroButton:SetPoint("TOPLEFT", CharacterMicroButton, "BOTTOMLEFT", 0, 20)
	
	-- Pet bar
	PetActionBarFrame:ClearAllPoints()
	PetActionBarFrame:SetPoint("BOTTOMLEFT", MultiBarBottomLeft:IsVisible() and MultiBarBottomLeft or MainMenuBar, "TOPLEFT", 0, 0)
	PetActionBarFrame.SetPoint = noop
	PetActionButton1:SetPoint("LEFT", PetActionBarFrame, "LEFT", -2, 0)

	for i = 2, NUM_SHAPESHIFT_SLOTS do
	    _G["PetActionButton" .. i]:SetPoint("LEFT", _G["PetActionButton" .. (i - 1)], "RIGHT", 3, 0)
	end    
	
	-- Shapeshift bar
	ShapeshiftBarFrame:SetPoint("BOTTOMLEFT", MultiBarBottomLeft, "TOPLEFT", 0, 0)
	ShapeshiftButton1:SetPoint("LEFT", ShapeshiftBarFrame, "LEFT", -2, 0)

	for i = 2, NUM_SHAPESHIFT_SLOTS do
	    _G["ShapeshiftButton" .. i]:SetPoint("LEFT", _G["ShapeshiftButton" .. (i - 1)], "RIGHT", 3, 0)
	end	

	-- Auto hide micro menu
	if config.autoHideMicroMenu then
		hooksecurefunc("VehicleMenuBar_MoveMicroButtons", function()
			CharacterMicroButton:ClearAllPoints()

			if VehicleMenuBar.currSkin == "Mechanical" then
		    CharacterMicroButton:SetPoint("BOTTOMLEFT", VehicleMenuBar, "BOTTOMRIGHT", -340, 41)
		  elseif VehicleMenuBar.currSkin == "Natural" then
				CharacterMicroButton:SetPoint("BOTTOMLEFT", VehicleMenuBar, "BOTTOMRIGHT", -365, 41)
		  else
				MainMenuBarBackpackButton:ClearAllPoints()

				if ContainerFrame1:IsShown() then
					MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 48)
					CharacterMicroButton:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -233, 8)
				else
					MainMenuBarBackpackButton:SetPoint("BOTTOMLEFT", UIParent, 9000, 9000)
					CharacterMicroButton:SetPoint("BOTTOMLEFT", UIParent, 9000, 9000)				
				end
			end
		end)

		ContainerFrame1:HookScript("OnShow", VehicleMenuBar_MoveMicroButtons)
		ContainerFrame1:HookScript("OnHide", VehicleMenuBar_MoveMicroButtons)

		VehicleMenuBar_MoveMicroButtons()
	end
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

-- Shape shift
if config.hideShapeShiftBar then
	ShapeshiftBarFrame:UnregisterAllEvents()
	ShapeshiftBarFrame:Hide()
	ShapeshiftBarFrame.Show = noop
end