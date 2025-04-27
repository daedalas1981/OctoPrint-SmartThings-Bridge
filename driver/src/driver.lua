local cosock = require "cosock"
local socket = require "cosock.socket"
local capabilities = require "st.capabilities"
local log = require "log"
local http_server = cosock.socket.tcp()

local function create_server(port)
  local server = assert(socket.tcp())
  server:setsockname("0.0.0.0", port)
  server:settimeout(0)
  server:listen()
  return server
end

local function parse_octoprint_payload(device, payload)
  local event_type = payload.event
  local data = payload.payload

  log.info("Received OctoPrint event: " .. event_type)

  if event_type == "PrintStarted" then
    device:emit_event(capabilities.switch.switch.on())
    device:emit_event(capabilities.switchLevel.level(0))
  elseif event_type == "PrintDone" or event_type == "PrintFailed" then
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(capabilities.switchLevel.level(100))
  end

  if data then
    if data.name then
      device:emit_event(capabilities.textLabel.label("Job: " .. data.name))
    end
    if data.bed_temp then
      device:emit_event(capabilities.temperatureMeasurement.temperature({ value = data.bed_temp, unit = "C" }))
    end
    if data.tool0_temp then
      device:emit_event(capabilities.relativeHumidityMeasurement.humidity({ value = data.tool0_temp }))
    end
  end
end

local function http_server_handler(driver, device)
  local server = create_server(8080)  -- choose your port

  driver:call_on_schedule(1, function()
    local client = server:accept()
    if client then
      client:settimeout(5)
      local request = client:receive("*l")
      if request then
        log.info("HTTP request received: " .. request)
        
        repeat
          line = client:receive("*l")
        until line == ""

        local body = client:receive("*a")

        local json = require "dkjson"
        local payload, pos, err = json.decode(body, 1, nil)
        if payload then
          parse_octoprint_payload(device, payload)
        else
          log.error("JSON Decode Error: " .. (err or "unknown"))
        end

        client:send("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nOK")
      end
      client:close()
    end
  end)
end

local function device_init(driver, device)
  log.info("OctoPrint SmartThings Device Initialized")
  http_server_handler(driver, device)
end

local driver_template = {
  supported_capabilities = {
    capabilities.switch,
    capabilities.switchLevel,
    capabilities.textLabel,
    capabilities.temperatureMeasurement,
    capabilities.relativeHumidityMeasurement
  },
  lifecycle_handlers = {
    init = device_init
  }
}

local Driver = require "st.driver"
Driver("OctoPrintDriver", driver_template):run()
