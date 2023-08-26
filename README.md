# Fall 2023 WashU Computer Engineering Capstone Project
## Oscilloscope Simulation
The goal of this project was to design a 32-bit microcontroller capable of plotting a continuous stream of data in order to create a portable oscilloscope via USB connection. VHDL, Xilinx Vivado, and ExpressPCB were utilized to design the logic of the microcontroller and a PCB for the system to be mounted on. The microcontroller is capable of connecting to a host application GUI (coded in Python) to control the amplifier gain of the system and plot a continuous stream of two-channel data. The device is built using a Digilent CMOD A7 module programmed using Vivado and mounted onto a custom PCB for testing. After the system is programmed, it can be connected to the host application where it can display a real-time feed of data being plotted. The option exists for a snapshot of data to be plotted or a "free-run" mode where the plot changes in real-time to incoming data (along with the ability to pause and restart this process).

Key components of the system include: an LTC6912 (Dual Programmable Gain Amplifiers) whose gain is modified using a SPI interface and an analog-to-digital converter that converts the analog signals from the amplifiers into digital values able to be plotted.

The host application itself communicates via a Serial Port and starts by programming the device to begin plotting. This process involves sending data to the programmed device that will be converted it into a series of assembly language instructions that will tell the device to set the gain of the amplifiers and continuously sample data coming from the ADC. This incoming data is stored and visualized in the host application.

# Demo
The following demo showcases how, after being programmed in Vivado, the microcontroller is programmed in the host application and how the data is visualized.
https://github.com/PersonaUnknown/Oscilloscope_SP23/assets/69654548/5a353e72-64e9-4015-b694-bc5dd1eacc3d

