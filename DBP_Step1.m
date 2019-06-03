clc
fclose('all');
close all

Nsamples=100000;
m = 6;                                        % Learning window
rer = 5;                                      % Relative error = 5%  
abser = 1;                                    % absolute error
terr = 2;                                     % time units
l=3;
feature=6;
for GG=2:21
    sensor=GG;
    for G=sensor:sensor
        fprintf('%d-----------------------------\n',G)                            
        NumberOfUpdate=0;
        mote=num2str(G);
        data = strcat('sensor_',mote,'.txt');         % Data array
        results = fopen('results.txt','w');           % estimated data
        transmitted = fopen('Transmitted.txt','w');   % Transmitted data
        errors = fopen('errors.txt','w');             % Error between each prediction and the real value
        index = fopen('index.txt','w');

        x = dlmread(data,' ',[0 feature Nsamples-1 feature]);     % Table of data
        reported=0;                                   % Count the number of reported values
        countTerr=0;
        edge1=[0,0,0];
        edge2=[0,0,0];
        mean1=0;
        mean2=0;
        slop=0;
        euc=0;
        errc=0;
        i=1;
        while i < Nsamples+1

        if i==1
            edge1=[x(1),x(2),x(3)];
            edge2=[x(m-2),x(m-1),x(m)];
            i=i+m;
            for j=1:m
                fprintf(results,'%d\n',x(j));
                fprintf(transmitted,'%d\n',x(i));
            end
			 
            mean1=mean(edge1);
            mean2=mean(edge2);
            slop=(mean2-mean1)/m;
            xold=mean2;
            reported=reported+m;
        end
            xnew=xold+slop;
            err=abs(x(i)-xnew);
            fprintf(errors,'%d\n',err);

            if err > abser || err >(x(i)*rer/100);
                countTerr=countTerr+1;
                if countTerr>2
                    NumberOfUpdate=NumberOfUpdate+1;
                    countTerr=0;
                    if Nsamples-i< m
                        for j=i:Nsamples
                            reported=reported+1;
                            fprintf(index,'%d\n',j);
                            fprintf(results,'%d\n',x(j));
                            fprintf(transmitted,'%d\n',x(j));
                            i=i+1;
                        end
                    else
                        edge1=[x(i),x(i+1),x(i+2)];
                        edge2=[x((i+m)-2),x((i+m)-1),x(i+m)];

                        for j=i:i+m-1
                            fprintf(index,'%d\n',j);
                            fprintf(results,'%d\n',x(j));
                            fprintf(transmitted,'%d\n',x(j));
                        end

                        mean1=mean(edge1);
                        mean2=mean(edge2);
                        slop=(mean2-mean1)/m;
                        xold=mean2;
                        reported=reported+m;
                        i=i+m-1;
                    end
                else
                    euc = euc + power(abs(x(i)-xnew),2);
                    errc = errc+1;
                    fprintf(transmitted,'%s\n',nan);
                    fprintf(results,'%d\n',xnew);
                    xold=xnew;
                end
            else
                countTerr=0;
                euc = euc + power(abs(x(i)-xnew),2);
                errc = errc+1;
                fprintf(transmitted,'%s\n',nan);
                fprintf(results,'%d\n',xnew);
                xold=xnew;
            end

        i=i+1;
        end
        disp('end');
        fprintf('number of transmitted data %d\n',reported);
        fprintf('percentage of transmited data: %f\n',(reported*100)/Nsamples);
        fprintf('Average error: %f/n',euc/errc);
       
    end
	
    DBP_Miss(sensor,feature,abser);
end
disp('done');
