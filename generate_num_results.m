outdir = '/home/qcri/Documents/ajay/CNN/Face/SOA/facerelight/results/in_full';
flist = dir(fullfile(outdir,'*_mask.png'));

data{1,1}='filename';
data{1,2}='l1_norm';
data{1,3}='l2_norm';
data{1,4}='ssim';

fid = fopen(fullfile(outdir,'results.csv'),'w');
fprintf(fid,'filename,l1_norm,l2_norm,ssim\n');
for k=1:length(flist)
    fprintf('processing %d\n',k);
    out_fname = fullfile(outdir,[flist(k).name(1:end-8) 'output.png']);
    gt_fname = fullfile(outdir,[flist(k).name(1:end-8) 'gt.png']);
    mask_fname = fullfile(outdir,flist(k).name);
    img_mask = im2double(imread(mask_fname));
    img_out =  im2double(imread(out_fname));
    img_gt =  im2double(imread(gt_fname));
    ssim_val = ssim(rgb2gray(img_out),rgb2gray(img_gt));
    l1_val = mean(abs(img_out(:)-img_gt(:)));
    l2_val = mean((img_out(:)-img_gt(:)).^2);
    data{k+1,1} = flist(k).name(1:end-8);
    data{k+1,2} = l1_val;
    data{k+1,3} = l2_val;
    data{k+1,4} = ssim_val;
    
    fprintf(fid,'%s,%f,%f,%f\n',flist(k).name(1:end-9),l1_val,l2_val,ssim_val);
end
fclose(fid);