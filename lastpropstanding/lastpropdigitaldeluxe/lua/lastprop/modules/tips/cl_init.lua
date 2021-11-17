CreateClientConVar('lps_protips', '1', true, true) -- Enable tips

hook.Add('GetGameOptions', 'GetGameOptions:Protips',  function(settings)
    settings.tips = {
        name = 'Tips',
        settings = {
            {
                convar = 'lps_protips',
                type = 'bool',
                name = 'Tips Enabled',
            }
        }
    }
end)

hook.Add('ResetConvars', 'ResetConvars:Protips',  function(settings)
    RunConsoleCommand('lps_protips', '1')
end)

local function getCMD(cmd)
    return string.format('[%s]', string.upper(input.LookupBinding(cmd) or cmd))
end

local function getKey(class, name)
    local data = lps.bindings:GetKey(class, name)
    return string.format('[%s]', lps.input:KeyData(data.key, data.type)[4])
end

hook.Add('Initialize', 'Initialize:Protips', function()
    local index = 1
    timer.Create('lps_protips', 90, 0, function()
        if (not GetConVar('lps_protips'):GetBool() or not IsValid(LocalPlayer())) then return end
        local red, yel, wht = Color(255, 0, 0), Color(255, 255, 0), Color(255, 255, 255)
        local tips = {
            {red, 'PRO TIP:', yel, ' Press ', wht, LocalPlayer():Team() == TEAM.PROPS and getKey('prop', 'taunt') or getKey('hunter', 'taunt'), yel, ' to Taunt!'},
            {red, 'PRO TIP:', yel, ' Press ', wht, getKey('global', 'tauntMenu'), yel, ' to open the taunt menu!'},
            {red, 'PRO TIP:', yel, ' Hold ', wht, getKey('prop', 'replace'), yel, ' while pressing ', wht, getCMD('use'), yel, ' on a prop to become the prop!'},
            {red, 'PRO TIP:', yel, ' Press ', wht, getCMD('+menu'), yel, ' to \'quick view\' your keybinds!'},
            {red, 'PRO TIP:', yel, ' Press ', wht, getKey('global', 'tpv'), yel, ' to toggle 3rd preson view!'},
            {red, 'PRO TIP:', yel, ' Press ', wht, getKey('global', 'tpvDistance'), yel, ' and use your scroll wheel to change the 3rd preson distance!'},
            {red, 'PRO TIP:', yel, ' Press ', wht, getKey('global', 'tpvOffset'), yel, ' to toggle over the shoulder 3rd preson view!'},
            {red, 'PRO TIP:', yel, ' Press ', wht, getKey('global', 'teamChat'), yel, ' to team voice chat and ', wht, getKey('global', 'localChat'), yel, ' to 3D chat!'},
            {red, 'PRO TIP:', yel, ' Press ', wht, getCMD('gm_showhelp'), yel, ' for some helpfull info!'},
            {red, 'PRO TIP:', yel, ' Stuck? Type \'!stuck\' to get unstuck!'},
            {red, 'PRO TIP:', yel, ' Press ', wht, getKey('prop', 'snap'), yel, ' to lock your prop at a straight angle!'},
            {red, 'PRO TIP:', yel, ' Hunters can use the crowbar to destroy items with out loosing health!'},
            {red, 'PRO TIP:', yel, ' Props can adjust the locked angle by pressing ', wht, getKey('prop', 'adjust'), yel, ' and using the scroll wheel!'},
            {red, 'PRO TIP:', yel, ' Props can press ', wht, getKey('prop', 'tauntLong'), yel, ', ', wht, getKey('prop', 'tauntMedium'), yel, ' and ', wht, getKey('prop', 'tauntShort'),  yel, ' for a long, medium and short random taunt!'},
            {red, 'PRO TIP:', yel, ' Music too loud? Type \'!settings\' to change the volume!'},
            {red, 'PRO TIP:', yel, ' Player too loud? Press ', wht, getCMD('+showscores'), yel, ' and click on the speaker icon to mute them!'},
            {red, 'PRO TIP:', yel, ' Button Masher has been added to the minigames! We also have Snake! Type \'!settings\' to change to it!'},
        }

        chat.AddText(unpack(tips[index]))

        if (index + 1 < #tips ) then
            index = index + 1
        else
            index = 1
        end
    end)
end)

