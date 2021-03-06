%% Read files
%% function for finding visual frequent patterns
%% naive implement with heuristic searching algorithms
%% for finding bottom-up frequent itemsets
%% #######
function [] = nrdc_yves(my_dir,my_out_dir,counter_thres, diversity_counter_thres,s_idx,e_idx)
%% my_dir = './tmobile/';
%% my_out_dir = './tmobile_out/';
files = dir(my_dir);
%% counter_thres = 200;
%% diversity_counter_thres = 6;
fileIndex = find(~[files.isdir]);

for i = s_idx:e_idx
    diversity_counter = 0;
    counter = 0;
    %% randomize search
    A = i+1:length(fileIndex);
    B=A(randperm(length(A)));
    for j = 1:length(B) %% shuffle the search order
        disp(strcat(num2str(i),'-',num2str(B(j)))); %% note the B(j) not j.
        filename = strcat(my_out_dir,num2str(i),'-',num2str(B(j)),'.jpg');
        srcname = strcat(my_out_dir,num2str(i),'.jpg');
        refname = strcat(my_out_dir,num2str(B(j)),'.jpg');
        counter = counter + 1;
        %% stop if a visual itm is already frequent or has gone through enough items
        if (counter > counter_thres || diversity_counter > diversity_counter_thres)
            break;
        end
        Src_path = strcat(my_dir, files(fileIndex(i)).name);
        Ref_path = strcat(my_dir, files(fileIndex(B(j))).name);
        Src             = double(imread(Src_path)) / 255.0;
        Ref             = double(imread(Ref_path)) / 255.0;
        %% Reduce size if source image is too big
        rf = max(max(size(Src)))  / 640;
        if (rf > 1)
            disp('source image is too big. resize automatically.')
            Src = imresize(Src, 1.0/rf);
            Ref = imresize(Ref, 1.0/rf);
        end
        %% Set an empty options struct
        NRDC_Options = [];
        [DCF, ~, ~, AlignedRef] = nrdc(Src, Ref, NRDC_Options);
        %% Display the result:
        if isempty(DCF)
            disp('No matching has been found.')
        else
            % Show aligned reference:
            diversity_counter = diversity_counter + 1;
            bw_align = im2bw(AlignedRef,0.01); %% work with binary images
            bw_align1 = bwconvhull(bw_align);  %% fidn the convex hull
            %% make the AlighedRef same size as src file. Note the padding direction
            bw_align2 = padarray(bw_align1,size(Src(:,:,1))-size(bw_align1),'post');
            a = repmat(bw_align2,[1,1,3]);
            masked = Src.*a; %% mask the original image and store it.
            %imshow(masked);
            imwrite(masked,filename);
            imwrite(Src,srcname);
            imwrite(Ref,refname);
        end
    end
end