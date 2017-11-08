function [value]=time_res_vector(value1,time_ref,time_input)

% Author: Giovanni Martucci, 2009.
% Post-Doc Researcher (C-CAPS, ECI, NUI Galway, Galway, Ireland).
% e-mail: giovanni.martucci@nuigalway.ie

time1=time_ref;
time2=time_input;
value=zeros(1,length(time1));
ift1=1;
ift2=1;
for i=1:length(time1)
    if time1(i)>time2(ift1)
        gap=(i-ift2);
        if gap<=1
            if i==1
                value(i)=value1(ift1);
                ift1=ift1+1;
            elseif i>1
                if ift1==1
                    interv_length1=(time1(i-1)-time2(ift1))/time2(ift1);
                    if interv_length1<=0
                        value(i-1)=value1(ift1);
                        ift1=ift1+1;
                    elseif interv_length1>0
                        l=1;
                        while (time1(i-1)-time2(ift1+l))>0
                            l=l+1;
                        end
                        interv_length=(time1(i-1)-time2(ift1+l-1))./(time2(ift1+l)-time2(ift1+l-1));
                        value(i-1)=value1(ift1+l-1)+(value1(ift1+l)-value1(ift1+l-1)).*interv_length;
                        ift1=ift1+l;
                    end
                elseif ift1>1 && ift1<length(time2)
                    interv_length1=(time1(i-1)-time2(ift1-1))/(time2(ift1)-time2(ift1-1));
                    if interv_length1>1
                        l=0;
                        while (time1(i-1)-time2(ift1-1))>(time2(ift1+l)-time2(ift1-1))
                            l=l+1;
                            if ift1+l>=length(time2)
                                break
                            end
                        end
                        interv_length=(time1(i-1)-time2(ift1+l-1))./(time2(ift1+l)-time2(ift1+l-1));
                        value(i-1)=value1(ift1+l-1)+(value1(ift1+l)-value1(ift1+l-1)).*interv_length;
                        if i==length(time1)
                            value(i)=value1(end)*(time1(i)/time2(end));
                        end
                        ift1=ift1+l;
                    elseif interv_length1<=1
                        value(i-1)=value1(ift1-1)+(value1(ift1)-value1(ift1-1)).*interv_length1;
                        ift1=ift1+1;
                        if i==length(time1)
                            value(i)=value1(end)*(time1(i)/time2(end));
                        end
                    end
                elseif ift1==length(time2)
                    interv_length1=(time1(i-1)-time2(ift1-1))/(time2(ift1)-time2(ift1-1));
                    if interv_length1>1
                        value(i-1)=value1(ift1);
                    elseif interv_length1<=1
                        value(i-1)=value1(ift1-1)+(value1(ift1)-value1(ift1-1)).*interv_length1;
                    end
                    value(i)=value1(ift1)*(time1(i)/time2(ift1));
                    ift1=ift1+1;
                end
            end
        elseif gap>1
            for k=ift2:ift2+gap-1
                if ift1==1
                    value(k)=value1(ift1);
                elseif ift1>1
                    interv_length=(time1(k)-time2(ift1-1))./(time2(ift1)-time2(ift1-1));
                    value(k)=value1(ift1-1)+((value1(ift1)-value1(ift1-1)).*interv_length);
                end
            end
            ift1=ift1+1;
        end
        ift2=i;
        if ift1>length(time2)
            for k=ift2:length(time1)
                value(k)=value1(ift1-1).*(1+((time1(end)/time2(ift1-1))-1)./(length(time1)-k+1));
            end
            break
        end
    else
        value(i)=value1(ift1);
    end
end
