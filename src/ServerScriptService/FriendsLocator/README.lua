--[[
    FriendsLocator
    Version: 1.1.0
    Author: Roblox
    Asset: https://www.roblox.com/library/6999703163

    View docs in browser: https://developer.roblox.com/resources/developer-modules/friends-locator

    # Home

    !!! warning Please note that this Dev Module does not support experiences with `StreamingEnabled`.

    This Dev Module allows your players to easily find other friends who are within the same place.

    Check out our [Quickstart](getting-started.md) guide to get started!

    # Getting Started

    !!! warning Please note that this Dev Module does not support experiences with `StreamingEnabled`.

    To install a Dev Module, you must first get a copy of it from the asset library. If you're reading this in Studio,
    you've already done this step! Otherwise, follow these steps to learn how to insert the Friends Locator Dev Module into
    your experience:

    1.  Visit the Dev Modules's page on the [asset library](https://www.roblox.com/library/6999703163).
    2.  Add it to your inventory for free by clicking the "Buy" button.
    3.  Open [Roblox Studio](https://www.roblox.com/create) and then either open an existing place, or create a new one.
    4.  Open the Toolbox and click on the Friends Locator Dev Module to insert it.

    Next, you can either leave the Dev Module where it was inserted in `Workspace`, or move it to `ServerScriptService`.
    It's up to you! You can now start the experience and the Dev Module will distribute itself to various services and start
    itself up.

    Each Dev Module is designed to work out of the box, so the moment you press play it will *just work*. If this isn't your
    style, you have full control over the Dev Module and how it works as the developer.

    ## Quickstart

    For this tutorial we will start off with an empty baseplate in Roblox Studio.

    ### Download Dev Module

    You can download the Dev Module by...

    1.  Downloading it from the [asset library](https://www.roblox.com/library/6999703163), or
    2.  Searching the module by name in the Studio Toolbox.

    ### Add to ServerScriptService

    Drag and drop the Dev Module into your Roblox Studio workspace and move the Dev Module into `ServerScriptService`.

    ### Start a game in Studio

    Hit `Play` or `F5` and open the Explorer. You should see the following structure (take note of the selected items!):

    ## Test

    After setting up the Dev Module, we want to verify that it works in Studio. This Dev Module is slightly tricky to test
    since you won't have any friends present in Studio test mode. We will go through how to verify that friend locators are
    showing up in this section.

    There are two methods to test that the dev module has been loaded:

    1.  Publish and join with your friends, or
    2.  Configure the Dev Module to display locators for all users, and launch a test server with 2 users

    **We will focus on method #2 in this section.**

    ### Create a new `LocalScript`

    In `LocalPlayer -> StarterPlayerScripts`, create a new `LocalScript` and rename it to `ConfigureFriendsLocator`.

    ### Configure Dev Module to show for all friends

    Paste the following code into `ConfigureFriendsLocator` from the previous step.

    This ensures that we will display friend locators for all users if we are running the Dev Module within Studio, but not
    in a published place.

    	local RunService = game:GetService("RunService")
    	local ReplicatedStorage = game:GetService("ReplicatedStorage")
    	
    	local FriendsLocator = require(ReplicatedStorage:WaitForChild("FriendsLocator"))
    	
    	FriendsLocator.configure({
    		showAllPlayers = RunService:IsStudio(),
    	})

    A complete list of configuration values and information can be found in the [API reference](api.md).

    ### Start a game in Studio

    Instead of starting the game with one player, start a test server with 2 players instead. 3 instances of Studio should
    launch. 2 for the players, and 1 for the server.

    Go into any of the player Studio instances, and zoom out. You should be able to see the locator show up on the other
    player. Due to the way we handle user IDs in Studio, avatars for the users will not show up (a blank circle will be
    shown).

    ## Connect to events

    This Dev Module also exposes events so that you can introduce custom behaviors when a user interacts with a Friend
    Locator. In this section, we will go through how to setup the basic code structure for hooking to these events.

    Note: Make sure that you have completed the previous section before moving on!

    ### Listen for `clicked` events

    Go to `ConfigureFriendsLocator`. Replace the script content with the following:

    	local RunService = game:GetService("RunService")
    	local ReplicatedStorage = game:GetService("ReplicatedStorage")
    	
    	local FriendsLocator = require(ReplicatedStorage:WaitForChild("FriendsLocator"))
    	
    	FriendsLocator.configure({
    		-- Allows for debugging in Studio
    		showAllPlayers = RunService:IsStudio(),
    	
    		-- Disable default behavior of teleporting to friend
    		teleportToFriend = false,
    	})
    	
    	FriendsLocator.clicked:Connect(function(player, _)
    		print(string.format("[FriendsLocator] You have clicked on locator for %s", player.DisplayName))
    	end)

    ### Verify implementation is working

    To verify that this is working, run your game in Studio. Click on a visible player's locator and you should see the
    following output show up in the output window:

    	\[FriendsLocator] You have clicked on locator for Player1

    Note that:

    1.  Local player that clicked on the locator should not have teleported to the target player, and
    2.  In the output window, `Player1` can show up as `Player2` or other names depending on which Studio instance you used

    Replace the code for the `print` statement with any custom logic that you want for your experience. Some fun examples to
    try out:

    1.  Display additional GUIs
    2.  Zoom camera into the target player
    3.  Send a "Hello" chat message to the target player

    Have fun with customizing your Dev Module's behaviors using events! More information on events and their respective
    parameters can be found in the [API reference](api.md#client-events).

    # Advanced

    Each Dev Module is packaged under one single folder. However, due to how the Roblox engine works many sub-components
    need to be moved to specific parts of the game hierarchy to run. For example, server code needs to be parented to
    `ServerScriptService`, and client code to `StarterPlayerScripts`. To this end, we have created an installer that
    performs the following steps:

    **Sub-component distribution:**

    The children of a Dev Module includes Folders named after Roblox services. The installer iterates through each Folder
    and reparents the children to the service with the same name. For instance, if the Dev Module has a folder called
    `ServerScriptService`, all its children will be moved to `game.ServerScriptService`.

    **Package deduplication:**

    Libraries like [Roact](https://github.com/Roblox/Roact) that might be re-used between various Dev Modules go through a
    process of deduplication. What this process entails is that, if any other Dev Modules present in the experience use the
    same libraries, those libraries are compared and only one copy will end up existing in the experience.

    This is done to prevent the same versions of a library being duplicated, which results in excess code and potential
    conflicts when a library expects to only exist once.

    ## Using the Install Script

    Every Dev Module comes with a `DevModuleInstaller` ModuleScript and an `Install` Script to run the installer. Inside the
    `Install` Script, you can make use of the following members:

    **`bool verboseLogging = false`**

    Set this to `true` to enable debug logging for the current Dev Module. This allows you to see how the Dev Module gets
    distributed, along with how each package is linked.

    	local DevModuleInstaller = require(script.Parent.DevModuleInstaller)
    	
    	DevModuleInstaller.verboseLogging = true

    **`RBXScriptSignal started`**

    This event is fired when the installer first starts up. You can hook into this event to run any pre-install steps.

    	local DevModuleInstaller = require(script.Parent.DevModuleInstaller)
    	
    	DevModuleInstaller.started:Connect(function()
    	    print("This is run before installation")
    	end)

    **`RBXScriptSignal finished`**

    This event is fired when the installer has finished installing the Dev Module. By this point, the contents of each
    service folder has been distributed and it is safe to reference `ReplicatedStorage.FriendsLocator`. You can hook into
    this event to run any post-install steps.

    	local DevModuleInstaller = require(script.Parent.DevModuleInstaller)
    	
    	DevModuleInstaller.finished:Connect(function()
    	    print("This is run after installation")
    	end)

    The Dev Module itself (that is, the parent of the `Install` script) has `Destroy()` run on it immediately after this
    event is fired.

    **`install(devModule: Instance): nil`**

    Installs the given Dev Module by overlaying each of the service folders over existing services. For example, a folder
    named `ReplicatedStorage` with a `ModuleScript` inside of it will be distributed to
    `game.ReplicatedStorage.ModuleScript` when installing.

    	local DevModuleInstaller = require(script.Parent.DevModuleInstaller)
    	
    	DevModuleInstaller.install(script.Parent)

    # API Reference

    ## Client Functions

    ### configure

    `configure(config: table): nil`

    Override the default configurations with the given values. Throws an error when given invalid values.

    The possible options are:

    	-- Sets BillboardGui on top of everything (prevents locator from being blocked by 3D world objects)
    	alwaysOnTop = true,
    	
    	-- Shows locators for all players, not just friends
    	showAllPlayers = false,
    	
    	-- Will reposition user to friend's location if set to true
    	teleportToFriend = true,
    	
    	-- Shows locators when players are farther than this threshold
    	thresholdDistance = 100,
    	
    	-- Maximum number of locators shown at a single time
    	maxLocators = 10,

    Usage:

    	local FriendsLocator = require(game.ReplicatedStorage.FriendsLocator)
    	
    	FriendsLocator.configure({
    		alwaysOnTop = true,
    		showAllPlayers = false,
    		teleportToFriend = true,
    		thresholdDistance = 100,
    		maxLocators = 10,
    	})

    ## Client Events

    ### visibilityChanged

    `visibilityChanged(player: Player, cframe: CFrame, isVisible: boolean): RBXScriptConnection`

    Event that is fired when a friend locator is shown/hidden on the LocalPlayer's screen.

    Parameters:

    1.  `player`: `Player` object that this locator belongs to
    2.  `cframe`: `CFrame` of the player that this locator belongs to
    3.  `isVisible`: `true` if the locator is currently visible to the `LocalPlayer`'s GUI, `false` otherwise.

    **Note**: `isVisible` will still be `true` if a locator renders behind an object in the workspace if `alwaysOnTop` is
    set to `false`.

    Usage:

    	local FriendsLocator = require(game.ReplicatedStorage:WaitForChild("FriendsLocator"))
    	
    	FriendsLocator.visibilityChanged:Connect(function(player, cframe, isVisible)
    		print("Locator visibility: ", isVisible)
    	end)

    ### clicked

    `clicked(player: Player, cframe: CFrame): RBXScriptConnection`

    Event that is fired when a friend locator is clicked/activated by the `LocalPlayer`.

    Parameters:

    1.  `player`: `Player` object that this locator belongs to
    2.  `cframe`: `CFrame` of the player that this locator belongs to

    Usage:

    	local FriendsLocator = require(game.ReplicatedStorage:WaitForChild("FriendsLocator"))
    	
    	FriendsLocator.clicked:Connect(function(player, cframe)
    		print("Locator clicked")
    	end)

--]]