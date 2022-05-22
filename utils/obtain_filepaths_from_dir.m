function [filepaths, filenames] = obtain_filepaths_from_dir(path)
    filepaths = strings(0);
    filenames = strings(0);
    if ~isfolder(path)
        throw("Given path is not a directory!");
    end
    if endsWith(path, "/")
        path = extractBefore(path, strlength(path));
    end
    ft = ls(path);
    if class(ft) ~= "cell"
        ft = split(ft);
    end
    ft = string(ft);
    c = 0;
    for i=1:length(ft)
        p = strcat(path, strcat("/", ft{i}));
        if isfile(p)
            c = c+1;
            filepaths(c) = p;
            [~, filenames(c), ~] = fileparts(ft{i});
        end
    end
end
