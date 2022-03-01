local E = unpack(ElvUI)
local EP = LibStub('LibElvUIPlugin-1.0')
local LCG = E.Libs.CustomGlow
local AB = E.ActionBars
local AddOnName, Engine = ...

local RAB = E:NewModule(AddOnName, 'AceHook-3.0')
_G[AddOnName] = Engine

RAB.Configs = {}

local texturePath = 'Interface\\Addons\\ElvUI_ActionBarMasks\\Textures\\'

local DefaultMasks = {
	circle = {
		borders = {
			border1 = '|T'..texturePath..'circle\\border1:15:15:0:0:128:128:2:56:2:56|t Stone Thing (Loading Screen)',
			border2 = '|T'..texturePath..'circle\\border2:15:15:0:0:128:128:2:56:2:56|t Suramar Street',
			border3 = '|T'..texturePath..'circle\\border3:15:15:0:0:128:128:2:56:2:56|t Draenor Moon (WoD)',
			border4 = '|T'..texturePath..'circle\\border4:15:15:0:0:128:128:2:56:2:56|t Wood Texture',
			border5 = '|T'..texturePath..'circle\\border5:15:15:0:0:128:128:2:56:2:56|t Ulduar (Loading Screen)',
			border6 = '|T'..texturePath..'circle\\border6:15:15:0:0:128:128:2:56:2:56|t Throne of Thunder (Loading Screen)',
			border7 = '|T'..texturePath..'circle\\border7:15:15:0:0:128:128:2:56:2:56|t Well of Eternity (Loading Screen)',
			border8 = '|T'..texturePath..'circle\\border8:15:15:0:0:128:128:2:56:2:56|t Kyrian Ring',
			border9 = '|T'..texturePath..'circle\\border9:15:15:0:0:128:128:2:56:2:56|t Necrolord Ring',
			border10 = '|T'..texturePath..'circle\\border10:15:15:0:0:128:128:2:56:2:56|t Night Fae Ring',
			border11 = '|T'..texturePath..'circle\\border11:15:15:0:0:128:128:2:56:2:56|t Venthyr Ring',
			border97 = '|T'..texturePath..'circle\\border97:15:15:0:0:128:128:2:56:2:56|t White (Thin)',
			border98 = '|T'..texturePath..'circle\\border98:15:15:0:0:128:128:2:56:2:56|t Black (Thin)',
			border99 = '|T'..texturePath..'circle\\border99:15:15:0:0:128:128:2:56:2:56|t White',
			border100 = '|T'..texturePath..'circle\\border100:15:15:0:0:128:128:2:56:2:56|t Black',
			border101 = '|T'..texturePath..'circle\\border101:15:15:0:0:128:128:2:56:2:56|t Black (Super Thick)'
		},
	},
	hexagon = {
		borders = {
			border97 = 'White (Thin)',
			border98 = 'Black (Thin)',
			border99 = 'White',
			border100 = 'Black',
			border101 = 'Black (Super Thick)'
		},
	},
	pentagon = {
		borders = {
			border97 = 'White (Thin)',
			border98 = 'Black (Thin)',
			border99 = 'White',
			border100 = 'Black',
			border101 = 'Black (Super Thick)'
		},
	}
}

function RAB:GetMaskDB()
	return DefaultMasks
end

function RAB:GetValidBorder()
	local db = E.db.rab.general
	local maskDB = RAB:GetMaskDB()
	local border = maskDB[db.shape].borders[db.borderStyle] and db.borderStyle or 'border100'
	local path = texturePath..db.shape..'\\'..border

	return path, border
end

local function GetOptions()
	for _, func in pairs(RAB.Configs) do
		func()
	end
end

