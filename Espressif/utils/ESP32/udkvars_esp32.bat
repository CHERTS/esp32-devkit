@echo Setting environment for using Unofficial Development Kit for Espressif ESP32 tools.

@set mingw_dir=C:\MinGW
@set devkit_dir=C:\Espressif
@set PATH=%devkit_dir%\xtensa-esp108-elf\bin;%devkit_dir%\utils\ESP32;%mingw_dir%\bin;%mingw_dir%\msys\1.0\bin;%PATH%
@cd %devkit_dir%\examples\ESP32
