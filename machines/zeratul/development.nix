{
  services.udev.extraRules = ''
    # Intel FPGA Download Cable
    SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6002", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6003", MODE="0666"

    # Intel FPGA Download Cable II
    SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6010", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6810", MODE="0666"

    # ACS ACR1252U NFC Card Reader
    SUBSYSTEM=="usb", ATTR{idVendor}=="072f", ATTR{idProduct}=="223b", MODE="0666"
  '';
}
