function run_experiment(operations, data_filepath)
% RUN_EXPERIMENT Carry out an experiment using MATLAB.
%   run_experiment(operations, data_filepath) Executes a sequence of operations specified by <operations>, and saves the workspace data to <data_filepath>.
%
%   See also run_analysis.

    arguments
        operations (:,1) cell;
        data_filepath string;
    end

    % Execute the sequence
    for i=1:length(operations)
        f = operations{i};
        fprintf("---------------- Step #%d ---------------\n", i);
        disp(f);
        f();
        % fprintf("-----------------------------------------\n");
    end

    % Save the workspace to file
    fprintf("---------------- Step #%d ---------------\n", length(operations)+1);
    fprintf("Saving data to file %s...\n", data_filepath);
    clear("operations", "f", "i");
    save(data_filepath, "-v7.3");
    fprintf("---------------- Finished! ---------------\n");
end
