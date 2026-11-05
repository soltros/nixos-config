{ lib
, stdenvNoCC
}:

stdenvNoCC.mkDerivation {
  pname = "plasma-chatgpt-widget";
  version = "1.0.0";

  src = ./.;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/plasmoids/org.kde.plasma.chatgpt
    cp -r metadata.json contents $out/share/plasma/plasmoids/org.kde.plasma.chatgpt/

    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp contents/icons/chatgpt.svg $out/share/icons/hicolor/scalable/apps/chatgpt.svg

    runHook postInstall
  '';

  meta = with lib; {
    description = "ChatGPT Plasma 6 taskbar widget with native theme styling and persistent login";
    homepage = "https://chatgpt.com";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
