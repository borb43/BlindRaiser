
local uibox_tag_ref = create_UIBox_blind_tag
function create_UIBox_blind_tag(blind_choice, run_info)
    if not run_info then
        G.GAME.round_resets.blind_tags = G.GAME.round_resets.blind_tags or {}
        if not G.GAME.round_resets.blind_tags[blind_choice] then return nil end
        local _tag = Tag(G.GAME.round_resets.blind_tags[blind_choice], nil, blind_choice)
        local _tag_ui, _tag_sprite = _tag:generate_UI()
        _tag_sprite.states.collide.can = not not run_info
        return {
            n = G.UIT.R,
            config = { id = 'tag_container', ref_table = _tag, align = "tm" },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = 'tm', minh = 0.65 },
                    nodes = {
                        { n = G.UIT.T, config = { text = localize('k_or'), scale = 0.55, colour = disabled and G.C.UI.TEXT_INACTIVE or G.C.WHITE, shadow = not disabled } },
                    }
                },
                {
                    n = G.UIT.C,
                    config = { id = 'tag_' .. blind_choice, align = "cm", r = 0.1, padding = 0.1, minw = 1, can_collide = true, ref_table = _tag_sprite },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { id = 'tag_desc', align = "cm", minh = 1 },
                            nodes = {
                                _tag_ui
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = "cm", colour = G.C.UI.BACKGROUND_INACTIVE, minh = 0.6, minw = 2, maxw = 2, padding = 0.07, r = 0.1, shadow = true, hover = true, one_press = true, button = 'skip_blind', func = 'hover_tag_proxy', ref_table = _tag },
                            nodes = {
                                { n = G.UIT.T, config = { text = localize('b_skip_blind'), scale = 0.4, colour = G.C.UI.TEXT_INACTIVE } }
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = "cm", colour = G.C.UI.BACKGROUND_INACTIVE, minh = 0.6, minw = 2, maxw = 2, padding = 0.07, r = 0.1, shadow = true, hover = true, one_press = true, button = 'skip_blind', func = 'hover_tag_proxy', ref_table = _tag },
                            nodes = {
                                { n = G.UIT.T, config = { text = localize('b_skip_blind'), scale = 0.4, colour = G.C.UI.TEXT_INACTIVE } }
                            }
                        },
                    }
                }
            }
        }
    else
        return uibox_tag_ref(blind_choice, run_info)
    end
end
