# Supersedes the three `gsettings set` shell-outs in the playbook's
# configure role.
# dconf.settings is declarative and idempotent,
# and unlike the Ansible version
# it doesn't need a `stat` check on /usr/bin/gsettings first.
#
# NOTE: these keys are GNOME-specific.
# EndeavourOS commonly ships Xfce, KDE or i3, where they are simply inert.
# See the README for the Xfce/KDE equivalents.
{
  dconf = {
    enable = true;

    settings = {
      "org/gnome/desktop/wm/preferences" = {
        # Alt-drag to move windows
        mouse-button-modifier = "<Alt>";
      };

      "org/gnome/desktop/wm/keybindings" = {
        switch-to-workspace-left = ["<Control><Super>Left"];
        switch-to-workspace-right = ["<Control><Super>Right"];
      };
    };
  };
}
