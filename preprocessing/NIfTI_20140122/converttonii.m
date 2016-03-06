% converting selected reconstructions and filters to nii files. of layer 1/2

load 41cube_50hid_10ep_layer1_vis.mat % loads visual_info: a 1X3 array of cells
images = visual_info{3}; % images is an array of 100 cells obtained rom 10 images and 10 epochs
% each cell has reconstructions from 50 filters.
z = 1;

% for layer 2
% for i=0:4.5:10
%     for j = 1:4:10
%          image = images{ceil(i)*10+j};
%         for k = 1:24:50
%             nifile = image(:,:,:,k);
%             save_nii(make_nii(nifile),['layer2/layer2_', num2str(z),'.nii'])
%             z=z+1;
%         end
%     end
% end

% for layer 1
% for i=0:1:9
%     for j = 1:4:10
%          image = images{i*10+j};
%          save_nii(make_nii(image),['layer1/layer1_', num2str(z),'.nii'])
%          z=z+1;
%     end
% end


% % for filters

for i=1:10:50
         image = images(:,:,:,1,i);
         save_nii(make_nii(image),['layer1/filter1_', num2str(z),'.nii'])
         z=z+1;
end

