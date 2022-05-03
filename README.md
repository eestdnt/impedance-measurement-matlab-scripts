# Li-ion battery cell impedance measurement

The repository contains MATLAB scripts for measuring the internal impedance of a Lithium-ion battery cell.

## Prerequisites

- MATLAB & Simulink
- MATLAB packages:
    - Signal Processing Toolbox
    - DSP System Toolbox
    - System Identification Toolbox
    - Control System Toolbox

## General workflow

- Open MATLAB and cd to the top directory of this repository.
- Run `init_workspace`
- Check that all devices in the measurement setup is ready.
- Run the measurement and analysis scripts. The script name can be given as a parameter in the `run_experiment` and `run_analysis` methods (see examples).

## Initialize workspace

```
init_workspace
```

## PRBS measurement

To measure a cell impedance with PRBS, run with
```
run_experiment({@init_impedance_measurement, @prbs_specs, @print_excitation_parameters, @nidaq_impedance_measurement, @stop_impedance_measurement}, "./files/prbs-test.mat")
```

To plot the impedance using the measured data, run
```
run_analysis("./files/prbs-test.mat", {@plot_prbs_measurement})
```

## Sinesweep measurement

To measure a cell impedance with sinesweep, run
```
run_experiment({@init_impedance_measurement, @sinesweep_specs, @print_excitation_parameters, @nidaq_impedance_measurement, @stop_impedance_measurement}, "./files/sinesweep-test.mat")
```

To plot the impedance using the measured data, run
```
run_analysis("./files/sinesweep-test.mat", {@plot_sinesweep_measurement})
```

## Overlay multiple impedance curves in a single plot using measurement data files

```
plot_measurements_from_files("./files/prbs-test.mat", "./files/sinesweep-test.mat")
```

## Measure Li-ion cell impedance using scripts for aging experiments

```
run_experiment({@init_impedance_measurement, @aging_specs_high, @print_excitation_parameters, @nidaq_impedance_measurement, @stop_impedance_measurement}, "./aging-experiments/files/cell-1-high.mat")
run_experiment({@init_impedance_measurement, @aging_specs_low, @print_excitation_parameters, @nidaq_impedance_measurement, @stop_impedance_measurement}, "./aging-experiments/files/cell-1-low.mat")
```

## Get help with the scripts

```
help run_experiment
help run_analysis
help plot_prbs_measurement
```
