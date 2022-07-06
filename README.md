# MATLAB scripts for measuring internal impedance of power-electronic devices

## 1. Prerequisites

- MATLAB & Simulink
- MATLAB packages:
    - Signal Processing Toolbox
    - DSP System Toolbox
    - System Identification Toolbox
    - Control System Toolbox

## 2. General workflow

- Open MATLAB and cd to the top directory of this repository.
- Run `init_workspace`
- Check that all devices in the measurement setup is ready.
- Run the measurement and analysis scripts. The script name can be given as a parameter in the `run_experiment` and `run_analysis` methods (see examples).

## 3. Examples

### Initialize MATLAB workspace

```
init_workspace
```

### Measuring impedance with sinesweep

```
run_experiment({@init_batt_imp_meas, @sinesweep, @print_excitation_parameters, @nidaq_galvanostatic, @stop_batt_imp_meas, @save_frequency_response_to_csv_file}, "./files/sinesweep-test.mat")
run_analysis("./files/sinesweep-test.mat", {@plot_impedance_sinesweep_measurement})
```

### Measuring impedance with PRBS

To measure a cell impedance with PRBS, run with
```
run_experiment({@init_batt_imp_meas, @prbs_specs, @print_excitation_parameters, @nidaq_galvanostatic, @stop_batt_imp_meas}, "./files/prbs-test.mat")
run_analysis("./files/prbs-test.mat", {@plot_impedance_prbs_measurement})
```

### Overlay multiple impedance curves in a single plot using measurement raw data files

```
plot_measurements_from_files("./files/prbs-test.mat", "./files/sinesweep-test.mat")
```

### Get help

Use "help" command to get help with the scripts, or contact minh.tran@tuni.fi. For example,

```
help run_experiment
help run_analysis
help plot_impedance_prbs_measurement
```
