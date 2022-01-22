local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local SOURCE_LOCALE = "en"
local translator = nil

local module = {}

local cancelStatusMessages = false

function module.loadTranslator()
	pcall(function()
		translator = LocalizationService:GetTranslatorForPlayerAsync(Players.LocalPlayer)
	end)
	if not translator then
		pcall(function()
			translator = LocalizationService:GetTranslatorForLocaleAsync(SOURCE_LOCALE)
		end)
	end
end

function module.typeWrite(guiObject, text, delayBetweenChars)
	guiObject.Visible = true
	guiObject.AutoLocalize = false
	local displayText = text

	-- Translate text if possible
	if translator then
		displayText = translator:Translate(guiObject, text)
	end

	-- Replace line break tags so grapheme loop will not miss those characters
	displayText = displayText:gsub("<br%s*/>", "\n")
	displayText:gsub("<[^<>]->", "")

	-- Set translated/modified text on parent
	guiObject.Text = displayText

	local index = 0
	for first, last in utf8.graphemes(displayText) do
		if cancelStatusMessages then
			cancelStatusMessages = false
			break
		end
		index = index + 1
		guiObject.MaxVisibleGraphemes = index
		task.wait(delayBetweenChars)
	end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if not processed then
		if input.KeyCode == Enum.KeyCode.KeypadEnter then
			cancelStatusMessages = true
		end
	end
end)

return module