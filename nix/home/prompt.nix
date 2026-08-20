# Starship, configured as a powerline without the powerline tax.
#
# The original powerline is a Python process per prompt; starship is a single
# static binary, so the only real cost left is what the *modules* do. This
# config keeps that cost near zero:
#
#   - Every language/toolchain module is off. Their versions come from
#     `foo --version`, i.e. a process spawn per prompt, and direnv already
#     tells us which toolchain is in play.
#   - `command_timeout` bounds the one module that can still block (git).
#   - Segments are self-contained: each carries its own separator, so an
#     absent module renders nothing rather than a dangling chevron.
#
# Visually this is deliberately *not* the usual powerline: no solid colour
# blocks, and no background fill at all. Colour is carried entirely by the
# text, and groups are divided by a recessive thin  chevron. Nothing is
# filled, bordered or capped, so the prompt sits on the terminal's own
# background — which matters when that background is translucent (see the
# opacity setting in terminal.nix).
#
# Glyphs need a Nerd Font — see nerd-fonts.meslo-lg in packages.nix.
# Every codepoint used below is present in MesloLGS Nerd Font.
{
  programs.starship = {
    enable = true;

    settings = {
      add_newline = false;

      # A slow `git status` in a huge repo drops the segment instead of
      # stalling the prompt.
      command_timeout = 500;
      scan_timeout = 10;

      format = builtins.concatStringsSep "" [
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      palette = "nord";
      palettes.nord = {
        # Separators only. Recessive enough to divide without being read as
        # content, but not so dark it disappears over a translucent terminal.
        dim = "#5b6b8a";
        blue = "#81a1c1";
        cyan = "#88c0d0";
        green = "#a3be8c";
        yellow = "#ebcb8b";
        red = "#bf616a";
        purple = "#b48ead";
      };

      # A chevron divides *groups*, and owns the space either side of itself,
      # so no segment needs a trailing space of its own.
      #
      # Only a module that vanishes entirely when irrelevant may own a chevron.
      # git_status is not one of those: with a clean tree it still renders its
      # format, just with an empty $all_status, so a chevron here would be left
      # dangling. It joins git_branch as a single "git" group instead, and its
      # clean-state output is one space — invisible with nothing filled.
      directory = {
        format = "[󰉋 $path]($style)";
        style = "fg:cyan bold";
        truncation_length = 4;
        truncate_to_repo = true;
        truncation_symbol = "…/";
        read_only = " 󰌾";
      };

      git_branch = {
        format = "[ ](fg:dim)[ $branch]($style)";
        style = "fg:purple";
      };

      git_state = {
        format = "[ $state $progress_current/$progress_total]($style)";
        style = "fg:red bold";
      };

      git_status = {
        format = "[ $all_status$ahead_behind]($style)";
        style = "fg:yellow";
        # Submodule status means recursing into every one of them.
        ignore_submodules = true;
      };

      nix_shell = {
        # No $name: devShells are named after their project, which the
        # directory segment has already told us.
        format = "[ ](fg:dim)[❄]($style)";
        style = "fg:blue";
        heuristic = false;
      };

      cmd_duration = {
        format = "[ ](fg:dim)[$duration]($style)";
        style = "fg:yellow";
        min_time = 2000;
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold blue)";
      };

      # Everything below spawns a subprocess to read a version string.
      # direnv + the project's devShell is the source of truth instead.
      aws.disabled = true;
      buf.disabled = true;
      bun.disabled = true;
      c.disabled = true;
      cmake.disabled = true;
      deno.disabled = true;
      docker_context.disabled = true;
      dotnet.disabled = true;
      elixir.disabled = true;
      elm.disabled = true;
      erlang.disabled = true;
      gcloud.disabled = true;
      golang.disabled = true;
      gradle.disabled = true;
      haskell.disabled = true;
      helm.disabled = true;
      java.disabled = true;
      julia.disabled = true;
      kotlin.disabled = true;
      kubernetes.disabled = true;
      lua.disabled = true;
      nodejs.disabled = true;
      ocaml.disabled = true;
      opa.disabled = true;
      openstack.disabled = true;
      package.disabled = true;
      perl.disabled = true;
      php.disabled = true;
      pulumi.disabled = true;
      python.disabled = true;
      rlang.disabled = true;
      ruby.disabled = true;
      rust.disabled = true;
      scala.disabled = true;
      swift.disabled = true;
      terraform.disabled = true;
      vagrant.disabled = true;
      zig.disabled = true;
    };
  };
}
