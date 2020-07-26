#lang racket

(require "wiring-pi.rkt"
         "gpio-setup.rkt")

(provide (all-defined-out))

(define PANEL-SETTING                               #x00)
(define POWER-SETTING                               #x01)
(define POWER-OFF                                   #x02)
(define POWER-OFF-SEQUENCE-SETTING                  #x03)
(define POWER-ON                                    #x04)
(define POWER-ON-MEASURE                            #x05)
(define BOOSTER-SOFT-START                          #x06)
(define DEEP-SLEEP                                  #x07)
(define DATA-START-TRANSMISSION-1                   #x10)
(define DATA-STOP                                   #x11)
(define DISPLAY-REFRESH                             #x12)
(define IMAGE-PROCESS                               #x13)
(define LUT-FOR-VCOM                                #x20)
(define LUT-BLUE                                    #x21)
(define LUT-WHITE                                   #x22)
(define LUT-GRAY-1                                  #x23)
(define LUT-GRAY-2                                  #x24)
(define LUT-RED-0                                   #x25)
(define LUT-RED-1                                   #x26)
(define LUT-RED-2                                   #x27)
(define LUT-RED-3                                   #x28)
(define LUT-XON                                     #x29)
(define PLL-CONTROL                                 #x30)
(define TEMPERATURE-SENSOR-COMMAND                  #x40)
(define TEMPERATURE-CALIBRATION                     #x41)
(define TEMPERATURE-SENSOR-WRITE                    #x42)
(define TEMPERATURE-SENSOR-READ                     #x43)
(define VCOM-AND-DATA-INTERVAL-SETTING              #x50)
(define LOW-POWER-DETECTION                         #x51)
(define TCON-SETTING                                #x60)
(define TCON-RESOLUTION                             #x61)
(define SPI-FLASH-CONTROL                           #x65)
(define REVISION                                    #x70)
(define GET-STATUS                                  #x71)
(define AUTO-MEASUREMENT-VCOM                       #x80)
(define READ-VCOM-VALUE                             #x81)
(define VCM-DC-SETTING                              #x82)

(define (epd-init)
  (epd-reset)
  
  (epd-send-command POWER-SETTING)
  (epd-send-data #x37)
  (epd-send-data #x00)

  (epd-send-command PANEL-SETTING)
  (epd-send-data #xCF)
  (epd-send-data #x08)

  (epd-send-command BOOSTER-SOFT-START)
  (epd-send-data #xC7)
  (epd-send-data #xCC)
  (epd-send-data #x28)

  (epd-send-command POWER-ON)
  (epd-wait-until-idle)

  (epd-send-command PLL-CONTROL)
  (epd-send-data #x3C)

  (epd-send-command TEMPERATURE-CALIBRATION)
  (epd-send-data #x00)

  (epd-send-command VCOM-AND-DATA-INTERVAL-SETTING)
  (epd-send-data #x77)

  (epd-send-command TCON-SETTING)
  (epd-send-data #x22)

  (epd-send-command TCON-RESOLUTION)
  (epd-send-data (arithmetic-shift EPD-WIDTH -8))
  (epd-send-data (bitwise-and EPD-WIDTH #xFF))
  (epd-send-data (arithmetic-shift EPD-HEIGHT -8))
  (epd-send-data (bitwise-and EPD-HEIGHT #xFF))

  (epd-send-command VCM-DC-SETTING)
  (epd-send-data #x1E)

  (epd-send-command #xE5)
  (epd-send-data #x03))

(define (epd-reset)
  (digitalWrite EPD-RST-PIN 1)
  (sleep .2)
  (digitalWrite EPD-RST-PIN 0)
  (sleep .2)
  (digitalWrite EPD-RST-PIN 1)
  (sleep .2))

(define (epd-send-command reg)
  (digitalWrite EPD-DC-PIN 0)
  (digitalWrite EPD-CS-PIN 0)
  (gpio-spi-write-byte reg)
  (digitalWrite EPD-CS-PIN 1))

(define (epd-send-data data)
  (digitalWrite EPD-DC-PIN 1)
  (digitalWrite EPD-CS-PIN 0)
  (gpio-spi-write-byte data)
  (digitalWrite EPD-CS-PIN 1))

(define (epd-turn-on-display)
  (epd-send-command DISPLAY-REFRESH)
  (sleep .1)
  (epd-wait-until-idle))

(define (epd-wait-until-idle)
  (when (equal? (digitalRead EPD-BUSY-PIN) 0)
    (begin
      (sleep .1)
      (epd-wait-until-idle))))

(define (epd-clear-display)
  (let ([width (if (modulo EPD-WIDTH 8)
                   (/ EPD-WIDTH 8)
                   (+ (/ EPD-WIDTH 8) 1))]
        [height EPD-HEIGHT])
    (epd-send-command DATA-START-TRANSMISSION-1)
    (for ([i height])
      (for ([j width])
        (for ([k 4])
          (epd-send-data 51))))
    (epd-turn-on-display)))

(define (epd-display-image screen screen-byte-width epd-height)
  (epd-send-command DATA-START-TRANSMISSION-1)
  (for ([index (* epd-height screen-byte-width)])
    (let ([data (vector-ref screen index)])        
      (epd-send-data data)))
  (epd-send-command DISPLAY-REFRESH)
  (sleep .1)
  (epd-wait-until-idle))






   

