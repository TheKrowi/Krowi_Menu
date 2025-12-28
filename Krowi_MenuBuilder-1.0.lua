--[[
    Copyright (c) 2025 Krowi

    All Rights Reserved unless otherwise explicitly stated.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

---@diagnostic disable: undefined-global
---@diagnostic disable: duplicate-set-field

-- ####################################################################
-- Krowi_MenuBuilder-1.0
-- A cross-version menu builder for WoW Classic and Modern
-- ####################################################################

local MAJOR, MINOR = "Krowi_MenuBuilder-1.0", KROWI_MENU_LIBRARY_MINOR
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

-- Store version constants
lib.MAJOR = MAJOR
lib.MINOR = MINOR

-- ####################################################################
-- MenuBuilder Class
-- ####################################################################

local MenuBuilder = {}
MenuBuilder.__index = MenuBuilder

-- ####################################################################
-- Utility Functions
-- ####################################################################

--[[
    Helper function to bind object methods to callbacks
    Eliminates boilerplate when all callbacks simply forward to methods on an object
    
    @param obj table The object whose methods will be bound
    @param methodNames table Map of callback names to method names
    @return table Map of callback names to bound functions
    
    Example:
    callbacks = lib.BindCallbacks(self, {
        GetCheckBoxStateText = "GetCheckBoxStateText",
        KeyIsTrue = "KeyIsTrue",
    })
]]
function lib.BindCallbacks(obj, methodNames)
    local callbacks = {}
    for callbackName, methodName in pairs(methodNames) do
        callbacks[callbackName] = function(...)
            return obj[methodName](obj, ...)
        end
    end
    return callbacks
end

-- ####################################################################
-- Constructor
-- ####################################################################

-- Local helper to set up default callbacks using Krowi_Util if available
local function SetupDefaultCallbacks(instance)
    local KrowiUtil = LibStub and LibStub("Krowi_Util-1.0", true)
    if not KrowiUtil or not KrowiUtil.ReadNestedKeys then
        return
    end
    
    -- Default KeyIsTrue: reads nested keys from filters table
    if not instance.callbacks.KeyIsTrue then
        instance.callbacks.KeyIsTrue = function(filters, keys)
            return KrowiUtil.ReadNestedKeys(filters, keys)
        end
    end
    
    -- Default KeyEqualsText: reads nested keys and compares to text
    if not instance.callbacks.KeyEqualsText then
        instance.callbacks.KeyEqualsText = function(text, filters, keys)
            return KrowiUtil.ReadNestedKeys(filters, keys) == text
        end
    end
end

-- Local helper to set default translations
local function SetupDefaultTranslations(instance)
    instance.translations["Select All"] = instance.translations["Select All"] or "Select All"
    instance.translations["Deselect All"] = instance.translations["Deselect All"] or "Deselect All"
    instance.translations["Version"] = instance.translations["Version"] or "Version"
end

--[[
    Creates a new MenuBuilder instance
    
    @param config table Configuration object with the following structure:
    {
        callbacks = {
            -- Required callbacks for checkbox functionality
            GetCheckBoxStateText = function(text, filters, keys) return string end,
            KeyIsTrue = function(filters, keys) return bool end,
            OnCheckboxSelect = function(filters, keys, ...) end, -- Varargs for custom user data
            
            -- Required callbacks for radio functionality
            KeyEqualsText = function(text, filters, keys) return bool end,
            OnRadioSelect = function(text, filters, keys, ...) end, -- Varargs for custom user data
            
            -- Required callback for build version filter
            IsMinorVersionChecked = function(filters, minor) return bool end,
            OnMinorVersionSelect = function(filters, minor) end,
            IsMajorVersionChecked = function(filters, major) return bool end,
            OnMajorVersionSelect = function(filters, major) end,
            OnAllVersionsSelect = function(filters, value) end,
            CreateBuildVersionFilterGroups = function(version, filters, menuBuilder) end,
            
            -- Required callbacks for rewards/factions
            SetRewardsFilters = function(filters, value) end,
            SetFactionFilters = function(filters, value) end,
        },
        translations = {
            -- Optional translations, defaults to English
            ["Select All"] = "Select All",
            ["Deselect All"] = "Deselect All",
            ["Version"] = "Version",
        },
        MenuItemClass = menuItemClass -- Required for Classic version
    }
]]
function lib:New(config)
    local instance = setmetatable({}, MenuBuilder)
    instance.config = config or {}
    instance.callbacks = config.callbacks or {}
    instance.translations = config.translations or {}
    
    -- Generate unique tag for this instance
    instance.uniqueTag = config.uniqueTag or tostring(instance):match("0x(%x+)") or tostring(math.random(100000, 999999))
    
    SetupDefaultTranslations(instance)
    SetupDefaultCallbacks(instance)
    
    instance:Init()
    
    return instance
end

-- ####################################################################
-- Callback Helper Methods (Version-Agnostic)
-- ####################################################################

-- Checkbox Callbacks
function MenuBuilder:GetCheckBoxStateText(text, filters, keys)
    if self.callbacks.GetCheckBoxStateText then
        return self.callbacks.GetCheckBoxStateText(text, filters, keys)
    end
    return text
end

function MenuBuilder:KeyIsTrue(filters, keys)
    if self.callbacks.KeyIsTrue then
        return self.callbacks.KeyIsTrue(filters, keys)
    end
    return false
end

function MenuBuilder:OnCheckboxSelect(filters, keys, ...)
    if self.callbacks.OnCheckboxSelect then
        self.callbacks.OnCheckboxSelect(filters, keys, ...)
    end
end

-- Radio Callbacks
function MenuBuilder:KeyEqualsText(text, filters, keys)
    if self.callbacks.KeyEqualsText then
        return self.callbacks.KeyEqualsText(text, filters, keys)
    end
    return false
end

function MenuBuilder:OnRadioSelect(text, filters, keys, ...)
    if self.callbacks.OnRadioSelect then
        self.callbacks.OnRadioSelect(text, filters, keys, ...)
    end
end

-- Build Version Filter Callbacks
function MenuBuilder:IsMinorVersionChecked(filters, minor)
    if self.callbacks.IsMinorVersionChecked then
        return self.callbacks.IsMinorVersionChecked(filters, minor)
    end
    return false
end

function MenuBuilder:OnMinorVersionSelect(filters, minor)
    if self.callbacks.OnMinorVersionSelect then
        self.callbacks.OnMinorVersionSelect(filters, minor)
    end
end

function MenuBuilder:IsMajorVersionChecked(filters, major)
    if self.callbacks.IsMajorVersionChecked then
        return self.callbacks.IsMajorVersionChecked(filters, major)
    end
    return false
end

function MenuBuilder:OnMajorVersionSelect(filters, major)
    if self.callbacks.OnMajorVersionSelect then
        self.callbacks.OnMajorVersionSelect(filters, major)
    end
end

function MenuBuilder:OnAllVersionsSelect(filters, value)
    if self.callbacks.OnAllVersionsSelect then
        self.callbacks.OnAllVersionsSelect(filters, value)
    end
end

-- Rewards/Factions Callbacks
function MenuBuilder:SetRewardsFilters(filters, value)
    if self.callbacks.SetRewardsFilters then
        self.callbacks.SetRewardsFilters(filters, value)
    end
end

function MenuBuilder:SetFactionFilters(filters, value)
    if self.callbacks.SetFactionFilters then
        self.callbacks.SetFactionFilters(filters, value)
    end
end

-- ####################################################################
-- Modern Implementation
-- ####################################################################

-- Initialization
function MenuBuilder:Init()
    self.menuGenerator = nil
    self.currentMenu = nil
end

-- Setup
function MenuBuilder:SetupMenuForModern(button)
    if not button.SetupMenu then
        error("Button must have SetupMenu method (WowStyle1FilterDropdownMixin)")
    end
    
    button:SetupMenu(function(owner, menu)
        menu:SetTag("KROWI_MENUBUILDER_FILTER_DROPDOWN_" .. self.uniqueTag)
        self.currentMenu = menu
        if self.CreateMenu then
            self:CreateMenu()
        end
    end)
end

-- Public API
function MenuBuilder:Show(anchor, offsetX, offsetY)
    -- Modern doesn't need manual showing, handled by SetupMenu
    -- This is a no-op, menu shows when button is clicked
end

function MenuBuilder:ShowPopup(createMenuFunc, anchor, offsetX, offsetY)
    -- Modern uses MenuUtil.CreateContextMenu for standalone popups
    local menuFunc = createMenuFunc or self.CreateMenu
    if not menuFunc then
        error("ShowPopup requires a createMenuFunc parameter or self.CreateMenu function")
    end
    
    local menu = MenuUtil.CreateContextMenu(anchor or UIParent, function(owner, menuObj)
        menuObj:SetTag("KROWI_MENUBUILDER_STANDALONE_POPUP_" .. self.uniqueTag);
        self.currentMenu = menuObj;
        menuFunc(self);
    end);
    if anchor then
        menu:SetPoint("TOPLEFT", anchor or UIParent, "BOTTOMLEFT", offsetX or 0, offsetY or 0);
    end
end

function MenuBuilder:Close()
    -- Modern menus close automatically
end

function MenuBuilder:GetMenu()
    return self.currentMenu
end

-- Menu Creation
function MenuBuilder:CreateDivider(menu)
    menu = menu or self:GetMenu()
    menu:CreateDivider()
end

function MenuBuilder:CreateCheckbox(menu, text, filters, keys, ...)
    menu = menu or self:GetMenu()
    local userData = {...}
    
    return menu:CreateCheckbox(
        self:GetCheckBoxStateText(text, filters, keys),
        function()
            return self:KeyIsTrue(filters, keys)
        end,
        function()
            self:OnCheckboxSelect(filters, keys, unpack(userData))
        end
    )
end

function MenuBuilder:CreateRadio(menu, text, filters, keys, ...)
    menu = menu or self:GetMenu()
    local userData = {...}
    
    local button = menu:CreateRadio(
        text,
        function()
            return self:KeyEqualsText(text, filters, keys)
        end,
        function()
            self:OnRadioSelect(text, filters, keys, unpack(userData))
        end
    )
    button:SetResponse(MenuResponse.Refresh)
    return button
end

-- Build Version Filter
function MenuBuilder:CreateMinorVersionGroup(majorGroup, filters, major, minor)
    return majorGroup:CreateCheckbox(
        major.Major .. "." .. minor.Minor .. ".x",
        function()
            return self:IsMinorVersionChecked(filters, minor)
        end,
        function()
            self:OnMinorVersionSelect(filters, minor)
        end
    )
end

function MenuBuilder:CreateMajorVersionGroup(version, filters, major)
    return version:CreateCheckbox(
        major.Major .. ".x.x",
        function()
            return self:IsMajorVersionChecked(filters, major)
        end,
        function()
            self:OnMajorVersionSelect(filters, major)
        end
    )
end

function MenuBuilder:CreateSelectDeselectAllVersions(version, filters)
    self:CreateDivider(version)
    
    local selectAll = version:CreateButton(
        self.translations["Select All"],
        function()
            self:OnAllVersionsSelect(filters, true)
        end
    )
    selectAll:SetResponse(MenuResponse.Refresh)
    
    local deselectAll = version:CreateButton(
        self.translations["Deselect All"],
        function()
            self:OnAllVersionsSelect(filters, false)
        end
    )
    deselectAll:SetResponse(MenuResponse.Refresh)
end

function MenuBuilder:CreateBuildVersionFilter(filters, menu)
    menu = menu or self:GetMenu()
    
    local version = menu:CreateButton(self.translations["Version"])
    if self.callbacks.CreateBuildVersionFilterGroups then
        self.callbacks.CreateBuildVersionFilterGroups(version, filters, self)
    end
    self:CreateSelectDeselectAllVersions(version, filters)
end

-- Rewards/Factions
function MenuBuilder:CreateSelectDeselectAllRewards(menu, text, filters, value)
    menu = menu or self:GetMenu()
    
    local button = menu:CreateButton(
        text,
        function()
            self:SetRewardsFilters(filters, value)
        end
    )
    button:SetResponse(MenuResponse.Refresh)
end

function MenuBuilder:CreateSelectDeselectAllFactions(menu, text, filters, value)
    menu = menu or self:GetMenu()
    
    local button = menu:CreateButton(
        text,
        function()
            self:SetFactionFilters(filters, value)
        end
    )
    button:SetResponse(MenuResponse.Refresh)
end

-- Utility
function MenuBuilder:CreateTitle(menu, text)
    menu = menu or self:GetMenu()
    menu:CreateTitle(text)
end

function MenuBuilder:CreateSubmenuButton(menu, text, func, isEnabled)
    menu = menu or self:GetMenu()
    local button = menu:CreateButton(text, func)
    if isEnabled == false then
        button:SetEnabled(false)
    end
    return button
end

function MenuBuilder:AddChildMenu(menu, child)
    -- Modern menus don't need explicit child addition
end

function MenuBuilder:CreateButtonAndAdd(menu, text, func, isEnabled)
    return self:CreateSubmenuButton(menu, text, func, isEnabled)
end

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    lib.MenuBuilder = MenuBuilder
    return
end

-- ####################################################################
-- Classic Implementation
-- ####################################################################

-- Initialization
function MenuBuilder:Init()
    self.rootMenu = LibStub("Krowi_Menu-1.0")
end

-- Public API
function MenuBuilder:Show(anchor, offsetX, offsetY)
    self.rootMenu:Clear()
    if self.CreateMenu then
        self:CreateMenu()
    end
    self.rootMenu:Toggle(anchor, offsetX or 0, offsetY or 0)
end

function MenuBuilder:ShowPopup(createMenuFunc, anchor, offsetX, offsetY)
    -- Classic clears and rebuilds menu each time
    local menuFunc = createMenuFunc or self.CreateMenu
    if not menuFunc then
        error("ShowPopup requires a createMenuFunc parameter or self.CreateMenu function")
    end
    
    self.rootMenu:Clear()
    menuFunc(self)
    self.rootMenu:Toggle(anchor or "cursor", offsetX or 0, offsetY or 0)
end

function MenuBuilder:Close()
    if self.rootMenu then
        self.rootMenu:Close()
    end
end

function MenuBuilder:GetMenu()
    return self.rootMenu
end

-- Menu Creation
function MenuBuilder:CreateDivider(menu)
    menu = menu or self:GetMenu()
    menu:AddSeparator()
end

function MenuBuilder:CreateCheckbox(menu, text, filters, keys, ...)
    menu = menu or self:GetMenu()
    local userData = {...}
    
    menu:AddFull({
        Text = self:GetCheckBoxStateText(text, filters, keys),
        Checked = function()
            return self:KeyIsTrue(filters, keys)
        end,
        Func = function()
            self:OnCheckboxSelect(filters, keys, unpack(userData))
            UIDropDownMenu_RefreshAll(UIDROPDOWNMENU_OPEN_MENU)
        end,
        IsNotRadio = true,
        NotCheckable = false,
        KeepShownOnClick = true
    })
end

function MenuBuilder:CreateRadio(menu, text, filters, keys, ...)
    menu = menu or self:GetMenu()
    local userData = {...}
    
    menu:AddFull({
        Text = text,
        Checked = function()
            return self:KeyEqualsText(text, filters, keys)
        end,
        Func = function()
            self:OnRadioSelect(text, filters, keys, unpack(userData))
            self.rootMenu:SetSelectedName(text)
        end,
        NotCheckable = false,
        KeepShownOnClick = true
    })
end

-- Build Version Filter
function MenuBuilder:CreateMinorVersionGroup(majorGroup, filters, major, minor)
    return majorGroup:AddFull({
        Text = major.Major .. "." .. minor.Minor .. ".x",
        Checked = function()
            return self:IsMinorVersionChecked(filters, minor)
        end,
        Func = function()
            self:OnMinorVersionSelect(filters, minor)
            UIDropDownMenu_RefreshAll(UIDROPDOWNMENU_OPEN_MENU)
        end,
        IsNotRadio = true,
        NotCheckable = false,
        KeepShownOnClick = true
    })
end

function MenuBuilder:CreateMajorVersionGroup(version, filters, major)
    return version:AddFull({
        Text = major.Major .. ".x.x",
        Checked = function()
            return self:IsMajorVersionChecked(filters, major)
        end,
        Func = function()
            self:OnMajorVersionSelect(filters, major)
            UIDropDownMenu_RefreshAll(UIDROPDOWNMENU_OPEN_MENU)
        end,
        IsNotRadio = true,
        NotCheckable = false,
        KeepShownOnClick = true
    })
end

function MenuBuilder:CreateSelectDeselectAllVersions(version, filters)
    self:CreateDivider(version)
    
    version:AddFull({
        Text = self.translations["Select All"],
        Func = function()
            self:OnAllVersionsSelect(filters, true)
            UIDropDownMenu_RefreshAll(UIDROPDOWNMENU_OPEN_MENU)
        end,
        KeepShownOnClick = true
    })
    version:AddFull({
        Text = self.translations["Deselect All"],
        Func = function()
            self:OnAllVersionsSelect(filters, false)
            UIDropDownMenu_RefreshAll(UIDROPDOWNMENU_OPEN_MENU)
        end,
        KeepShownOnClick = true
    })
end

function MenuBuilder:CreateBuildVersionFilter(filters, menu)
    menu = menu or self:GetMenu()
    
    local version = self:CreateSubmenuButton(menu, self.translations["Version"])
    if self.callbacks.CreateBuildVersionFilterGroups then
        self.callbacks.CreateBuildVersionFilterGroups(version, filters, self)
    end
    self:CreateSelectDeselectAllVersions(version, filters)
    self:AddChildMenu(menu, version)
end

-- Rewards/Factions
function MenuBuilder:CreateSelectDeselectAllRewards(menu, text, filters, value)
    menu = menu or self:GetMenu()
    
    menu:AddFull({
        Text = text,
        Func = function()
            self:SetRewardsFilters(filters, value)
            UIDropDownMenu_RefreshAll(UIDROPDOWNMENU_OPEN_MENU)
        end,
        KeepShownOnClick = true
    })
end

function MenuBuilder:CreateSelectDeselectAllFactions(menu, text, filters, value)
    menu = menu or self:GetMenu()
    
    menu:AddFull({
        Text = text,
        Func = function()
            self:SetFactionFilters(filters, value)
            UIDropDownMenu_RefreshAll(UIDROPDOWNMENU_OPEN_MENU)
        end,
        KeepShownOnClick = true
    })
end

-- Utility
function MenuBuilder:CreateTitle(menu, text)
    menu = menu or self:GetMenu()
    menu:AddTitle(text)
end

function MenuBuilder:CreateSubmenuButton(menu, text, func, isEnabled)
    menu = menu or self:GetMenu()
    return LibStub("Krowi_MenuItem-1.0"):New({
        Text = text,
        Func = func,
        Disabled = isEnabled == false
    })
end

function MenuBuilder:AddChildMenu(menu, child)
    menu = menu or self:GetMenu()
    if not menu or not child then
        return
    end
    menu:Add(child)
end

function MenuBuilder:CreateButtonAndAdd(menu, text, func, isEnabled)
    menu = menu or self:GetMenu()
    self:AddChildMenu(menu, self:CreateSubmenuButton(nil, text, func, isEnabled))
end

lib.MenuBuilder = MenuBuilder
