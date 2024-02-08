function strday = ChangeT(Year,month,day,hour,dtt,timestep)
%dtt 是你需要一共跑的时间例如2022/04/01/00-2022/04/03/00 dtt = 3*24
%timestep是时间间隔，1=1hour
for ss = 1:dtt
    hour = hour + timestep;
    if hour>=24 
        day=day+1;hour=hour-24;
    end
    if day == 32 && (month == 1 || month == 3 || month == 5 || month == 7|| month == 8|| month == 10|| month == 12); 
        day=day-31;month=month+1;
    end         
    if day==31 && (month == 4|| month == 6|| month == 9|| month == 11) 
        day=day-30;month = month+1;
    end         
    if day==30 && month==2 && mod(Year-2000,4)== 0;
        day=day-29;
		month=month+1;
    end     
      
    if day==29 && month==2;
        if mod(Year - 2000,4)== 0;
            day = day; %updated by Zhonghao Lin 2021/1/15 
        else
            day=day-28;
            month=month+1;
        end
    end  
    
    if  month == 13 
        month = month-12;Year=Year+1; 
    end
end
  %-----------------------------------------------  
strday = num2strtime(Year,month,day,hour);
  %-----------------------------------------------
end 