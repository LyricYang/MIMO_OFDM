function y=add_CP(x,Ncp)
    y = [x(:,end-Ncp+1:end) x];
end