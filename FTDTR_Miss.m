clc
close all
fclose('all');
%%%%%%%%%%%%%%%%%% Choose Nsamples acoording to witch Mote you want to use#######
Nsamples=100000;
feature=3;
if feature==3 || feature==4
    maxerr=0.1;
elseif feature==6
    maxerr=1;
end

trh=1;
MissMatrix=fopen('MissMatrix.txt','w');
 
for G=2:21
    mote=num2str(G);
    filename = strcat('sensor_',mote,'.txt');                        % Data array
    transmit=0;
    i=1;
    %##############################################
    %all data
    results = zeros(1,Nsamples);
    %Transmitted data
    transmitted = zeros(1,Nsamples);
    %errors between real data and estimated ones
    errors = zeros(1,Nsamples);

    x = dlmread(filename,' ',[0 feature Nsamples feature]);
    %##############################Algorithm############################################
    res=x(i+1)-x(i);                        % Res is the average value to add on the previous measurements
    oldres=res;
    xold=x(i+1);                            % The most recent sensed/estimated value.
    xn=x(i+1);                              % Last transmitted value for adaptation

    % At first Transmit the two first readings.
    results(1)=x(i);
    results(2)=x(i+1);
    transmitted(1)=x(i);
    transmitted(2)=x(i+1);
    errors(1)=0;
    errors(2)=0;
    
    i=3;
    alphaarray=zeros(1,Nsamples);
    alpha=1;  
    alphaarray(1)=alpha;
    alphaarray(2)=alpha;
    % Slope resitification value
    transmit=transmit+2;
    bool=0;
     while i <= Nsamples
        xnew=xold+res*alpha;
        err=abs(x(i)-xnew);                           % Sens the value of x(i+1) to check if inside error range
        errors(i)=err;

        if err > maxerr
              
            R = binornd(1,0.5); %0.1=10%

            if R==1
                trh=trh+1; % count how many time a data have been estimated before the next transmittion
                transmitted(i)=nan;
                results(i)=nan;
                xold=xnew;
                i=i+1;
                continue;
            end
        
            transmit=transmit+1;
            transmitted(i)=x(i);
            results(i)=x(i);

            res = (x(i)-xn)/trh;                        % The new average is the difference between the current measurement and the last transmitted "adaptation value"
            if trh==1
                AF = (xnew-x(i));
            else
                AF = (xnew-x(i))/(trh-1);
            end

            if abs(AF)<maxerr && AF<maxerr && abs(AF)>10^(-4)
                bool=1;
            else
                bool=0;
                alpha=0.5;
            end

            if  bool==1
                P=AF*100/maxerr;
                alpha=alpha-(P*alpha/100);
                if alpha>1
                    alpha=1;
                end
            end

            xn=x(i);                                  % Set the last recieved "adaptaion" value to the currently
            trh=1;                                    % Start counting how many values are estimated before a re-adjustment is needed.
            xold=x(i);                                % xold will be used to calculate the value of x(i+2)
        else
            trh=trh+1; % count how many time a data have been estimated before the next transmittion
            transmitted(i)=nan;
            results(i)=xnew;
            xold=xnew;
        end
        i=i+1;
        alphaarray(i)=alpha;
     end

    %Count how many values exceeds emax
    count=0;
    for i=1:Nsamples
    value=abs(x(i)-results(i));
    if value>maxerr || isnan(value)
        count=count+1;
    end
    end
    fprintf('%d\n',count);

    for i=1:Nsamples
    fprintf(MissMatrix,'%d ',results(i));
    end
    fprintf(MissMatrix,'\n');

end
 
%  figure;
%  plot(x,'r','linewidth',2); hold on;
%  plot(results,'b','linewidth',2); hold on;

    
 