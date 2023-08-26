import tkinter as tk
from tkinter import messagebox
import serial
import matplotlib.backends.backend_tkagg as tkagg
import matplotlib.pyplot as plt 
from matplotlib.figure import Figure
import threading
import numpy as np

# --- Helper Functions -------------------------------------------
def scopeHelper(integer): # Based on slider value, return appropriate value (to later be written to UART)
    if integer == 0:
        return b'\x00'
    elif integer == 1:
        return b'\x11'
    elif integer == 2:
        return b'\x22'
    elif integer == 3:
        return b'\x33'
    elif integer == 4:
        return b'\x44'
    elif integer == 5:
        return b'\x55'
    elif integer == 6:
        return b'\x66'
    elif integer == 7:
        return b'\x77'
    elif integer == 8:
        return b'\x88'
    elif integer == 9:
        return b'\x99'
    elif integer == 10:
        return b'\xAA'
    elif integer == 11:
        return b'\xBB'
    elif integer == 12:
        return b'\xCC'
    elif integer == 13:
        return b'\xDD'
    elif integer == 14:
        return b'\xEE'
    else:
        return b'\xFF'

def partitionBytes(inputBytes): # Takes in string of 32 bytes in hex (length 8) and creates byte array
    length = len(inputBytes)
    output = []

    # Accepts a string of length 8
    if length is not 8:
        return "Error"
    
    stop = False
    index = 0
    while not stop:
        byte = inputBytes[index] + inputBytes[index + 1]
        output.append(bytes.fromhex(byte))
        index = index + 2
        stop = index == length
    
    return output

def createAppButton(root, text, command): # To help easily create button object
       return tk.Button(root, text = text, font = ('Times New Roman', 16), background = '#5286e7', activebackground='#4470c1', command = command)

# --- GUI Start -------------------------------------------
root = tk.Tk()
root.title("Test App")
root.geometry("1280x720")
root.resizable(0, 0)
root.configure(background='#394994')

# --- Turn on LED -------------------------------------------
def turnOnLED():
    # Turn On
    try:
        ser = serial.Serial('COM' + comPortText.get(1.0, "end-1c"), baudrate=115200)  
        
        ser.write(b'W')
        for byte in partitionBytes("fffffff0") + partitionBytes("00000001"):
            ser.write(byte)

        ser.write(b'W')
        for byte in partitionBytes("fffffff4") + partitionBytes("00000001"):
            ser.write(byte)
        
        ser.close()
    except:
        messagebox.showerror(title="Failed Connection", message="Please try again.")

# --- Turn Off LED -------------------------------------------
def turnOffLED():
    try:
        ser = serial.Serial('COM' + comPortText.get(1.0, "end-1c"), baudrate=115200)  

        ser.write(b'W')
        for byte in partitionBytes("fffffff0") + partitionBytes("00000001"):
            ser.write(byte)

        ser.write(b'W')
        for byte in partitionBytes("fffffff4") + partitionBytes("00000000"):
            ser.write(byte)
        
        ser.close()
    except:
        messagebox.showerror(title="Failed Connection", message="Please try again.")

turnOnBtn = createAppButton(root, text = "Turn On LED", command = turnOnLED)
turnOnBtn.place(x = 0, y = 0, width = 200, height = 50)

turnOffBtn = createAppButton(root, text = "Turn Off LED", command = turnOffLED)
turnOffBtn.place(x = 0, y = 50, width = 200, height = 50)

comPortLabel = tk.Label(root, text = "COM PORT", font = ("Times New Roman", 14), background = "#5286e7")
comPortLabel.place(x = 450, y = 0, width = 200, height = 50)
comPortText = tk.Text(root)
comPortText.place(x = 450, y = 50, width = 200, height = 25)

# --- Poke Data -------------------------------------------------------
def pokeData():
    address = pokeAddressInput.get(1.0, "end-1c")
    data = pokeDataInput.get(1.0, "end-1c")

    if len(address) is not 8 or len(data) is not 8:
        return

    try:
        ser = serial.Serial('COM' + comPortText.get(1.0, "end-1c"), baudrate=115200)  
        
        ser.write(b'W')
        for byte in partitionBytes(address):
            ser.write(byte)

        for byte in partitionBytes(data):
            ser.write(byte)

        ser.close()
    except:
        messagebox.showerror(title="Failed Connection", message="Please try again.")

pokeBtn = createAppButton(root, text = "Poke", command = pokeData)
pokeBtn.place(x = 0, y = 100, width = 200, height = 50)
pokeAddressLabel = tk.Label(root, text = "Address:", font = ("Times New Roman", 14))
pokeAddressLabel.place(x = 200, y = 100, width = 75, height = 25)
pokeAddressInput = tk.Text(root)
pokeAddressInput.place(x = 275, y = 100, width = 100, height = 25)
pokeDataLabel = tk.Label(root, text = "Data:", font = ("Times New Roman", 14))
pokeDataLabel.place(x = 200, y = 125, width = 75, height = 25)
pokeDataInput = tk.Text(root)
pokeDataInput.place(x = 275, y = 125, width = 100, height = 25)

