clc;
clear;
close all;
morph_number = 60;
writerObj = VideoWriter('test.avi');
writerObj.FrameRate = 10;
open(writerObj);
Image_Org = imread('face2.jpg');
% Image1 = rgb2gray(Image1);
% Image1 = double(Image1);
Image_Tar = imread('face3.jpg');
% Image2 = rgb2gray(Image2);
% Image2 = double(Image2);

[Image_Org_points,Image_Tar_points] = self_click_correspondences(Image_Org,Image_Tar);
Image_Org_points = fliplr(Image_Org_points);
Image_Tar_points = fliplr(Image_Tar_points);
% Image_points = (Image1_points +Image2_points)/2;
[m1,n1,~] = size(Image_Org);
[m2,n2,~] = size(Image_Tar);
m = max(m1,m2);
n = max(n1,n2);
Image_Org_pad = imresize(Image_Org,[m,n]);
Image_Tar_pad = imresize(Image_Tar,[m,n]);


Tri_Org = delaunay(Image_Org_points);
Tri_Tar = delaunay(Image_Tar_points);
Tri_num = size(Tri_Org,1);

for frame = 1:1:morph_number
    fprintf('Processing step # %d...\n', frame);
    frac = frame/morph_number;
    Image_Mid_points = (1-frac) * Image_Org_points + frac * Image_Tar_points;       %得到当前帧的三角剖分点
    Image_mid = zeros(m,n,3); 
    for x=1:m
        for y=1:n
            for k=1:Tri_num
                Mid_pts_X= Image_Mid_points(Tri_Org(k,:),1);
                Mid_pts_Y = Image_Mid_points(Tri_Org(k,:),2);
                [IN, ON] = inpolygon(x, y, Mid_pts_X, Mid_pts_Y); 
                if (IN == 1 || ON == 1)
                    Mrx_mid = [Mid_pts_X, Mid_pts_Y, ones(3, 1)]';
                    Mrx_or = [Image_Org_points(Tri_Org(k,1),:);Image_Org_points(Tri_Org(k,2),:);Image_Org_points(Tri_Org(k,3),:)];
                    Mrx_org = [Mrx_or,ones(3,1)]';
                    Mrx_ta = [Image_Tar_points(Tri_Org(k,1),:);Image_Tar_points(Tri_Org(k,2),:);Image_Tar_points(Tri_Org(k,3),:)];
                    Mrx_tar = [Mrx_ta,ones(3,1)]';             
                    tran1 = Mrx_org * Mrx_mid^(-1);  
                    pos1 = tran1 * [x;y;1]; 
                    tran2 = Mrx_tar * Mrx_mid^(-1);  
                    pos2 = tran2 * [x;y;1]; 
                    Image_mid(x,y,:) = (1-frac)*Image_Org_pad(round(pos1(1,1)), round(pos1(2,1)), :) + frac*Image_Tar_pad(round(pos2(1,1)), round(pos2(2,1)),:);
                    break;
                end
            end
        end
    end
    a = Image_mid(:,:,1);
    b = Image_Org(:,:,1);
    c = Image_Tar(:,:,1);
%     mov(frame).cdata = Image_mid;
    
    imshow(Image_mid/256);axis image;axis off;drawnow;
    writeVideo(writerObj,getframe(gcf));
%     writeVideo(writerObj,mov(frame).cdata);
end
close(writerObj);

