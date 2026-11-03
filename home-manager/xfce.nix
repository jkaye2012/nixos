{ lib, ... }:
let
  screenshotDir = "/home/jkaye/Pictures/Screenshots";

  # Workspace digits in i3 order: <Super>1..<Super>9 then <Super>0 for 10.
  workspaces =
    lib.imap1
      (index: digit: {
        inherit digit;
        index = toString index;
      })
      [
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
        "9"
        "0"
      ];

  # xfwm4 keeps ONE accelerator per action: getShortcut() in settings.c walks
  # the shortcut list, returns the first entry whose command matches, and
  # stores it in a single keys[] slot. An action left with two accelerators
  # binds whichever the xfconf XML happens to list first, which changes every
  # time the file is rewritten. So each action gets exactly one accelerator
  # here, and the XFCE default it replaces is removed below.
  wmBindings = {
    # i3's j/k/l/semicolon cluster. xfwm4 has no directional focus action,
    # so these tile instead.
    "<Super>j" = "tile_left_key";
    "<Super>k" = "tile_down_key";
    "<Super>l" = "tile_up_key";
    "<Super>semicolon" = "tile_right_key";

    # i3's move cluster. xfwm4 cannot move a window within a tiling tree,
    # so these send it to the adjacent workspace instead.
    "<Shift><Super>j" = "move_window_left_workspace_key";
    "<Shift><Super>k" = "move_window_down_workspace_key";
    "<Shift><Super>l" = "move_window_up_workspace_key";
    "<Shift><Super>semicolon" = "move_window_right_workspace_key";

    "<Shift><Super>q" = "close_window_key";
    "<Super>f" = "fullscreen_key";
  }
  // lib.listToAttrs (
    map (w: lib.nameValuePair "<Super>${w.digit}" "workspace_${w.index}_key") workspaces
  )
  // lib.listToAttrs (
    map (
      w: lib.nameValuePair "<Shift><Super>${w.digit}" "move_window_workspace_${w.index}_key"
    ) workspaces
  );

  # XFCE defaults whose action is rebound above. Each must be dropped or the
  # action ends up with two accelerators and binds unpredictably.
  supersededDefaults = [
    "<Super>KP_Left" # tile_left_key
    "<Super>KP_Right" # tile_right_key
    "<Super>KP_Up" # tile_up_key
    "<Super>KP_Down" # tile_down_key
    "<Alt>F4" # close_window_key
    "<Alt>F11" # fullscreen_key
  ]
  # workspace_1_key .. workspace_10_key
  ++ map (w: "<Primary>F${w.index}") workspaces
  # move_window_workspace_1_key .. _9_key (10 has no default)
  ++ map (w: "<Primary><Alt>KP_${w.index}") (lib.filter (w: w.index != "10") workspaces);

  commandBindings = {
    # Launchers
    "<Super>d" = "rofi -show run";
    "<Shift><Super>d" = "rofi -show window";
    "<Super>Return" = "ghostty";
    "<Super>x" = "xflock4";

    # Screenshots. The i3 config passed -c and -s together; they select
    # mutually exclusive destinations, so they are split across keys here.
    "Print" = "xfce4-screenshooter -r -c";
    "<Shift>Print" = "xfce4-screenshooter -r -s ${screenshotDir}";
    "<Alt>Print" = "xfce4-screenshooter -w -c";
    "<Primary>Print" = "xfce4-screenshooter -f -s ${screenshotDir}";

    # Media transport via playerctl, volume via wireplumber. pactl and amixer
    # are not installed, and the panel has no pulseaudio plugin to grab these.
    "AudioPlay" = "playerctl play-pause";
    "AudioNext" = "playerctl next";
    "AudioPrev" = "playerctl previous";
    "AudioStop" = "playerctl stop";
    "AudioRaiseVolume" = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
    "AudioLowerVolume" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
    "AudioMute" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    "AudioMicMute" = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
  };

  prefixAttrs =
    prefix: attrs: lib.mapAttrs' (accel: value: lib.nameValuePair "${prefix}${accel}" value) attrs;

  duplicateActions = lib.filterAttrs (_: count: count > 1) (
    lib.foldl' (acc: action: acc // { ${action} = (acc.${action} or 0) + 1; }) { } (
      lib.attrValues wmBindings
    )
  );

  overlap = lib.intersectLists supersededDefaults (lib.attrNames wmBindings);

  # xfconf distinguishes int from uint, and home-manager writes a bare Nix
  # integer as int. xfce4-panel stores sizes, lengths and enum-ish settings
  # as uint, so those go through here.
  uint = value: {
    type = "uint";
    inherit value;
  };

  # Panel and plugin ids are handed out by xfce4-panel itself and referenced
  # by /panels/panel-N/plugin-ids, so the numbering below is whatever the
  # running panel assigned, gaps and all. Renumbering means rebuilding the
  # panels by hand, so it is reproduced verbatim.
  #
  # panel-1, top edge of DP-2, full width. The ids run out of order because
  # plugins were added to the middle of an existing panel:
  #   1 applicationsmenu | 2 tasklist | 3 separator(expand) | 4 pager |
  #   5 sep | 6 systray | 7 sep | 8 clock | 9 sep | 20 sep |
  #   27 pulseaudio | 26 power-manager | 28 sep | 10 actions | 29 sep
  #
  # panel-3, bottom edge of DP-2, full width. xfce4-panel has no "center this
  # plugin" setting: free space is divided evenly among every item marked
  # expand, so a plugin between two expanding separators lands in the middle.
  #   24 separator(expand) | 23 systemload | 25 separator(expand)
  panelSettings = {
    # The panel's config schema version, declared so a fresh machine does not
    # look like an empty channel and get the stock layout instead of this one.
    # If a panel upgrade ever migrates the schema it writes a higher number
    # here and activation would force it back, re-running the migration. Bump
    # this to match if that happens.
    "configver" = 2;

    "panels" = [
      1
      3
    ];
    "panels/dark-mode" = true;

    # Positions are absolute desktop coordinates, where x,y is the panel's
    # center point, for this machine's DP-2 stacked above eDP-1 arrangement.
    # They do not mean anything on a different monitor layout.
    "panels/panel-1/position" = "p=6;x=0;y=0";
    "panels/panel-1/position-locked" = true;
    "panels/panel-1/length" = uint 100;
    "panels/panel-1/length-adjust" = true;
    "panels/panel-1/icon-size" = uint 16;
    "panels/panel-1/size" = uint 26;
    "panels/panel-1/plugin-ids" = [
      1
      2
      3
      4
      5
      6
      7
      8
      9
      20
      27
      26
      28
      10
      29
    ];

    # panel-3 stores length as a double where panel-1 uses a uint. That is
    # simply how xfce4-panel wrote each of them, and it is kept as-is.
    "panels/panel-3/position" = "p=12;x=1269;y=1410";
    "panels/panel-3/length" = 100.0;
    "panels/panel-3/size" = uint 26;
    "panels/panel-3/enable-struts" = true;
    "panels/panel-3/plugin-ids" = [
      24
      23
      25
    ];

    "plugins/plugin-1" = "applicationsmenu";

    "plugins/plugin-2" = "tasklist";
    "plugins/plugin-2/grouping" = uint 1;

    # separator style: 0 transparent, 1 line, 2 handle, 3 dots.
    "plugins/plugin-3" = "separator";
    "plugins/plugin-3/expand" = true;
    "plugins/plugin-3/style" = uint 0;

    "plugins/plugin-4" = "pager";

    "plugins/plugin-5" = "separator";
    "plugins/plugin-5/style" = uint 0;

    # known-items and known-legacy-items are deliberately left out: the panel
    # rewrites them as tray icons come and go, and the legacy list accumulates
    # wifi SSIDs and signal strengths. They are bookkeeping, not settings.
    "plugins/plugin-6" = "systray";
    "plugins/plugin-6/square-icons" = true;

    "plugins/plugin-7" = "separator";
    "plugins/plugin-7/style" = uint 0;

    "plugins/plugin-8" = "clock";

    "plugins/plugin-9" = "separator";
    "plugins/plugin-9/style" = uint 0;

    "plugins/plugin-10" = "actions";

    "plugins/plugin-20" = "separator";

    # Needs pkgs.xfce.xfce4-systemload-plugin, which flake.nix passes through
    # extra-pkgs. Every one of its own settings is at its default, so nothing
    # under plugin-23 is declared; tune them in the GUI and they appear as
    # /plugins/plugin-23/* to be added here.
    "plugins/plugin-23" = "systemload";

    "plugins/plugin-24" = "separator";
    "plugins/plugin-24/expand" = true;
    "plugins/plugin-24/style" = uint 3;

    "plugins/plugin-25" = "separator";
    "plugins/plugin-25/expand" = true;
    "plugins/plugin-25/style" = uint 3;

    # power-manager-plugin and pulseaudio both ship with the system XFCE
    # install as libxfce4powermanager.so and libpulseaudio-plugin.so, so
    # unlike systemload neither needs anything added to extra-pkgs.
    "plugins/plugin-26" = "power-manager-plugin";

    "plugins/plugin-27" = "pulseaudio";
    "plugins/plugin-27/enable-keyboard-shortcuts" = true;
    # known-players is left out for the same reason as the systray lists
    # above: the plugin appends to it whenever it meets a new MPRIS player,
    # so it refills itself the first time Spotify runs.

    "plugins/plugin-28" = "separator";

    "plugins/plugin-29" = "separator";
  };
