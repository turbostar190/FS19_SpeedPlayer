-- SpeedPlayer Mod

-- Refactored from FS17, FS19 by *TurboStar* | LS Modcompany

-- V1.0.0.0  		Initial release

SpeedPlayer = {}

function SpeedPlayer:loadMap(...)
	-- 						 GDN says 6.0...
	self.SPEEDS = {0.8, 2.0, 4.0*0.7, 4.0, 12.0, 32.0, 60.0, 80.0} -- m/s
	self.SPEEDSLENGTH = table.getn(self.SPEEDS)
	self.TEXTS = {[0.8] = "keyslow3", [2.0] = "keyslow2", [4.0*0.7] = "keyslow1", [4.0] = "key0", [12.0] = "key1", [32.0] = "key2", [60.0] = "key15", [80.0] = "key3", ["other"] = "othermod"}
	self.cont = 4
	self.eventIdReduce = ""
	self.eventIdIncrease = ""
	self.inputsActive = false
	self.errorDisplayed = false
end

function SpeedPlayer:deleteMap()
end

function SpeedPlayer:mouseEvent(...)
end

function SpeedPlayer:keyEvent(...)
end

function SpeedPlayer:reduceSpeed()
	if (self.cont == 1) then return end
	self.cont = self.cont - 1
	
	local speed = self.SPEEDS[self.cont]
	SpeedPlayer:setSpeed(speed)
end
function SpeedPlayer:incrementSpeed()
	if (self.cont == self.SPEEDSLENGTH) then return end
	self.cont = self.cont + 1
	
	local speed = self.SPEEDS[self.cont]
	SpeedPlayer:setSpeed(speed)
end

function SpeedPlayer:setSpeed(speed)
	local info = g_currentMission.player.motionInformation
	if speed ~= nil then 
		info.maxWalkingSpeed = tonumber(speed)
		info.maxRunningSpeed = tonumber(speed * 1.5)
		info.maxSwimmingSpeed = tonumber(speed / 2)
		info.maxCrouchingSpeed = tonumber(speed / 3)
		info.maxFallingSpeed = tonumber(speed)
		info.maxCheatRunningSpeed = tonumber(speed * (34/4))
	end
end

function SpeedPlayer:update(dt)
	if g_currentMission:getIsClient() then -- don't run on the Dedicated Server itself
		if g_gui.currentGui == nil and g_currentMission.controlledVehicle == nil then -- only if no vehicle is entered or menu is up
		
			if (self.cont ~= nil and (self.cont < 1 or self.cont > self.SPEEDSLENGTH)) or self.cont == nil then
				if not self.errorDisplayed then 
					print("SpeedPlayer: something is wrong on SpeedPlayer.cont ... Aborting functionality. Please report your log.txt")
					self.errorDisplayed = true
				end
				return
			end
			
			if not self.inputsActive then -- register input events
				_, self.eventIdReduce = g_inputBinding:registerActionEvent(InputAction.SPEEDMINUS, SpeedPlayer, SpeedPlayer.reduceSpeed, false, true, false, false)
				_, self.eventIdIncrease = g_inputBinding:registerActionEvent(InputAction.SPEEDPLUS, SpeedPlayer, SpeedPlayer.incrementSpeed, false, true, false, false)
				self.inputsActive = true
			end
				
			local eventIdReduce = self.eventIdReduce
			local eventIdIncrease = self.eventIdIncrease
			
			if self.cont == 1 then
				-- disable and hide reduce speed button
				g_inputBinding:setActionEventActive(eventIdReduce, false)
				g_inputBinding:setActionEventTextVisibility(eventIdReduce, false)
			elseif self.cont == self.SPEEDSLENGTH then 
				-- disable and hide increase speed button
				g_inputBinding:setActionEventActive(eventIdIncrease, false)
				g_inputBinding:setActionEventTextVisibility(eventIdIncrease, false)
			else
				-- show both buttons
				g_inputBinding:setActionEventActive(eventIdReduce, true)
				g_inputBinding:setActionEventTextVisibility(eventIdReduce, true)
				g_inputBinding:setActionEventActive(eventIdIncrease, true)
				g_inputBinding:setActionEventTextVisibility(eventIdIncrease, true)
			end
			
			local info = g_currentMission.player.motionInformation
			if self.TEXTS[info.maxWalkingSpeed] ~= nil then g_currentMission:addExtraPrintText(g_i18n:getText(self.TEXTS[info.maxWalkingSpeed])) else g_currentMission:addExtraPrintText(g_i18n:getText(self.TEXTS["other"])) end
		else
			self.inputsActive = false
		end
		
	end
end

function SpeedPlayer:draw()
end

print("  Loaded SpeedPlayer Mod...")
addModEventListener(SpeedPlayer)