function time = changetime(Year,month,day,hour,timestep,tt)

for ss = 1:tt
    if Year ==2021 && month ==7 &&day==1&&hour==1
         fprintf(['20210701:',num2str(ss),'s\n']);
    end
    if Year ==2021 && month ==10 &&day==1&&hour==1
         fprintf(['20211001:',num2str(ss),'s\n']);
    end
    if Year ==2022 && month ==1 &&day==1&&hour==1
         fprintf(['20220101:',num2str(ss),'s\n']);
   end
   if Year ==2022 && month ==4 &&day==1&&hour==1
         fprintf(['20220401:',num2str(ss),'s\n']);
   end
    
    time(ss)=greg2mjulian(Year,month,day,hour, 00, 00);
    hour=hour+timestep;
    if hour>=24 
        day=day+1;
        hour=hour-24;
    end
    if day==32&&(month == 1||month == 3||month == 5||month == 7||month == 8||month == 10||month == 12)
        day=day-31;
        month=month+1;
    end         
    if day==31&& (month == 4||month == 6||month == 9||month == 11) 
        day=day-30;
        month=month+1;
    end         
    if day==30&&month==2&&mod(year-2000,4)==0
        day=day-29;
        month=month+1;
    end     
    if day==29&&month==2 
        day=day-28;
        month=month+1;
    end                 
    if  month==13;
        month=month-12;
        Year=Year+1; 
    end
end

end