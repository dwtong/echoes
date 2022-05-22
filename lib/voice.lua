ZONE_LENGTH = 60 -- buffer zone per voice
DEFAULT_PRE = 0.5 -- TODO move to params

voice = {}

  -- v.clock_sync = 1/voice -- TODO move to params
function voice.zone_start(v) return (v-1) * ZONE_LENGTH end
function voice.zone_end(v) return v * ZONE_LENGTH end

function voice.init_softcut(v)
  -- TODO custom routing
  sc.level_input_cut(1, v, 1.0)
  sc.level_input_cut(2, v, 1.0)

  sc.enable(v, 1)
  sc.buffer(v, 1)
  sc.level(v, 0.0)
  sc.fade_time(v, 0.5)
  sc.play(v, 1)
  sc.rate(v, 1.0)
  sc.pan(v, 0)
  sc.loop(v, 1)
  sc.position(v, voice.zone_start(v))
  sc.loop_start(v, voice.zone_end(v))
  sc.loop_end(v, voice.zone_end(v))
  sc.rec(v, 1)
  sc.rec_level(v, 1.0)
  sc.pre_level(v, DEFAULT_PRE)

  -- nice filter defaults from halfsecond
  sc.filter_dry(v, 0.125);
  sc.filter_fc(v, 1200);
  sc.filter_lp(v, 0);
  sc.filter_bp(v, 1.0);
  sc.filter_hp(v, 0.0);
  sc.filter_rq(v, 2.0);
end

function voice.init_params(v)
  params:add_separator("voice "..v)
  -- params:add_group("voice "..v, 2)

  params:add_control(v.."pan", v.." pan", controlspec.PAN)
  params:set_action(v.."pan", function(n) sc.pan(v, n) end)

  -- TODO add sane rates
  -- params:add_option(v.."rate", v.." rate", rates, 10)
  params:add_control(v.."rate", v.." rate", controlspec.PAN)
  params:set_action(v.."rate", function(n) sc.rate(v, n) end)

  params:add_control(v.."level", v.." level", controlspec.DB)
  params:set_action(v.."level", function(n) sc.level(v, util.dbamp(n)) end)

  params:add_binary(v.."togglerec", "toggle rec (K3)", "toggle", 1)
  params:set_action(v.."togglerec",function(x)
    if x == 1 then
      print(v.."rec")
      sc.rec_level(v, 1.0)
      sc.pre_level(v, DEFAULT_PRE)
      -- TODO reenable after adding rate params
      -- sc.rate(v, 1.0)
    else
      print(v.."play")
      sc.rec_level(v, 0)
      sc.pre_level(v, 1.0) -- preserve current buffer contents
      -- TODO reenable after adding rate params
      -- sc.rate(v, params:get(v.."rate")) -- allows for pitch shifting when playing back
    end
    _menu.rebuild_params()
  end)
end

return voice
