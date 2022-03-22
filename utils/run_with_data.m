function run_with_data(path, func)
% RUN_WITH_DATA Run a function or script with workspace data coming from a MATLAB file specified by path.

    fprintf("Load data file at %s...\n", path);
    load(path);
    disp("Data loaded!");

    disp("Execute script...");
    func();
    disp("Script execution completed!");
end
