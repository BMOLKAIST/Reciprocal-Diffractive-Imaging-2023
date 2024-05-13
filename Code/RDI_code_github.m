
clear; close all; clc;

%% define a sample field

pixel_num = 200;

amplitude0 = rand(pixel_num);
phase0 = rand(pixel_num);
sample_field0 = amplitude0 .* exp(1i .* phase0*2*pi);

%% define a support

pad = 2;
tri = round(pixel_num/4);

pgon = ones(pixel_num);
pgon(1:tri, pixel_num - tri + 1:pixel_num) = 0;
imagesc(pgon), axis image

pgon2 = pad_center(pgon, size(pgon)*pad);

%% sample field in the detector plane

temp = fftshift(fft2(ifftshift(sample_field0)));
temp = pad_center(temp, size(temp)*pad);
ground = temp .* pgon2;

sample_field1 = fftshift(ifft2(ifftshift(ground)));

%% reciprocal HIO algorithm

gpuDevice(1);

amp = gpuArray(abs(sample_field1));
initial = amp .* exp(1i*2*pi*rand(size(amp)));
initial = fftshift(fft2(ifftshift(initial)));

for ii = 1:1500
  
    if ii < 500
        lambda = 0.005;
    else
        lambda = 0.1;
    end
    
    if ii == 1 
        temp0 = initial;
    else
        temp0 = gpuArray(temp2);
    end
    
    til_psi = fftshift(ifft2(ifftshift(temp0)));

    amp_prime = (1- lambda)*amp + lambda*abs(til_psi);
    temp = amp_prime .* gpuArray(exp(1i .* angle(til_psi)));
    g_k_prime = fftshift(fft2(ifftshift(temp)));

    g_k = gpuArray(zeros(size(temp0)));
    g_k(pgon2 == 1) = g_k_prime(pgon2 == 1);
    g_k(pgon2 == 0) = temp0(pgon2 == 0) - 0.6*g_k_prime(pgon2 == 0);

    temp2 = g_k;

    if corr_c(temp2, temp0) > 0.999999
        break;
    end    
end

for ii = 1:100
    
    temp0 = temp2;
    temp0 = fftshift(ifft2(ifftshift(temp0)));
    temp0 = amp .* exp(1i .* angle(temp0));
    temp2 = pgon2 .* fftshift(fft2(ifftshift(temp0)));
end

imagesc(abs(temp2)), axis image
corr_c(temp2, ground)
