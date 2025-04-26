# OctoPrint-SmartThings-Bridge

![Version](https://img.shields.io/badge/version-0.1.0-blue)

A simple SmartThings Edge Driver + OctoPrint Webhook bridge to monitor 3D printing directly from your SmartThings app!

## Features
- Print Status (Printing = On, Done = Off)
- Print Progress (0%-100%)
- Bed Temperature (°C)
- Nozzle Temperature (°C)
- Print Job Name Display

## Requirements
- OctoPrint Server (latest version recommended)
- OctoPrint Webhook Plugin (installed via Plugin Manager)
- Samsung SmartThings Hub (V2/V3/Aeotec)
- SmartThings Developer CLI installed

## OctoPrint Setup
1. Install the Webhook Plugin via Plugin Manager.
2. Create a webhook:
   - Method: POST
   - Content-Type: `application/json`
   - URL: `http://<Your_Hub_Local_IP>:8080/octoprint`

## SmartThings Setup
1. Install the driver:
   ```bash
   smartthings edge:drivers:package driver/
