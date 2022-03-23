# Impedance frequency-response measurement

This repository contains MATLAB scripts for measuring the internal impedance of power-electronic converters and batteries.

## Prerequisites

- MATLAB packages:
  - MATLAB
  - Simulink
  - Data Acquisition Toolbox
  - Signal Processing Toolbox

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
run_broadband_measurement_from_file('./sample_specs/prbs_specs.json', './blob/prbs_measurement_data.mat', @plot_prbs_measurement)
```

### Calculate internal impedance and plot the impedance spectra

```
run_with_data("./blob/prbs_measurement_data.mat", @plot_prbs_measurement)
```

### Get help with the scripts

```
help run_broadband_measurement_from_file
help run_with_data
help plot_prbs_measurement
```
