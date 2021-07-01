clc; clear; close all;
 
image_folder = 'data uji';
filenames = dir(fullfile(image_folder, '*.jpg'));
total_images = numel(filenames);
 
data_uji = zeros(8,total_images);
 
for n = 1:total_images
    full_name= fullfile(image_folder, filenames(n).name);
    Img = imread(full_name);
    Img = im2double(Img);
    
    resize = [150 220];
    
    Img = imresize(Img,[resize]);
     
    % Ekstraksi Ciri Warna RGB
    R = Img(:,:,1);
    G = Img(:,:,2);
    B = Img(:,:,3);
     
    CiriR = mean2(R);
    CiriG = mean2(G);
    CiriB = mean2(B);
     
    % Ekstraksi Ciri Tekstur Filter Gabor
    I = (rgb2gray(Img));
    wavelength = 4;
    orientation = 90;
    [mag,phase] = imgaborfilt(I,wavelength,orientation);
     
    H = imhist(mag)';
    H = H/sum(H);
    I = [0:255]/255;
     
    CiriMEAN = mean2(mag);
    CiriENT = -H*log2(H+eps)';
    CiriVAR = (I-CiriMEAN).^2*H';
    
    %Ekstraksi ciri bentuk
    I = (rgb2gray(Img));
    threshold = graythresh(I);
    bw = im2bw(I, threshold);
    bw = bwareaopen(bw, 5000);
    
    se = strel('disk', 5);
    bw = imclose(bw, se);
    bw = imfill(bw, 'holes');
    [B, L]= bwboundaries(bw,'noholes');
    
    for k = 1:length(B)
        boundary = B{k};
    end
    stats = regionprops(L,'Area','Perimeter','Eccentricity');
    
    for k = 1:length(B)
        boundary = B{k};
        area = stats(k).Area;
        perimeter = stats(k).Perimeter;
        eccentricity = stats(k).Eccentricity;
        metric = 4*pi*area/perimeter^2;
    end
    
    
    
    data_uji(1,n) = CiriR;
    data_uji(2,n) = CiriG;
    data_uji(3,n) = CiriB;
    data_uji(4,n) = CiriMEAN;
    data_uji(5,n) = CiriENT;
    data_uji(6,n) = CiriVAR;
    data_uji(7,n) = eccentricity;
    data_uji(8,n) = metric;
end
 
% Pembentukan target uji
target_uji = zeros(5,total_images);
target_uji(1,1:20) = 1;
target_uji(2,21:40) = 1;
target_uji(3,41:60) = 1;
target_uji(4,61:80) = 1;
target_uji(5,81:100) = 1;

%//
load net;
hasil_uji = round(sim(net,data_uji));
 
akurasi1 = find(hasil_uji(1,1:20) == 1);
[baris1,kolom1] = size(akurasi1);
akurasi2 = find(hasil_uji(2,21:40) == 1);
[baris2,kolom2] = size(akurasi2);
akurasi3 = find(hasil_uji(3,41:60) == 1);
[baris3,kolom3] = size(akurasi3);
akurasi4 = find(hasil_uji(4,61:80) == 1);
[baris4,kolom4] = size(akurasi4);
akurasi5 = find(hasil_uji(5,81:100) == 1);
[baris5,kolom5] = size(akurasi5);
akurasi = (kolom1+kolom2+kolom3+kolom4+kolom5)/100



