
local uibox_tag_ref = create_UIBox_blind_tag
function create_UIBox_blind_tag(blind_choice, run_info)
    --to make this feature toggleable, the relevant config option should also be checked here
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
                            config = { align = "cm", colour = G.C.UI.BACKGROUND_INACTIVE, minh = 0.6, minw = 2, maxw = 2, padding = 0.07, r = 0.1, shadow = true, hover = true, one_press = true, button = 'blr_upgrade_blind', func = 'hover_tag_proxy', ref_table = _tag },
                            nodes = {
                                { n = G.UIT.T, config = { text = localize('blr_upgrade_blind'), scale = 0.4, colour = G.C.UI.TEXT_INACTIVE } }
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

G.FUNCS.blr_upgrade_blind = function (e)
    local upgraded = G.GAME.blind_on_deck
    stop_use()
    G.CONTROLLER.locks.boss_reroll = true
    local _tag = e.UIBox:get_UIE_by_ID('tag_container')
    G.GAME.blr_blind_upgrades = (G.GAME.blr_blind_upgrades or 0) + 1
    if _tag then
        add_tag(_tag.config.ref_table)
        G.GAME.upgraded_blinds[upgraded] = true
        G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            func = function()
                play_sound("other1")
                G.blind_select_opts[upgraded:lower()]:set_role({ xy_bond = "Weak" })
                G.blind_select_opts[upgraded:lower()].alignment.offset.y = 20
                return true
            end,
        }))
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.3,
            func = function()
                local boss = get_new_boss()
                local par = G.blind_select_opts[upgraded:lower()].parent
                G.GAME.round_resets.blind_choices[upgraded] = boss

                G.blind_select_opts[upgraded:lower()]:remove()
                G.blind_select_opts[upgraded:lower()] = UIBox({
                    T = { par.T.x, 0, 0, 0 },
                    definition = {
                        n = G.UIT.ROOT,
                        config = { align = "cm", colour = G.C.CLEAR },
                        nodes = {
                            UIBox_dyn_container(
                                { create_UIBox_blind_choice(upgraded) },
                                false,
                                get_blind_main_colour(boss),
                                mix_colours(G.C.BLACK, get_blind_main_colour(boss), 0.8)
                            ),
                        },
                    },
                    config = {
                        align = "bmi",
                        offset = { x = 0, y = G.ROOM.T.y + 9 },
                        major = par,
                        xy_bond = "Weak",
                    },
                })
                par.config.object = G.blind_select_opts[upgraded:lower()]
                par.config.object:recalculate()
                G.blind_select_opts[upgraded:lower()].parent = par
                G.blind_select_opts[upgraded:lower()].alignment.offset.y = 0

                G.E_MANAGER:add_event(Event({
                    blocking = false,
                    trigger = "after",
                    delay = 0.5,
                    func = function()
                        G.CONTROLLER.locks.boss_reroll = nil
                        return true
                    end,
                }))

                delay(0.3)
                SMODS.calculate_context({blr_upgrade_blind = true})
                save_run()
                for i = 1, #G.GAME.tags do
                    G.GAME.tags[i]:apply_to_run({ type = 'immediate' })
                end
                for i = 1, #G.GAME.tags do
                    if G.GAME.tags[i]:apply_to_run({ type = 'new_blind_choice' }) then break end
                end
                return true
            end,
        }))
    end
end
