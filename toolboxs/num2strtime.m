function strday = num2strtime(Year,month,day,hour)
if day >=10 & hour >= 10 & month >= 10
    strday = [num2str(Year),num2str(month),num2str(day),num2str(hour)];
        !strday = [num2str(Year),'0',num2str(month),'0',num2str(day),'0',num2str(hour)];
elseif  hour < 10 & day >=10 & month >=10
        strday = [num2str(Year),num2str(month),num2str(day),'0',num2str(hour)];
elseif  hour < 10 & day <10 & month >=10
        strday = [num2str(Year),num2str(month),'0',num2str(day),'0',num2str(hour)];
elseif  hour < 10 & day <10 & month < 10
        strday = [num2str(Year),'0',num2str(month),'0',num2str(day),'0',num2str(hour)];
elseif  hour < 10 & day >=10 & month < 10
        strday = [num2str(Year),'0',num2str(month),num2str(day),'0',num2str(hour)];
elseif  hour >= 10 & day >=10 & month < 10
        strday = [num2str(Year),'0',num2str(month),num2str(day),num2str(hour)];
elseif  hour >= 10 & day <10 & month < 10
        strday = [num2str(Year),'0',num2str(month),'0',num2str(day),num2str(hour)];
elseif  hour >= 10 & day <10 & month >= 10
        strday = [num2str(Year),num2str(month),'0',num2str(day),num2str(hour)];
end 
end