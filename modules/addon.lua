local version = 2.0
if not __addons or __addons.version < version then __addons = { version = version }

  local events = {
    ['loaded']           = EVENT_ADD_ON_LOADED,
    ['player loaded']    = EVENT_PLAYER_ACTIVATED,
    ['inventory update'] = EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    ['store opened']     = EVENT_OPEN_STORE,
  }

  local filters = {
    ['bag']              = REGISTER_FILTER_BAG_ID,
    ['reason']           = REGISTER_FILTER_INVENTORY_UPDATE_REASON,
  }

  local conditions = {
    ['backpack']         = BAG_BACKPACK,
    ['default']          = INVENTORY_UPDATE_REASON_DEFAULT,
  }

  function print (str)
    return d(str)
  end

  function loadstring (str)
    return LoadString(str)
  end

  function with (object)
    local function meta (self, func)
      return function (self, ...)
        assert(object[func], func..' missing in object')
        object[func](object, ...)
        return self
      end
    end
    return setmetatable({ value = function() return object end }, { __index = meta })
  end

  function class (parent)
    local base = {}
    return setmetatable(base, {
      __index = parent,
      __call  = function (class, ...)
        local object = setmetatable({}, { __index = base })
        object:init(...)
        return object
      end
    })
  end

  function addon (addon, func)

    local function export (name, value)
      __addons[addon][name] = value
    end

    local function forget (event)
      if not events[event] then return end
      EVENT_MANAGER:UnregisterForEvent(addon, events[event])
    end

    local function filter (event, filter, condition)
      if not events[event] then return end
      EVENT_MANAGER:AddFilterForEvent(addon, events[event], filters[filter], conditions[condition])
    end

    local function on (event, func)
      if not events[event] then return end
      local call = func
      if events[event] == EVENT_ADD_ON_LOADED then 
        call = function(_, name) 
          if addon ~= name then return end
          export('data', ZO_SavedVars:NewAccountWide(addon, 1, nil, nil))
          export('chardata', ZO_SavedVars:New(addon, 1, nil, nil))
          func()
        end
      end 
      EVENT_MANAGER:RegisterForEvent(addon, events[event], call)
    end

    if not __addons[addon] then 
      __addons[addon] = {
        export = export, 
        event  = {on = on, forget = forget, filter = filter}
      } 
      setmetatable(__addons[addon], {__index = _G})
    end
    
    setfenv(func, __addons[addon]); func()
  end

end