# --- Peek Data -------------------------------------------------------------------
def peekData():
    address = peekAddressInput.get(1.0, "end-1c")

    if len(address) is not 8:
        return

    try:
        ser = serial.Serial('COM' + comPortText.get(1.0, "end-1c"), baudrate=115200)  
        
        ser.write(b'R')
        for byte in partitionBytes(address):
            ser.write(byte)

        line = ser.read(4)
        print(line)
        print('{:032b}'.format(int.from_bytes(line, byteorder='big')))
        ser.close()
    except:
        messagebox.showerror(title="Failed Connection", message="Please try again.")
peekBtn = createAppButton(root, text = "Peek", command = peekData)
peekBtn.place(x = 0, y = 150, width = 200, height = 50)
peekAddressLabel = tk.Label(root, text = "Address:", font = ("Times New Roman", 14))
peekAddressLabel.place(x = 200, y = 162.5, width = 75, height = 25)
peekAddressInput = tk.Text(root)
peekAddressInput.place(x = 275, y = 162.5, width = 100, height = 25)

# --- Test Version Number ----------------------------------------------------------------
def getVersionNumber():
    try:
        ser = serial.Serial('COM' + comPortText.get(1.0, "end-1c"), baudrate=115200)  
        ser.write(b'V')
        version = ser.read(1).decode('ascii')
        messagebox.showinfo(title = "Version", message = "RichArduino v" + version)
        ser.close()
    except:
        messagebox.showerror(title = "Failed Connection", message="Please try again.")
versionBtn = createAppButton(root, text = "Version Number", command = getVersionNumber)
versionBtn.place(x = 0, y = 540, width = 200, height = 100)

# --- Programming Loopback (HW 2) ------------------------------------------------------
def programLoopback():
    firmware_contents = open("loopback.bin")
    lines = []
    line = firmware_contents.readline()
    while line is not "":
        if line.__contains__("\t"):
            if line.__contains__("\n"):
                lines.append(line[line.index("\t") + 1 : len(line) - 1])
            else :
                lines.append(line[line.index("\t") + 1 : len(line)])
        line = firmware_contents.readline()

    # Calculate length in bytes
    numBytes = len(lines) * 4
    lengthBytes = numBytes.to_bytes(4, byteorder = 'big')
    
    binData = []
    for line in lines:
        partition = partitionBytes(line)
        if partition is not 'Error':
            binData.append(partition)
    try:
        ser = serial.Serial('COM' + comPortText.get(1.0, "end-1c"), baudrate=115200)  
        ser.write(b'P')
        ser.write(lengthBytes)
        for data in binData:
            for byteData in data:
                ser.write(byteData)

        ser.close()
        print("Program installed successfully.")
    except:
        messagebox.showerror(title = "Failed Connection", message="Please try again.")

programLoopbackBtn = createAppButton(root, text = "Program Loopback", command = programLoopback)
programLoopbackBtn.place(x = 0, y = 200, width = 300, height = 50)

# --- Test Loopback -----------------------------------------------------------------
def loopback():
    input = loopbackInput.get(1.0, "end-1c")
    if input == '':
        return
    try:
        ser = serial.Serial('COM' + comPortText.get(1.0, "end-1c"), baudrate=115200, timeout = 0.5)  
        output = ''
        for char in input:
            charConverted = bytes(char, 'utf-8')
            ser.write(charConverted)
            newString = ser.read(1).decode()
            output += newString
        print(output)
        ser.close()
    except:
        messagebox.showerror(title = "Failed Connection", message="Please try again.")

def callLoopback():
    threading.Thread(target = loopback).start()

loopbackBtn = createAppButton(root, text = "Test Loopback", command = callLoopback)
loopbackBtn.place(x = 0, y = 250, width = 300, height = 50)
loopbackInput = tk.Text(root)
loopbackInput.place(x = 300, y = 250, width = 125, height = 50)

# --- Program to infinitely read 512 Samples -------------------------------------------
def programScope():
    firmware_contents = open("sample.bin")
    lines = []
    line = firmware_contents.readline()
    while line is not "":
        if line.__contains__("\t"):
            if line.__contains__("\n"):
                lines.append(line[line.index("\t") + 1 : len(line) - 1])
            else :
                lines.append(line[line.index("\t") + 1 : len(line)])
        line = firmware_contents.readline()

    # Calculate length in bytes
    numBytes = len(lines) * 4
    lengthBytes = numBytes.to_bytes(4, byteorder = 'big')
    
    binData = []
    for line in lines:
        partition = partitionBytes(line)
        if partition is not 'Error':
            binData.append(partition)
    try:
        ser = serial.Serial('COM' + comPortText.get(1.0, "end-1c"), baudrate=115200)  
        ser.write(b'P')
        ser.write(lengthBytes)
        for data in binData:
            for byteData in data:
                ser.write(byteData)

        ser.close()
        print("Program installed successfully.")
    except:
        messagebox.showerror(title = "Failed Connection", message = "Please try again.")    

