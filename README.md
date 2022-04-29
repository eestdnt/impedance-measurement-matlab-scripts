# Li-ion battery cell impedance measurement

The repository contains MATLAB scripts for measuring the internal impedance of a Lithium-ion battery cell.

## Prerequisites

- MATLAB
- MATLAB packages:
    - Signal Processing Toolbox
    - DSP System Toolbox
    - Simulink
    - System Identification Toolbox

## Usage

- Open MATLAB and cd to the top directory of this repository
- Run `init_workspace`
- Check that all devices in the measurement setup is ready
- Run the measurement script by typing in MATLAB command window the script name found in measurement/ subdirectory. See examples below.
- Run the analysis script to plot the calculated impedance from raw measurement data by typing in MATLAB command window the script name found in analysis/ subdirectory. See examples below.

## Command examples

### Initialize workspace

```
init_workspace
```

### Measure Li-ion cell impedance with PRBS

```
run_experiment({@prbs_specs, @nidaq_prbs_impedance_measurement}, "./blob/prbs-test.mat")
```

### Measure Li-ion cell impedance using scripts for an experiment

```
run_experiment({@init_impedance_measurement, @aging_specs_high, @print_excitation_parameters, @nidaq_impedance_measurement, @stop_impedance_measurement}, "./blob/aging-tests/cell-1-high.mat")
run_experiment({@init_impedance_measurement, @aging_specs_low, @print_excitation_parameters, @nidaq_impedance_measurement, @stop_impedance_measurement}, "./blob/aging-tests/cell-1-low.mat")
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
