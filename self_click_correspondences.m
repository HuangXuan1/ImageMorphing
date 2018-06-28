function [Image1_points,Image2_points] = click_correspondences(Image1,Image2)
[nr1,nc1,~] = size(Image1);
[nr2,nc2,~] = size(Image2);
nr = max(nr1,nr2);
nc = max(nc1,nc2);
Image1_pad = imresize(Image1,[nr,nc]);
Image2_pad = imresize(Image2,[nr,nc]);
disp('Please do not click the four corner points, this fuction will choose them automatically.');
[Image2_points,Image1_points] = cpselect(Image2_pad,Image1_pad,'Wait',true);
Image1_points = [Image1_points; 1,1; 1,nr; nc,nr; nc,1];
Image2_points = [Image2_points; 1,1; 1,nr; nc,nr; nc,1];
end

