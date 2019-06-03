clc 
close all;
fclose('all');
Nsamples=100000;
maxerr=1;
feature=6;
for GG=2:21
    Nsamples=100000;
    sensor=GG;
    for G=sensor:sensor
		fprintf('%d-----------------------------\n',G)
        euc=0;
        errc=0;
        transmit=0;
        i=1;
        mote=num2str(G);
        filename = strcat('sensor_',mote,'.txt');
        results = fopen('results.txt','w');
        transmitted = fopen('Transmitted.txt','w');
        errors = fopen('errors.txt','w');
        index = fopen('index.txt','w');             % Store the index where there is a transmission
        data = dlmread(filename,' ',[0 feature Nsamples-1 feature]);

        N=5;
        W=zeros(1,N);
        W=W';
        x=[data(N),data(N-1),data(N-2),data(N-3),data(N-4)];
        x=x';

         for i=1:N
             fprintf(results,'%d\n',data(i));
             fprintf(transmitted,'%d\n',data(i));
             fprintf(errors,'%d\n',0);
         end

        for i=(N+1):Nsamples
            value=data(i);                         %read the value at time i
            prediction=W'*x;
            error=value-prediction;
            fprintf(errors,'%d\n',error);

            if abs(error) < maxerr
                d=x(1,1);

                for k=N:-1:2
                    x(k,1)=x(k-1,1);
                end
                x(1,1)=prediction;
				
                %################### Updating W ##############
                t=d*x';
                t1=pinv(x*x');
                t4=x'*x;
                inter5=((((t*t1)-W')*x)/t4)*x;
                
                for j=1:N
                    W(j,1)=W(j,1)+inter5(j,1);
                end 

                euc = euc + power(abs(value-prediction),2);
                errc = errc+1;
                fprintf(transmitted,'%s\n',nan);
                fprintf(results,'%d\n',prediction);
                
                %################ end updating W #################
            else
                fprintf(index,'%d\n',i);
                transmit=transmit+1;
                fprintf(results,'%d\n',data(i));
                fprintf(transmitted,'%d\n',data(i));
                fprintf(errors,'%d\n',0);

                for k=N:-1:2
                    x(k,1)=x(k-1,1);
                end
                x(1,1)=data(i);
                d=data(i);
                %################### Updating W ##############
                t=d*x';
                t1=pinv(x*x');
                t4=x'*x;
                inter5=((((t*t1)-W')*x)/t4)*x;

                for j=1:N
                    W(j,1)=W(j,1)+inter5(j,1);
                end 
                %################ end of updating W ################
            end
        end

         fprintf('number of transmitted data %d\n',transmit);
         fprintf('percentage of transmited data: %f\n',(transmit*100)/Nsamples);
         fprintf('Average error: %f/n',euc/errc);
    end
    OSSLMS_Miss(sensor,feature,maxerr); % Now that we now at what time stamp OSSLMS algorithm is going to tranmist (using the index file) we can now simulate data loss while transmission using this function
end
    fprintf('DONE')
