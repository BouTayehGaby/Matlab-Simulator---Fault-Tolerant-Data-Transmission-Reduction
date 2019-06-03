clc
fclose('all');
close all
for GG=2:21
    Nsamples=100000;
    sensor=GG;
    for G=sensor:sensor
        fprintf('%d-----------------------------\n',G)
        NumberOfUpdate=0;                              % Number of Samples
        mote=num2str(G);
        filename = strcat('sensor_',mote,'.txt');
		
        %############################# Settings #########################################
        feature=6;                          % 3 = Temperature , 4= Humidity , 6=Infrared
        maxerr=1;                           % Maximum error treshold
        %#################################################################################

        x = dlmread(filename,' ',[0 feature Nsamples-1 feature]);

        %############################# Variables ##########################################
        m1=3;                               % Lenght of each filter 
        m2=2;                               % Number of subfilters
        count=0;
        count2=0;
        trh=1;
        sent=0;
        flag=0;
        euc=0;
        errc=0;
		
        %#################################### Files ########################################
         fresults = fopen('fresults.txt','w');
         Transmitted = fopen('Transmitted.txt','w');
         errorDiff = fopen('errorDiff.txt','w');
         index = fopen('index.txt','w');             % Store the index where a transmission has been done
        %###################################################################################

        %Initializing coeficient Matrix W1(n) , wd=[w11,w12,w13;w21,w22,w23];
        wd=[0,0,0;0,0,0];

        %Single filter at Level 2 joing the two filters at an upper level. 
        %wd2=[w1,w2];
        wd2=[0,0];

        %output of both level 1 filters, yd=[y11,y12];
        yd=[0,0]; % output of the two upper layer filters

        %error outputetd by both level 1 filters, ed=[e11,e12];
        ed=[0,0];

        ud=[x(6),x(5),x(4),x(3),x(2),x(1)];
        %ud=ud';
        sent=sent+6;
         fprintf(fresults,'%d\n%d\n%d\n%d\n%d\n%d\n',x(1),x(2),x(3),x(4),x(5),x(6));
         fprintf(Transmitted,'%d\n%d\n%d\n%d\n%d\n%d\n',x(1),x(2),x(3),x(4),x(5),x(6));
         fprintf(errorDiff,'%d\n%d\n%d\n%d\n%d\n%d\n',0,0,0,0,0,0);

        n=7;
        desired=ud(6);
		
		%calculating mu ; ligne 1->2
		p1=(1/3*(power(ud(3),2)))+(1/3*(power(ud(2),2)))+(1/3*(power(ud(1),2)));
		p2=(1/3*(power(ud(4),2)))+(1/3*(power(ud(5),2)))+(1/3*(power(ud(6),2)));
		if p1>p2
		  mu1=0+rand(1,1)*((2/p1)-0);
		else
		  mu1=0+rand(1,1)*((2/p2)-0);
		end

        while n < Nsamples+1 

            %ligne 3,4,5 in the Algo
            for i=1:m2
                yd(i)=0;
                for j=1:m1
                    yd(i)= yd(i)+(wd(i,j)*ud(7-(i-1)*m1-j));
                end
            end 

            %ligne 6,7,8 in Algo
            for i=1:m2
                ed(i)=desired-yd(i);
            end

            %ligne 9->13 in Algo
            for i=1:m2
                for j=1:m1
                wd(i,j)=wd(i,j)+(mu1*ed(i)*ud(7-(i-1)*m1-j));
                end
            end

            y=0;
            for i=1:m2
                y=y+(wd2(i)*yd(i));
            end

            error=desired-y;
            fprintf(errorDiff,'%d\n',error);
			
			if  yd(1)~=0 && yd(2)~=0
				p3=(1/2*(power(yd(1),2)))+(1/2*(power(yd(2),2)));
				mu2=0+rand(1,1)*((2/p3)-0);
			end

            %ligne 18 to ligne 20
            for i=1:m2
                wd2(i)=wd2(i)+(mu2*error*yd(i));
            end

            TheRealError=abs(x(n)-y);
			
            if TheRealError < maxerr

                euc=euc+abs(x(n)-y);
                errc = errc+1;

                fprintf(fresults,'%d\n',y);
                fprintf(Transmitted,'%s\n','nan');
                temp=zeros(1,6);
                temp(2:6)=ud(1:5); % shift array to the left and add the newest input to the far right box
                temp(1)=y; 
                ud=temp;
                desired=ud(1);
            else
                NumberOfUpdate=NumberOfUpdate+1;
                sent=sent+1;
                fprintf(fresults,'%d\n',x(n));
                fprintf(Transmitted,'%d\n',x(n));
                fprintf(index,'%d\n',n);
                temp=zeros(1,6);
                temp(2:6)=ud(1:5); % shift array to the left and add the newest input to the far right box
                temp(1)=x(n); 
                ud=temp;
                desired=x(n);
            end
            n=n+1;
        end

         fprintf('number of sent measurements: %d\n',mu1);
         fprintf('number of sent measurements: %d\n',sent);
         fprintf('percentage of trasmitted data:  %f\n',(100*sent)/Nsamples);
         fprintf('Average error: %f\n',(euc/errc));
         fprintf('Number of adaptation: %f\n',NumberOfUpdate);
         fprintf('%f\n',mu1);
         fprintf('%d\n',sent);
         fprintf('%f\n',(100*sent)/Nsamples);
         fprintf('%f\n',(euc/errc));



    end

    HLMSV3_Miss(sensor,feature,maxerr,mu1);
end
fprintf('done');
