# `lfs.enable` registers the smudge/clean filters,
# which installing the git-lfs package alone does not do.
#
# User identity is deliberately left unset —
# it varies per machine and per checkout.
{
  programs.git = {
    enable = true;
    lfs.enable = true;

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
      };
    };
  };
}
