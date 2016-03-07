% A script for data pre-processing of 3D cell imaging data
% This script takes 3D masks and saves the cropped portions of cells
% from the 3 channels into separate folders.

function preprocessCellData()
%     clear all
%     close all    

    datasetDirPath = '/Users/alex/Projects/3DDeepCellClass/data/fibroblast/nii';
    datasetDir = dir(datasetDirPath);
    datasetDirFlags = [datasetDir.isdir];
    datasetSubDirs = datasetDir(datasetDirFlags);

    % iterate through every class
    % start from 3 because for some reason the 1st 2 folders in the 
    %  array of structs are standard '.' '..' folders (no use of them).
    for cellClass = 3:length(datasetSubDirs)
        cellClassName = datasetSubDirs([cellClass]).name;
        disp(['Class:', cellClassName])
        cellClassDir = dir([datasetDirPath, '/', cellClassName]);
        cellClassDirFlags = [cellClassDir.isdir];
        cellClassSubDirs = cellClassDir(cellClassDirFlags);
        for run = 3:length(cellClassSubDirs)
            runNum = cellClassSubDirs([run]).name;
            disp(['Run:', runNum])
            preprocessRun([datasetDirPath, '/', cellClassName, '/', runNum]);
        end
    end
end

function preprocessRun(path)

% use to process one run (comment preprocessCellData above)
% function preprocessCellData()
%     path = '/Users/alex/Projects/3DDeepCellClass/data/fibroblast/nii/ss/167';

    addpath(genpath(path));

    dirMask = dir([path, '/c0_masks']);
    listFile = dir([path, '/*.lst']);
    % gives cell array of mask names
    listMasks = textread(listFile.name, '%s');

    % iterate over the 3 channel directories
    for c = 0:2

        % Channel Directory
        dirC = dir([path, '/c', num2str(c)]);

        newchannelfolder = [path, '/c', num2str(c),'_masked_cropped'];
        if ~isdir(newchannelfolder)
            mkdir(newchannelfolder);
        end

        % iterating over every image within channel directory
        for i = 3:length(dirC) 
            imageName = dirC(i).name; 
            gridName = imageName(end-7:end-4);
            cImage = read3DImage(imageName);
            cmaskFlag = strfind(listMasks, gridName); 
            % iterating over all the masks relevant to that channel image
            for m = 1:length(cmaskFlag)
                if ~isempty(cmaskFlag{m})
                    currentMask = char(listMasks(m));
                    mask = read3DImage(currentMask);
                    maskNo = currentMask(end-6:end-4);
                    cimageMasked = cImage .* mask;
                    % finding the most abundant slice
                    [~,cZ] = max(sum(sum(mask)));
                    slice = mask(:, :, cZ);
                    stat = regionprops(slice, 'centroid');
                    if ~isempty(stat)
                        outputImage = zeros(250, 250, 15);

                        for x = 1: numel(stat)
                            if ~isnan(stat(x).Centroid(1))
                                if cZ > 24 || cZ < 8
                                   % If the centroid lies in the corner of the image stack ...
                                    %    pad zeros in 3rd dimension
                                    cimageMasked = padarray(cimageMasked, [0, 0, 8]);
                                    cZ = cZ + 8;
                                end
                                for depth = 1:15    
                                    croppedImage = imcrop(cimageMasked(:, :, cZ-8+depth), ...
                                    [stat(x).Centroid(1) - 125, ...
                                    stat(x).Centroid(2) - 125, 249, 249]);
                                    [ciW,ciH] = size(croppedImage);
                                    if ciW ~= 250
                                        croppedImage = padarray(croppedImage,[ceil((250-ciW)/2),0],'pre');
                                        croppedImage = padarray(croppedImage,[floor((250-ciW)/2),0],'post');
                                    end
                                    if ciH ~= 250
                                        croppedImage = padarray(croppedImage,[0,ceil((250-ciH)/2)],'pre');
                                        croppedImage = padarray(croppedImage,[0,floor((250-ciH)/2)],'post');
                                    end
                                    outputImage(:,:,depth) = croppedImage;
                                % Rect = [Xmin Ymin Width Height], Unsure why width and
                                % ... and height have to be 1 less than the desired
                                end
                                save_nii(make_nii(outputImage),[newchannelfolder, '/', ...
                                    imageName(1:end-4), '_cropped_masked_', num2str(maskNo), '.nii']);
                            end
                        end
                    end
                end
            end
        end
    end
end

