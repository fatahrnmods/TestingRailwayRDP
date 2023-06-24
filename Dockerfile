FROM mcr.microsoft.com/windows/servercore:ltsc2019
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install Chocolatey package manager
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install xrdp and xfce desktop environment
RUN choco install -y xrdp xfce --version=4.14.3.0

# Install ngrok
RUN choco install -y ngrok

# Set ngrok auth token
ARG NGROK_AUTH_TOKEN
RUN ngrok authtoken $env:2JaiAWKOJhh7FRWIdIGWWEhEl3O_6PHCFHKnMfuZUsJd2NZp5

# Set RDP username and password
RUN reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UsernameHint /d "kinokino" /f
RUN reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f
RUN net user kinokino kinosan /add
RUN net localgroup "Remote Desktop Users" kinokino /add

# Expose RDP and ngrok ports
EXPOSE 3389
EXPOSE 4040

# Start ngrok and xrdp on container startup
CMD ["cmd.exe", "/C", "start", "/B", "ngrok", "tcp", "3389", "--region=jp", "--log=stdout", "&&", "start", "/B", "xrdp"]
