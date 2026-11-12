<#
.SYNOPSIS
    Windows Personalization Customizer (Bypasses unactivated UI limits)
#>

Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "       Windows Personalization Customizer         " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Apply Dark Mode
$choiceDark = Read-Host "Do you want to enable Dark Mode? (Y/N)"
if ($choiceDark -eq 'Y' -or $choiceDark -eq 'y') {
    $ThemePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Set-ItemProperty -Path $ThemePath -Name "AppsUseLightTheme" -Value 0 -Type DWord
    Set-ItemProperty -Path $ThemePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord
    Write-Host "[SUCCESS] Dark Mode enabled for system and apps." -ForegroundColor Green
}
Write-Host ""

# 2. Taskbar Alignment (Windows 11)
$choiceTaskbar = Read-Host "Do you want to align Taskbar icons to the Left? (Y/N)"
if ($choiceTaskbar -eq 'Y' -or $choiceTaskbar -eq 'y') {
    $AdvPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $AdvPath -Name "TaskbarAl" -Value 0 -Type DWord
    Write-Host "[SUCCESS] Taskbar icons aligned to the left." -ForegroundColor Green
}
Write-Host ""

# 3. Custom Wallpaper Path
$wallpaperPath = Read-Host "Enter full path to a JPG/PNG image for wallpaper (or press Enter to skip)"
if (-not [string]::IsNullOrWhiteSpace($wallpaperPath)) {
    # Clean up any accidental quotes in the path
    $wallpaperPath = $wallpaperPath.Trim('"').Trim("'")
    
    if (Test-Path $wallpaperPath) {
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $wallpaperPath
        
        # Inject C# Win32 API call to immediately refresh wallpaper
        Add-Type -TypeDefinition @"
        using System.Runtime.InteropServices;
        public class WallpaperHelper {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
        }
        "@
        [WallpaperHelper]::SystemParametersInfo(20, 0, $wallpaperPath, 3)
        Write-Host "[SUCCESS] Wallpaper applied successfully." -ForegroundColor Green
    } else {
        Write-Host "[WARNING] File not found at path: $wallpaperPath. Wallpaper skipped." -ForegroundColor Yellow
    }
}
Write-Host ""

# 4. Restart Explorer to apply UI changes
Write-Host "Refreshing Windows Explorer to apply all changes..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " All tasks complete! You can close this window.   " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Start-Sleep -Seconds 3
