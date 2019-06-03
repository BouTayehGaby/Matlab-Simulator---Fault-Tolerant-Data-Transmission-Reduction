
function DBP_Miss(sensor,feature,maxerr)
    clc
    close all
    Nsamples=100000;                               % Number of Samples
	fprintf('%d-----------------------------\n',sensor)
    arraysent=zeros(1,1);
    arrayperc=zeros(1,1);
    arrayMiss=zeros(1,1);
    arrayerror=zeros(1,1);
    for GG=1:1
        for G=sensor:sensor
           fprintf('%d-----------------------------\n',G)
           
            NumberOfUpdate=0;
            mote=num2str(G);
            data = strcat('sensor_',mote,'.txt');         % Data array
            results = fopen('results.txt','w');           % estimated data
            transmitted = fopen('Transmitted.txt','w');   % Transmitted data
            errors = fopen('errors.txt','w');             % Error between each prediction and the real value
            index = 'index.txt';
            indexes = dlmread(index,' ');
            indexes((numel(indexes)+1):100000)=0;


            x = dlmread(data,' ',[0 feature Nsamples-1 feature]);     % Table of data
            reported=0;                                   % Count the number of reported values
            m = 6;                                        % Learning window
            rer = 5;                                      % Relative error = 5%  
            abser = 0.1;                                  % absolute error
            terr = 2;                                     % time units
            l=3;
            countTerr=0;
            edge1=[0,0,0];
            edge2=[0,0,0];
            mean1=0;
            mean2=0;
            slop=0;
            euc=0;
            errc=0;
            i=1;
            k=1;
            attemptSend=0;
            Miss=0;
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

                if indexes(k) == i
                    k=k+m;
                    attemptSend=attemptSend+m;
                    R = binornd(1,0.5); %0.5=50%

                    if R=1 %Miss
                        Miss=Miss+m;
                        euc = euc + power((abs(x(i)-xnew)),2);
                        errc = errc+1;
                        fprintf(transmitted,'%s\n',nan);
                        fprintf(results,'%d\n',xnew);
                        xold=xnew;

                    else
                        NumberOfUpdate=NumberOfUpdate+1;
                        if Nsamples-i< m
                            for j=i:Nsamples
                                reported=reported+1;
                                fprintf(results,'%d\n',x(j));
                                fprintf(transmitted,'%d\n',x(j));
                                i=i+1;
                            end
                        else
                            edge1=[x(i),x(i+1),x(i+2)];
                            edge2=[x((i+m)-2),x((i+m)-1),x(i+m)];

                            for j=i:i+m-1
                                fprintf(results,'%d\n',x(j));
                                fprintf(transmitted,'%d\n',x(j));
                            end

                            mean1=mean(edge1);
                            mean2=mean(edge2);
                            slop=(mean2-mean1)/m;;
                            xold=mean2;
                            reported=reported+m;
                            i=i+m-1;
                        end
                    end 
                else
                    euc = euc + power((abs(x(i)-xnew)),2);
                    errc = errc+1;
                    fprintf(transmitted,'%s\n',nan);
                    fprintf(results,'%d\n',xnew);
                    xold=xnew;
                end


            i=i+1;
            end
            disp('end');
%            printf('number of transmitted data %d\n',reported);
%            fprintf('percentage of transmited data: %f\n',(reported*100)/Nsamples);
%            fprintf('Average error: %f/n',euc/errc);
%            fprintf('Attempt to Send : %d\n',attemptSend);
%            fprintf('Miss : %d\n',Miss)
%            fprintf('Number of updates : %d\n',NumberOfUpdate); 
        end
        arraysent(GG)=reported;
        arrayperc(GG)=q/Nsamples;
        arrayMiss(GG)=Miss;
        arrayerror(GG)=sqrt(euc/errc);
    end

    results='results.txt';
    x1=dlmread(results,' ',[0 0 Nsamples-1 0]);

    rr=0;
    for i=1:Nsamples
        if abs(x(i)-x1(i))>maxerr
            rr=rr+1;
            euc = euc + power(x(i)-x1(i),2);
            errc = errc+1;
        end
    end
	fprintf('%d-----------------------------\n',G)
    fprintf('%f\n',mean(arraysent));
    fprintf('%f\n',mean(arrayperc));
    fprintf('%f\n',mean(arrayMiss));
    fprintf('%f\n',sqrt(euc/errc));
    fprintf('%f\n',rr);
    fprintf('--\n'); 
    fprintf('--\n');
    fclose('all');
    
end
