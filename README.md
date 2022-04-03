# Frequency-response measurement scripts

This repository contains MATLAB scripts for measuring the internal impedance of power-electronic converters and batteries.

## Prerequisites

- MATLAB and MATLAB packages.

## Usage

- Open MATLAB and cd to the top directory of this repository
- Run "init_workspace"
- Check that all devices in the measurement setup is ready
- Run the measurement script by typing in MATLAB command window the script name found in measurement/ subdirectory. See examples below.
- Run the analysis script to plot the calculated impedance from raw measurement data by typing in MATLAB command window the script name found in analysis/ subdirectory. See examples below.

## Command examples

### Initialize workspace

```
init_workspace
```

### Measure impedance with PRBS

```
run_experiment({@prbs_specs, @nidaq_prbs_impedance_measurement}, "./blob/prbs-test.mat")
```

### Calculate internal impedance and plot the impedance spectra

```
run_analysis("./blob/prbs-test.mat", {@plot_prbs_measurement})
```

### Get help with the scripts

```
help run_experiment
help run_analysis
help plot_prbs_measurement
```
