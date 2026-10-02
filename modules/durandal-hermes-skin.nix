{ ... }:

{
  # The persona assets and setup command now live in nix_ai_setup.
  # Keep Durandal as the default skin for normal Hermes sessions.
  services.hermes-agent.settings.display.skin = "durandal-marathon";
}
