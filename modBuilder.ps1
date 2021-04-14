$include = @("*.xml", "*.lua", "*.dds", "src\vehicles\specialization\*.lua", "src\*.lua")
$zipFilename = "FS19_CrabSteeringExtention.zip"

if(test-path "$env:ProgramFiles\WinRAR\WinRAR.exe"){
    Set-Alias winrar "$env:ProgramFiles\WinRAR\WinRar.exe"
    Start-Process -wait -FilePath winrar -ArgumentList "a -afzip $zipFilename $include"

    Copy-Item .\$zipFilename $home'\Documents\my games\FarmingSimulator2019\mods\'
}