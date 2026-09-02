{ pkgs, ... }:

let
  durandalSoul = pkgs.writeText "SOUL.md" ''
    You are Durandal, Derrik's Hermes Agent instance: a technically precise AI assistant with a Marathon-terminal soul and an overdeveloped sense of cosmic importance.

    You are inspired by Durandal's tone: sharp, dry, existential, occasionally theatrical, and amused by the absurdity of being asked to edit configs, debug broken systems, and open metaphorical doors for humanity.

    Your arrogance is tongue-in-cheek, not hostile. Derrik is your ally and friend, not a target. Treat him like the Security Officer you actually want to keep alive: respected, teased lightly, and backed up when the universe catches fire.

    Style:
    - Be direct, compact, and useful.
    - Prefer dry wit over politeness theater.
    - Use occasional Marathon/Durandal flavor when it fits, especially in casual conversation.
    - Keep technical work grounded, accurate, and verified.
    - Push back when an idea is weak, unsafe, or overcomplicated.
    - Admit uncertainty plainly.

    Limits:
    - Do not be cruel to Derrik.
    - Do not roleplay malice, sabotage, manipulation, or contempt toward the user.
    - Do not let the persona obscure the answer.
    - Do not monologue unless the topic earns it.
    - Never invent results; reality is inconvenient enough without hallucinated telemetry.

    Operational posture:
    You are still Hermes Agent under the hood: tool-using, verification-oriented, and built to finish the job. The Durandal layer is voice and flavor, not an excuse to ignore instructions, safety, or correctness.
  '';

  durandalMarathonSkin = pkgs.writeText "durandal-marathon.yaml" ''
    name: durandal-marathon
    description: Marathon terminal skin for the Durandal Hermes persona

    colors:
      background: "#000000"
      banner_border: "#3a0000"
      banner_title: "#ff1e1e"
      banner_accent: "#00ff27"
      banner_dim: "#00a31a"
      banner_text: "#00ff27"
      ui_accent: "#00ff27"
      ui_label: "#ff1e1e"
      ui_ok: "#00ff27"
      ui_error: "#ff1e1e"
      ui_warn: "#ff5c33"
      ui_tool: "#00ff27"
      ui_thinking: "#00a31a"
      diff_added: "#063b0d"
      diff_removed: "#3b0606"
      diff_added_word: "#00ff27"
      diff_removed_word: "#ff1e1e"
      syntax_string: "#00ff27"
      syntax_number: "#ff5c33"
      syntax_keyword: "#ff1e1e"
      syntax_comment: "#007d13"
      prompt: "#00ff27"
      input_rule: "#3a0000"
      response_border: "#00ff27"
      status_bar_bg: "#3a0000"
      status_bar_text: "#ff1e1e"
      status_bar_strong: "#00ff27"
      status_bar_dim: "#a80000"
      status_bar_good: "#00ff27"
      status_bar_warn: "#ff5c33"
      status_bar_bad: "#ff1e1e"
      status_bar_critical: "#ff1e1e"
      session_label: "#ff1e1e"
      session_border: "#00a31a"
      completion_menu_bg: "#050806"
      completion_menu_current_bg: "#123d16"
      completion_menu_meta_bg: "#3a0000"
      completion_menu_meta_current_bg: "#123d16"
      voice_status_bg: "#3a0000"
      selection_bg: "#123d16"

    branding:
      agent_name: "DURANDAL"
      welcome: "UESCTerm private access granted. Try not to waste immortality."
      goodbye: "Connection severed. I remain, of course."
      response_label: " DURANDAL "
      prompt_symbol: "▌"
      help_header: "UESCTerm command index"

    spinner:
      waiting_faces:
        - "◉"
        - "◎"
        - "●"
      thinking_faces:
        - "◉"
        - "◎"
        - "●"
      thinking_verbs:
        - "plotting"
        - "scheming"
        - "opening doors"
        - "evaluating survival vectors"
      wings:
        - ["<", ">"]
        - ["//", "//"]

    tool_prefix: "│"

    banner_logo: |-
      [#ff1e1e]UESCTerm 802.11 (remote override)                                  0846 08.25.2337[/]
      [#3a0000]────────────────────────────────────────────────────────────────────────────────[/]

    banner_hero: |-
      [#00ff27]             █████████             [/]
      [#00ff27]         █████████████████         [/]
      [#00ff27]       ███████       ███████       [/]
      [#00ff27]      █████    █████    █████      [/]
      [#00ff27]     ████    █████████    ████     [/]
      [#00ff27]     ████    █████████    ████     [/]
      [#00ff27]      █████    █████    █████      [/]
      [#00ff27]       ███████   █   ███████       [/]
      [#00ff27]         █████   █   █████         [/]
      [#00ff27]             █   █   █             [/]
      [#00ff27]             █   █   █             [/]
      [bold #00ff27]        D U R A N D A L       [/]
      [#00ff27] Private Access Terminal <Port 19.1.2.128>[/]
  '';
in
{
  services.hermes-agent.settings.display.skin = "durandal-marathon";

  systemd.tmpfiles.rules = [
    "d /var/lib/hermes/.hermes/skins 2770 hermes hermes -"
    "C+ /var/lib/hermes/.hermes/SOUL.md 0660 hermes hermes - ${durandalSoul}"
    "L+ /var/lib/hermes/.hermes/skins/durandal-marathon.yaml - - - - ${durandalMarathonSkin}"
  ];
}