# --- Test reading 512 Samples (Once) -------------------------------------------------------------
def scope():
    try:
        ser = serial.Serial('COM' + comPortText.get(1.0, "end-1c"), baudrate=115200, timeout = 0.1)  
        ser.write(scopeHelper(gainScale.get()))
        channelFourData.clear()
        channelTwelveData.clear()
        for i in range(512):
            channelFourData.append(int.from_bytes(ser.read(), byteorder = "big"))
            channelTwelveData.append(int.from_bytes(ser.read(), byteorder = "big"))
        ser.close()
    except:
        messagebox.showerror(title = "Failed Connection", message="Please try again.")

def callScope():
    threading.Thread(target = scope).start()

gainScale = tk.Scale(root, from_ = 2, to = 8, orient = "horizontal")
gainScale.place(x = 300, y = 350)

programScopeBtn = createAppButton(root, text = "Program Sampler", command = programScope)
programScopeBtn.place(x = 0 , y = 300, width = 300, height = 50)
scopeBtn = createAppButton(root, text = "Test Scope", command = scope)
scopeBtn.place(x = 0, y = 350, width = 300, height = 50)

# --- Print out data (Assuming you have fetched a sample of 512 ONLY ONCE) -------------------
def printData():
    if len(channelFourData) != 512 or len(channelTwelveData) != 512:
        return
    for i in range(512):
        print(channelFourData[i], channelTwelveData[i])

def callPrintData():
    threading.Thread(target = printData).start()

# --- Plot out data (Assuming you have fetched a sample of 512 ONLY ONCE) --------------------
def plotData():
    if len(channelFourData) != 512 or len(channelTwelveData) != 512:
        return
    
    plt.title(label = 'XADC Channels 4 and 12')
    plt.plot(np.arange(0, 512), channelFourData)
    plt.plot(np.arange(0, 512), channelTwelveData)
    plt.legend(['Channel 4', 'Channel 12'])
    plt.show()

showCapturedDataBtn = createAppButton(root, text = "Console Print Data", command = callPrintData)
showCapturedDataBtn.place(x = 0 , y = 400, width = 300, height = 50)

plotCapturedDataBtn = createAppButton(root, text = "Plot Once", command = plotData)
plotCapturedDataBtn.place(x = 0, y = 450, width = 300, height = 50)

channelFourData = []
channelTwelveData = []

# --- Test fetching 512 Samples repeatedly and plotting it (Free Run Mode-esque)
fig = Figure()
ax = fig.add_subplot(111)
ax.set_title('XADC Channels 4 and 12')
ax.set_xlim(0, 512)
ax.set_ylim(0, 255)
lines = ax.plot([], [])[0]
lines2 = ax.plot([], [])[0]
fig.legend(['Channel 4', 'Channel 12'])

canvas = tkagg.FigureCanvasTkAgg(fig, master = root)
canvas.get_tk_widget().place(x = 450, y = 100, width = 800, height = 550)
canvas.draw()

toolbar = tkagg.NavigationToolbar2Tk(canvas, root, pack_toolbar = False)
toolbar.update()
toolbar.place(x= 450, y = 650, width = 250, height = 40)

ch4Data = []
ch12Data = []
continueFetchingSamples = False

def finalTestScope():
    global continueFetchingSamples, ch4Data, ch12Data
    if continueFetchingSamples:
        try:
            ser = serial.Serial('COM' + comPortText.get(1.0, "end-1c"), baudrate=115200, timeout = 0.1)  
            ser.write(scopeHelper(gainScale.get()))

            for i in range(512):
                if len(ch4Data) < 512:
                    ch4Data.append(int.from_bytes(ser.read(), byteorder = "big"))
                    ch12Data.append(int.from_bytes(ser.read(), byteorder = "big"))
                else:
                    ch4Data[i] = int.from_bytes(ser.read(), byteorder = "big")
                    ch12Data[i] = int.from_bytes(ser.read(), byteorder = "big")
            lines.set_xdata(np.arange(0, len(ch4Data)))
            lines.set_ydata(ch4Data)
            lines2.set_xdata(np.arange(0, len(ch12Data)))
            lines2.set_ydata(ch12Data)
            canvas.draw()
            ser.close()
        except:
            print("Failed")

    root.after(2, finalTestScope)

def callFinalTestScope():
    threading.Thread(target = finalTestScope).start()

def start():
    global continueFetchingSamples
    continueFetchingSamples = True

def stop():
    global continueFetchingSamples
    continueFetchingSamples = False

writeAndPlotDataBtn = createAppButton(root, text = "Free Run Start", command = start)
writeAndPlotDataBtn.place(x = 0 , y = 500, width = 200, height = 50)
stopFetchingBtn = createAppButton(root, text = "Free Run Stop", command = stop)
stopFetchingBtn.place(x = 200, y = 500, width = 200, height = 50)

# root.after(1, callFinalTestScope)
callFinalTestScope()
root.mainloop()