---
layout: single
classes: wide
title:  "Installed processing.py on raspberry pi 4 in headless mode"
date:   2020-04-04 10:44:36 +1100
categories: raspberry_pi
excerpt: "...why would anyone want to do that anyway?"
header:
  overlay_image: /assets/images/pi_lego.jpg
  overlay_filter: 0.5
  caption: "Photo credit: Image by planet_fox from Pixabay"
---

Okay! So I bought a Rasberry Pi 4 to work on on a video project, and I couldn't find an up-to-date guide on how to get [Processing.py](https://py.processing.org) to run in headless mode on the Rasberry Pi. So here we are!

Why would anyone want to do this? Well, I have ideas on generating real-time video, and I'm too lazy to do maths to do it properly, so why not run a huge bloated java application to do it for me? Yeah!

Okay, so I assume you have a Rasberry Pi 4. This [guide actually works](https://github.com/processing/processing/wiki/Running-without-a-Display) to get you started, even thought it says it doesn't.

Here's a list of things we need to do:
* Install a fake x server to pretend we have a window
* Install the right version of java we need
* Install Processing and Processing.py

We're going to install `xvfb` which stands for X video frame buffer. Processing needs a window to output, but we don't have a window, so we can create a fake one.

```bash
sudo apt install xvfb libxrender1 libxtst6 libxi6 
```

Now we've got that, let's make a file called `/home/pi/bin/autostart`:

```bash
sudo Xvfb :1 -screen 0 1024x768x24 </dev/null &
export DISPLAY=":1"
```
Make it executable:
```bash
pi@raspberrypi:~/bin $ chmod +x autostart
```

Then change `/etc/rc.local` to run that script on startup:

```bash
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP"
fi
/home/pi/bin/autostart

exit 0
```

Okay okay okay, we've got our bloody window starting up each time. Noice.

Here's where things change from the instuctions above though, DO NOT install java through the command line. We need to download the *specific* java version that processing.py uses. 

We need version [8u202](https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html), specifically this version: `jdk-8u202-linux-arm32-vfp-hflt.tar.gz`

I needed to make an account just to download it, fuck you Oracle. 🖕

I downloaded it on Windows, yes my work computer is Windows, and powershell is not terrible. Sometimes. Copy to the pi:

```bash
> scp jdk-8u202-linux-arm32-vfp-hflt.tar.gz pi@raspberrypi.local:/home/pi
```

... and on the Pi

```bash
pi@raspberrypi:~ $ tar -xvzf jdk-8u202-linux-arm32-vfp-hflt.tar.gz
pi@raspberrypi:~ $ sudo cp -r jdk1.8.0_202/ /usr/local/
```

Then add this line to you `~/.bashrc` file:
```bash
export PATH=/usr/local/jdk1.8.0_202/bin:$PATH"
```
Adding it to the front of `PATH` means it'll take precedence over the 50 other java versions you have installed. Let's test that shit works:
```bash
pi@raspberrypi:~ $ source .bashrc
pi@raspberrypi:~ $ java -version
java version "1.8.0_202"
Java(TM) SE Runtime Environment (build 1.8.0_202-b08)
Java HotSpot(TM) Client VM (build 25.202-b08, mixed mode)
```

Wooo!

Okay okay okay, now where were we, oh yeah, getting the bloody thing to work. So far we have the fake window manager running, and the correct version of java installed.

Next we need to download processing and processing.py. To get processing, [their website](https://pi.processing.org/download/) tells us how to install it.

```bash
pi@raspberrypi:~ $ curl https://processing.org/download/install-arm.sh | sudo sh
```

To get processing.py, their website has a [command line page](https://py.processing.org/tutorials/command-line/) which is quite helpful.

The thing we need to get is the Linux 32 bit standalone verion.

```bash
pi@raspberrypi:~ $ wget http://py.processing.org/processing.py-linux32.tgz
pi@raspberrypi:~ $ tar -xzvf processing.py-linux32.tgz
```

The file we want is the file `processing-py.jar` located in the directory `processing.py/processing.py-<version>-linux32/`

To test it, let's my a dumb script that just prints numbers
```python
def setup():
    size(150, 84)
    print("It's running!")

x = 0
y = 0
def draw():
    global x,y
    background(255)
    fill(0)
    ellipse(x, y, 20, 20)
    x += 1
    x %= width
    y += 1
    y %= height
```

```bash
pi@raspberrypi:~/processing.py/processing.py-3017-linux32 $ java -jar processing-py.jar test_file.py
It's running!
```
  
🎉🎉🎉

Now, there's no real point to generating real-time video if we can't pass variables to it. Not sure how to do that... Did I just waste all that time? Lol. That's for the next installment!