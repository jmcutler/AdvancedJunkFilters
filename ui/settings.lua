Addon('JunkFilters', function() 

  local SortInsert = Require('SortInsert')
  local LAM        = LibStub('LibAddonMenu-2.0')

  local function Settings (Save, Delete)

    local editFont = 'JunkFilters/UI/Fonts/Inconsolata.otf|16|soft-shadow-thin'
    local docsLink = 'https://github.com/eromelcm/AdvancedJunkFilters/wiki'
    local editing, name, test, priority = false, '', '', 1

    local function Names ()
      local names   = {}
      local compare = function(a, b) return Data.Filters[a].Priority < Data.Filters[b].Priority end
      for name in pairs(Data.Filters) do SortInsert(names, name, compare) end
      return names
    end

    local function UpdateUI ()
      JF_SliderPriority:UpdateValue()
      JF_EditboxFilter:UpdateValue()
      JF_EditboxName:UpdateValue()
      JF_EditboxName:UpdateDisabled()
      JF_ButtonDelete:UpdateDisabled()
    end

    local function Update ()
      editing  = false
      name     = ''
      test     = '' 
      priority = 1 
      JF_DrwopdownFilters:UpdateChoices(Names())
      UpdateUI()
    end

    local function Select (selection)
      local Filter = Data.Filters[selection]
      if Filter then
        editing  = true
        name     = selection 
        test     = Filter.Test
        priority = Filter.Priority
        UpdateUI()
      end
    end

    LAM:RegisterAddonPanel('JunkFilterSettings', { 
      type        = 'panel',
      name        = 'Advanced Junk Filters',
      displayName = 'Advanced Junk Filters',
      author      = '@eromeclm',
      version     = '1.7',
    })

    LAM:RegisterOptionControls('JunkFilterSettings', {
      [1] = {
        type        = 'checkbox',
        name        = 'Automatically Sell Junk',
        getFunc     = function() return Data.Options.AutoSell end,
        setFunc     = function(value) Data.Options.AutoSell = value end,
      },
      [2] = {
        type        = 'divider',
        width       = 'full',
        alpha       = 0.4,
      },
      [3] = {
        type        = 'dropdown',
        name        = 'Edit Filter',
        reference   = 'JF_DrwopdownFilters',
        choices     = Names(),
        getFunc     = function() return nil end,
        setFunc     = function(filter) Select(filter) end,
      },
      [4] = {
        type        = 'slider',
        name        = 'Filter Priority',
        reference   = 'JF_SliderPriority',
        min         = 1,
        max         = 100,
        getFunc     = function() return priority end,
        setFunc     = function(num) priority = num end,
      },
      [5] = {
        type        = 'editbox',
        name        = 'Filter Name',
        reference   = 'JF_EditboxName',
        isExtraWide = true,
        disabled    = function() return editing end,
        getFunc     = function() return name end,
        setFunc     = function(str) name = str end,
      },
      [6] = {
        type        = 'editbox',
        name        = 'Filter Code',
        reference   = 'JF_EditboxFilter',
        isExtraWide = true,
        isMultiline = true,
        getFunc     = function() JF_EditboxFilter.editbox:SetFont(editFont); return test end,
        setFunc     = function(str) test = str end, 
      },
      [7] = {
        type        = 'button',
        name        = 'Delete Filter',
        reference   = 'JF_ButtonDelete',
        width       = 'half',
        disabled    = function() return not editing end,
        func        = function() Delete(name); Update() end,
      },
      [8] = {
        type        = 'button',
        name        = 'Save Filter',
        width       = 'half',
        func        = function() Save(name, priority, test); Update() end,
      },
      [9] = {
        type        = 'divider',
        width       = 'full',
        alpha       = 0.4,
      },
      [10] = {
        type        = 'description',
        text        = 'You can use "|cACC0E0/filternow|r" to run your filters on your entire inventory if needed. How to write a filter is documented online.',
        width       = 'full',
      },
      [11] = {
        type        = 'button',
        name        = 'View Documentation',
        func        = function() RequestOpenUnsafeURL(docsLink) end,
      }
    })

  end

  Export('Settings', Settings)
  
end)