in
{
  # Shortcuts mirror home-manager/i3/default.nix as closely as xfwm4 allows.
  # Accelerators must be written in GTK's canonical modifier order: Primary,
  # Shift, Alt, Super. `xfconf-query -c xfce4-keyboard-shortcuts -lv` dumps
  # what is live; a null value removes a property.
  assertions = [
    {
      assertion = duplicateActions == { };
      message =
        "xfce.nix: xfwm4 binds one accelerator per action, but these are bound more than once: "
        + lib.concatStringsSep ", " (lib.attrNames duplicateActions);
    }
    {
      assertion = overlap == [ ];
      message =
        "xfce.nix: these accelerators are both set and removed: " + lib.concatStringsSep ", " overlap;
    }
  ];

  xfconf.settings = {
    xfce4-keyboard-shortcuts =
      prefixAttrs "commands/custom/" commandBindings
      // prefixAttrs "xfwm4/custom/" wmBindings
      // lib.genAttrs (map (accel: "xfwm4/custom/${accel}") supersededDefaults) (_: null);

    # i3 exposed 10 workspaces; XFCE ships 4, which would leave <Super>5
    # through <Super>0 inert. Drop this line to keep the XFCE default.
    xfwm4."general/workspace_count" = 10;

    # Captured from a configured panel with `xfconf-query -c xfce4-panel -lv`,
    # with types read off ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    # xfce4-panel.xml. xfce4-panel rewrites this channel on exit, so these
    # values are authoritative at activation, not continuously enforced: after
    # a rebuild run `xfce4-panel -r` to make the running panel pick them up.
    xfce4-panel = panelSettings;
  };

  # xfce4-screenshooter -s needs the directory to already exist.
  home.file."Pictures/Screenshots/.keep".text = "";
}
