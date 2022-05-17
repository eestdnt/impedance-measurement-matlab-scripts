# Commands to run this experiment

```
run_experiment({@init_impedance_measurement, @aging_specs_high, @print_excitation_parameters, @nidaq_impedance_measurement, @stop_impedance_measurement}, "./blob/aging-tests/cell-1-high.mat")
run_experiment({@init_impedance_measurement, @aging_specs_low, @print_excitation_parameters, @nidaq_impedance_measurement, @stop_impedance_measurement}, "./blob/aging-tests/cell-1-low.mat")
```

# Commands to generate impedance data

```
run_analysis()