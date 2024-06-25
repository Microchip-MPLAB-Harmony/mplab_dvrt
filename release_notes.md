![Microchip logo](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_logo.png)
![Harmony logo small](https://raw.githubusercontent.com/wiki/Microchip-MPLAB-Harmony/Microchip-MPLAB-Harmony.github.io/images/microchip_mplab_harmony_logo_small.png)

# Microchip MPLAB® Harmony 3 Release Notes

## MPLAB-DVRT Release v3.0.0

### New features
Added DVRT support for MCUs and MPU devices.

### Device Support
The following table provides information on DVRT support for MCUs and MPUs.

    | Product Family      | TC_u2212  |  TC_u2249  | TC_6082  |  TC_44162  |  TMR_02815  |  TMR1_02141 |   TMR_00745  |  TMR1_00687  |  Systick  |  Coretimer  |
    | --------------------| --------- | ---------- |--------- | ---------- | ----------- | ----------- |  ----------- | ------------ | --------- | ----------- |
    | SAM C20/C21         |           |    Yes     |          |            |             |             |              |              |    Yes    |             |
    | SAM D10             |   Yes     |            |          |            |             |             |              |              |    Yes    |             |
    | SAM D11             |   Yes     |            |          |            |             |             |              |              |    Yes    |             |
    | SAM D20             |   Yes     |            |          |            |             |             |              |              |    Yes    |             |
    | SAM HA1             |   Yes     |            |          |            |             |             |              |              |    Yes    |             |
    | SAM L21             |           |    Yes     |          |            |             |             |              |              |    Yes    |             |
    | SAM L22             |           |    Yes     |          |            |             |             |              |              |    Yes    |             |
    | SAM D21 DA1         |           |            |          |            |             |     Yes     |              |              |    Yes    |             |
    | PIC32CM MC00        |           |    Yes     |          |            |             |             |              |              |    Yes    |             |
    | PIC32CM JH00/01     |           |    Yes     |          |            |             |             |              |              |    Yes    |             |
    | SAM L10/L11         |           |    Yes     |          |            |             |             |              |              |    Yes    |             |
    | PIC32CM LE/LS       |           |    Yes     |          |            |             |             |              |              |    Yes    |             |
    | PIC32 CK GC/SG      |           |            |          |            |             |             |              |              |    Yes    |             |
    | CEC173X             |           |            |          |            |             |             |              |              |    Yes    |             |
    | SAM G55             |           |            |   Yes    |            |             |             |              |              |    Yes    |             |
    | PIC32CX SG41        |           |    Yes     |          |            |             |             |              |              |    Yes    |             |
    | SAM D5X/E5X         |           |    Yes     |          |            |             |             |              |              |    Yes    |             |
    | PIC32CX MT          |           |            |          |    Yes     |             |             |              |              |    Yes    |             |
    | PIC32CX BZ3         |           |            |   Yes    |            |             |             |              |              |    Yes    |             |
    | PIC32CX BZ2         |           |            |   Yes    |            |             |             |              |              |    Yes    |             |
    | PIC32CZ-CA          |           |            |          |            |             |             |              |              |    Yes    |             |
    | SAM E7X/V7X/S7X     |           |            |   Yes    |            |             |             |              |              |    Yes    |             |
    | SAM RH71            |           |            |   Yes    |            |             |             |              |              |    Yes    |             |
    | SAM RH707           |           |            |   Yes    |            |             |             |              |              |    Yes    |             |
    | SAM 9X7             |           |            |          |    Yes     |             |             |              |              |    Yes    |             |
    | SAM 9X6             |           |            |          |    Yes     |             |             |              |              |    Yes    |             |
    | SAM A5D2            |           |            |   Yes    |            |             |             |              |              |    Yes    |             |
    | SAM A7G5            |           |            |          |    Yes     |             |             |              |              |    Yes    |             |
    | PIC32MZ DA          |           |            |          |            |             |     Yes     |     Yes      |              |           |     Yes     |
    | PIC32MZ EF          |           |            |          |            |             |             |     Yes      |     Yes      |           |     Yes     |
    | PIC32MZ-W1          |           |            |          |            |             |     Yes     |     Yes      |              |           |     Yes     |
    | PIC32MK             |           |            |          |            |     Yes     |     Yes     |              |              |           |     Yes     |
    | PIC32MM             |           |            |          |            |             |             |     Yes      |              |           |     Yes     |
    | PIC32MX             |           |            |          |            |             |     Yes     |     Yes      |     Yes      |           |     Yes     |

### Known Issues

The current known issues are as follows:

-   None


### Development Tools

- [MPLAB® X IDE v6.20](https://www.microchip.com/mplab/mplab-x-ide)
- MPLAB® X IDE plug-ins:
  - MPLAB® Code Configurator (MCC) v5.5.1
- [MPLAB® XC32 C/C++ Compiler v4.40](https://www.microchip.com/mplab/compilers)

