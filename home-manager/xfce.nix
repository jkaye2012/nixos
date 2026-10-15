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
  };

  # xfce4-screenshooter -s needs the directory to already exist.
  home.file."Pictures/Screenshots/.keep".text = "";
}
