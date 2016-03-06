%% This funciton takes the 3D image path and outputs a double 3D array
%% works for TIF and NII image formats

function Output = read3DImage(inputName)

extension = inputName(end-2:end);

if strcmp(extension,'tif')
    info = imfinfo(inputName);
    width= info(1).Width; height = info(1).Height; depth = numel(info);
    Output = zeros(width,height,depth);
    for i = 1:numel(info)
        Output(:,:,i) = double(imread(inputName,'Index',i));
        Output(:,:,i) = Output(:,:,i)'; % To match the NII image 
    end
    
elseif strcmp(extension,'nii')
    OutputStruct = load_nii(inputName); % load_nii returns a struct
    Output = double(OutputStruct.img);
    
else
    disp('3D Image format is neither TIF nor NII'); 
end


end