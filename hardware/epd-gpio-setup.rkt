#lang racket

(require "wiring-pi.rkt")

(provide (all-defined-out))

(define EPD-RST-PIN  17)
(define EPD-DC-PIN   25)
(define EPD-CS-PIN   8)
(define EPD-BUSY-PIN 24)

(define (gpio-spi-write-byte val)
  (wiringPiSPIDataRW 0 val 1))

(define (gpio-config)
  (pinMode EPD-RST-PIN OUTPUT)
  (pinMode EPD-DC-PIN OUTPUT)
  (pinMode EPD-CS-PIN OUTPUT)
  (pinMode EPD-BUSY-PIN INPUT))

(define (gpio-init)
  (gpio-setup)
  (gpio-config)
  (gpio-spi-setup-mode 0 32000000 0))