function RAB:UpdateOptions()
	local db = E.db.rab.general
	local cooldown
	local path = RAB:GetValidBorder()
	for button in pairs(AB.handledbuttons) do
		if button then
			cooldown = _G[button:GetName()..'Cooldown']

			if button.mask then
				button.mask:SetTexture(texturePath..db.shape..'\\mask.tga', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
			end

			if button.border then
				-- button.border:SetTexture(texturePath..db.shape..'\\'..db.borderStyle)
				button.border:SetTexture(path)
				button.border:SetVertexColor(db.borderColor.r, db.borderColor.g, db.borderColor.b, 1)
			end
			if button.shadow then
				button.shadow:SetTexture(texturePath..db.shape..'\\shadow.tga')
			end
			if cooldown:GetDrawSwipe() then
				cooldown:SetSwipeTexture(texturePath..db.shape..'\\mask.tga')
			end
			if button.procFrame and button.procFrame.procRing then
				button.procFrame.procRing:SetTexture(texturePath..db.shape..'\\procRingWhite')
				button.procFrame.procRing:SetVertexColor(db.procColor.r, db.procColor.g, db.procColor.b, 1)
			end

			if button.procFrame then
				if button.procFrame.procMask then
					if db.procStyle == 'solid' then
						button.procFrame.procMask:SetTexture(texturePath..db.shape..'\\mask', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
					else
						button.procFrame.procMask:SetTexture(texturePath..'repooctest.tga', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
					end
					button.procFrame.procRing:AddMaskTexture(button.procFrame.procMask)
				end
				if button.procFrame.spinner then
					button.procFrame.spinner:SetLooping('REPEAT') --maybe an option... idk yet -- Done in RAB:UpdateOptions()
				end
				if button.procFrame.rotate then
					button.procFrame.rotate:SetDuration(120)
					button.procFrame.rotate:SetDegrees(21600)
				end
				if button.procFrame.pulse then
					if db.procPulse and not button.procFrame.pulse:IsPlaying() then
						button.procFrame.pulse:Play()
					elseif not db.procPulse and button.procFrame.pulse:IsPlaying() then
						button.procFrame.pulse:Stop()
					end
				end
			end
		end
	end
end

local function SetupMask(button)
	if not button then return end

	local name = button:GetName()
	local normal = _G[name..'NormalTexture']
	-- local cooldown = _G[name..'Cooldown'] -- Done in RAB:UpdateOptions()
	-- local db = E.db.rab.general
	-- local path = RAB:GetValidBorder() -- Done in RAB:UpdateOptions()

	if not button.rabHooked then
		button.Center:Hide()
		button.RightEdge:Hide()
		button.LeftEdge:Hide()
		button.TopEdge:Hide()
		button.TopRightCorner:Hide()
		button.TopLeftCorner:Hide()
		button.BottomRightCorner:Hide()
		button.BottomLeftCorner:Hide()
		button.BottomEdge:Hide()
	end

	if not button.mask then
		button.mask = button:CreateMaskTexture(nil, 'Background', nil, 4)
		button.mask:SetAllPoints(button)
	end
	-- button.mask:SetTexture(texturePath..db.shape..'\\mask.tga', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE') -- Done in RAB:UpdateOptions()

	if button.mask and not button.rabHooked then
		if button.checked then button.checked:AddMaskTexture(button.mask) end
		if button.hover then button.hover:AddMaskTexture(button.mask) end
		if button.icon then button.icon:AddMaskTexture(button.mask) end
		if button.pushed then button.pushed:AddMaskTexture(button.mask) end
		if normal then normal:AddMaskTexture(button.mask) end
	end

	--==============--
	--= Add Border =--
	--==============--
	if not button.border then
		button.border = button:CreateTexture()
		button.border:SetAllPoints(button)
	end
	-- button.border:SetTexture(texturePath..db.shape..'\\'..db.borderStyle)
	-- button.border:SetTexture(path) -- Done in RAB:UpdateOptions()
	-- button.border:SetVertexColor(db.borderColor.r, db.borderColor.g, db.borderColor.b, 1) -- Done in RAB:UpdateOptions()

	--==============--
	--= Add Shadow =--
	--==============--
	if not button.shadow then
		button.shadow = button:CreateTexture()
		button.shadow:SetAllPoints(button)
	end
	-- button.shadow:SetTexture(texturePath..db.shape..'\\shadow.tga') -- Done in RAB:UpdateOptions()

	--==========================--
	--= Cooldown Swipe Texture =--
	--==========================--
	-- if cooldown:GetDrawSwipe() then
	-- 	cooldown:SetSwipeTexture(texturePath..db.shape..'\\mask.tga') -- Done in RAB:UpdateOptions()
	-- end

	--==================--
	--= Add Proc Frame =--
	--==================--
	if not button.procFrame then
		button.procFrame = CreateFrame('Frame')
		button.procFrame:SetParent(button)
		button.procFrame:SetPoint('Center', button)
		button.procFrame:Hide()
	end
	button.procFrame:SetSize(button:GetSize())

	--=================--
	--= Add Proc Ring =--
	--=================--
	if not button.procFrame.procRing then
		button.procFrame.procRing = button.procFrame:CreateTexture()
		button.procFrame.procRing:SetParent(button.procFrame)
		button.procFrame.procRing:SetAllPoints(button.procFrame)
		button.procFrame.procRing:SetDrawLayer('BORDER')
	end
	button.procFrame.procRing:SetSize(button:GetSize())
	-- button.procFrame.procRing:SetTexture(texturePath..db.shape..'\\procRingWhite') -- Done in RAB:UpdateOptions()
	-- button.procFrame.procRing:SetVertexColor(db.procColor.r, db.procColor.g, db.procColor.b, 1) -- Done in RAB:UpdateOptions()

	--================--
	--= Add ProcMask =--
	--================--
	if not button.procFrame.procMask then
		button.procFrame.procMask = button.procFrame:CreateMaskTexture()
		button.procFrame.procMask:SetParent(button.procFrame)
		button.procFrame.procMask:SetAllPoints(button.procFrame.procRing)
		-- button.procFrame.procMask:SetPoint('CENTER', button.procFrame.procRing)
		-- button.procFrame.procMask:SetSize(80, 80)
	end
	-- if db.procStyle == 'solid' then -- Done in RAB:UpdateOptions()
	-- 	button.procFrame.procMask:SetTexture(texturePath..db.shape..'\\mask', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE') -- Done in RAB:UpdateOptions()
	-- else -- Done in RAB:UpdateOptions()
	-- 	button.procFrame.procMask:SetTexture(texturePath..'repooctest.tga', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE') -- Done in RAB:UpdateOptions()
	-- end -- Done in RAB:UpdateOptions()
	-- button.procFrame.procRing:AddMaskTexture(button.procFrame.procMask) -- Done in RAB:UpdateOptions()
	--button.procFrame:AddMaskTexture(button.procFrame.procMask)

	--==========================--
	--= Add Spinner Anim Group =--
	--==========================--
	if not button.procFrame.spinner then
		button.procFrame.spinner = button.procFrame:CreateAnimationGroup()
	end
	-- button.procFrame.spinner:SetLooping('REPEAT') --maybe an option... idk yet -- Done in RAB:UpdateOptions()

	--===================--
	--= Add Rotate Anim =--
	--===================--
	if not button.procFrame.rotate then
		button.procFrame.rotate = button.procFrame.spinner:CreateAnimation('Rotation')
		button.procFrame.rotate:SetOrder(1)
		button.procFrame.rotate:SetTarget(button.procFrame.procMask)
		button.procFrame.rotate:SetStartDelay(0)
	end
	-- button.procFrame.rotate:SetDuration(120) -- Done in RAB:UpdateOptions()
	-- button.procFrame.rotate:SetDegrees(db.proc.reverse and -(360) or 360)
	-- button.procFrame.rotate:SetDegrees(db.procReverse and -(21600) or 21600)
	-- button.procFrame.rotate:SetDegrees(21600) -- Done in RAB:UpdateOptions()

	--button.procFrame.rotate:SetSmoothing('OUT')
	--button.procFrame.rotate:SetOrigin('CENTER', 0, 0)

	--========================--
	--= Add Pulse Anim Group =--
	--========================--
	if not button.procFrame.pulse then
		button.procFrame.pulse = button.procFrame:CreateAnimationGroup()
		button.procFrame.pulse:SetLooping('BOUNCE')
	end

	--======================--
	--= Add Scale Out Anim =--
	--======================--
	if not button.procFrame.scaleOut then
		button.procFrame.scaleOut = button.procFrame.pulse:CreateAnimation('Scale')
		button.procFrame.scaleOut:SetOrder(1)
		button.procFrame.scaleOut:SetDuration(0.7)
		button.procFrame.scaleOut:SetStartDelay(0)
		button.procFrame.scaleOut:SetSmoothing('OUT')
		button.procFrame.scaleOut:SetFromScale(0.98, 0.98)
		button.procFrame.scaleOut:SetToScale(1.05, 1.05)
	end

	button.rabHooked = true
end

function RAB:PositionAndSizeBar(barName)
	local bar = AB['handledBars'][barName]
	if not bar then return end
	local button
	for i=1, NUM_ACTIONBAR_BUTTONS do
		button = bar.buttons[i]
		SetupMask(button)
	end
end

function RAB:PositionAndSizeBarPet()
	local button
	for i = 1, NUM_PET_ACTION_SLOTS do
		button = _G['PetActionButton'..i]
		if not button.rabHooked then _G[button:GetName()..'Shine']:SetAlpha(0) end
		SetupMask(button)
	end
end

local function ControlProc(button, autoCastEnabled)
	if not button or (button and not button.procFrame) then return end
	local db = E.db.rab.general

	if button._PixelGlow and button._PixelGlow:GetAlpha() > 0 then button._PixelGlow:SetAlpha(0) end
	if button._ButtonGlow and button._ButtonGlow:IsShown() then button._ButtonGlow:Hide() end
	if button._AutoCastGlow and button._AutoCastGlow:GetAlpha() > 0 then button._AutoCastGlow:SetAlpha(0) end

	if db.procEnable and autoCastEnabled then
		button.procFrame:Show()
		button.procFrame.spinner:Play(db.procReverse)
		if db.procPulse and not button.procFrame.pulse:IsPlaying() then
			button.procFrame.pulse:Play()
		end
	else
		button.procFrame:Hide()
		button.procFrame.spinner:Stop()
		button.procFrame.pulse:Stop()
	end
end

function RAB:UpdatePet(event, unit)
	if (event == 'UNIT_FLAGS' or event == 'UNIT_PET') and unit ~= 'pet' then return end
	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		local button = _G['PetActionButton'..i]
		local _, _, _, _, _, autoCastEnabled = GetPetActionInfo(i)
		ControlProc(button, autoCastEnabled)
	end
end

function RAB:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions)
	if not AB.Initialized or not E.db.rab.general.enable then return end

	hooksecurefunc(E, 'UpdateDB', RAB.UpdateOptions)
	hooksecurefunc(AB, 'PositionAndSizeBar', RAB.PositionAndSizeBar)
	for i = 1, 10 do
		RAB:PositionAndSizeBar('bar'..i)
	end

	RAB:PositionAndSizeBarPet()
	hooksecurefunc(AB, 'PositionAndSizeBarPet', RAB.PositionAndSizeBarPet)

	RAB:UpdateOptions()

	hooksecurefunc(LCG, 'ShowOverlayGlow', function(button) ControlProc(button, true) end)
	hooksecurefunc(LCG, 'HideOverlayGlow', function(button) ControlProc(button, false) end)
	hooksecurefunc(AB, 'UpdatePet', RAB.UpdatePet)
end

E.Libs.EP:HookInitialize(RAB, RAB.Initialize)
