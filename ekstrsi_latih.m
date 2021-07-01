clc; clear; close all; warning off all;
 
image_folder = 'data latih';
filenames = dir(fullfile(image_folder, '*.jpg'));
total_images = numel(filenames);
 
data_latih = zeros(8,total_images);
 
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
    
    
    
    data_latih(1,n) = CiriR;
    data_latih(2,n) = CiriG;
    data_latih(3,n) = CiriB;
    data_latih(4,n) = CiriMEAN;
    data_latih(5,n) = CiriENT;
    data_latih(6,n) = CiriVAR;
    data_latih(7,n) = eccentricity;
    data_latih(8,n) = metric;
end


% Pembentukan target latih
target_latih = zeros(5,total_images);
target_latih(1,1:100) = 1;
target_latih(2,101:200) = 1;
target_latih(3,201:300) = 1;
target_latih(4,301:400) = 1;
target_latih(5,401:500) = 1;


net = newff(minmax(data_latih), [45,5], {'logsig','logsig','traincgp'});
init(net);
net.trainParam.epochs=1000;
net.trainParam.goal=0.001;

net = train(net, data_latih, target_latih);

save net;
hasil_latih = round(sim(net,data_latih));

 

akurasi1 = find(hasil_latih(1,1:100) == 1);
[baris1,kolom1] = size(akurasi1);

akurasi2 = find(hasil_latih(2,101:200) == 1);
[baris2,kolom2] = size(akurasi2);

akurasi3 = find(hasil_latih(3,201:300) == 1);
[baris3,kolom3] = size(akurasi3);

akurasi4 = find(hasil_latih(4,301:400) == 1);
[baris4,kolom4] = size(akurasi4);

akurasi5 = find(hasil_latih(5,401:500) == 1);
[baris5,kolom5] = size(akurasi5);

akurasi = (kolom1+kolom2+kolom3+kolom4+kolom5)/500




