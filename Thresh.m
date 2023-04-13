function y=Thresh(x,t,type)
    
    if strcmp(type,'hard')    

        y = x .* (abs(x) > t);

    elseif strcmp(type,'soft') 
    
        res = (abs(x) - t);
        res = (res + abs(res))/2;
          y = sign(x).*res;

    end