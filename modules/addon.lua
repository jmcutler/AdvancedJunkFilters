local version = 3.1
if not ADDONS or ADDONS.version < version then ADDONS = { version = version }

  function Print (str) return d(str) end

  function With (Object)

    local function Return () return Object end

    local function Meta (self, func)
      return function (self, ...)
        assert(Object[func], 'function not found in object')
        Object[func](Object, ...)
        return self
      end
    end

    return setmetatable({ Return = Return }, { __index = Meta })
  end

  function Addon (addon, Func)

    local Modules = {}

    local function Require (name)
      assert(Modules[name], string.format('Require "%s" was not found.', name))
      return Modules[name]
    end

    local function Export (name, value)
      Modules[name] = value
    end

    local function On (event, Callback)
      EVENT_MANAGER:RegisterForEvent(addon, event, Callback)

      local Options = {}

      function Options.Filter (filter, condition) 
        EVENT_MANAGER:AddFilterForEvent(addon, event, filter, condition)
        return Options
      end
      
      return Options
    end

    local function Forget (event)
      EVENT_MANAGER:UnregisterForEvent(addon, event)
    end

    local function OnLoad (Func)
      On(EVENT_ADD_ON_LOADED, function(code, name) 
        if not addon == name then return end
        ADDONS[addon].Data = ZO_SavedVars:NewAccountWide(addon, 1, nil, {})
        ADDONS[addon].CharData = ZO_SavedVars:New(addon, 1, nil, {})
        Forget(EVENT_ADD_ON_LOADED); Func()
      end)
    end

    if not ADDONS[addon] then 
      ADDONS[addon] = {
        Export  = Export, 
        Require = Require,
        Event   = { 
          On     = On, 
          Forget = Forget, 
          OnLoad = OnLoad,
        }
      } 
      setmetatable(ADDONS[addon], { __index = _G })
    end
    
    setfenv(Func, ADDONS[addon]); Func()
    
  end

end