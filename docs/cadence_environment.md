# Cadence EDA Environment Setup

## Overview

This document records the required Cadence EDA environment setup for the SPI Slave ASIC FYP project.

The current flow uses:

- Genus: RTL synthesis
- Innovus: physical implementation
- Xcelium: RTL simulation
- Virtuoso: custom analog/layout design environment


Technology:

- TSMC 180nm HV BCD CMOS
- Core library: tcb018bcdgp2atc
- IO library: tps018bcdnv5tc


---

# 1. Shell Environment

The Cadence environment uses tcsh.

Check current shell:

    echo $SHELL

Expected:

    /bin/tcsh


Important:

tcsh uses setenv.

Do NOT use:

    export PATH=...

Use:

    setenv PATH ...


---

# 2. License Environment

Before running Cadence tools, configure the license server.

Example:

    setenv LM_LICENSE_FILE 27021@ls-cad1.ece.ust.hk:27021@ls-cad2.ece.ust.hk


Check:

    echo $LM_LICENSE_FILE


---

# 3. Cadence Tool Versions

## Genus

Purpose:

RTL synthesis and timing analysis.


Executable:

    /usr/eelocal/cadence/genus211/tools/bin/genus


Check:

    which genus


Version:

    genus -version


Expected:

    Genus(TM) Synthesis Solution
    Version: 21.14-s082_1



## Innovus

Purpose:

Physical design implementation.

Version:

    Innovus 21.13


## Xcelium

Purpose:

RTL simulation.

Version:

    Xcelium 23.05


## Virtuoso

Purpose:

Analog/custom layout environment.

Version:

    IC618HF


---

# 4. Running Genus

Enter synthesis directory:

    cd ~/spi-fyp/syn


Run synthesis:

    genus -no_gui -f run_full_io_pad.tcl


General format:

    genus -no_gui -f <run_script>.tcl



---

# 5. Current Synthesis Flow

The Genus synthesis script contains:

1. Library loading

2. RTL reading

3. Design elaboration

4. Clock definition

5. IO timing constraint definition

6. Synthesis optimization

7. Timing report generation

8. Area report generation



Typical reports:

    reports/
        timing_*.rpt
        area_*.rpt
        *_net_*.rpt



---

# 6. SPI Slave ASIC Configuration

Technology:

    TSMC 180nm HV BCD


Corner:

    TT / 25C / 5V


SPI configuration:

    DATA_WIDTH = 16
    Mode = 0
    MSB first


Target frequency:

    110 MHz



---

# 7. IO Pad Timing Model


## SCLK Input PAD

Signal direction:

    External FPGA
          |
          v
       SCLK PAD
          |
          v
      CORE_SCLK
          |
          v
     SPI Slave Core


SCLK is treated as a clock input.

The PAD delay is characterized using the mapped IO cell.


The internal clock is created after the PAD:

    CORE_SCLK



---

## MOSI Input PAD


Signal direction:

    External FPGA
          |
          v
       MOSI PAD
          |
          v
      MOSI_CORE
          |
          v
     SPI Slave Core


MOSI is a normal data input.

The Liberty PAD input arc:

    PAD -> C

is automatically included by Genus.


---

## MISO Output PAD


Signal direction:

    SPI Core
        |
        v
    MISO_CORE
        |
        v
     MISO PAD
        |
        v
    External FPGA


MISO is an output timing path.

The output PAD delay is included in timing analysis.



---

# 8. Verified Milestone 5A


Completed:

- Real SCLK input PAD
- Real MOSI input PAD
- Real MISO output PAD


Configuration:

    Frequency:
        110 MHz

    External load:
        MISO = 5 pF

    SCLK slew:
        1.0 ns

    MOSI slew:
        1.0 ns



Timing reports:

    timing_sclk_*.rpt
    timing_mosi_*.rpt
    timing_miso_*.rpt


Area reports:

    area_*.rpt



---

# 9. Next Milestones


Milestone 5B:

- CSB PAD integration
- Analyze asynchronous control timing
- Recovery/removal timing check


Milestone 6:

- Innovus physical implementation
- Placement
- Clock tree synthesis
- Routing
- Post-layout extraction
- Signoff timing verification


---

# Notes

SCLK, MOSI, and MISO use different timing models:

SCLK:

    Clock input
    Requires clock propagation modeling


MOSI:

    Data input
    Uses PAD input delay arc


MISO:

    Data output
    Uses PAD output delay arc


CSB:

    Asynchronous control signal
    Requires separate recovery/removal analysis
