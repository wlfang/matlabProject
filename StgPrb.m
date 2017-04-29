function p=StgPrb(x)
% chi-square test of image with hidden message

% first classify the pixels based on their value
% calculate the frequency of pixel value
n=sum(hist(x,[0:255]),2);

% caluculate the frequency of pixel value 2k+1
h2i=n([3:2:255]);
% caluculate the average value of frequency of pixel value 2k and 2k+1
h2is=(h2i+n([4:2:256]))/2;
% remove the 0 data
filter=(h2is~=0);
k=sum(filter);
idx=zeros(1,k);
for i=1:127
    if filter(i)==1
        idx(sum(filter(1:i)))=i;
    end
end
% use chi-square attack
r=sum(((h2i(idx)-h2is(idx)).^2)./(h2is(idx)));
p=1-chi2cdf(r,k-1);
