# The playbook installed the git-lfs package but never ran `git lfs install`,
# so LFS smudge/clean filters were never actually registered.
# `lfs.enable` closes that gap declaratively.
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
