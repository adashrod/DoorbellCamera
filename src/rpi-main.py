import requests
import RPi.GPIO as Gpio
import subprocess
import sys
import time

assert len(sys.argv) > 2, "Home Assistant hostname must be passed as the 1st argument, and Webhook ID must be passed as the 2nd argument"

debounceTime = 5000
ledPin = 4
buttonPin = 17
#ringtone = "src/ringtones/ClosedHiHat.mp3"
#ringtone = "src/ringtones/DrumFill.mp3"
ringtone = "src/ringtones/DingDong0sPad.mp3"
#ringtone = "src/ringtones/Silence5s.mp3"
lastRingTimestamp = 0
webhookUrl = f"http://{sys.argv[1]}/api/webhook/{sys.argv[2]}"

def onPress(channel):
    global lastRingTimestamp # makes the global variable available in this scope, preventing shadowing
    print(f"onPress last={lastRingTimestamp}")
    now = time.time() * 1000
    if now - lastRingTimestamp < debounceTime:
        print("debounced")
        return
    lastRingTimestamp = now
    Gpio.output(ledPin, Gpio.HIGH)
    # when using run(), the onPress callback fires twice, causing the ringtone to play twice
    # subprocess.run(["cvlc", ringtone, "vlc://quit"])
    subprocess.Popen(["cvlc", ringtone, "vlc://quit"])
    requests.post(webhookUrl)
    # Popen() doesn't block, so keep the LED on for 2s
    time.sleep(2.0)
    Gpio.output(ledPin, Gpio.LOW)
    print("end onPress")

# BCM uses the GPIO numbers, not the position numbers. https://i.stack.imgur.com/JtpG7.png
Gpio.setmode(Gpio.BCM)
Gpio.setwarnings(False)

Gpio.setup(ledPin, Gpio.OUT)
Gpio.setup(buttonPin, Gpio.IN, pull_up_down=Gpio.PUD_DOWN)

Gpio.add_event_detect(buttonPin, Gpio.RISING, callback=onPress)
message = input("Press Enter to quit\n")

Gpio.cleanup()
