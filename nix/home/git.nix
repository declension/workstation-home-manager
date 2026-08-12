# `lfs.enable` registers the smudge/clean filters,
# which installing the git-lfs package alone does not do.
#
# This is a work machine, so the work identity is the default.
# Override per-checkout with `git config user.email ...` where that's wrong.
{
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings.user = {
      name = "Nick Boultbee";
      email = "nick.boultbee@generative.vision";
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
      };
    };
  };
}
