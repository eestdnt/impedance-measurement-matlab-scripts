function run_analysis(data_filepath, operations)
% RUN_ANALYSIS Process the experiment data.
%   run_analysis(data_filepath, operations) loads experiment data from <data_filepath> into MATLAB workspace and executes a sequence of operations specified by <operations>.
%
%   See also run_experiment.

    arguments
        data_filepath string;
        operations (:,1) cell;
    end

    % Load experiment data
    fprintf("---------------- Step #1 ---------------\n");
    fprintf("Loading data from file %s...\n", data_filepath);
    load(data_filepath);

    % Execute the sequence
    for i=1:length(operations)
        f = operations{i};
        fprintf("---------------- Step #%d ---------------\n", i+1);
        disp(f);
        f();
    end
    fprintf("---------------- Finished! ---------------\n");
end
