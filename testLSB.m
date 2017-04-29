clear all;
% read the image
[fn,pn]=uigetfile({'*.jpg','JPEG?files(*.jpg)';'*.bmp','BMP?files(*.bmp)'},'select?file?to?hide message');
name=strcat(pn,fn);
I=imread(name);
sz=size(I);

% generate messages, hide them in image and do chi-square analysis
for k=1:4
    % generate secret message
    % rt is the coverage rate of secrete message
	rt=0+0.3*(k-1);
    row=round(sz(1)*rt);
    col=round(sz(2)*rt);
    msg = rand(1, row * col);
    msg = round(msg);
    msg = reshape(msg, row, col);
	
    % hide the message in image
    stg=I;
	stg(1:row,1:col)=bitset(stg(1:row,1:col),1,msg);
	imwrite(stg,strcat(pn,strcat(sprintf('stg_%?d_',floor(100*rt)),fn)),'bmp');
    
    % do chi-square analysis
    i=1;
	for rto=0.1:0.01:1
        row=round(sz(1)*rto);
        col=round(sz(2)*rto);
        p(k,i)=StgPrb(stg(1:row,1:col));
        i = i+1;
    end
end

% show the result
figure;
[r, c] = size(p);
x = 1: c;
plot(x,p(1,:),'-', x,p(2,:),'-', x,p(3,:),'-', x,p(4,:),'-');
legend('coverage: 0 * 0','coverage: 0.3 * 0.3', 'coverage: 0.6 * 0.6', 'coverage: 0.9 * 0.9')
