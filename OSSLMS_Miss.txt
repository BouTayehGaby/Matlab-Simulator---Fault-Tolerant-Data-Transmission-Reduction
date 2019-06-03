function OSSLMS_Miss(sensor,feature,maxerr)
    fprintf('%d-----------------------------\n',sensor)
    close all;
    fclose('all');
    arraysent=zeros(1,1);
    arrayperc=zeros(1,1);
    arrayMiss=zeros(1,1);
    Nsamples=100000;

    for GG=1:21
        p=1;
		attemptSend=0;
		Miss=0;
		euc=0;
		errc=0;
		transmit=0;
		mote=num2str(sensor);
		filename = strcat('sensor_',mote,'.txt');
		results = fopen('results.txt','w');
	    transmitted = fopen('Transmitted.txt','w');
	    errors = fopen('errors.txt','w');
		
		index = 'index.txt';             % File containig the indexes where a transmission must be done.
		indexes = dlmread(index,' ');
		indexes((numel(indexes)+1):100000)=0;

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
			prediction=W'*x;

			if indexes(p) ~= i %if no transmission here
				d=x(1,1);

				for k=N:-1:2
					x(k,1)=x(k-1,1);
				end
				x(1,1)=prediction;
				
				%###################Updating W##############
				t=d*x';
				t1=pinv(x*x');
				t4=x'*x;
                inter5=((((t*t1)-W')*x)/t4)*x;

				for j=1:N
					W(j,1)=W(j,1)+inter5(j,1);
				end 

                fprintf(transmitted,'%s\n',nan);
				fprintf(results,'%d\n',prediction);
				%################end updating W#################
			else
				p=p+1;
				% count how many attempt to send a reading has been tried.
				attemptSend=attemptSend+1;

				R = binornd(1,0.5); %0.1=10%
				if R=1 %Miss
					Miss=Miss+1;
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

					fprintf(results,'%d\n',prediction);
				else

					transmit=transmit+1;
					fprintf(results,'%d\n',data(i));
		            fprintf(transmitted,'%d\n',data(i));
		            fprintf(errors,'%d\n',0);

					for k=N:-1:2
						x(k,1)=x(k-1,1);
					end
					x(1,1)=data(i);
					d=data(i);
					%################### updating W ##############
					
					t=d*x';
					t1=pinv(x*x');
					t4=x'*x;
					inter5=((((t*t1)-W')*x)/t4)*x;

					for j=1:N
						W(j,1)=W(j,1)+inter5(j,1);
					end 
				end
			
			end

              fprintf('number of transmitted data %d\n',transmit);
              q=transmit*100;
              w=Nsamples;
              fprintf('percentage of transmited data: %f\n',q/w);

		end
            arraysent(GG)=transmit;
            arrayperc(GG)=(100*transmit)/Nsamples;
            arrayMiss(GG)=Miss;

    end
    results='results.txt';
    x1=dlmread(results,' ',[0 0 Nsamples-1 0]);

    gemax=0;
    for i=1:Nsamples
        if abs(data(i)-x1(i))>maxerr
			euc = euc + power(abs(data(i)-x1(i)),2);
			errc = errc+1; 
			gemax=gemax+1;
        end
    end

    fprintf('%f\n',mean(arrayMiss));
    fprintf('%f\n',sqrt(euc/errc));
    fprintf('%f\n',gemax);
    fprintf('--\n');
    fprintf('--\n');
    fclose('all');
end