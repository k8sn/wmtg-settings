#!/usr/bin/python2
# Rev 1.0 Sam Nabkey K8SN
# Thanks to Chris W0SIS for the examples (googletts)
import urllib, pycurl, os, sys

TextToSpeak=str(sys.argv[1])

def downloadFile(url, FileName):
    fp = open(FileName, "wb")
    curl = pycurl.Curl()
    curl.setopt(pycurl.USERAGENT, "WMTG:WX:T2S")
    curl.setopt(pycurl.FOLLOWLOCATION, 1)
    curl.setopt(pycurl.URL, url)
    curl.setopt(pycurl.WRITEDATA, fp)
    curl.perform()
    curl.close()
    fp.close()

def GetSpeechURL(words):
    SpeechURL = "http://status.wmtg.me/convert?"
    parameters = {'a': words}
    data = urllib.urlencode(parameters)
    SpeechURL = "%s%s" % (SpeechURL,data)
    return SpeechURL

def SpeakText(phrase):
    SpeechURL = GetSpeechURL(phrase)
    downloadFile(SpeechURL,"/tmp/tts/tts.wav")
   
SpeakText(TextToSpeak)
print "done..."
