function save_mat_files_as_hdf5(path)

    filepaths = strings(0);
    c = 0;

    if isfolder(path)
        [paths, ~] = obtain_filepaths_from_dir(path);
        for i=1:length(paths)
            if endsWith(paths(i), ".mat")
                c = c+1;
                filepaths(c) = paths(i);
            end
        end
    elseif isfile(path)
        filepaths(1) = path;
    end

    for filepath = filepaths
        if ~endsWith(filepath, ".mat")
            continue;
        end

        output_filepath = extractBefore(filepath, strlength(filepath)-3) + ".hdf5";
        disp("Output filepath: " + output_filepath);

        if isfile(output_filepath)
            error("Output file exists! Aborting.");
        end

        disp("Processing file " + filepath);

        mat_file_to_hdf5(filepath, output_filepath);

        disp("Finished processing file " + filepath);
    end
end
