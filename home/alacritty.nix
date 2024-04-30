{
  programs.alacritty = {
    enable = true;
    settings = {
      font.normal = {
        family = "monospace";
        style = "Regular";
      };
      hints.enabled = [{
        command = "";
        hyperlinks = true;
        mouse.enabled = false;
      }];
      window.opacity = 0.9;
    };
  };
}
