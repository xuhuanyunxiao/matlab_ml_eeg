%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File:LzCm.m
% Function:This function gets the Lempel-Ziv complexity measure of a time series.
% Author:Feiyan Fan          
% Time: 2005
%
%  Usage:
%         >>  LzCm(datavector);
%  Inputs:
%  datavector = a time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[lzc]=LzCm(y)
%first translate the time series y to a 0-1 sequencesylen=length(y);
ylen=length(y);
yav=median(y); 
%yav=mean(y);
for i=1:ylen
  if (y(i)>yav)
    y(i)=1;
  else
    y(i)=0;
  end

end
%now get the Lempel-ziv complexity of the 0-1 series
cm=1;
i=1;
while (i<ylen)
    j=i+1;
    while (j<=ylen)
       temp1=y(i+1:j);
       k=1;
       esign=0;
       while(k<=i)
         temp2=y(k:k+j-i-1);
         if (temp2==temp1)
           k=i+1;
           j=j+1;
           esign=1;    
         else
           k=k+1;
       end
       end 
        if (j>ylen)
         i=ylen;
        end
        if (esign==0)
	      cm=cm+1;
          i=j;  
          j=ylen+1;  
       end
    end
end

%normalization
lzc=cm/(ylen/log2(ylen));

