# Impedance frequency-response measurement

This repository contains MATLAB scripts for measuring the internal impedance of power-electronic converters and batteries.

## Prerequisites

- MATLAB R2021b

## Usage

- Open MATLAB and cd to the top directory of this repository
- Run "init_workspace"
- Check that all devices in the measurement setup is ready
- Run the measurement script by typing in MATLAB command window the script name found in measurement/ subdirectory. The measurement script is a MATLAB function where the first parameter is the excitation signal specification file and the second parameter is the measurement raw data file to be saved to the local storage.
- Run the analysis script to plot the calculated impedance from raw measurement data by typing in MATLAB command window the script name found in analysis/ subdirectory.

## Command examples

### Initialize workspace

```
init_workspace
```

### Measure impedance with PRBS

```
nidaq_prbs_measure('./sample_specs/prbs_specs.json', './blob/prbs_measurement_data.mat')
```

### Calculate internal impedance and plot the impedance spectra

```
plot_prbs_measurement('./blob/prbs_measurement_data.mat')
```
